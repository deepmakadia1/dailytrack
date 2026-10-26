import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/ads/domain/ad_screen_probe.dart';
import 'package:flutter/widgets.dart';

/// Screens that never get a full-screen ad over them: forms, lock,
/// onboarding, PIN, and premium (spec §11, contracts/routes.md). Every
/// other screen, Home included, is a reading screen (clarification Q1).
bool isReadingLocation(String path) {
  const blocked = {
    Routes.splash,
    Routes.onboarding,
    Routes.lock,
    Routes.premium,
    Routes.pin,
  };
  if (blocked.contains(path)) return false;
  // Add and edit forms (EXP-02, HAB-02, the recurring rule editor).
  return !(path.endsWith('/add') || path.endsWith('/edit'));
}

/// [AdScreenProbe] over the router location, the lock session, and the
/// app lifecycle (feature 009 research R10).
final class RouterAdScreenProbe implements AdScreenProbe {
  new({required this.location, required this.locked});

  /// The current router path, without query.
  final String Function() location;
  final bool Function() locked;

  @override
  bool get canShowFullScreenAd {
    final state = WidgetsBinding.instance.lifecycleState;
    if (state != null && state != AppLifecycleState.resumed) return false;
    if (locked()) return false;
    return isReadingLocation(location());
  }
}
