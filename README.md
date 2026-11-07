# LinuxDojo

> Learn Linux commands offline, one card at a time.

[![CI](https://github.com/ari/linuxdojo/actions/workflows/ci.yml/badge.svg)](https://github.com/ari/linuxdojo/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-6fcf8e.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.47.1-5fc8cc.svg)](https://flutter.dev)

LinuxDojo is an offline-first mobile app for learning Linux commands with
spaced repetition. It mixes flip cards and multiple choice questions, schedules
reviews with a simplified SM-2 algorithm, and keeps everything on-device. No
accounts, no network calls, no tracking.

## Status

Early development. Module 0 (project setup) is complete. Study sessions, content,
gamification, and smart notifications are next.

## Planned MVP

- 8 Linux command decks with 30 cards each.
- Hybrid study sessions: ~60% flip cards and ~40% multiple choice.
- Simplified SM-2 scheduling with Again / Hard / Good / Easy grades.
- Multiple choice feedback with auto-grading and usage examples.
- Daily streaks, 30+ achievements, and weekly stats.
- Smart daily reminders based on usage patterns.
- 100% offline with local SQLite progress.
- Dark-only, terminal-inspired Material 3 interface.

## Tech stack

| Layer | Choice |
| --- | --- |
| UI | Flutter, Material 3 |
| State | Riverpod |
| Persistence | drift + SQLite |
| Charts | fl_chart |
| Notifications | flutter_local_notifications |
| Platforms | Android (APK), iOS source |

## Getting started

Requires Flutter 3.47.1 or newer (Dart 3.13.1+).

```bash
flutter pub get
flutter run
```

## Quality checks

```bash
flutter analyze
flutter test
```

The same commands run in GitHub Actions on every push and pull request.

## Building the Android APK

```bash
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/`. LinuxDojo is distributed
as an APK; there is no Play Store release for the MVP.

## Project structure

```text
lib/
├── app/                     # App root and MaterialApp configuration
├── core/
│   ├── theme/               # Dark Material 3 theme, colors, typography
│   └── widgets/             # Shared UI building blocks
└── features/
    ├── home/                # Home / daily study entry point
    ├── decks/               # Deck browsing
    ├── stats/               # Weekly stats and achievements
    ├── settings/            # Preferences, reminders, about
    └── shell/               # Bottom navigation shell
```

## License

Released under the [MIT License](LICENSE).
