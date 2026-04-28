# SRS: Todo List (plugin_todo)

## 1. Introduction
### Purpose
Describe the functional and non-functional requirements for the Todo List utility in SQA-Multitools, focusing on cognitive energy management and Ultradian rhythms.

### Scope
The tool is called **Todo List**. It provides task management anchored to 90-minute cognitive energy cycles, utilizing Time Blocks instead of static deadlines.

### Definitions & Abbreviations
- **Ultradian Rhythm:** Recurrent periods or cycles repeated throughout a 24-hour day (90-minute focus cycles).
- **Time Block:** A period of the day categorized by expected cognitive energy levels.
- **Wake Anchor:** The user-defined start time of their day used to align 90-minute cycles.

## 2. Overall Description
### Product Perspective
Modular plugin for SQA-Multitools utilizing the `SqaPlugin` interface.

### Product Functions
- **Task Management:** Create, Read, Update, Delete tasks with specialized fields.
- **Cognitive Time Blocking:** Assign tasks to energy-appropriate periods (Morning, Noon, etc.).
- **Ultradian Notifications:** Subtle toolbar reminders triggered at focus cycle peaks.
- **Auto-Carryover:** Incomplete tasks persist to the next day automatically.
- **History Tracking:** Review completed and past tasks grouped by date.
- **Monthly Rolling Storage:** Automatic data management and pruning.

## 3. System Features
### Task Definition
- **Fields:** Title, Time Block, Duration Preset, Priority, Status, Category, Notes, CreatedAt.
- **Duration Presets:** 5, 15, 25, 45, 90 mins (constrained by Time Block).

### Cognitive Scheduling
- **Logic:** Users select a Time Block (e.g., Afternoon).
- **Constraints:**
  - Current Block: 5, 15, 25 min
  - Morning: 25, 45, 90 min
  - Noon: 5, 15, 25 min
  - Afternoon: 25, 45 min
  - Evening: 5, 15, 25 min
  - Tonight: 5, 15 min

### Smart Reminders
- **Trigger:** Calculated from Wake Anchor in 90-minute increments.
- **Output:** Unobtrusive badge on the main toolbar.
- **Optional Feature:** Auto-open Todo view on trigger (with "Back" button to previous plugin).

### Data Retention
- **Mechanism:** Monthly JSON files.
- **Pruning:** Deletes files older than the user-defined retention period (e.g., 30 days).

## 4. User Interface (UI)
- **Style:** Standard SQA Unified Design System.
- **Tabs:** "Today" and "History".
- **Interaction:** `SqaModal` for editing, `SqaCard` for list items.
- **Destructive Actions:** Confirmation via `SqaModal.showDanger` for all task deletions.
- **Navigation:** Reuses `NavigationService` for `goBack()` functionality.

## 5. Non-Functional Requirements
- **Reliability:** Data must persist across app restarts.
- **Performance:** UI remains responsive even with large task lists.
- **Maintainability:** Strict adherence to `GEMINI.md` architectural rules.
