import 'package:dailytrack/app/bootstrap.dart';
import 'package:dailytrack/app/router/app_shell.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/app/splash/splash_screen.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/module/root_navigator.dart';
import 'package:dailytrack/core/security/lock_session.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:dailytrack/features/lock/presentation/pin_flow_mode.dart';
import 'package:dailytrack/features/lock/presentation/screens/pin_screen.dart';
import 'package:dailytrack/features/lock/presentation/screens/unlock_screen.dart';
import 'package:dailytrack/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:dailytrack/features/settings/presentation/controllers/web_page_controller.dart';
import 'package:dailytrack/features/settings/presentation/screens/backup_screen.dart';
import 'package:dailytrack/features/settings/presentation/screens/export_screen.dart';
import 'package:dailytrack/features/settings/presentation/screens/modules_screen.dart';
import 'package:dailytrack/features/settings/presentation/screens/security_screen.dart';
import 'package:dailytrack/features/settings/presentation/screens/settings_screen.dart';
import 'package:dailytrack/features/settings/presentation/screens/themes_screen.dart';
import 'package:dailytrack/features/settings/presentation/screens/web_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// The app router (contracts/routes.md). Branches are built once from the
/// module registry; redirects re-run whenever startup state or settings
/// change.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final registry = ref.read(moduleRegistryProvider);
  final refresh = ValueNotifier<int>(0);
  ref
    ..listen(bootstrapProvider, (_, _) => refresh.value++)
    ..listen(appSettingsProvider, (_, _) => refresh.value++)
    // Locking and unlocking re-run the lock rules (feature 007).
    ..listen(
      lockSessionProvider.select((s) => (s.locked, s.mode)),
      (_, _) => refresh.value++,
    )
    ..onDispose(refresh.dispose);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(lockSessionProvider);
      return redirectFor(
        location: state.matchedLocation,
        uri: state.uri,
        bootstrap: ref.read(bootstrapProvider),
        settings: ref.read(appSettingsProvider).value,
        registry: registry,
        sessionLocked: session.locked,
        sessionMode: session.mode,
        coveredLocation: session.coveredLocation,
      );
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      // SYS-03 as a route: cold start, or a navigation while locked.
      GoRoute(
        path: Routes.lock,
        name: RouteNames.lock,
        builder: (context, state) => UnlockScreen(
          mode: LockMode.route,
          from: state.uri.queryParameters['from'],
        ),
      ),
      // SYS-04, full screen above everything (SET-05, SYS-02 step 4).
      GoRoute(
        path: Routes.pin,
        name: RouteNames.pin,
        builder: (context, state) => PinScreen(
          mode: PinFlowMode.fromQuery(state.uri),
          from: state.uri.queryParameters['from'],
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                name: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          for (final module in registry.all)
            StatefulShellBranch(routes: module.routes),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.more,
                name: RouteNames.more,
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: Routes.modulesSegment,
                    name: RouteNames.modules,
                    builder: (context, state) => const ModulesScreen(),
                  ),
                  GoRoute(
                    path: Routes.themesSegment,
                    name: RouteNames.themes,
                    builder: (context, state) => const ThemesScreen(),
                  ),
                  GoRoute(
                    path: Routes.securitySegment,
                    name: RouteNames.security,
                    builder: (context, state) => const SecurityScreen(),
                  ),
                  GoRoute(
                    path: Routes.backupSegment,
                    name: RouteNames.backup,
                    builder: (context, state) => const BackupScreen(),
                  ),
                  // Full screen above the shell, so EXP-11 can push it and
                  // back returns to Reports (feature 008 contracts/routes.md).
                  GoRoute(
                    path: Routes.exportSegment,
                    name: RouteNames.export,
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) {
                      final q = state.uri.queryParameters;
                      final period = {
                        for (final k in const ['kind', 'start', 'end'])
                          k: ?q[k],
                      };
                      return ExportScreen(
                        datasetId: q['dataset'],
                        periodQuery: period.length == 3
                            ? Uri(queryParameters: period).query
                            : null,
                      );
                    },
                  ),
                  // Full screen above the shell; an unknown page goes back
                  // to SET-01.
                  GoRoute(
                    path: Routes.webPageSegment,
                    name: RouteNames.webPage,
                    parentNavigatorKey: rootNavigatorKey,
                    redirect: (context, state) =>
                        webPageUrl(state.pathParameters['page'] ?? '') == null
                        ? Routes.more
                        : null,
                    builder: (context, state) {
                      final page = state.pathParameters['page']!;
                      return WebPageScreen(page: page, url: webPageUrl(page)!);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}

/// Redirect rules from contracts/routes.md, as a pure function so they can be
/// unit tested.
///
/// [location] is the matched path; [uri] the full location with its query
/// (defaults to [location]). The lock rules (feature 007 contracts/routes.md)
/// read the session: [sessionLocked], [sessionMode], and [coveredLocation],
/// the location the resume overlay is covering.
String? redirectFor({
  required String location,
  required AsyncValue<BootstrapResult> bootstrap,
  required AppSettings? settings,
  required ModuleRegistry registry,
  Uri? uri,
  bool sessionLocked = false,
  LockMode sessionMode = LockMode.route,
  String? coveredLocation,
}) {
  final result = bootstrap.value;
  final full = uri ?? Uri(path: location);

  // Rules 1 and 2: stay on the splash until startup succeeds (a failure is
  // rendered by the splash itself). Once ready, leave the splash for the
  // first screen startup chose.
  if (result is! BootstrapReady || settings == null) {
    return location == Routes.splash ? null : Routes.splash;
  }
  if (location == Routes.splash) return result.initialLocation;

  // Rule 3: onboarding comes first. SYS-02 step 4 may open SYS-04 to set a
  // PIN (research R10).
  final settingPin =
      location == Routes.pin &&
      const [
        Routes.pinModeSet,
        Routes.pinModeChange,
      ].contains(full.queryParameters['mode']);
  if (!settings.onboardingDone &&
      location != Routes.onboarding &&
      !settingPin) {
    return Routes.onboarding;
  }

  final locked = settings.onboardingDone && settings.lockEnabled;

  // Rule 4b: leave SYS-03 once unlocked, or when erase turned the lock off.
  if (location == Routes.lock && (!locked || !sessionLocked)) {
    return full.queryParameters['from'] ?? Routes.home;
  }

  // Rule 4: while locked, every location shows SYS-03 first and opens
  // after unlocking. The location the resume overlay covers stays as it is,
  // so its screens and unsaved input survive (clarification Q4).
  if (locked && sessionLocked && location != Routes.lock) {
    final here = full.toString();
    final covered = sessionMode == LockMode.overlay && here == coveredLocation;
    if (!covered) return Routes.lockPath(from: here);
  }

  // Rule 5: a disabled module's routes are unreachable.
  final owner = registry.owning(location);
  if (owner != null && !settings.enabledModules.contains(owner.id)) {
    return Routes.home;
  }

  // Rule 6: once onboarding is done, leave it for Home.
  if (settings.onboardingDone && location == Routes.onboarding) {
    return Routes.home;
  }
  return null;
}
