---

description: "Task list for Foundation (Phase 0)"
---

# Tasks: Foundation (Phase 0)

**Input**: Design documents from `specs/001-foundation/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: REQUIRED. Constitution IV says every acceptance criterion has at least one automated
test. Spec SC-003 also requires it. Test names start with the Screen ID, for example
`SYS-02 user cannot turn off both modules`. Within each phase, write tests first and make sure
they fail before implementing.

**Organization**:
- Phase 1 (Setup) is T0.1 scaffolding.
- Phase 2 (Foundational) is the T0.2–T0.4 core that every story needs.
- Phases 3–7 are the spec user stories, US1 to US5.
- Phase 8 is polish and the quality gates.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: US1 Onboarding · US2 Startup routing (SYS-01) · US3 Tab navigation · US4 SET-06 Modules · US5 Maintainer base
- Paths are relative to the repo root `C:\Workspace\DailyTrack`

## Global rules for every task (from the constitution and CLAUDE.md)

- **Strings**: no hard-coded user-facing strings. Add every string to `lib/core/l10n/app_en.arb`,
  `app_hi.arb`, and `app_gu.arb`, using placeholders and never concatenation.
- **Styling**: no `Color(0x…)`, `Colors.*`, or hex literals outside
  `lib/core/theme/app_colors.dart`. No raw sizes or spacing. Use `AppTokens.of(context)` and the
  theme text styles.
- **Layers**: `domain/` has no Flutter imports. `presentation/` never imports `data/` or
  `package:drift`.
- **Data**: money is `int` minor units. Timestamps are UTC epoch ms (`int`).
- **After each phase**: run `dart run build_runner build --delete-conflicting-outputs`,
  `flutter analyze`, and `flutter test --exclude-tags golden`.

---

## Phase 1: Setup (Shared Infrastructure, T0.1)

**Purpose**: Clean project scaffold, dependencies, flavors, lints, folder layout, and CI.

- [X] T001 Update `docs/spec.md` before any code (Constitution I). First, in §4 under the `categories` table, add the default seed list: "Expense (12): food, groceries, transport, fuel, shopping, bills, rent, health, education, entertainment, travel, other. Income (5): salary, business, gift, interest, other. Account: Cash (type cash, opening balance 0)" (from `specs/001-foundation/research.md` R7). Second, in §6 SYS-02 step 2, change "Searchable list" to "Searchable list of 30 common ISO 4217 currencies" (research R5). Third, in §6 SYS-02 step 4, after "Set app lock" (optional, opens SYS-04), add "(shown from T3.1; hidden in Phase 0 because SYS-04 doesn't exist yet)". Fourth, in §6 SYS-01 States, after "Restore from backup" add "(added in T3.2; Phase 0 offers Retry only)". Fifth, in `specs/001-foundation/spec.md` Assumptions, change the "Currency list" bullet to "curated subset of 30 ISO 4217 currencies".
- [X] T002 Confirm the git repository layout with the user before creating CI. `C:\Workspace\DailyTrack` is not a git repo, and `dailytrack/` contains a nested repo holding only `.gitattributes` (plan Open item 3). Record the decision in `specs/001-foundation/plan.md` Open items. Do NOT delete `dailytrack/` without explicit approval.
- [X] T003 Delete the counter-app sample: replace `lib/main.dart` with an empty `void main() {}` stub and delete `test/widget_test.dart`.
- [X] T004 Update `pubspec.yaml`:
  - Set `description: "Expense and habit tracker"` and `environment.sdk: ^3.13.5`.
  - Add dependencies with `flutter pub add`: `flutter_riverpod`, `riverpod_annotation`, `go_router`, `drift`, `drift_flutter`, `freezed_annotation`, `json_annotation`, `intl`, `flutter_local_notifications`, `uuid`, `flutter_native_splash` (runtime dependency, because `lib/` calls `FlutterNativeSplash.preserve`/`remove`), and `flutter_localizations` (sdk).
  - Add dev dependencies: `build_runner`, `riverpod_generator`, `drift_dev`, `freezed`, `json_serializable`, `very_good_analysis`, `mocktail`.
  - Remove `flutter_lints` and `cupertino_icons`. Set `flutter: generate: true`.
  - Use the versions from research.md R1 as the minimums and let the solver pick the latest compatible ones.
- [X] T005 [P] Download and add the font files to `assets/fonts/`: `NotoSans-Regular.ttf`, `NotoSans-SemiBold.ttf`, `NotoSansDevanagari-Regular.ttf`, `NotoSansDevanagari-SemiBold.ttf`, `NotoSansGujarati-Regular.ttf`, `NotoSansGujarati-SemiBold.ttf` (OFL, from the Google Fonts / notofonts GitHub releases). Add `assets/fonts/OFL.txt`. Register the families `NotoSans`, `NotoSansDevanagari`, `NotoSansGujarati` (weights 400 and 600) under `flutter: fonts:` in `pubspec.yaml`.
- [X] T006 [P] Add a placeholder logo `assets/branding/logo.png` (1024×1024, teal mark on a transparent background, generated simply). Register `assets/branding/` in `pubspec.yaml`. Add a `flutter_native_splash:` config to `pubspec.yaml`:
  - `color: "#FFFFFF"`, `color_dark: "#191C1B"`, `image: assets/branding/logo.png`.
  - An `android_12:` block with `image`, `color`, `color_dark`.
  - Run `dart run flutter_native_splash:create`.
- [X] T007 [P] Replace `analysis_options.yaml`:
  - `include: package:very_good_analysis/analysis_options.yaml`
  - `analyzer.exclude`: `build/**`, `**/*.g.dart`, `**/*.freezed.dart`, `lib/core/l10n/gen/**`, `test/drift/**/generated/**`
  - `linter.rules.public_member_api_docs: false`
- [X] T008 [P] Create `l10n.yaml` with `arb-dir: lib/core/l10n`, `template-arb-file: app_en.arb`, `output-dir: lib/core/l10n/gen`, `output-localization-file: app_localizations.dart`, `output-class: AppLocalizations`, `nullable-getter: false`.
- [X] T009 [P] Create `build.yaml` with a `drift_dev` section, `databases: app_database: lib/core/database/app_database.dart`, `schema_dir: drift_schemas/`, `test_dir: test/drift/`, and `dart_test.yaml` declaring the tag `golden`.
- [X] T010 [P] Add Android flavors in `android/app/build.gradle.kts`: `flavorDimensions += "env"`, then `productFlavors { create("dev") { dimension = "env"; applicationIdSuffix = ".dev"; resValue("string", "app_name", "DailyTrack Dev") }; create("prod") { dimension = "env"; resValue("string", "app_name", "DailyTrack") } }`. Set `minSdk = 24`. In `android/app/src/main/AndroidManifest.xml`, set `android:label="@string/app_name"` and add `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>`.
  - *Done note:* AGP 9.1 needs `buildFeatures { resValues = true }` for the flavor `app_name`. `flutter_local_notifications` 22 needs core library desugaring (`isCoreLibraryDesugaringEnabled = true` plus `desugar_jdk_libs:2.1.4`). Both are added.
- [X] T011 [P] Create `lib/app/flavor.dart`: `enum Flavor { dev, prod }` and `FlavorConfig.current`, which reads `appFlavor` from `package:flutter/services.dart` (`'prod'` → prod, anything else → dev) and exposes `bool get showDebugBanner` (true for dev).
- [X] T012 Create the §3 folder skeleton with a `.gitkeep` in each empty folder: `lib/core/{ads,billing,database/tables,notifications,security,backup,settings/domain,settings/data,theme,l10n,utils,widgets,module}`, `lib/features/{onboarding/domain,onboarding/presentation/screens,onboarding/presentation/widgets,onboarding/presentation/controllers,lock/presentation/screens,dashboard/presentation/screens,expense/data/tables,expense/data/seed,expense/domain,expense/presentation/screens,habit/presentation/screens,settings/presentation/screens,settings/presentation/controllers,premium}`, `lib/app/router`, `lib/app/splash`, `test/`, `integration_test/`.
- [X] T013 [P] Create `.github/workflows/ci.yml`:
  - Triggers: `pull_request`, and `push` to `main`. Runner: `ubuntu-latest`, Java 17 (`actions/setup-java`), `subosito/flutter-action@v2` (channel stable, `flutter-version: 3.47.x`, cache true).
  - Steps: `flutter pub get` → `dart run build_runner build --delete-conflicting-outputs` → `flutter analyze` → `dart format --set-exit-if-changed .` → `flutter test --coverage` → `flutter build appbundle --flavor prod --release`.
  - Upload `build/app/outputs/bundle/prodRelease/*.aab` and golden failure diffs as artifacts.
  - Depends on T002 for where the file lives.
- [X] T014 [P] Create `test/flutter_test_config.dart`, which loads the six bundled Noto fonts with `FontLoader` before tests run (needed for deterministic goldens, research R11).

**Checkpoint**: `flutter pub get` and `flutter analyze` succeed on the empty scaffold.

---

## Phase 2: Foundational (Blocking Prerequisites, T0.2–T0.4 core)

**Purpose**: Theme, l10n, utilities, database and settings, the module contract, the router
skeleton, and the shared widgets that the screens in US1–US4 use.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

### Theme and tokens

- [X] T015 [P] Create `lib/core/theme/app_colors.dart`. This is the ONLY file with hex literals. It holds:
  - `seed = Color(0xFF0F766E)`.
  - Light: `income #15803D`, `expense #B91C1C`, `warning #B45309`, `success #15803D`.
  - Dark: `income #4ADE80`, `expense #F87171`, `warning #FBBF24`, `success #4ADE80`.
  - A `palette` list of exactly 16 category/habit colors, chosen for ≥ 3:1 contrast on both themes' surfaces.
- [X] T016 [P] Unit test `test/core/theme/app_colors_test.dart`: every one of the 16 palette colors has a contrast ratio ≥ 3.0 against both the light and dark `ColorScheme.fromSeed(seedColor: seed).surface`. Semantic text colors have ≥ 4.5 against their theme surface (WCAG AA).
- [X] T017 Create `lib/core/theme/app_tokens.dart`: a `ThemeExtension<AppTokens>` with the fields from `contracts/app_tokens.md`. Values: spacing `4,8,12,16,24,32,48`, `screenPadding 16`, `screenPaddingWide 24`, `cardGap 12`, `wideBreakpoint 600`, `maxContentWidth 600`, `radiusChip 8`, `radiusCard 16`, `radiusSheet 28`, `iconSize 24`, `chipIconSize 20`, `avatarSize 40`, `minTouchTarget 48`, `navBarHeight 80`, `motionShort 150ms`, `motionMedium 250ms`, and `habitDoneDarkOpacity` 0.85 (dark) / 1.0 (light). Include `copyWith`, `lerp`, `static AppTokens of(BuildContext)`, and `AppTokens.light` / `AppTokens.dark`.
- [X] T018 Create `lib/core/theme/app_theme.dart`:
  - `AppTheme.light()` and `AppTheme.dark()` with `useMaterial3: true` and `ColorScheme.fromSeed(seedColor: AppColors.seed, brightness: …)`.
  - `fontFamily: 'NotoSans'`, `fontFamilyFallback: ['NotoSansDevanagari','NotoSansGujarati']`.
  - Text theme: `displaySmall 36/600`, `headlineSmall 24/600`, `titleMedium 16/600`, `bodyMedium 14/400`, `bodySmall 12/400`, `labelLarge 14/600`, `labelSmall 11/600`.
  - Flat elevation: `cardTheme` elevation 0 on `surfaceContainer`, `appBarTheme` scrolledUnderElevation 0. `navigationBarTheme` height 80 and `labelBehavior: alwaysShow`.
  - Attach `AppTokens`.
- [X] T019 [P] Test `test/core/theme/app_theme_test.dart`: both themes have `AppTokens` attached, use Material 3, have the text sizes and weights above, and have a navigation bar height of 80.
- [X] T020 [P] Test `test/core/theme/no_hardcoded_style_test.dart`: scan every `.dart` file under `lib/features/`, `lib/core/widgets/`, and `lib/app/` (not generated files). Fail if any contains `Color(0x`, `Colors.`, or `EdgeInsets.all(<number>` with a raw literal. Also fail if any file under `lib/core/` other than `lib/core/database/app_database.dart` imports `package:dailytrack/features/` (plan Complexity Tracking). Also fail if any file under `lib/features/` imports anything from `package:dailytrack/app/` except `app/router/routes.dart`, which is a constants-only file with no imports (plan M1 rule). Also fail if any `lib/features/**/presentation/` file imports `flutter_local_notifications` or `local_notification_permission.dart` (T043). Also fail if `lib/core/settings/settings_providers.dart` imports anything under `core/settings/data/` or `package:drift`, or if any file other than `lib/main.dart` and `lib/core/settings/data/**` imports `settings_repository_impl.dart`. Also fail if any `lib/features/*/presentation/` file imports `/data/` or `package:drift`.

### Localization

- [X] T021 Create `lib/core/l10n/app_en.arb`, `app_hi.arb`, and `app_gu.arb` with every Phase 0 key, translated in all three files, with `@key` descriptions in en:
  - `appName`, `common_next`, `common_back`, `common_skip`, `common_retry`, `common_tryAgain`, `common_comingSoon`, `common_placeholderMessage`
  - `nav_home`, `nav_expenses`, `nav_habits`, `nav_more`
  - `splash_errorMessage`
  - `onboarding_welcomeTitle` ("Track money and habits in one place"), `onboarding_languageLabel`, `onboarding_currencyTitle`, `onboarding_currencySearchHint`, `onboarding_noMatches`, `onboarding_clearSearch`, `onboarding_modulesTitle`, `onboarding_atLeastOneModule`, `onboarding_privacyTitle`, `onboarding_privacyBody` (data stays on device), `onboarding_allowNotifications`, `onboarding_notificationsGranted`, `onboarding_notificationsDenied`, `onboarding_getStarted`, `onboarding_saveError`, `onboarding_stepLabel` ("Step {current} of {total}")
  - `modules_title`, `modules_expense`, `modules_habit`, `modules_water`, `modules_period`, `modules_atLeastOne`, `modules_reorderHandle` ("Reorder {name}")
  - `more_modulesEntry`, `lock_title`, `lock_placeholderMessage`
  - `expense_cat_food` … `expense_cat_other` (12 keys), `income_cat_salary` … `income_cat_other` (5 keys), `expense_account_cash`
  - `currency_<CODE>` for the 30 codes in T024
  - Shared-widget keys used in Phase 7: `common_previousMonth`, `common_nextMonth`, `common_undo`, `premium_watchAd`, `premium_getPro`
  - Language names are always shown in their own script: `language_en` "English", `language_hi` "हिन्दी", `language_gu` "ગુજરાતી" (same value in all three files).
- [X] T022 Run `flutter gen-l10n` and confirm `lib/core/l10n/gen/app_localizations.dart` is generated with `supportedLocales` en, hi, gu.

### Utilities (pure Dart, unit tests first)

- [X] T023 [P] Test `test/core/utils/money_formatter_test.dart`:
  - `format(123456700, currencyCode: 'INR', locale: 'en')` → `₹12,34,567.00`.
  - `format(1050, 'INR')` → `₹10.50`.
  - `signed: true` with income gives `+₹10.50`, and with expense gives `−₹10.50` (U+2212).
  - USD uses Western grouping (`$1,234,567.00`). JPY uses 0 minor digits.
  - The hi and gu locales still format INR with Indian grouping.
  - The API never accepts or returns `double` for amounts.
- [X] T024 [P] Create `lib/core/utils/currencies.dart`: `class CurrencyInfo { final String code; final String symbol; final int minorDigits; }` and `const currencies` with exactly 30 entries, INR first: INR, USD, EUR, GBP, AED, SAR, QAR, KWD, OMR, BHD, SGD, MYR, THB, IDR, PHP, JPY, CNY, HKD, KRW, AUD, NZD, CAD, CHF, SEK, NOK, DKK, ZAR, NPR, BDT, LKR. Also `CurrencyInfo? currencyByCode(String)`.
- [X] T025 Create `lib/core/utils/money_formatter.dart` (`MoneyFormatter.format(int minor, {required String currencyCode, required String locale, MoneySign sign = MoneySign.none})`). Use `intl` `NumberFormat.currency` with `en_IN` grouping for INR and digits from `currencies.dart`. Make T023 pass.
  - *Done note:* the planned `locale` parameter was dropped. Grouping depends only on the currency (Indian for INR, Western otherwise), with Latin digits in every UI language. Formatting uses `BigInt` and never `double`. contracts/app_tokens.md is updated.
- [X] T026 [P] Test `test/core/utils/date_keys_test.dart`:
  - `DateKeys.fromLocal(DateTime(2026,10,13,23,59))` → `2026-10-13`.
  - Parse round-trips.
  - `Epoch.nowUtcMs()` is UTC.
  - `Epoch.toLocal`.
  - Relative labels: today → "Today", yesterday → "Yesterday", otherwise `EEE, d MMM`. The labels come from a passed-in resolver, not hard-coded strings.
- [X] T027 Create `lib/core/utils/date_keys.dart` (`DateKeys`, `Epoch`). Make T026 pass.
- [X] T028 [P] Test `test/core/utils/keypad_expression_test.dart`:
  - `"12.5+7.5"` → 2000 minor units.
  - `"100×3"` → 30000.
  - `"10÷3"` → 333 (round half up, integer math).
  - More than 2 decimals is rejected.
  - Division by zero returns an error result.
  - Empty input → 0.
- [X] T029 Create `lib/core/utils/keypad_expression.dart` (`KeypadExpression.evaluateToMinor(String input, {int minorDigits = 2})` → `Result<int, KeypadError>`). Use integer and BigInt arithmetic only. Also create `lib/core/utils/result.dart` (sealed `Result<T,E>` with `Ok`/`Err`). Make T028 pass.

### Database and settings (T0.3)

- [X] T030 [P] Create `lib/core/database/tables/settings_table.dart`: Drift table `Settings` with `key` TEXT primary key, `value` TEXT not null (JSON), `updatedAt` INTEGER not null (UTC ms).
- [X] T031 [P] Create `lib/features/expense/domain/enums.dart` with these comments: `enum CategoryType { expense, income }` and `enum AccountType { cash, bank, upi, card, wallet }`, both marked "append-only: never reorder or remove (stored as int index)".
- [X] T032 [P] Create `lib/features/expense/data/tables/categories_table.dart`: Drift table `Categories` with:
  - `id` TEXT PK (UUID v4)
  - `name` TEXT not null, "1–40 chars" (CHECK length between 1 and 40)
  - `type` intEnum<CategoryType> not null
  - `iconKey` TEXT not null
  - `colorHex` TEXT not null, `#RRGGBB`
  - `isDefault` BOOL not null default false
  - `isArchived` BOOL not null default false
  - `sortOrder` INT not null
  - `createdAt`, `updatedAt` INT not null (UTC ms)
  - `deletedAt` INT nullable
  - Index `(type, sortOrder)`
- [X] T033 [P] Create `lib/features/expense/data/tables/accounts_table.dart`: Drift table `Accounts` with:
  - `id` TEXT PK (UUID v4)
  - `name` TEXT not null 1–40 chars
  - `type` intEnum<AccountType> not null
  - `openingBalanceMinor` INT not null default 0
  - `iconKey`, `colorHex` TEXT not null
  - `isArchived` BOOL not null default false
  - `sortOrder` INT not null
  - `createdAt`, `updatedAt` INT not null
  - `deletedAt` INT nullable
- [X] T034 Create `lib/core/database/app_database.dart`:
  - `@DriftDatabase(tables: [Settings, Categories, Accounts])`, `schemaVersion = 1`.
  - `MigrationStrategy(onCreate: (m) => m.createAll(), onUpgrade: stepByStep(), beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'))`.
  - Constructor taking a `QueryExecutor`, plus a factory `AppDatabase.open()` that uses `driftDatabase(name: 'dailytrack')`.
  - Also create `lib/core/database/database_provider.dart` (`@Riverpod(keepAlive: true) AppDatabase appDatabase(Ref ref)`, which disposes on close).
- [X] T035 Run `dart run build_runner build --delete-conflicting-outputs`, then `dart run drift_dev make-migrations`. Commit `drift_schemas/app_database/drift_schema_v1.json` and the generated `test/drift/app_database/generated/*`.
  - *Done note:* with only schema v1, `make-migrations` writes the schema dump but no test scaffolding. The helpers were generated with `dart run drift_dev schema generate drift_schemas/app_database/ test/drift/app_database/generated/`.
- [X] T036 Test `test/drift/app_database/migration_test.dart` (generated by make-migrations, then edited): use `SchemaVerifier` to check that a fresh v1 database matches `drift_schema_v1.json`. Leave a commented template for future `v1→v2` tests. Run it with `NativeDatabase.memory()`.
- [X] T037 [P] Create `lib/core/settings/domain/app_settings.dart`: a freezed `AppSettings` with typed fields and defaults exactly as in the data-model.md §1 table:
  - `String? locale`, `currencyCode 'INR'`, `themeMode 'system'`, `selectedTheme 'default'`, `firstDayOfWeek 1`
  - `lockEnabled false`, `biometricEnabled false`
  - `List<String> enabledModules ['expense','habit']`, `List<String> moduleOrder ['expense','habit']`
  - `onboardingDone false`, `String? adConsentStatus`, `int? lastBackupAt`, `removeAdsPurchased false`
  - Also create `OnboardingChoices` (freezed: `String? locale`, `currencyCode`, `moduleOrder`, `enabledModules`) and `final class LastModuleError implements Exception`. This is pure Dart, with no Flutter imports.
- [X] T038 [P] Create `lib/core/settings/domain/settings_repository.dart`: the abstract interface exactly as in `contracts/services.md` (`load`, `watch`, `setLocale`, `setCurrency`, `setModules`, `completeOnboarding`). Also add `Future<void> markSeeded(String seederId)` and `Future<bool> isSeeded(String seederId)`, which are used by SeedRunner inside its transaction.
- [X] T039 Test `test/core/settings/settings_repository_test.dart` (in-memory `AppDatabase`):
  - Defaults are returned for an empty table.
  - A corrupt JSON value for a key falls back to that key's default without throwing.
  - `setLocale('xx')` is ignored and only en/hi/gu are stored.
  - `setModules(enabled: [])` throws `LastModuleError` and leaves the stored value unchanged.
  - Unknown module ids are dropped on read.
  - `completeOnboarding` writes locale, currency, modules, and `onboardingDone=true` atomically. A simulated failure mid-write leaves `onboardingDone=false`.
  - `watch()` emits after each write.
  - A write takes < 100 ms (stopwatch, measured on in-memory DB).
  - `SC-006 settings survive a restart`: write locale `gu`, currency `USD`, and modules `order ['habit','expense']`, `enabled ['habit']` to an `AppDatabase(NativeDatabase(tempFile))`. Close it, open a NEW `AppDatabase` and `SettingsRepositoryImpl` on the same temp file, and verify `load()` returns the same values. This is where real persistence is proven. Widget tests use fakes (T059).
- [X] T040 Create `lib/core/settings/data/settings_codec.dart` (JSON encode and decode per key, with defaults on error) and `lib/core/settings/data/settings_repository_impl.dart` (Drift implementation, with `completeOnboarding` in `db.transaction`). Create `lib/core/settings/settings_providers.dart`, which MUST NOT import `data/` or Drift (same pattern as `moduleRegistryProvider`, T046):
  - `@Riverpod(keepAlive: true) SettingsRepository settingsRepository(Ref ref) => throw UnimplementedError('override in main() / tests')`, typed to the domain interface.
  - `@Riverpod(keepAlive: true) Stream<AppSettings> appSettings(Ref ref) => ref.watch(settingsRepositoryProvider).watch()`.

  `SettingsRepositoryImpl` is bound only in `lib/main.dart` (T058), which is the composition root, and in test helpers. Presentation controllers (T066, T088) import `settings_providers.dart` and the domain types only. Make T039 pass.

### Module contract, router skeleton, and services (T0.4 core)

- [X] T041 [P] Create `lib/core/database/seeding.dart` (the `Seeder` interface: `String get id`, `Future<void> seed(AppDatabase db)`) and `lib/core/module/tracker_module.dart` (`TrackerModule`, `QuickAddAction`, the empty `BackupSection` interface, and `ComingSoonModule { id, nameKey }`), exactly as in `contracts/tracker_module.md`.
- [X] T042 [P] Create `lib/core/ads/ad_service.dart` (`abstract interface class AdService { Future<void> initialize(); }`, `final class NoAdsService implements AdService` that does nothing) and `lib/core/ads/ad_providers.dart` (`adServiceProvider` returning `const NoAdsService()`).
- [X] T043 [P] Create the notification permission in three files, so presentation code never imports the platform plugin:
  - `lib/core/notifications/notification_permission.dart`: ONLY the pure-Dart interface `NotificationPermission` (`Future<bool> request()`). No plugin import.
  - `lib/core/notifications/local_notification_permission.dart`: `LocalNotificationPermission implements NotificationPermission`, which calls `FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission()`.
  - Return true when null (Android ≤ 12 or non-Android). Catch all errors and return false. It must never throw.
  - `lib/core/notifications/notification_providers.dart`: `notificationPermissionProvider` (returns `LocalNotificationPermission`). Presentation imports the interface and this provider only.
- [X] T044 [P] Create `lib/app/router/routes.dart` (constants only, MUST have no imports, so features can safely import it): `abstract final class Routes` with path and name constants `splash '/splash'`, `onboarding '/onboarding'`, `lock '/lock'`, `home '/home'`, `expenses '/expenses'`, `habits '/habits'`, `more '/more'`, `modules '/more/modules'` (name `modules`).
- [X] T045 Create the placeholder modules:
  - `lib/features/expense/expense_module.dart`: `ExpenseModule implements TrackerModule`, with id `'expense'`, `rootPath Routes.expenses`, icons `Icons.receipt_long_outlined` / `Icons.receipt_long`, routes `[GoRoute(path: Routes.expenses, builder: ExpensesPlaceholderScreen)]`, `dashboardCard` a `SummaryCard` placeholder, `quickAddAction` null, `backupSection` null, seeders `[ExpenseDefaultsSeeder()]`, and no-op `onEnable`/`onDisable`.
  - `lib/features/habit/habit_module.dart`: id `'habit'`, `rootPath Routes.habits`, icons `Icons.check_circle_outline` / `Icons.check_circle`, seeders `[]`.
  - *Done note:* `ExpenseModule.seeders` is `const []` for now, because `ExpenseDefaultsSeeder` is created in T078. T078 registers it.
- [X] T046 Split the registry so features never import `lib/app/` code that imports features (no app ↔ features cycle):
  - `lib/core/module/module_registry.dart`: the `ModuleRegistry` class (`all`, `byId`, `visible(AppSettings)` = `moduleOrder` filtered by `enabledModules`, `owning(String location)` by `rootPath` prefix), `comingSoonModules` (water → `modules_water`, period → `modules_period`), and `@Riverpod(keepAlive: true) ModuleRegistry moduleRegistry(Ref ref) => throw UnimplementedError('override in main')`. Features import only this file.
  - `lib/app/module_registry.dart`: only `final registeredModules = <TrackerModule>[ExpenseModule(), HabitModule()];`. This is the only file that imports concrete modules. `main.dart` (T058) and `pumpTestApp` (T059) override `moduleRegistryProvider` with `ModuleRegistry(registeredModules)` or with fakes.
- [X] T047 [P] Tests split to mirror `lib/` (FR-003):
  - `test/core/module/module_registry_test.dart` (uses `FakeTrackerModule`s from T059, so run it after T059; it does not use the real modules):
    - `visible` respects order and the enabled filter.
    - `owning('/expenses/x')` → the module whose `rootPath` is `/expenses`.
    - `owning('/more')` → null.
    - `byId` of an unknown id → null.
  - `test/app/registered_modules_test.dart` (the real `registeredModules`):
    - Ids are unique.
    - Every module's routes all start with its `rootPath`.
    - No two modules share a `rootPath`.

### Shared widgets the screens need (subset of §15.4)

Each widget reads only `AppTokens` and the theme, has 48 dp minimum targets, and gives icon buttons semantic labels.

- [X] T048 [P] Create `lib/core/widgets/app_scaffold.dart` (`AppScaffold`: `title`, `body`, `actions`, `fab`, `bannerSlot`, `showBack`, `largeTitle`). It handles safe areas, side padding of 16 dp (24 dp when width > 600), content centered with max width 600, the FAB placed above the banner slot, and a banner slot of 0 height when null. Add the widget test `test/core/widgets/app_scaffold_test.dart`.
- [X] T049 [P] Create `lib/core/widgets/empty_state.dart` (`EmptyState`: `title`, `message`, `actionLabel?`, `onAction?`, `illustration?`) and `lib/core/widgets/error_state.dart` (`ErrorState`: `message`, `onRetry`, `retryLabel?` defaulting to the `common_tryAgain` ARB string, `secondaryAction?`). Add widget tests in `test/core/widgets/empty_state_test.dart` and `test/core/widgets/error_state_test.dart`.
- [X] T050 [P] Create `lib/core/widgets/skeleton.dart` (`SkeletonCard`, `SkeletonList(itemCount)`, and `DelayedSkeleton(child, delay: 300ms)`, which shows nothing until 300 ms have passed and has no shimmer when `MediaQuery.disableAnimations`). Add the widget test `test/core/widgets/skeleton_test.dart` (nothing is visible before 300 ms and the skeleton is visible after).
- [X] T051 [P] Create `lib/core/widgets/category_avatar.dart` (`CategoryAvatar`: `icon`, `color`, `semanticLabel`; a 40 dp circle with a 24 dp icon) and `lib/core/widgets/summary_card.dart` (`SummaryCard`: `title`, `value` Widget, `progress?`, `actionChip?`; 16 dp radius, tonal surface). Add widget tests in `test/core/widgets/category_avatar_test.dart` and `test/core/widgets/summary_card_test.dart`.
- [X] T052 [P] Create `lib/core/widgets/chip_selector.dart` (`ChipSelector<T>`: `options`, `selected` (Set<T>), `multi`, `labelBuilder`, `onChanged`; 48 dp targets) and the widget test `test/core/widgets/chip_selector_test.dart` (single and multi selection behavior).

### App shell skeleton

- [X] T053 Create `lib/app/bootstrap.dart` with a MINIMAL `bootstrap(Ref)`: open the DB and load settings, then return `BootstrapReady(initialLocation)` where `initialLocation` is `!onboardingDone → '/onboarding'`, else `'/home'`. Call `FlutterNativeSplash.remove()` once the result is known, whether it succeeded or failed. Also add the sealed `BootstrapResult` (`BootstrapReady`, `BootstrapFailed`) and the `bootstrapProvider` (`@Riverpod(keepAlive: true)` AsyncNotifier with a `retry()` method). Seeding, the lock route, and the ads gate are added in US2.
- [X] T054 Create placeholder screens, each using `AppScaffold` + `EmptyState` (`common_placeholderMessage`) and a localized title:
  - `lib/features/dashboard/presentation/screens/home_placeholder_screen.dart`: also lists `module.dashboardCard()` for `registry.visible(settings)`, separated by the `cardGap` token.
  - `lib/features/expense/presentation/screens/expenses_placeholder_screen.dart`
  - `lib/features/habit/presentation/screens/habits_placeholder_screen.dart`
  - `lib/features/settings/presentation/screens/more_placeholder_screen.dart`: includes a `ListTile` labelled `more_modulesEntry` that pushes `Routes.modules`.
  - `lib/features/lock/presentation/screens/lock_placeholder_screen.dart`: `PopScope(canPop: false)`, no back button, title `lock_title`, message `lock_placeholderMessage`.
- [X] T055 Create `lib/app/router/app_router.dart`:
  - `@Riverpod(keepAlive: true) GoRouter appRouter(Ref)` with `initialLocation: Routes.splash`.
  - Routes: `/splash` (SplashScreen from T057), `/onboarding` (a temporary `SizedBox` until US1), `/lock`.
  - A `StatefulShellRoute.indexedStack` with branches `[home, ...registry.all.map((m) => StatefulShellBranch(routes: m.routes)), more (with child route `modules` → a temporary `SizedBox` until US4)]`, built once.
  - `refreshListenable` bridges `bootstrapProvider` and `appSettingsProvider`.
  - Redirect rules 1, 2, and 3 from `contracts/routes.md`. Rule 6 is added in US1 (T072), rule 4 in US2 (T081), and rule 5 in US3 (T085).
  - *Done note:* rule 1 also sends a ready app from `/splash` to `BootstrapReady.initialLocation`. Without that, rules 1–3 alone never leave the splash, and the Phase 2 checkpoint needs it. The redirect logic is the pure function `redirectFor()` so it can be unit tested.
- [X] T056 Create `lib/app/router/app_shell.dart` (`AppShell(navigationShell)`): a `NavigationBar` with a STATIC list of 4 destinations (Home, Expenses, Habits, More) using `nav_*` labels, outlined icons when inactive and filled icons when selected. It calls `navigationShell.goBranch(i, initialLocation: i == currentIndex)`. US3 makes it dynamic.
- [X] T057 Create `lib/app/splash/splash_screen.dart`: the logo (`assets/branding/logo.png`) centered on `colorScheme.surface`, with `appName` below in `titleMedium`. When `bootstrapProvider` is in error, show `ErrorState(message: splash_errorMessage, onRetry: ref.read(bootstrapProvider.notifier).retry)`. No ads.
- [X] T058 Create `lib/app/app.dart` (`DailyTrackApp`: `MaterialApp.router` with `routerConfig`, `theme: AppTheme.light()`, `darkTheme: AppTheme.dark()`, `themeMode` from settings, `locale` from `appSettings.locale` (null → system), `supportedLocales`/`localizationsDelegates` from `AppLocalizations`, a `localeResolutionCallback` that falls back to `en` for unsupported device locales, and `debugShowCheckedModeBanner: FlavorConfig.current.showDebugBanner`). Update `lib/main.dart`:
  - `final binding = WidgetsFlutterBinding.ensureInitialized();`
  - `FlutterNativeSplash.preserve(widgetsBinding: binding);` keeps the native splash up until bootstrap finishes. `FlutterNativeSplash.remove()` is called from `bootstrap()` (T053 for the minimal version, T080 for the full one) as soon as the result is ready or has failed.
  - `runApp(ProviderScope(overrides: [moduleRegistryProvider.overrideWithValue(ModuleRegistry(registeredModules)), settingsRepositoryProvider.overrideWith((ref) => SettingsRepositoryImpl(ref.watch(appDatabaseProvider)))], child: const DailyTrackApp()));`. These are the registry override (T046) and the settings binding (T040). `main.dart` is the only `lib/` file that imports `SettingsRepositoryImpl`.
- [X] T059 Create the test helpers `test/helpers/test_app.dart`:
  - Constitution IV: **widget tests MUST use fake repositories and `NoAdsService`**. `pumpTestApp` never opens a Drift database.
  - `pumpTestApp(tester, {FakeSettingsRepository? settings, FakeBootstrap? bootstrap, AdService? ads, NotificationPermission? notif, ModuleRegistry? registry, List<Override> overrides})`. It overrides:
    - `settingsRepositoryProvider`, with the given `settings` or a new `FakeSettingsRepository()`.
    - `bootstrapProvider`, with the given `bootstrap` or `FakeBootstrap.fromSettings(settings)`. The latter computes `initialLocation` from the fake settings using the same rule as the real bootstrap: `!onboardingDone` → `/onboarding`, `lockEnabled` → `/lock`, otherwise `/home`.
    - `adServiceProvider`, with `ads` or `const NoAdsService()`.
    - `notificationPermissionProvider`, with `notif` or `FakeNotificationPermission(result: true)`.
    - `moduleRegistryProvider`, with `registry` or `ModuleRegistry(registeredModules)`.
    - `appDatabaseProvider`, with a provider that throws `StateError('widget tests must not touch the database')`. Any accidental database use fails loudly.
  - `restartTestApp(tester, {required FakeSettingsRepository settings, ...})` pumps `const SizedBox()` to dispose the widget tree and provider container, then calls `pumpTestApp` again with the SAME `settings` instance. This simulates an app restart over persisted settings. Real disk persistence is proven by T039 and T103.
  - `test/helpers/real_container.dart` (for UNIT tests that use a real database, never widget tests): `ProviderContainer makeRealContainer(AppDatabase db, {ModuleRegistry? registry, AdService? ads, List<Override> overrides})`. It overrides `appDatabaseProvider` → `db`, `settingsRepositoryProvider` → `SettingsRepositoryImpl(db)`, `moduleRegistryProvider` → `registry ?? ModuleRegistry(registeredModules)`, and `adServiceProvider` → `ads ?? const NoAdsService()`, and registers `addTearDown(container.dispose)`. Both providers throw unless overridden (T040, T046), so every unit test that builds a container MUST use this helper. That applies to T074, T087 and T105.
  - `test/helpers/fakes.dart` also gets:
    - `FakeSettingsRepository implements SettingsRepository`: an in-memory `AppSettings` with a broadcast `watch()` stream that emits on every write. It has the same validation as the real repository (`setModules(enabled: [])` throws `LastModuleError`, unknown locales are ignored), a `failNextCompleteOnboarding` flag that makes the next `completeOnboarding` throw (for T063), call counters per method, and in-memory `markSeeded`/`isSeeded`.
    - `FakeBootstrap`: an AsyncNotifier-compatible fake for `bootstrapProvider`. It can be built with a queue of results (`[BootstrapFailed(e), BootstrapReady('/home')]`, so Retry gets the next one), and counts calls.
  - `test/helpers/fakes.dart`: `FakeNotificationPermission(result | throws)`, `MockAdService` (mocktail), `FakeTrackerModule({String id, String rootPath, List<RouteBase>? routes})` (configurable id, root path and routes, and records `onEnable`/`onDisable` calls; used by T047, T086 and T111).

**Checkpoint**: `flutter run --flavor dev` shows the splash and then Home with 4 placeholder
tabs, or the onboarding placeholder on a fresh install. All Phase 2 tests pass.

---

## Phase 3: User Story 1 - First-time setup through onboarding (Priority: P1) 🎯 MVP

**Goal**: SYS-02. Choose language, currency, and modules in 4 steps. "Get started" or "Skip"
saves the choices and lands on Home.

**Independent Test**: On a fresh install, choose Gujarati, USD, and Habit only, then Get started.
Home shows in Gujarati with no Expenses tab after US3, and the choices survive a restart.

### Tests for User Story 1 ⚠️ write first, they must fail

- [X] T060 [P] [US1] Widget test `test/features/onboarding/onboarding_screen_test.dart` → `SYS-02 selected language persists and applies after app restart`: on step 1 tap the ગુજરાતી chip, verify the Gujarati `onboarding_welcomeTitle` shows right away, complete onboarding, call `restartTestApp(tester, settings: fake)` with the same `FakeSettingsRepository` instance (T059), and verify Home placeholder text is in Gujarati and no onboarding is shown.
- [X] T061 [P] [US1] Same file → `SYS-02 denying the notification permission does not block onboarding`: run once with `FakeNotificationPermission(result: false)` and once with `throws`. On step 4 tap Allow notifications, verify the `onboarding_notificationsDenied` text, tap Get started, and verify `/home` is reached and `onboardingDone == true`.
- [X] T062 [P] [US1] Same file → `SYS-02 user cannot turn off both modules`: on step 3 turn Habit off, then try to turn Expense off. The Expense switch stays on, `onboarding_atLeastOneModule` shows, and after Get started the stored `enabledModules == ['expense']`.
- [X] T063 [P] [US1] Same file, scenario tests:
  - Skip on step 1 saves the defaults (device locale `fr` → `locale` null and the UI in en; INR; both modules) and lands on Home.
  - Skip is visible on steps 1–2 and absent on steps 3–4.
  - The step 2 search "dol" shows US Dollar, "zzz" shows `onboarding_noMatches` with a clear action.
  - With device locale `en_IN`, INR is preselected.
  - Step 3 shows Water and Period as disabled "Coming soon".
  - No "Set app lock" button exists.
  - A language change on step 1 keeps the other choices.
  - Save failure: `FakeSettingsRepository(failNextCompleteOnboarding: true)` makes `completeOnboarding` throw. This keeps the user on step 4 with the choices intact, shows `onboarding_saveError` with a `common_retry` button, and a retry that then succeeds lands on Home. The same applies to Skip.
- [X] T064 [P] [US1] Unit test `test/features/onboarding/onboarding_controller_test.dart`: the state transitions in data-model.md §6 (next/back bounds 1–4, skip only on steps 1–2), `toggleModule` refusing to empty the enabled list, `filteredCurrencies` matching code or localized name case-insensitively, and `complete()` calling `SettingsRepository.completeOnboarding` once with the right `OnboardingChoices`.

### Implementation for User Story 1

- [X] T065 [US1] Create `lib/features/onboarding/presentation/controllers/onboarding_state.dart`: freezed `OnboardingState { int step (1..4); String? languageCode; String currencyCode; List<String> moduleOrder; List<String> enabledModules; String query; bool saving; String? moduleMessageKey; bool? notificationsGranted; String? saveErrorKey; }`.
- [X] T066 [US1] Create `lib/features/onboarding/presentation/controllers/onboarding_controller.dart` (`@riverpod class OnboardingController`):
  - `build()` seeds from the current settings, with currency INR preselected (research R5).
  - Methods: `next`, `back`, `skip` (defaults: locale null, INR, both modules, then `completeOnboarding`), `selectLanguage(code)` (calls `SettingsRepository.setLocale` immediately so the UI switches), `selectCurrency`, `setQuery`, `toggleModule(id)` (rejects the last enabled module by setting `moduleMessageKey = 'onboarding_atLeastOneModule'`), `requestNotifications()` (awaits `NotificationPermission.request()`, stores the result, never throws), and `complete()`. `complete()` and `skip()` set `saving=true` and call `completeOnboarding`. On an exception they set `saving=false` and `saveErrorKey='onboarding_saveError'` and keep all choices. A successful retry clears `saveErrorKey`.
  - It depends only on domain interfaces and providers. Make T064 pass.
  - *Done note:* the controller reads settings once with `ref.read` instead of watching them. Choosing a language writes settings, and watching would reset the user's progress. `retrySave()` repeats whichever save failed (Skip or Get started).
- [X] T067 [P] [US1] Create `lib/features/onboarding/presentation/widgets/language_step.dart`: an illustration (an `Icon` composition is fine until artwork exists), the headline `onboarding_welcomeTitle` in `headlineSmall`, and a `ChipSelector` with en/hi/gu using the `language_*` labels.
- [X] T068 [P] [US1] Create `lib/features/onboarding/presentation/widgets/currency_step.dart`: a search `TextField` (hint `onboarding_currencySearchHint`) and a `ListView` of `currencies` showing the localized name (`currency_<CODE>` looked up through a generated switch helper in `lib/core/l10n/currency_names.dart`), code, and symbol, with a radio-style selection. With no matches, show text `onboarding_noMatches` and a `TextButton` `onboarding_clearSearch` (no illustration, §15.6).
  - *Done note:* `currency_names.dart` and `seed_names.dart` (T079) are thin wrappers over `lib/core/l10n/l10n_lookup.dart`, a key-to-translation switch generated by `tool/l10n/phase0_strings.py` alongside the ARB files, so they can't drift from them.
- [X] T069 [P] [US1] Create `lib/features/onboarding/presentation/widgets/modules_step.dart`: two toggle cards (`CategoryAvatar` + name + `Switch`) for `registry.all`, a "Coming soon" row for `comingSoonModules` with disabled switches and the `common_comingSoon` label, and the inline `moduleMessageKey` text wrapped in `Semantics(liveRegion: true)`.
- [X] T070 [P] [US1] Create `lib/features/onboarding/presentation/widgets/privacy_step.dart`: `onboarding_privacyTitle` and `onboarding_privacyBody`, an `OutlinedButton` `onboarding_allowNotifications` that shows the granted or denied result text after the request, and NO "Set app lock" button.
- [X] T071 [US1] Create `lib/features/onboarding/presentation/screens/onboarding_screen.dart`:
  - A `PageView` with `NeverScrollableScrollPhysics`, driven by `state.step`.
  - The top bar has the step indicator (`onboarding_stepLabel` plus `LinearProgressIndicator` value step/4) and "Skip" (top right) only on steps 1–2.
  - A sticky bottom bar has Back (secondary) and Next or `onboarding_getStarted` (the single primary `FilledButton`), lifted above the keyboard.
  - States (FR-024): while `saving`, the primary button shows a small progress indicator and is disabled, so it can't be tapped twice. When `saveErrorKey` is set, an inline `ErrorState`-style message with `common_retry` appears above the bottom bar. There is no full-screen loading state, because the settings are local. The content state is the page itself.
  - No ads. Wire it to route `/onboarding` in `lib/app/router/app_router.dart`, replacing the T055 temporary widget.
- [X] T072 [US1] Add redirect rule 6 to `lib/app/router/app_router.dart` (it is not in T055), so that after `onboardingDone` becomes true the router leaves `/onboarding` for `/home`, triggered by `refreshListenable`. Make T060–T063 pass.

**Checkpoint**: US1 is fully functional. Fresh install → onboarding → Home in the chosen
language, and it persists across restarts.

---

## Phase 4: User Story 2 - Returning launch and startup routing (Priority: P1)

**Goal**: SYS-01. Exactly-once seeding (FR-025), lock routing to `/lock` (FR-026), the ads gate
(FR-027), and an error state with Retry.

**Independent Test**: With onboarding done, a cold start lands on Home. With the lock setting
faked on, it lands on `/lock`. With storage failing, it shows the error and Retry.

### Tests for User Story 2 ⚠️ write first, they must fail

- [X] T073 [P] [US2] Unit test `test/core/database/seed_runner_test.dart` → `SYS-01 first launch seeds 12 expense categories, 5 income categories, and one Cash account, exactly once`:
  - After `runAll` on an empty in-memory DB, there are exactly 12 rows with `type=expense, isDefault=true`, 5 with `type=income, isDefault=true`, and 1 account with name `expense_account_cash`, `type=cash`, `openingBalanceMinor=0`.
  - After calling `runAll` 3 more times, plus a fresh `SeedRunner` on the same DB, the counts are unchanged.
  - A seeder that throws midway leaves 0 rows and no `seed.<id>` key (the transaction rolled back), and a later successful run seeds once.
- [X] T074 [P] [US2] Unit test `test/app/bootstrap_test.dart`, using `makeRealContainer(AppDatabase(NativeDatabase.memory()), ads: mockAdService)` from T059:
  - `SYS-01 returning user with lock on lands on SYS-03; without lock lands on DSH-01`: settings `onboardingDone=true, lockEnabled=true` → `BootstrapReady('/lock')`; `lockEnabled=false` → `'/home'`; `onboardingDone=false` → `'/onboarding'`.
  - `SYS-01 ads SDK is not initialized when Remove Ads is purchased`: `MockAdService` with `removeAdsPurchased=true` → `verifyNever(initialize)`; with `false` → `verify(initialize).called(1)`.
  - `adService.initialize()` throwing still gives `BootstrapReady`.
  - A DB open that throws gives `BootstrapFailed`.
  - Bootstrap calls `SeedRunner` with the seeders of ALL registered modules, even when `enabledModules=['habit']`.
- [X] T075 [P] [US2] Widget test `test/app/splash/splash_screen_test.dart`, using `FakeBootstrap` with the results `[BootstrapFailed(StateError('db')), BootstrapReady('/home')]` (T059; no real database): the first result shows `ErrorState` with `splash_errorMessage` and `common_retry`. Tapping Retry gets the next result and navigates to `/home`. A second run with `BootstrapReady('/onboarding')` lands on onboarding. Retry can be tapped repeatedly without crashing. No ad widgets are in the tree at any time.
  - *Done note:* "no ad widgets in the tree" can't be asserted meaningfully yet, because ad widgets don't exist until T4.1. The `/home` case uses settings with `onboardingDone=true`, otherwise redirect rule 3 correctly sends the user to onboarding.
- [X] T076 [P] [US2] Widget test `test/app/router/lock_redirect_test.dart`: with `FakeSettingsRepository` seeded with `onboardingDone=true, lockEnabled=true` (`FakeBootstrap.fromSettings`), the app lands on `LockPlaceholderScreen`, and the system back (`tester.binding.handlePopRoute`) does not leave it.

### Implementation for User Story 2

- [X] T077 [P] [US2] Create `lib/core/database/seed_runner.dart` (`SeedRunner(AppDatabase db)`, `runAll(Iterable<Seeder>)`). For each seeder, inside ONE `db.transaction`: if the settings key `seed.<id>` is absent, run `seed(db)`, then write `seed.<id>` = `Epoch.nowUtcMs()` as JSON. Any error rolls back and rethrows.
- [X] T078 [P] [US2] Create `lib/features/expense/data/seed/expense_defaults_seeder.dart` (`ExpenseDefaultsSeeder`, id `'expense.defaults.v1'`):
  - Register it in `ExpenseModule.seeders` (`lib/features/expense/expense_module.dart`), which is `const []` until this task.
  - Insert 12 expense categories with `sortOrder` 0..11 and names `expense_cat_{food,groceries,transport,fuel,shopping,bills,rent,health,education,entertainment,travel,other}`.
  - Insert 5 income categories with `sortOrder` 0..4 and names `income_cat_{salary,business,gift,interest,other}`.
  - All have `isDefault: true`, an `iconKey` from a fixed map, a `colorHex` from `AppColors.palette` as `#RRGGBB`, a UUID v4 `id`, and `createdAt`/`updatedAt` = now UTC ms.
  - Insert 1 account: `name 'expense_account_cash'`, `type AccountType.cash`, `openingBalanceMinor 0`, `sortOrder 0`.
- [X] T079 [P] [US2] Create `lib/core/l10n/seed_names.dart`: `String localizedSeedName(AppLocalizations l10n, String key)`, a switch mapping each seeded key to its generated getter. User-created names are returned unchanged. Add the unit test `test/core/l10n/seed_names_test.dart`, which checks that every key used by `ExpenseDefaultsSeeder` resolves in en, hi, and gu.
- [X] T080 [US2] Extend `lib/app/bootstrap.dart` to the full order in `contracts/services.md`:
  1. Open the DB (migrations) and load settings.
  2. `SeedRunner.runAll(registry.all.expand((m) => m.seeders))`.
  3. `if (!settings.removeAdsPurchased) await adService.initialize()`, wrapped in try/catch so it never blocks.
  4. `initialLocation = !onboardingDone ? Routes.onboarding : lockEnabled ? Routes.lock : Routes.home`.
  - *Done note:* the first-route rule is the shared function `initialLocationFor(settings)`, which `FakeBootstrap` reuses so the fake can't drift from the real rule.

  Any exception in steps 1–2 gives `BootstrapFailed`. Call `FlutterNativeSplash.remove()` when the result is known. Make T073–T074 pass.
- [X] T081 [US2] Update `lib/app/router/app_router.dart` with redirect rule 4: `onboardingDone && lockEnabled && location != '/lock'` → `/lock`, applied at startup only (re-lock on resume is T3.1). Make T075–T076 pass.
  - *Done note:* with no unlock flow yet, rule 4 applies whenever lock is on. T3.1 adds the unlocked-session state and re-lock on resume. A pure-function test of rules 1–4 and 6 is in `test/app/router/redirect_test.dart`.

**Checkpoint**: US1 and US2 both work. All three SYS-01 acceptance criteria are green.

---

## Phase 5: User Story 3 - Moving between the four main tabs (Priority: P2)

**Goal**: A registry-driven, settings-ordered bottom navigation where each tab keeps its own back
stack, back goes to Home, and disabled-module routes redirect.

**Independent Test**: Switch between all tabs. Push SET-06 in More, switch away, and come back
to it. Back on the Expenses root goes to Home. Disabling Habit hides its tab.

### Tests for User Story 3 ⚠️ write first, they must fail

- [X] T082 [P] [US3] Widget test `test/app/router/app_shell_test.dart`:
  - Default settings show 4 destinations in order Home, Expenses, Habits, More, with labels always visible and the selected destination using the filled icon.
  - `enabledModules=['habit']` shows 3 destinations (no Expenses).
  - `moduleOrder=['habit','expense']` shows Home, Habits, Expenses, More.
  - Push `/more/modules`, tap Habits, tap More, and SET-06 is still shown (per-tab stack).
  - On the Expenses root, `handlePopRoute` → Home is selected.
  - On Home, `handlePopRoute` returns false (the app exits).
  - Tapping the active tab pops it to its root.
- [X] T083 [P] [US3] Widget test `test/app/router/disabled_module_redirect_test.dart`: with `enabledModules=['expense']`, `router.go('/habits')` lands on `/home`.

### Implementation for User Story 3

- [X] T084 [US3] Rewrite `lib/app/router/app_shell.dart`:
  - Destinations = `[home, ...registry.visible(settings), more]` from `appSettingsProvider` and `moduleRegistryProvider`.
  - Map visible index ↔ branch index (branch order is `[home, ...registry.all, more]`).
  - Selected index is derived from `navigationShell.currentIndex`.
  - Module destinations use `module.displayName`, `icon`, and `selectedIcon`. `NavigationBar` height comes from `AppTokens.navBarHeight`.
  - Back behavior: a `PopScope` intercepts back when the current branch ≠ home and is at its root, and calls `goBranch(0)`.
  - *Done note:* module tabs use the new `TrackerModule.tabLabel(context)` (`nav_expenses` "Expenses"), not `displayName` (`modules_expense` "Expense", shown in SYS-02 and SET-06). The contract's "Tab label key" column already named these keys but the interface had no member for them; `contracts/tracker_module.md` is updated. The `PopScope` sits on the shell's root-navigator page, so go_router pops a branch's pushed screen first and only reaches the shell at a tab root.
- [X] T085 [US3] Update `lib/app/router/app_router.dart` with redirect rule 5: if `registry.owning(location)` is non-null and not in `settings.enabledModules` → `/home`. Make T082–T083 pass.
  - *Done note:* `redirectFor()` now takes the `ModuleRegistry`; rule 5 is also covered in `test/app/router/redirect_test.dart`, and disabling the module whose tab is open sends the user Home (`disabled_module_redirect_test.dart`).

**Checkpoint**: US1–US3 work. Navigation behaves as in spec §5.

---

## Phase 6: User Story 4 - Turning trackers on and off (SET-06) (Priority: P2)

**Goal**: SET-06 Modules. A reorderable list with toggles, at least one module enabled,
`onEnable`/`onDisable` hooks, and "Coming soon" rows.

**Independent Test**: Disable Habit and the tab disappears. Re-enable it and it returns. Drag
Habit above Expense and the tab order changes and survives a restart.

### Tests for User Story 4 ⚠️ write first, they must fail

- [X] T086 [P] [US4] Widget test `test/features/settings/modules_screen_test.dart` (registry overridden with two `FakeTrackerModule`s and a shared `FakeSettingsRepository`; no database, per Constitution IV):
  - `SET-06 disabling a module hides its tab and dashboard card and calls onDisable`: disable expense, and the Expenses destination and card disappear, `onDisable` is called once, and the only repository write is `setModules` (the fake's call counters show no other write). Data retention is checked in T087.
  - `SET-06 at least one module stays enabled`: with one enabled, toggling it off leaves the switch on and shows `modules_atLeastOne`, with no `onDisable` call.
  - `SET-06 reorder changes tab and card order and persists`: drag habit above expense → `moduleOrder == ['habit','expense']`, the nav order is updated, and it survives `restartTestApp(tester, settings: fake)` with the same fake instance (T059).
  - `SET-06 coming soon rows are disabled and not reorderable`.
  - `SET-06 re-enabling calls onEnable and restores the tab`.
- [X] T087 [P] [US4] Unit test `test/features/settings/modules_controller_test.dart`: `toggle(id)` calls `SettingsRepository.setModules`, then `onDisable`/`onEnable` exactly once. A `LastModuleError` sets `messageKey='modules_atLeastOne'` and calls no hook. `reorder(old, new)` persists the new order and keeps the enabled set. Uses `FakeSettingsRepository`.
  - `SET-06 disabling a module keeps its data` (unit test, real database allowed outside widget tests): `makeRealContainer(AppDatabase(NativeDatabase.memory()))` (T059; it overrides the registry with the real modules and binds `SettingsRepositoryImpl`), with `SeedRunner` having run `ExpenseDefaultsSeeder`. Call `toggle('expense')` (disable) and then `toggle('expense')` (enable). The `categories` and `accounts` row counts (17 and 1) and the rows' `deletedAt` (all null) are unchanged after each step.

### Implementation for User Story 4

- [X] T088 [US4] Create `lib/features/settings/presentation/controllers/modules_controller.dart`: a freezed `ModulesState { List<ModuleRow> rows; String? messageKey; }` (`ModuleRow { String id; bool enabled; }`) and `@riverpod class ModulesController` with `build()` from `appSettingsProvider` + registry, `toggle(id)`, and `reorder(oldIndex, newIndex)`. Make T087 pass.
  - *Done note:* `ModulesState`/`ModuleRow` live in `modules_state.dart` (re-exported by the controller), the same split as onboarding. `build()` is async and watches `appSettingsProvider`, so the screen gets loading and error states and follows the settings stream. Toggling off the last module is rejected before any write, and a `LastModuleError` from the repository is handled the same way. Hooks run only after a successful write. Any other write failure shows the error state, and `retry()` re-reads settings. A registered module missing from `moduleOrder` is appended (needed for T111).
- [X] T089 [US4] Create `lib/features/settings/presentation/screens/modules_screen.dart`:
  - `AppScaffold(title: modules_title, showBack: true)`.
  - Loading state is `DelayedSkeleton(SkeletonList(itemCount: 2))`. The error state is `ErrorState` with retry. There is no empty state.
  - A `ReorderableListView` of rows: a drag handle with semantics `modules_reorderHandle`, `CategoryAvatar` (module icon), the name, and a `Switch` with a semantic label.
  - An inline `messageKey` text in `Semantics(liveRegion: true)`.
  - A "Coming soon" section with Water and Period, disabled switches, outside the reorderable list.
  - No ads.
  - Wire it to `Routes.modules` in `lib/app/router/app_router.dart`, replacing the T055 temporary widget. Make T086 pass.
  - *Done note:* the error state needed a string, so `modules_errorMessage` was added (en/hi/gu) through `tool/l10n/phase0_strings.py`. The section header reuses `common_comingSoon`. Reordering uses `ReorderableListView.onReorderItem` (`onReorder` is deprecated), whose `newIndex` is already the final position. Drag handles are explicit 48 dp `ReorderableDragStartListener`s, so the Coming soon rows in the `footer` can't be dragged. The temporary `_PendingScreen` was removed from the router.

**Checkpoint**: All user-facing stories (US1–US4) work on their own.

---

## Phase 7: User Story 5 - A safe, consistent base for later phases (Priority: P3)

**Goal**: Finish the rest of T0.1–T0.3 that isn't covered above: the remaining §15.4 widgets,
golden tests for all shared widgets, flavor checks, and CI green.

**Independent Test**: Both flavors install side by side. All quality gates pass in CI, including
goldens and the migration test.

### Tests for User Story 5 ⚠️ write first, they must fail

- [X] T090 [P] [US5] Widget test `test/core/widgets/amount_text_test.dart`:
  - `AmountText(amountMinor: 123456700, currencyCode: 'INR', kind: expense, showSign: true)` renders `−₹12,34,567.00` in `AppTokens.expense` color, with tabular figures (`FontFeature.tabularFigures()` in the style).
  - Income gives `+` and the income color.
  - The semantics label contains the formatted amount.
- [X] T091 [P] [US5] Widget tests `test/core/widgets/progress_status_test.dart`: `ProgressBarStatus` and `ProgressRing` at ratios 0.5, 0.85, and 1.2 use the success, warning, and expense colors in that order, AND each shows a text label (never color alone).
- [X] T092 [P] [US5] Widget tests `test/core/widgets/period_selector_test.dart`, `numeric_keypad_test.dart`, `app_bottom_sheet_test.dart`, `undo_snack_bar_test.dart`, `confirm_dialog_test.dart`, and `locked_feature_overlay_test.dart`:
  - Arrows and keys are ≥ 48×48 dp and icon buttons have semantic labels.
  - The keypad emits digits, operators, backspace, and done.
  - The bottom sheet has a drag handle, 28 dp top radius, and keyboard inset padding.
  - The undo snackbar lasts 5 s and Undo calls back.
  - `ConfirmDialog.show` returns true or false and the destructive button uses `colorScheme.error`.
  - The overlay shows a lock badge and two actions.
- [X] T093 [P] [US5] Golden tests (tag `golden`) in `test/core/widgets/goldens/shared_widgets_golden_test.dart`: every §15.4 component (AppScaffold, AmountText, CategoryAvatar, SummaryCard, ProgressBarStatus, ProgressRing, PeriodSelector, ChipSelector, NumericKeypad, AppBottomSheet, EmptyState, ErrorState, SkeletonList/SkeletonCard, UndoSnackBar, ConfirmDialog, LockedFeatureOverlay) in light and dark themes, with en text plus one gu variant for text-bearing widgets. Generate the baselines on Linux (research R11).
  - *Done note:* 58 cases (16 components × light/dark, plus gu for the 12 text-bearing ones). `test/flutter_test_config.dart` now also loads the SDK's MaterialIcons font (via `FLUTTER_ROOT`), otherwise icons render as empty boxes. The cases were rendered once on Windows to check they build without errors, then the PNGs were deleted; baselines are T102.
- [X] T094 [P] [US5] Test `test/app/flavor_test.dart`: `FlavorConfig` maps `'prod'` → prod (no debug banner) and anything else → dev. Also scan `lib/` for the pattern `ca-app-pub-` and fail on any match that isn't Google's published test IDs (`ca-app-pub-3940256099942544`).

### Implementation for User Story 5

- [X] T095 [P] [US5] Create `lib/core/widgets/amount_text.dart` (`AmountText`: `amountMinor`, `currencyCode`, `kind` (income/expense/neutral), `showSign`, `style?`). It uses `MoneyFormatter` with the current locale, colors from `AppTokens`, tabular figures, and `Semantics(label: formatted)`. Make T090 pass.
- [X] T096 [P] [US5] Create `lib/core/widgets/progress_status.dart` (`ProgressBarStatus` and `ProgressRing`: `ratio`, `label`). Thresholds: < 0.8 → success, 0.8–1.0 → warning, > 1.0 → expense, with a text label and an icon for the over-budget case. Make T091 pass.
- [X] T097 [P] [US5] Create `lib/core/widgets/period_selector.dart` (`PeriodSelector`: `period` (year, month), `onChanged`, `onPick`; `< Month Year >` with 48 dp `IconButton`s labelled `common_previousMonth` and `common_nextMonth` from T021).
- [X] T098 [P] [US5] Create `lib/core/widgets/numeric_keypad.dart` (`NumericKeypad`: `onKey`, `onBackspace`, `onOperator`, `onDone`). It shows digits 0–9, `.`, `+ − × ÷`, `=`, backspace, and done, sized from tokens with a 48 dp minimum. Expression evaluation stays in `keypad_expression.dart`.
- [X] T099 [P] [US5] Create `lib/core/widgets/app_bottom_sheet.dart` (`AppBottomSheet.show<T>(context, {required String title, required Widget child})`: drag handle, 28 dp top corners via `AppTokens.radiusSheet`, `viewInsets` bottom padding).
- [X] T100 [P] [US5] Create `lib/core/widgets/undo_snack_bar.dart` (`UndoSnackBar.show(context, {required String message, required VoidCallback onUndo})`, 5 s, action label `common_undo` from T021) and `lib/core/widgets/confirm_dialog.dart` (`ConfirmDialog.show(context, {title, consequence, confirmLabel, destructive}) → Future<bool>`).
- [X] T101 [P] [US5] Create `lib/core/widgets/locked_feature_overlay.dart` (`LockedFeatureOverlay`: `child`, `onWatchAd`, `onGetPro`; `ImageFiltered` blur, a lock badge, and two buttons with ARB labels `premium_watchAd` and `premium_getPro` from T021). Make T092 pass.
  - *Done note:* four strings added for these widgets (en/hi/gu, via `tool/l10n/phase0_strings.py`): `common_cancel` (ConfirmDialog), `keypad_backspace` and `keypad_done` (NumericKeypad), `premium_lockedLabel` (overlay lock badge). `UndoSnackBar` sets `persist: false`, since a snackbar with an action no longer auto-dismisses by default. `PeriodSelector.period` is a `DateTime` (only year and month are used). The overlay's blur sigma reuses the `s8` token.
- [ ] T102 [US5] Generate the golden baselines on Linux (CI artifact or WSL) with `flutter test --tags golden --update-goldens`. Commit `test/core/widgets/goldens/*.png`. Make T093 pass.
  - *Blocked note (2026-10-14):* no Linux environment on the dev machine (no WSL distro installed) and no GitHub remote for CI yet. Until the baselines are committed, `flutter test --tags golden` and the CI `flutter test --coverage` step fail on missing goldens. Generate them via WSL (`wsl --install -d Ubuntu`) or a CI run with `--update-goldens`.
- [X] T103 [US5] Create `integration_test/app_smoke_test.dart`: launch `DailyTrackApp` on the dev flavor, complete onboarding with Skip, and assert the Home placeholder and 4 destinations are visible. Then test a restart with the real database: on a fresh install, choose ગુજરાતી and Get started. Pump `const SizedBox()` to dispose the `ProviderScope`, which closes the real database. Pump `ProviderScope(DailyTrackApp)` again with the production providers. Assert the app lands on Home in Gujarati without onboarding (SC-006, end to end). Run with `flutter test integration_test --flavor dev` on an emulator.
  - *Done note:* passed on the Pixel 8a emulator (2026-10-14). `integration_test` (Flutter SDK) was added as a dev dependency. `lib/main.dart` now exposes `productionOverrides()` so the test runs exactly the shipped bindings. Each scenario empties the real database first to simulate a fresh install, and launches wait for the splash to hand over because bootstrap's disk I/O isn't driven by frames.

**Checkpoint**: All five stories are complete. The full suite, including goldens, passes on Linux.

---

## Phase 8: Polish & Cross-Cutting Concerns

- [X] T104 [P] Accessibility pass. Add widget tests in `test/a11y/font_scale_test.dart` that pump SYS-01 error state, every SYS-02 step, SET-06, the 4 placeholders, and `/lock` at `textScaler: TextScaler.linear(2.0)` with a 360×800 surface, in en, hi, and gu, and assert no `RenderFlex overflowed` exceptions. Also add `meetsGuideline(androidTapTargetGuideline)` and `labeledTapTargetGuideline` checks for the same screens.
  - *Done note:* 24 tests (11 screens/states × en/hi/gu, with the four tabs and SET-06 reached through the router). Each one also asserts the screen really sees a 2× text scaler.
- [ ] T105 [P] Performance check: add `test/app/bootstrap_perf_test.dart`, which asserts the in-memory `bootstrap()` (DB open, migrations, seeding, settings) finishes in < 300 ms, using `makeRealContainer` (T059). Manually measure cold start to Home with `flutter run --flavor prod --profile --trace-startup` on a mid-range device. The target is < 1.5 s (SC-002). Record the result in the task summary.
  - *Partly done (2026-10-14):* `bootstrap_perf_test.dart` passes (< 300 ms, timed after one untimed JIT warm-up run because the app ships AOT and the single cold run was flaky under `--coverage`). **Open:** the on-device `--profile --trace-startup` measurement needs a physical mid-range device (profile mode doesn't run on emulators).
- [ ] T110 [P] Screen golden tests (tag `golden`, required by Constitution V via §15.10) in `test/goldens/screens_golden_test.dart`, each in light and dark × en and gu (4 variants), on a 360×800 surface, using `pumpTestApp` with fakes:
  - SYS-01 Splash, initializing state and error state.
  - SYS-02 Onboarding, each of steps 1–4, plus the step 3 "at least one module" message.
  - SET-06 Modules, the default state and the state with Habit disabled.
  - *Partly done (2026-10-14):* `test/goldens/screens_golden_test.dart` has 36 cases (9 states × light/dark × en/gu). They were rendered once on Windows to check them, including that the splash logo is precached so it appears, and the PNGs were deleted. **Open:** generate and commit the baselines on Linux (same blocker as T102).

  Name the tests with their Screen ID, for example `SYS-02 step 3 golden`. Generate the baselines on Linux with `flutter test --tags golden --update-goldens` and commit `test/goldens/*.png`.
- [X] T111 [P] SC-008 extensibility test in `test/app/module_extensibility_test.dart`. Using `pumpTestApp` with a `ModuleRegistry` of the two real modules plus a third `FakeTrackerModule(id: 'notes', rootPath: '/notes', routes: [GoRoute(path: '/notes', ...)])` (and settings `moduleOrder`/`enabledModules` including `'notes'`), assert all of the following with no other code changes. Use a neutral id, not `water` or `period`, because those are the built-in "Coming soon" entries and would show twice.
  - The bottom bar shows Home, Expenses, Habits, Notes, More.
  - Tapping Notes shows its route.
  - SET-06 lists a Notes row with a working toggle and drag handle, and the "Coming soon" section still shows exactly Water and Period.
  - The Home placeholder shows its `dashboardCard()`.
  - Disabling it in SET-06 hides the tab and calls its `onDisable`.
  - *Done note:* also drags Notes above Habit in SET-06 and checks that the tab order follows.

  This also proves the router builds branches from the registry, not from a hard-coded list.
- [ ] T106 Run the §15.10 design review checklist (after T110) for SYS-01, SYS-02, SET-06, and the placeholders. Record the results in `specs/001-foundation/checklists/design-review.md`. Every item must be checked. "Light and dark golden tests pass, in English and Gujarati" is satisfied by T110. Placeholder tab screens and the `/lock` placeholder are reviewed against the justified deviation recorded in `plan.md` Complexity Tracking (no notifier, content and empty states only, and no screen goldens, until EXP-01 T1.3, HAB-01 T2.3, DSH-01 T2.5, SET-01 and SYS-03 T3.1 replace them). For those three items, cite that row in the review and don't mark them as passing. Every other §15.10 item MUST pass for the placeholders now.
  - *Partly done (2026-10-14):* `checklists/design-review.md` is written. Every §15.10 item is checked for SYS-01, SYS-02 and SET-06 except "light and dark goldens", which waits for the T110 baselines. Placeholder deviations are cited as plain lines, not checkboxes. The review also found that SET-06's loading and error states had no tests, so two were added to `modules_screen_test.dart`.
- [X] T107 Coverage check: run `flutter test --coverage` and verify ≥ 80% line coverage for `lib/core/settings/`, `lib/core/database/`, `lib/core/utils/`, and `lib/features/expense/data/`. Add tests where coverage falls short.
  - *Done note:* settings 96.3%, database 95.7%, utils 99.1%, expense data 100%. Drift table DSL files and the production-only `AppDatabase.open()`/`appDatabaseProvider` are marked `coverage:ignore` with a reason (the code generator reads them; the migration and integration tests exercise them). The `onUpgrade` hook is still counted.
- [ ] T108 Run all quality gates from `specs/001-foundation/quickstart.md` §1 and §2 (build_runner, `flutter analyze` zero issues, `dart format --set-exit-if-changed .`, `flutter test`, `make-migrations` with no diff), then the §3 flavor side-by-side install and the §5 manual smoke test. Then check the APK size budget (Constitution V): run `flutter build apk --flavor prod --release --split-per-abi --analyze-size --target-platform android-arm64` and the same for `android-arm` and `android-x64`. Each per-ABI APK MUST be < 25 MB. Record each size and the top contributors from the `--analyze-size` output (expect the Noto fonts to be the largest assets) in the task summary. If any ABI is over budget, stop and raise it before marking the task done.
  - *Partly done (2026-10-14):* build_runner, analyze (0 issues), format (0 changed), `flutter test --exclude-tags golden` (237 passed), make-migrations (no change), side-by-side flavor install on the emulator, and the APK budget (arm64 21.0 / v7a 18.6 / x86_64 22.4 MB) all pass, with results in `summary.md`. **Open:** `flutter test` with goldens (Linux), the quickstart §5 manual smoke test on a device, and the first CI run.
- [ ] T109 Update the `docs/CLAUDE.md` "How to work" section with Phase 0 conventions: run goldens on Linux only, use `pumpTestApp` helpers, and every module must add `Seeder`s through `TrackerModule.seeders`. Mark T0.1–T0.5 done in the `docs/spec.md` §14 checklist. Write the task summary: files changed, tests added, checklist results, and open items (logo artwork, release signing).
  - *Partly done (2026-10-14):* `docs/CLAUDE.md` "How to work" is updated (goldens on Linux only, `pumpTestApp` / `makeRealContainer`, Seeders via `TrackerModule.seeders`, strings via `tool/l10n/phase0_strings.py`), and the summary is in `specs/001-foundation/summary.md`. In `docs/spec.md` §14, T0.3 and T0.4 are checked. **Open:** check T0.1, T0.2 and T0.5 once the goldens and CI are green.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: T001 (spec update) comes first. T002 (git decision) blocks only T013 (CI). All other Setup tasks can start right away.
- **Foundational (Phase 2)**: depends on Setup and BLOCKS all user stories. Inside Phase 2:
  - Theme (T015–T020) and l10n (T021–T022) come first.
  - Utilities (T023–T029) can run in parallel with the DB work.
  - DB (T030–T036) → settings (T037–T040) → modules and router (T041–T046, T053–T059), then T047, which needs the T059 fakes.
  - Widgets (T048–T052) need only theme and l10n.
- **US1 (Phase 3)** and **US2 (Phase 4)**: both start after Phase 2. They edit different files, except `app_router.dart` (T072 and T081), so run those two router tasks one after the other.
- **US3 (Phase 5)**: after Phase 2. T085 also edits `app_router.dart`, so do it after T072 and T081 when stories run in parallel.
- **US4 (Phase 6)**: after Phase 2. Its tab-hiding assertion uses the US3 `AppShell` (T084), so finish US3 first or run T086's nav assertions after T084.
- **US5 (Phase 7)**: after Phase 2. It is independent of US1–US4.
- **Polish (Phase 8)**: after all stories. T110 (screen goldens) and T111 (SC-008 extensibility) come before T106 (design review).

### Within Each User Story

Tests (they fail) → state and controllers → widgets and screens → router wiring → tests pass.

### Parallel Opportunities

- Setup: T005–T011, T013, T014 in parallel after T004.
- Foundational: T015/T016/T019/T020, T023/T024/T026/T028, T030–T033, T037/T038, T041–T044, and T048–T052 are all [P] in their groups.
- US1: T060–T064 together, then T067–T070 together.
- US2: T073–T076 together, then T077–T079 together.
- US5: T090–T094 together, then T095–T101 together.
- Separate stories can run in parallel by different developers. Router edits (T072, T081, T085, T089) are done one at a time.

---

## Parallel Example: User Story 1

```bash
# Tests first (all [P], same file split by test group, or separate files if preferred):
Task: "T060 SYS-02 selected language persists and applies after app restart"
Task: "T061 SYS-02 denying the notification permission does not block onboarding"
Task: "T062 SYS-02 user cannot turn off both modules"
Task: "T064 onboarding controller unit tests"

# Then the step widgets together:
Task: "T067 language_step.dart"   Task: "T068 currency_step.dart"
Task: "T069 modules_step.dart"    Task: "T070 privacy_step.dart"
```

## Parallel Example: User Story 2

```bash
Task: "T073 seed_runner_test.dart"   Task: "T074 bootstrap_test.dart"
Task: "T075 splash_screen_test.dart" Task: "T076 lock_redirect_test.dart"
# then
Task: "T077 seed_runner.dart"  Task: "T078 expense_defaults_seeder.dart"  Task: "T079 seed_names.dart"
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2)

1. Phase 1: Setup (T001 spec update first).
2. Phase 2: Foundational. This is the critical path.
3. Phase 3: US1 Onboarding, then **validate**: fresh install → onboarding → Home in the chosen language.
4. Phase 4: US2 Startup routing, then **validate** all 3 SYS-01 acceptance criteria.
5. Stop for review. One task per session, per CLAUDE.md.

### Incremental Delivery

Setup + Foundational → US1 → US2 (MVP: a runnable first-launch flow) → US3 (navigation) → US4
(SET-06) → US5 (rest of the widget library, goldens, CI green) → Polish. After each phase, run
the quality gates and stop for review.

---

## Notes

- [P] = different files, no dependency on unfinished tasks. Tasks that edit `lib/app/router/app_router.dart` (T055, T072, T081, T085, T089) are deliberately not marked [P] against each other.
- Test names carry the Screen ID for traceability (Constitution I).
- Commit after each task or logical group, once the git repo decision (T002) is made.
- T110 and T111 were added after `/speckit-analyze`. Both run in Phase 8 before T106, which depends on them.
- Don't add packages beyond research.md R1 without updating plan.md (Constitution VII).
