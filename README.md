# LinuxDojo

> Learn Linux commands offline, one card at a time.

[![CI](https://github.com/ari/linuxdojo/actions/workflows/ci.yml/badge.svg)](https://github.com/ari/linuxdojo/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-6fcf8e.svg)](LICENSE)
[![Flutter 3.47.1](https://img.shields.io/badge/Flutter-3.47.1-5fc8cc?logo=flutter&logoColor=white)](https://flutter.dev)

LinuxDojo is an offline-first Flutter app for learning Linux commands with
spaced repetition. It mixes flip cards and multiple choice questions, schedules
reviews with a simplified SM-2 algorithm, and keeps everything on-device. No
accounts, network calls, or tracking.

## Screenshots

<p align="center">
  <img src="docs/screenshots/home.jpg" width="190" alt="Home screen with streak, due cards, and Study button">
  <img src="docs/screenshots/decks.jpg" width="190" alt="Deck browser with mastery progress">
  <img src="docs/screenshots/stats.jpg" width="190" alt="Weekly stats and streak progress">
</p>


## Features

- **240 Linux command cards** across 8 decks: basics, files, permissions,
  processes, networking, users and groups, text processing, and system
  information.
- **Short 10-card study sessions** with roughly 60% flip cards and 40%
  multiple choice. Flip cards use Again / Hard / Good / Easy; multiple choice
  answers auto-grade as Good when correct and Again when wrong.
- **Immediate feedback** with the correct answer and a usage example on every
  multiple choice response. Distractors come from the same deck.
- **Simplified SM-2 scheduling** that updates ease, repetitions, interval, and
  the next review date after each grade.
- **Daily streaks, 42 achievements, and weekly activity stats.** Streaks count
  only when the daily goal is met, and achievements live on their own screen.
- **Smart local reminders** scheduled at a time derived from recent study
  patterns, streak, goal, and a safe waking window. They skip the rest of a
  day once its goal is met, open a study session when tapped, and reschedule
  after sessions, goal changes, and app resume. Notification access can be
  restored from Settings; Android restores scheduled reminders after reboot.
- **First-launch onboarding and persistent settings** for experience level,
  daily goal, reminders, and progress reset.
- **Dark-only, terminal-inspired Material 3 UI** with monospace command accents.
- **100% offline** with local SQLite progress and no network permissions.

## Tech stack

| Layer | Choice |
| --- | --- |
| UI | Flutter 3.47.1, Material 3 |
| State | Riverpod 3 |
| Persistence | drift + SQLite |
| Charts | fl_chart |
| Notifications | flutter_local_notifications, timezone |
| Testing | flutter_test, in-memory drift |
| CI | GitHub Actions |
| Platforms | Android + iOS source |

## Getting started

Requires Flutter 3.47.1 / Dart 3.13.1 or newer.

```bash
flutter pub get
flutter run
```

The app is supported on Android and iOS. An iOS build requires macOS and Xcode.

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
as an APK; there is no Play Store release.

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
