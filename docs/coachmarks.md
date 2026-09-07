# Coachmark System: Architecture, Implementation & Copywriting Catalog

## Overview

The **SqaCoachmark** system delivers an interactive, visual walkthrough experience across SQA-Multitools. It guides users through the app's toolbar features and individual plugin workflows using illuminated spotlight cutouts, contextual tooltip cards, step progress indicators, and keyboard navigation.

---

## 1. Core Architecture & Components

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            SqaCoachmarkController                           │
│  Manages step state, OverlayEntry insertion/removal, next/prev/dismiss     │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           _SqaCoachmarkOverlay                              │
│  Renders semi-transparent backdrop, spotlight border, and tooltip card     │
└───────┬──────────────────────────────┬──────────────────────────────┬───────┘
        │                              │                              │
        ▼                              ▼                              ▼
┌──────────────┐             ┌──────────────────┐           ┌──────────────────┐
│  TargetRect  │             │ Target Highlight │           │   Tooltip Card   │
│  Resolution  │             │ Static Thick     │           │ Dynamic Position │
│ (GlobalKey)  │             │ Accent Border    │           │ (Top/Bottom/...) │
└──────────────┘             └──────────────────┘           └──────────────────┘
```

### Key Data Structures

1. **`SqaCoachmarkStep`** (`lib/core/models/sqa_coachmark_step.dart`)
   - `targetKey`: `GlobalKey` pointing to the target UI element.
   - `title`: Short title string for the step.
   - `description`: Detailed copywriting explaining the feature.
   - `contentAlign`: Position of the tooltip card relative to the target (`top`, `bottom`, `left`, `right`).
   - `spotlightPadding`: Optional `EdgeInsets` defining custom directional padding around the cutout. Defaults to `EdgeInsets.all(8.0)`. Allows fine-tuning cutout bounding boxes (e.g. eliminating top encroachment on adjacent header titles) without altering plugin UI layouts.
   - `beforeStepAction`: Optional `Future<void> Function(WidgetRef ref)` executed **before** spotlight calculation. Used to programmatically drive state (tab switches, view mode changes, item scrolling).

2. **`CoachmarkKeyRegistry`** (`lib/core/providers/coachmark_key_registry.dart`)
   - Riverpod provider (`keepAlive: true`) mapping string keys to `GlobalKey` instances for cross-component target resolution.

3. **`CoachmarkService`** (`lib/core/providers/coachmark_provider.dart`)
   - Manages tour completion state and preferences (`seen_toolbar_tour`, `seen_plugin_tour_<id>`).

---

## 2. Platform & Rendering Implementation Highlights

### Win32 DWM Compositor Synchronization (`dart:ffi`)

On Flutter Windows Desktop, after long asynchronous operations (e.g. multi-step tab transitions or delayed scroll animations), the Windows Desktop Window Manager (DWM) compositor may enter an idle state. Under this state, overlay repaints queued via `setState()` may fail to present visually until an external OS event (such as window unfocus/Alt-Tab) triggers `WM_PAINT`.

To guarantee immediate rendering without manual user interaction, `sqa_coachmark.dart` uses Win32 FFI calls to force synchronous window repaints. This is strictly guarded by checking if the app is actively focused to prevent inadvertently repainting a background application:

```dart
typedef _GetForegroundWindowC = IntPtr Function();
typedef _GetForegroundWindow = int Function();
typedef _InvalidateRectC = Int32 Function(IntPtr hwnd, Pointer<Void> lpRect, Int32 bErase);
typedef _InvalidateRect = int Function(int hwnd, Pointer<Void> lpRect, int bErase);
typedef _UpdateWindowC = Int32 Function(IntPtr hwnd);
typedef _UpdateWindow = int Function(int hwnd);

Future<void> _forceWindowsRepaint() async {
  if (!Platform.isWindows) return;
  try {
    // Prevent inadvertently forcing a repaint on another application
    final isFocused = await windowManager.isFocused();
    if (!isFocused) return;

    final user32 = DynamicLibrary.open('user32.dll');
    final getForegroundWindow =
        user32.lookupFunction<_GetForegroundWindowC, _GetForegroundWindow>('GetForegroundWindow');
    final invalidateRect =
        user32.lookupFunction<_InvalidateRectC, _InvalidateRect>('InvalidateRect');
    final updateWindow =
        user32.lookupFunction<_UpdateWindowC, _UpdateWindow>('UpdateWindow');
        
    final hwnd = getForegroundWindow();
    if (hwnd != 0) {
      invalidateRect(hwnd, nullptr, 0); // Invalidate client area
      updateWindow(hwnd);               // Synchronously dispatch WM_PAINT
    }
  } catch (_) {}
}
```

### Frame Confirmation, Multi-Frame Retry & Fallback Positioning

To handle dynamic UI elements (such as scrollable cards or tab views that mount during `beforeStepAction`), `_SqaCoachmarkOverlayState` executes a robust frame confirmation and retry lifecycle:

1. **Awaits `beforeStepAction` completion.**
2. **Executes a time-based retry loop (up to 1000ms)** calling `scheduleFrame()` and `addPostFrameCallback` on each iteration until `_getTargetRect(step.targetKey)` returns a valid non-null `Rect`.
3. **Applies Zero-Size Center Fallback**: If the target key is unmounted or offscreen after the timeout, `_targetRect` falls back to `Rect.fromCenter(center: Offset(width / 2, height / 3), width: 0, height: 0)`.
   - `_SpotlightPainter` recognizes `width == 0 && height == 0` and paints a full dark scrim without a floating highlight box.
   - `_CoachmarkCard` recognizes `width == 0 && height == 0` and positions the tooltip card cleanly in the center of the viewport.
   - **User impact**: The tour card is *always* visible with step details and action buttons (`Next`, `Back`, `Done`), guaranteeing the app never locks into an unclickable dimmed state.
4. **Commits `_targetRect` via `setState()`**.
5. **Executes `_forceWindowsRepaint()`** to wake the Win32 DWM compositor.
6. **Awaits `addPostFrameCallback`** to confirm the frame is presented.
7. **Animates tooltip card fade-in (`_fadeController.forward()`)**.

### Scroll Ancestor Alignment

For targets nested inside scrollable viewports (such as buttons inside cards inside `ListView.builder`), calling `Scrollable.ensureVisible()` directly on child keys surrounded by transform/stack containers can resolve to incorrect inner scroll ancestors. In complex plugins (e.g., `SecurityPayloads`), `beforeStepAction` targets the top-level list card context (`firstCardKey`) to ensure proper scroll alignment.

### Directional Spotlight Sizing & Inset Customization (`EdgeInsets spotlightPadding`)

By default, `_SpotlightPainter` applies an 8px uniform padding (`SqaTokens.spacingMedium`) around the target's bounding box. For compact widgets placed directly adjacent to titles, dividers, or headers (e.g., the workspace selector in Document Obfuscator), uniform expansion may cause the cutout to overlap neighboring text.

`SqaCoachmarkStep` supports an optional `spotlightPadding: EdgeInsets` override. `_SpotlightPainter` calculates the cutout as:

```dart
final paddedRect = Rect.fromLTRB(
  targetRect.left - spotlightPadding.left,
  targetRect.top - spotlightPadding.top,
  targetRect.right + spotlightPadding.right,
  targetRect.bottom + spotlightPadding.bottom,
);
```

This allows tour steps to configure slim, asymmetrical cutouts (such as `EdgeInsets.fromLTRB(4, 0, 4, 3)`) entirely within the coachmark configuration without requiring artificial layout adjustments or compromising plugin UI layouts.

---

## 3. Copywriting & Tour Catalog

Below is the complete copywriting reference for all coachmark tours in SQA-Multitools.

### Main Toolbar Tour

| Step # | Title | Target Key | Alignment | Copywriting Description |
| :---: | :--- | :--- | :---: | :--- |
| 1 | **Welcome to SQA-Multitools** | `_pluginBarKey` | Bottom | This bar is your command center. Every icon here is a QA tool — click any one to open it instantly. |
| 2 | **More Tools Are Hidden Here** | `_pluginBarKey` | Bottom | Scroll or drag this bar left and right to reveal all your enabled tools. You can also reorder them in Settings → Plugins. |
| 3 | **Settings & Customization** | `_settingsIconKey` | Bottom | Open Settings to change the theme, manage which plugins appear in this bar, or unlock supporter features. |
| 4 | **Drag Me Anywhere** | `_dragHandleKey` | Bottom | Grab this handle to reposition the toolbar wherever it works best for your workflow. It floats above all other windows. |
| 5 | **Close to Tray** | `_closeButtonKey` | Bottom | This hides the toolbar to the system tray without exiting. SQA-Multitools keeps running silently in the background. |

---

### Plugin Tours

#### 1. Focus Block (TODO) (`com.sqa.plugin.todo`)
| Step # | Title | Target Key | Alignment | Copywriting Description |
| :---: | :--- | :--- | :---: | :--- |
| 1 | **Your Focus for Today** | `TodoView.todayTabKey` | Bottom | Tasks are organized into time blocks aligned to your natural energy cycles — Morning, Noon, Afternoon, and Evening. Add tasks where your energy fits the work. |
| 2 | **Add Your First Task** | `TodoView.addTaskKey` | Top | Type a task and assign it a Time Block and duration. Incomplete tasks carry over automatically to the next day so nothing gets lost. |
| 3 | **Gentle Reminders on the Toolbar** | `todoIconKey` | Bottom | When a focus cycle peaks, a small dot appears on this icon in the toolbar. It's your cue to check in with your task list — without breaking your flow. |

#### 2. Timer / Countdown (`com.sqa.timer`)
| Step # | Title | Target Key | Alignment | Copywriting Description |
| :---: | :--- | :--- | :---: | :--- |
| 1 | **Four Tools in One** | `_TimerPluginView.clockTabKey` | Bottom | Switch between the Clock, a countdown Timer, Unix timestamp converter, and a manual Counter — each in its own tab. |
| 2 | **Countdown or Stopwatch** | `_TimerPluginView.timerTabKey` | Bottom | Set a duration first, then press Start for a countdown. Leave it at 0:00 and press Start to use it as a stopwatch instead. |
| 3 | **Track Anything, Manually** | `_TimerPluginView.counterTabKey` | Bottom | The Counter tab lets you tally test cases, bugs found, or any event count. Reset requires confirmation so you never lose your tally. |

#### 3. Swagger Explorer (`com.sqa.swagger_explorer`)
| Step # | Title | Target Key | Alignment | Copywriting Description |
| :---: | :--- | :--- | :---: | :--- |
| 1 | **Discover APIs** | `SwaggerListView.swaggerUrlKey` | Bottom | Paste a URL to an openapi.json file (or load a local file) to natively render and explore any OpenAPI specification without leaving the app. |
| 2 | **Bridge with cURL Requester** | `SwaggerDetailView.swaggerEndpointsKey` | Left | Click the "Send to cURL" button on any endpoint to instantly transfer it to the cURL Requester. Path parameters, query strings, and schemas are pre-filled automatically. |

#### 4. Text Editor (`com.sqa.text_editor`)
| Step # | Title | Target Key | Alignment | Copywriting Description |
| :---: | :--- | :--- | :---: | :--- |
| 1 | **Your Documents** | `TextListView.listKey` | Top | All your saved notes and reports live here. Tap any document to open it. Pin important ones to keep them at the top. |
| 2 | **Start from a Template** | `TextListView.newDocKey` | Top | Create a blank note, a structured Bug Report, or a Dev Ticket — pre-filled with the right sections so you never have to format from scratch. |
| 3 | **Write Like a Pro** | `TextEditorView.editorKey` | Top | This is a live Markdown editor — bold, tables, code blocks, and links are styled as you type. Your work is auto-saved and exports to a clean .md file. |

#### 5. Security Payloads (`com.sqa.security_payloads`)
| Step # | Title | Target Key | Alignment | Copywriting Description |
| :---: | :--- | :--- | :---: | :--- |
| 1 | **Reference Tabs** | `SecurityPayloadsView.tabBarKey` | Bottom | Start with the Risk Legend, then explore Web or System Vulnerabilities, and review the Ethical guidelines. |
| 2 | **Expand for Full Context** | `SecurityPayloadsView.firstCardKey` | Top | Each payload comes with a vulnerability primer, what the payload does, how to test it, and what a successful exploit looks like. Expand the card to read it. |
| 3 | **Copy & Paste into Your Target** | `SecurityPayloadsView.copyButtonKey` | Top | Hit Copy to grab the payload string. Paste it directly into the field you're testing — no reformatting needed. |

#### 6. Screen Recorder (`com.sqa.screen_recorder`)
| Step # | Title | Target Key | Alignment | Copywriting Description |
| :---: | :--- | :--- | :---: | :--- |
| 1 | **Choose What to Record** | `ScreenRecorderView.captureModeKey` | Top | Pick Full Screen to capture everything, or Area to draw a region on your screen. Your last setting is remembered. |
| 2 | **Hit Record** | `ScreenRecorderView.recordButtonKey` | Top | Press this to start. A floating control bar will appear on your screen so you can pause or stop without switching back to this window. |
| 3 | **Your Recordings Are Saved Here** | `ScreenRecorderView.historyKey` | Top | Find every capture here. Tap the ⋮ menu on any recording to open, rename, or delete it. |

#### 7. Requirement Obfuscator (`com.sqa.requirement_obfuscator`)
| Step # | Title | Target Key | Alignment | Copywriting Description |
| :---: | :--- | :--- | :---: | :--- |
| 1 | **Organize by Project** | `ObfuscatorListView.workspaceSelectorKey` | Bottom | Each workspace is an isolated project with its own dictionary. Create separate workspaces for different clients or products to keep substitutions clean. |
| 2 | **Paste Your Requirements Here** | `ObfuscatorDocumentView.editorKey` | Top | Paste your spec or bug report, then toggle the Obfuscate switch. The scanner automatically finds sensitive terms and replaces them with realistic-looking alternatives. |
| 3 | **Review & Manage Substitutions** | `ObfuscatorListView.dictionaryPanelKey` | Top | Every detected term appears here with its replacement. You can enable, disable, or delete individual entries — or highlight any word in the document to add it manually. |

#### 8. Screenshot Tool (`com.sqa.screenshot`)
| Step # | Title | Target Key | Alignment | Copywriting Description |
| :---: | :--- | :--- | :---: | :--- |
| 1 | **Three Ways to Capture** | `ScreenshotView.captureModeKey` | Top | Full Screen grabs the whole monitor. Area lets you draw a selection. Long Screenshot scrolls and stitches a tall page into one image. |
| 2 | **Mark It Up Instantly** | `ScreenshotView.captureButtonKey` | Top | After capturing, a floating toolbar appears with drawing tools. Draw arrows, boxes, or text directly on the screenshot before saving. |
| 3 | **All Captures Are Here** | `ScreenshotView.historyKey` | Top | Every screenshot is listed below. Use the ⋮ menu to open, rename, or delete any capture. |

#### 9. cURL Requester (`com.sqa.curl_requester`)
| Step # | Title | Target Key | Alignment | Copywriting Description |
| :---: | :--- | :--- | :---: | :--- |
| 1 | **The Command Deck** | `CurlRequesterView.urlInputKey` | Bottom | Paste any raw cURL command here and watch it instantly parse into a structured request. Or build it visually and see the cURL update in real-time. |
| 2 | **Structured Editing** | `CurlRequesterView.requestTabsKey` | Top | Switch to the Grid view to safely edit headers, query parameters, and auth tokens without breaking command syntax. Supports variables like {{TOKEN}}. |
| 3 | **History & Saved Requests** | `CurlRequesterView.mainTabsKey` | Bottom | Every request is saved automatically. Access your past transactions, replay them, or save frequent ones for quick access. |

#### 10. Data Generator (`com.sqa.data_generator`)
| Step # | Title | Target Key | Alignment | Copywriting Description |
| :---: | :--- | :--- | :---: | :--- |
| 1 | **All Your Test Data, Organized** | `_DataGeneratorView.tabBarKey` | Bottom | Generate names, emails, lorem text, special characters, UUIDs, JSON, and dates — all from these four categories. |
| 2 | **One Click to Generate** | `_DataGeneratorView.generateButtonKey` | Bottom | Press this to instantly generate a fresh batch. Hit it again for a new result — each click is completely randomized. |
| 3 | **Change Language & Volume** | `_DataGeneratorView.settingsButtonKey` | Bottom | Tap the gear to switch locale (55 languages supported!) or adjust how many items to generate at once. |

#### 11. QA Cheatsheet (`com.sqa.plugin.qa_cheatsheet`)
| Step # | Title | Target Key | Alignment | Copywriting Description |
| :---: | :--- | :--- | :---: | :--- |
| 1 | **Categorized Knowledge** | `QaCheatsheetView.categoryTabsKey` | Bottom | Navigate between broad testing domains — Web, Mobile, API, and Security. Each domain contains curated checklists, heuristics, and attack vectors. |
| 2 | **Switch Topics Quickly** | `QaCheatsheetView.sectionSwitcherKey` | Top | Use these tabs to dive into specific topics within a domain. The content features syntax-highlighted code blocks, tables, and copy buttons for immediate use. |

#### 12. QA Oracle (Magic 8-Ball) (`com.sqa.magic8ball`)
| Step # | Title | Target Key | Alignment | Copywriting Description |
| :---: | :--- | :--- | :---: | :--- |
| 1 | **The QA Oracle** | `magic8BallFocusKey` | Bottom | Tap the magic 8-ball (or shake your device if supported) to get a randomized, sarcastic, but brutally honest answer to your pressing QA questions. |
| 2 | **Share the Wisdom** | `magic8BallFortuneKey` | Bottom | Tap the text answer to instantly copy it to your clipboard. Perfect for pasting into Slack when a developer asks "Is this a bug or a feature?" |

#### 13. Code Beautifier (`com.sqa.beautifier`)
| Step # | Title | Target Key | Alignment | Copywriting Description |
| :---: | :--- | :--- | :---: | :--- |
| 1 | **Pick Your Language First** | `BeautifierView.languageSelectorKey` | Bottom | Select the language (JSON, SQL, XML, YAML, Dart, JS, CSS, HTML) before pasting your code. This determines which formatting engine is used. |
| 2 | **Paste Your Messy Code Here** | `BeautifierView.inputFieldKey` | Top | Paste any raw or minified code into this field. Press Format (or enable Auto-Format) and the beautified result instantly appears. |
| 3 | **Format and Copy** | `BeautifierView.formatButtonKey` | Bottom | Press this button to format the code. The output will pop up in a new window where you can easily copy it with syntax highlighting applied. |
