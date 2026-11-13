# Project Specification: Open-Source 24h Radial Day Planner & Local Calendar

## 1. Core Concept & Role
You are an expert Flutter and Dart developer. Build a privacy-first, 100% offline, open-source 24-hour radial day planner and calendar app (similar to Dialed / Sectograph). Zero telemetry, zero cloud sync, zero external network requests. All user data must remain strictly in local device storage.

## 2. Tech Stack & Environment
- **Framework**: Flutter (latest stable via FVM) & Dart.
- **Target Platforms**: iOS (compiled unsigned via GitHub Actions for SideStore sideloading) and Android/Desktop for local testing.
- **Local Storage**: Use `hive_ce` or `sqflite` / `drift` (prefer lightweight, fast local storage with zero native build issues on iOS).
- **State Management**: Clean, modular state management (`Riverpod` or `Provider` + `ChangeNotifier`).
- **UI Constraint**: Wrap the main viewport in a responsive mobile container (`maxWidth: 430`) when running on wide desktop/web screens so the radial dial never stretches awkwardly.

## 3. Core Functional Requirements

### A. 24-Hour Radial Clock Interface (`CustomPainter`)
- **Dial Geometry**: A 24-hour circular ring where `00:00` is at the top (`-pi / 2`), `06:00` is right, `12:00` is bottom, and `18:00` is left.
- **Time Blocks**: Render scheduled events as colored arcs along the ring proportional to their `startMinute` (0–1439) and `durationMinutes`.
- **Current Time Indicator**: A distinct needle/dot showing the current real-time hour and minute (only visible when viewing today's date).
- **Labels & Readability**: Display hour markers (`00h`, `03h`, `06h`, etc.) and cleanly render event titles/icons either inside arcs or via clean callouts without overlapping.

### B. Interactive Touch & Gestures
- **Tap on Empty Ring Segment**: Opens a quick-create bottom sheet pre-filled with the tapped hour/minute (snapped to 15-minute intervals).
- **Tap on Existing Event Block**: Opens an edit/delete modal for that event.
- **Drag / Resize Handles (Optional/Phase 2)**: Allow dragging the start or end edges of an arc to adjust time/duration using `atan2` polar coordinate math, with subtle haptic feedback (`HapticFeedback.selectionClick()`).

### C. Calendar Navigation & Future Scheduling
- **Date Navigation**: Top horizontal week-strip calendar + date picker button allowing the user to navigate to past days and schedule events into future dates ("days yet to come").
- **Today Shortcut**: A quick "Today" button to jump back to the current date.

### D. Repeating Events (Recurrence Engine)
- **Recurrence Rules**: Support creating events that repeat:
  - `None` (one-time event on a specific `YYYY-MM-DD`)
  - `Daily` (every day)
  - `Weekdays` (Monday to Friday)
  - `Weekly` (specific days of the week, e.g., `[1, 3, 5]` for Mon/Wed/Fri)
  - `Monthly` (same day of the month)
- **Exception Handling**: When editing or deleting a repeating event, prompt the user: *"This event only"* or *"All future events"*, storing exceptions cleanly in the local database.

## 4. Data Model Architecture
Design a clean `TimeEvent` model:
- `id`: String (UUID)
- `title`: String
- `notes`: String?
- `date`: DateTime (normalized to midnight `YYYY-MM-DD` for anchor/start date)
- `startMinute`: int (0 to 1439)
- `durationMinutes`: int (minimum 15)
- `colorValue`: int (ARGB color)
- `recurrenceType`: Enum (`none`, `daily`, `weekdays`, `weekly`, `monthly`)
- `recurrenceDays`: List<int>? (1=Mon .. 7=Sun, used when `weekly`)
- `recurrenceEndDate`: DateTime? (optional end date for series)
- `excludedDates`: List<String>? (`YYYY-MM-DD` strings for deleted single instances)

## 5. Implementation Roadmap for the Agent
Execute this build iteratively in clean, testable milestones:
1. **Milestone 1 (Data & Storage)**: Set up local persistence (`sqflite` or `hive_ce`), the `TimeEvent` model, and a `CalendarRepository` capable of querying all active events for any given `DateTime` (evaluating recurrence rules and exclusions).
2. **Milestone 2 (Calendar Header & Radial Canvas)**: Build the top date selector, the 24h `CustomPainter` dial, current time indicator, and empty-state guidance.
3. **Milestone 3 (CRUD & Recurrence UI)**: Build the Add/Edit Event Bottom Sheet with time pickers, duration presets (15m, 30m, 1h, 2h), color palette selector, and recurrence rule selector.
4. **Milestone 4 (Direct Dial Interaction)**: Add `GestureDetector` polar hit-testing (`atan2` & radius distance checks) so tapping anywhere on the ring creates an event at that exact time or opens the tapped block.
5. **Milestone 5 (Polish & iOS Readiness)**: Ensure dark/light theme support, smooth animations, and verify `flutter build ios --release --no-codesign` compatibility.

## 6. Coding Standards
- Keep UI widgets decoupled from business logic and recurrence calculations.
- Write unit tests for the recurrence calculation logic (verifying weekly/monthly edge cases and excluded dates).
- Use `fvm flutter` for all CLI commands.
