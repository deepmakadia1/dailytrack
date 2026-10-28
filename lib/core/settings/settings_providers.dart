import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/domain/settings_repository.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_providers.g.dart';

/// Typed to the domain interface and free of data/ and Drift imports, so
/// presentation code can depend on it (Constitution II).
/// `production_overrides.dart` binds the Drift implementation; tests bind fakes
/// or use `makeRealContainer`.
@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) =>
    throw UnimplementedError('settingsRepositoryProvider must be overridden');

/// Live settings; the locale, router and navigation bar rebuild from this.
@Riverpod(keepAlive: true)
Stream<AppSettings> appSettings(Ref ref) =>
    ref.watch(settingsRepositoryProvider).watch();

/// The SET-01 full-date format, for code without a `BuildContext` (e.g.
/// share text). Widgets use `FullDateFormatScope.of(context)`.
@Riverpod(keepAlive: true)
FullDateFormat fullDateFormat(Ref ref) => FullDateFormat.fromStorage(
  ref.watch(appSettingsProvider.select((s) => s.value?.dateFormat ?? '')),
);

/// The sign-in mode (feature 011 research R6); `none` until settings load.
/// The router, the lock session, and SET-01 read it.
@Riverpod(keepAlive: true)
AuthMode authMode(Ref ref) => ref.watch(
  appSettingsProvider.select((s) => s.value?.authMode ?? AuthMode.none),
);
