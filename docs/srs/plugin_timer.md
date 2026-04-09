# SRS: Timer & Stopwatch (plugin_timer)

## 1. Introduction
### Purpose
Describe the functional and non-functional requirements for the Timer/Stopwatch utility in SQA-Multitools.

### Scope
The tool is called **Timer & Clock**. It provides real-time clock synchronization (Local/UTC), interval tracking (Stopwatch), and Unix timestamp utilities.

### Definitions & Abbreviations
- **TBD:** To Be Defined.

### References
- [Core Architecture SRS](file:///e:/Github/sqa-tools/docs/srs/00_core.md)

## 2. Overall Description
### Product Perspective
This is a modular plugin for SQA-Multitools, utilizing the standard `SqaPlugin` interface.

### Product Functions
- **Real-time Clock:** Displays Local and UTC synchronized time.
- **Stopwatch:** Count-up time tracking for testing intervals.
- **Unix Timestamp:** Quick access to the current Unix Epoch time.
- **Simple Counter:** Manual tracking for test cases or events.

### User Classes & Characteristics
- **Standard User:** QA Engineers and Developers.

### Operating Environment
- **Platform:** Windows Desktop.

### Design & Implementation Constraints
- **Framework:** Flutter.
- **Icon:** `Symbols.timer`.

## 3. System Features (Functional Requirements)
### Clock Synchronization
- **Description:** Real-time display of the current system time in both Local and UTC+0 formats.
- **Processing:** Updates once per second via `Timer.periodic`.
- **Outputs:** HH:mm:ss formatted strings.

### Track Time (Smart Timer)
- **Description**: Dual-purpose mode that switches between Countdown and Stopwatch.
- **Inputs**: User clicks Start/Stop/Pause/Reset buttons.
- **Smart Logic**: If the initial duration is 0, it operates as a Stopwatch (counts up). If a duration is set via the interactive segments, it operates as a high-precision Countdown (counts down).
- **Processing**: `dart:async`'s `Timer` logic with millisecond precision.
- **Outputs**: HH:mm:ss.SSS formatted display.

### Unix Utilities
- **Description**: Real-time display and conversion of Unix timestamps (Epoch).
- **Processing**: Updates once per second via `UnixNotifier` during "Live" mode.
- **Direct Entry**: Users can directly type into the Unix Timestamp field to trigger a reverse conversion to human-readable segments.
- **Conversion**: Bi-directional synchronization between human-readable Date/Time segments and Unix 10-digit integers.
- **Outputs**: 10-digit integer representation in `SqaField` and YYYY/MM/DD HH:mm:ss segments.

### Simple Counter
- **Description**: Manual event tracking for QA sessions.
- **Inputs**: User clicks Add (+), Reduce (-), or Reset.
- **Processing**: Standard integer increment/decrement logic.
- **Conditional Layout**: Reset button only appears when counter value is non-zero.
- **Outputs**: Large format integer display (`displaySmall`).

## 4. External Interface Requirements
### User Interface (UI)
- **Style:** Standard SQA Unified Design System.
- **Navigation**: Use `SqaTabBar` for Clock, Timer, and Unix sections.
- **Time Display**: Use `InteractiveTimeSegment` (Timer) and `InteractiveDateSegment` (Unix) for granular adjustments.
- **Millisecond Precision**: Timer display includes a **3-digit millisecond (.SSS)** counter.
- **Unix Tool**: Use `SqaField` for editable and copyable timestamp values.
- **Counter Tool**: Use a horizontal Row for `[-]` `0` `[+]` aligned centered.
- **Layout**: Use `SqaPluginScrollableContent` to ensure all tabs (Clock, Timer, Unix, Counter) are vertically centered when the window is expanded.
- **Actions**: Smart toggle buttons for "Start/Pause" and "Reset" using `SqaButton`.

### Hardware Interfaces
- **Not implemented**.

### Software Interfaces
- **Not implemented**.

### Communication Interfaces
- **Not implemented**.

## 5. Non-Functional Requirements (Quality Attributes)
### Performance
- Accuracy: +/- 10ms.

### Safety & Security
- **Not implemented**.

### Reliability
- Time consistency: High.

### Maintainability
- Isolated plugin structure.
