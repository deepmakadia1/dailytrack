import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/features/onboarding/presentation/controllers/onboarding_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Moved to core for SET-01 (feature 007 T052); re-exported for callers.
export 'package:dailytrack/core/utils/currencies.dart' show filterCurrencies;

part 'onboarding_controller.g.dart';

const String atLeastOneModuleKey = 'onboarding_atLeastOneModule';
const String saveErrorKey = 'onboarding_saveError';

/// SYS-02 Onboarding controller (T066). Depends only on domain interfaces
/// and providers.
@riverpod
class OnboardingController extends _$OnboardingController {
  /// Which save to repeat on "Retry": skip with defaults, or complete.
  bool _lastSaveWasSkip = false;

  @override
  OnboardingState build() {
    // Read once, never watch: choosing a language writes settings, and the
    // user's progress must survive that (spec edge case).
    final settings = ref.read(appSettingsProvider).value ?? const AppSettings();
    return OnboardingState(
      languageCode: settings.locale,
      currencyCode: settings.currencyCode,
      moduleOrder: settings.moduleOrder,
      enabledModules: settings.enabledModules,
    );
  }

  void next() {
    if (state.step < OnboardingState.stepCount) {
      state = state.copyWith(step: state.step + 1, moduleMessageKey: null);
    }
  }

  void back() {
    if (state.step > 1) {
      state = state.copyWith(step: state.step - 1, moduleMessageKey: null);
    }
  }

  /// Applies the new language right away so the UI switches instantly.
  Future<void> selectLanguage(String code) async {
    state = state.copyWith(languageCode: code);
    await ref.read(settingsRepositoryProvider).setLocale(code);
  }

  void selectCurrency(String code) =>
      state = state.copyWith(currencyCode: code);

  void setQuery(String query) => state = state.copyWith(query: query);

  /// Turns a module on or off. Refuses to turn off the last enabled one.
  void toggleModule(String id) {
    final enabled = [...state.enabledModules];
    if (enabled.contains(id)) {
      if (enabled.length == 1) {
        state = state.copyWith(moduleMessageKey: atLeastOneModuleKey);
        return;
      }
      enabled.remove(id);
    } else {
      enabled.add(id);
    }
    state = state.copyWith(enabledModules: enabled, moduleMessageKey: null);
  }

  /// Asks for notification permission. Denial or a plugin failure is a
  /// normal result and never blocks onboarding.
  Future<void> requestNotifications() async {
    final permission = ref.read(notificationPermissionProvider);
    bool granted;
    try {
      granted = await permission.request();
    } on Object {
      granted = false;
    }
    state = state.copyWith(notificationsGranted: granted);
  }

  /// "Skip" on steps 1–2: device language, INR, every module on.
  Future<void> skip() async {
    if (!state.canSkip) return;
    _lastSaveWasSkip = true;
    final ids = ref.read(moduleRegistryProvider).ids;
    await _save(
      OnboardingChoices(
        locale: null,
        currencyCode: 'INR',
        moduleOrder: ids,
        enabledModules: ids,
      ),
    );
  }

  /// "Get started" on step 4.
  Future<void> complete() async {
    _lastSaveWasSkip = false;
    await _save(
      OnboardingChoices(
        locale: state.languageCode,
        currencyCode: state.currencyCode,
        moduleOrder: state.moduleOrder,
        enabledModules: state.enabledModules,
      ),
    );
  }

  /// Repeats the save that failed.
  Future<void> retrySave() => _lastSaveWasSkip ? skip() : complete();

  Future<void> _save(OnboardingChoices choices) async {
    if (state.saving) return;
    state = state.copyWith(saving: true, saveErrorKey: null);
    try {
      await ref.read(settingsRepositoryProvider).completeOnboarding(choices);
      // The router leaves /onboarding for AUTH-01 once settings report it
      // done (feature 011).
      if (ref.mounted) state = state.copyWith(saving: false);
    } on Object {
      if (ref.mounted) {
        state = state.copyWith(saving: false, saveErrorKey: saveErrorKey);
      }
    }
  }
}
