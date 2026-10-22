import 'dart:async';

import 'package:dailytrack/app/app_open_runner.dart';
import 'package:dailytrack/app/background_entry_points.dart';
import 'package:dailytrack/app/flavor.dart';
import 'package:dailytrack/app/router/app_router.dart';
import 'package:dailytrack/app/router/lock_back_button_dispatcher.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/root_navigator.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:dailytrack/core/security/lock_session.dart';
import 'package:dailytrack/core/security/secure_screen_service.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/theme/app_text_scaler.dart';
import 'package:dailytrack/core/theme/app_theme.dart';
import 'package:dailytrack/core/theme/color_themes.dart';
import 'package:dailytrack/core/theme/theme_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/widget/widget_providers.dart';
import 'package:dailytrack/core/widgets/full_date_format_scope.dart';
import 'package:dailytrack/features/lock/presentation/screens/unlock_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyTrackApp extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<DailyTrackApp> createState() => _DailyTrackAppState();
}

class _DailyTrackAppState extends ConsumerState<DailyTrackApp> {
  late final AppLifecycleListener _lifecycle;
  late final LockAwareBackButtonDispatcher _back;
  final GlobalKey<NavigatorState> _lockNavigator = GlobalKey<NavigatorState>(
    debugLabel: 'lockOverlay',
  );
  StreamSubscription<String>? _taps;
  StreamSubscription<String>? _widgetLaunches;
  StreamSubscription<NotificationActionEvent>? _actions;

  LockSession get _session => ref.read(lockSessionProvider.notifier);

  DateTime _now() => ref.read(clockProvider).now();

  /// Where the router is now, as the redirect sees it.
  String _location() => ref
      .read(appRouterProvider)
      .routerDelegate
      .currentConfiguration
      .uri
      .toString();

  @override
  void initState() {
    super.initState();
    _back = LockAwareBackButtonDispatcher(
      isLocked: () => ref.read(lockSessionProvider).locked,
    );
    _lifecycle = AppLifecycleListener(
      // App lock: note when the app leaves the screen, and lock on the way
      // back after "Lock after" (feature 007 research R7).
      onHide: () => _session.markBackgrounded(_now(), location: _location()),
      onResume: () {
        _session.onResumed(_now(), location: _location());
        // Every resume counts as an app open (feature 003 research R10).
        unawaited(ref.read(appOpenRunnerProvider).run());
      },
    );
    // A notification or widget tapped while the app runs opens its
    // location; the router's redirects still apply (disabled modules).
    // While locked it waits until after unlocking, so the screens under
    // the lock are kept (feature 008 R20 for the widget).
    final notifications = ref.read(notificationServiceProvider);
    _taps = notifications.taps.listen(_open, onError: (Object _) {});
    _widgetLaunches = ref
        .read(homeWidgetBridgeProvider)
        .launches
        .listen(_open, onError: (Object _) {});
    // A reminder button tapped while the app runs: handled like in the
    // background, with no navigation and no unlock (feature 008 R16).
    _actions = notifications.actions.listen(
      (e) =>
          unawaited(handleNotificationAction(e.actionId, e.payload, ref.read)),
      onError: (Object _) {},
    );
    ref
      // After unlocking, open what a notification asked for.
      ..listenManual(lockSessionProvider, (previous, next) {
        final pending = previous?.pendingLocation;
        if (previous != null &&
            previous.locked &&
            !next.locked &&
            pending != null) {
          ref.read(appRouterProvider).go(pending);
        }
      })
      // FLAG_SECURE follows SYS-03 and "Hide app content in recents".
      ..listenManual(secureScreenControllerProvider, (_, _) {});
  }

  void _open(String location) {
    if (!location.startsWith('/')) return;
    if (ref.read(lockSessionProvider).locked) {
      _session.deferLocation(location);
    } else {
      ref.read(appRouterProvider).go(location);
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    unawaited(_taps?.cancel());
    unawaited(_widgetLaunches?.cancel());
    unawaited(_actions?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(appSettingsProvider).value;
    final session = ref.watch(lockSessionProvider);
    // After a resume, SYS-03 covers the app instead of replacing it, so the
    // open screens and unsaved input survive (clarification Q4).
    final covering = session.locked && session.mode == LockMode.overlay;
    final code = settings?.locale;
    // SET-04: the effective color theme (Default teal while a premium one is
    // locked) and font size (feature 007 research R11).
    final seed =
        (ref.watch(effectiveColorThemeProvider).value ?? appColorThemes.first)
            .seed;
    final large = settings?.fontSize == 'large';
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      backButtonDispatcher: _back,
      scaffoldMessengerKey: rootMessengerKey,
      theme: AppTheme.light(seed: seed),
      darkTheme: AppTheme.dark(seed: seed),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: appTextScaler(media.textScaler, large: large),
          ),
          // SET-01 date format for every full date (feature 007 R13).
          child: FullDateFormatScope(
            format: FullDateFormat.fromStorage(settings?.dateFormat ?? ''),
            // The same tree whether or not SYS-03 covers the app, so the
            // router below never loses its state. Offstage keeps it mounted
            // but unpainted, untappable, and hidden from TalkBack.
            child: Stack(
              fit: StackFit.expand,
              children: [
                Offstage(
                  offstage: covering,
                  child: child ?? const SizedBox.shrink(),
                ),
                // Its own navigator, so "Forgot PIN?" can open sheets and
                // dialogs while the router below stays untouched.
                if (covering)
                  Navigator(
                    key: _lockNavigator,
                    onGenerateRoute: (_) => PageRouteBuilder<void>(
                      pageBuilder: (_, _, _) =>
                          const UnlockScreen(mode: LockMode.overlay),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      themeMode: switch (settings?.themeMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      // Null follows the device language (resolved below).
      locale: code == null ? null : Locale(code),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      localeResolutionCallback: resolveLocale,
      debugShowCheckedModeBanner: FlavorConfig.current.showDebugBanner,
    );
  }
}

/// Device language if the app supports it (en, hi, gu), otherwise English.
Locale resolveLocale(Locale? device, Iterable<Locale> supported) {
  final code = device?.languageCode;
  return supportedLanguageCodes.contains(code)
      ? Locale(code!)
      : const Locale('en');
}
