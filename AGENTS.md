# AGENTS.md

## Project
- LinuxDojo is an offline-only Flutter app (Android + iOS source; iOS cannot be built on this Linux host). Do not add network calls, accounts, sync, AI, card creation, or a light theme.
- The actual app/package id is `com.ari.linuxdojo` in Android/iOS config. Some local docs say `om.ari...`; config wins.
- UI is English-only, Material 3, dark-only. Use `AppColors`, `AppTheme`, and `AppTypography.command` instead of hardcoded colors or command fonts.
- Toolchain: Flutter 3.47.1 / Dart 3.13.1, Riverpod 3.x, drift 2.x. CI pins Flutter 3.47.1.

## Commands
- Setup: `flutter pub get`
- CI order: `flutter analyze && flutter test`
- Single test file: `flutter test test/features/study/domain/sm2_engine_test.dart`
- Single test by name: `flutter test --plain-name "Good, Good, Good"`
- Format: `dart format lib test` (CI does not check formatting)
- Drift codegen after table changes: `dart run build_runner build` (this build_runner version ignores `--delete-conflicting-outputs`)
- Do not build the APK unless explicitly asked; analyze/test are the normal verification loop.

## Architecture
- Feature-first: put feature code in `lib/features/<feature>/{data,domain,presentation}`; shared database/theme/models go in `lib/core`.
- `lib/main.dart` creates a `ProviderContainer`, awaits `databaseSeedProvider`, then runs the app. Seeding happens before the first frame.
- Drift schema is in `lib/core/database/tables.dart`. `app_database.g.dart` is generated and committed; never hand-edit it.
- Repositories own their Riverpod providers and receive `AppDatabase` via `appDatabaseProvider`.
- SM-2 lives in `lib/features/study/domain/`; `ReviewRepository` persists schedule changes.

## Content and seeding
- MVP content is 8 decks × 30 cards (240) in `assets/decks/*.json`. Each deck has 18 flip / 12 MC and all four difficulty tags. Local docs under `instructions/` say 3 decks; the 8-deck product decision wins.
- `instructions/` is gitignored (local product docs only). User decisions override those docs on conflict.
- Deck paths are hardcoded in `AssetSeedSource.deckAssetPaths`; update that list when adding or removing a deck. `test/assets/deck_assets_test.dart` enforces 8×30, all difficulty tags, and at least 18 flip / 12 MC per deck.
- Seeding only runs when the `decks` table is empty. JSON edits do not update an existing install; clear app data or add an explicit reseed/version path.
- Schema changes need a `schemaVersion` bump, a migration, and codegen; commit the regenerated `app_database.g.dart`.

## Android
- `flutter_local_notifications` requires core library desugaring. Keep `isCoreLibraryDesugaringEnabled = true`, `multiDexEnabled = true`, and `desugar_jdk_libs:2.1.4` in `android/app/build.gradle.kts`; removing them breaks the build.
- `compileSdk = 37` is set manually.
- `web/` is leftover scaffold; supported targets are Android and iOS.

## Testing
- Tests use in-memory drift through `test/helpers/test_database.dart`; no external database or services are needed.
- Asset tests need `TestWidgetsFlutterBinding.ensureInitialized()`.
- Keep test paths mirroring `lib/features/...`; add seeding or repository tests when changing data behavior.
- SM-2 uses the current ease factor to compute the interval, then applies the grade's ease delta (Good, Good, Good produces 1, 6, 15 days). The tests encode the expected sequences.

## Scope
- Build module-by-module per `instructions/implementation_plan.md`; Modules 0–6 are complete. Do not implement later modules unprompted.
- Locked behavior: ~60/40 flip/MC sessions, argument cards always Flip, usage example always shown, MC correct = Good / wrong = Again, streak only when the daily goal is met, 30+ achievements, weekly stats.
- Out of scope for MVP: accounts/sync, AI or free-text recall, card creation, quick review (v2), Play Store.
