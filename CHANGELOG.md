# Changelog

All notable changes to this project since `v1.0` are documented in this file.

## [v1.0.1] - 2026-03-31

### Added

- User-facing README with installation instructions, feature overview, settings guidance, and macOS Gatekeeper troubleshooting.
- Custom menu bar icon that combines the clock and water drop branding instead of relying on a system symbol.
- Follow-up eye-strain completion notification that fires 20 seconds after the initial reminder with a sound cue.
- New Pomodoro setting: `Skip Eye-Strain Reminder Near Break`, with a configurable merge window from 0 to 10 minutes.

### Changed

- Default Pomodoro timings now use 50-minute work sessions and 10-minute short breaks.
- Eye-strain reminders now use persistent alert-style macOS notifications by default.
- The next focus session now starts only after the user presses `OK` on the break-complete notification.
- The working-state menu bar icon now keeps the clock hands visible inside the filled clock face.
- Eye-strain suppression near breaks is now configurable, with a default window of 5 minutes.
- Restored in-progress work sessions now restart the eye-strain sub-timer after app relaunch.

### Distribution

- Added Apple development team and signing-related project settings to support local code signing and export workflows.

### Fixed

- Fixed a restore-path gap where an active work timer could resume after relaunch without resuming eye-strain reminders.
- Fixed timer notification cleanup so pending eye-strain reminders and their follow-up completion notifications are removed correctly.

### Documentation

- Added installation guidance for unpacking and launching the app.
- Added troubleshooting steps for the macOS “Apple could not verify” Gatekeeper warning.
- Added a direct link from installation to the troubleshooting section.

## [v1.0] - 2026-03-30

- Initial MVP release.
