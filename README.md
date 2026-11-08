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

Early development. Modules 0–8 are complete: project setup, theme, app shell,
drift schema, seeded deck content, repositories, the SM-2 scheduling engine,
flip study sessions with animated cards and four grade buttons, multiple choice
questions with same-deck distractors, immediate feedback, usage examples, and
auto-grading, deck browsing with mastery progress and read-only card details,
gamification with daily streaks, 42 achievements, and a weekly activity chart,
first-launch onboarding and persistent settings for level, daily goal, and
reminders, plus smart daily notifications that learn from study times and are
scheduled locally.

## Planned MVP

- 8 Linux command decks with 30 cards each.
- Hybrid study sessions: ~60% flip cards and ~40% multiple choice.
- Simplified SM-2 scheduling with Again / Hard / Good / Easy grades.
- Multiple choice feedback with auto-grading and usage examples.
- Daily streaks, 30+ achievements, and weekly stats.
- Smart daily reminders based on usage patterns.
- 100% offline with local SQLite progress.
- Dark-only, terminal-inspired Material 3 interface.

## Spaced repetition

Grades are mapped to SM-2 quality values: Again = 0, Hard = 3, Good = 4,
Easy = 5. The engine updates the ease factor, repetition count, interval, and
next review date. Multiple choice answers auto-grade as Good when correct and
Again when wrong. The ease factor never drops below 1.3.

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

The same commands run in GitHub Actions on every push and pull request. After
changing drift tables, regenerate the database code:

```bash
dart run build_runner build
```

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
│   ├── database/            # Drift schema, seed loader, database providers
│   ├── models/              # Card type and difficulty enums
│   ├── theme/               # Dark Material 3 theme, colors, typography
│   └── widgets/             # Shared UI building blocks
└── features/
    ├── home/                # Home / daily study entry point
    ├── decks/               # Deck browsing + deck repository
    ├── study/               # Due cards, sessions, reviews, and SM-2 domain
    ├── stats/               # Weekly stats, achievements repository
    ├── notifications/       # Smart reminder algorithm and local scheduling
    ├── settings/            # Preferences, reminders, settings repository
    ├── onboarding/          # First-launch preference flow
    └── shell/               # Bottom navigation shell
```

## License

Released under the [MIT License](LICENSE).
