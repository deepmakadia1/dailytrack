import 'package:flutter/material.dart';

/// The app's root navigator. Full-screen modals (EXP-02, later HAB-02) set
/// it as their `parentNavigatorKey` so they open above the tab shell
/// (research R10). Lives in core so features can use it without importing
/// `app/`.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// The app's root [ScaffoldMessengerState]. Undo snackbars raised while a
/// screen is closing use it, so they never touch a disposed context and stay
/// visible on the screen underneath (research R12).
final GlobalKey<ScaffoldMessengerState> rootMessengerKey =
    GlobalKey<ScaffoldMessengerState>(debugLabel: 'rootMessenger');
