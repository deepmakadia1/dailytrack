import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation around the tab branches (spec §5, §15.3,
/// contracts/routes.md "Shell").
///
/// Branches are fixed at `[home, ...registry.all, more]`. Destinations are
/// `[Home, ...registry.visible(settings), More]`, so a destination index
/// maps to a branch index through [_branchesFor].
class AppShell extends ConsumerWidget {
  const new({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const int _homeBranch = 0;

  /// Branch index of each visible destination, in display order.
  static List<int> _branchesFor(ModuleRegistry registry, AppSettings settings) {
    final all = registry.all;
    return [
      _homeBranch,
      for (final module in registry.visible(settings)) 1 + all.indexOf(module),
      1 + all.length,
    ];
  }

  void _goBranch(int branch) => navigationShell.goBranch(
    branch,
    // Tapping the active tab pops it back to its root.
    initialLocation: branch == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final registry = ref.watch(moduleRegistryProvider);
    final settings =
        ref.watch(appSettingsProvider).value ?? const AppSettings();
    final branches = _branchesFor(registry, settings);
    final current = navigationShell.currentIndex;
    // A disabled module's branch can be current for one frame before
    // redirect rule 5 moves to Home; show Home selected meanwhile.
    final selected = branches.indexOf(current).clamp(0, branches.length - 1);

    return PopScope(
      // Back on another tab's root goes Home; on Home the app exits. Pushed
      // screens inside a branch are popped by its own navigator first.
      canPop: current == _homeBranch,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigationShell.goBranch(_homeBranch);
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          height: tokens.navBarHeight,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          selectedIndex: selected,
          onDestinationSelected: (i) => _goBranch(branches[i]),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l10n.nav_home,
            ),
            for (final module in registry.visible(settings))
              NavigationDestination(
                icon: Icon(module.icon),
                selectedIcon: Icon(module.selectedIcon),
                label: module.tabLabel(context),
              ),
            NavigationDestination(
              icon: const Icon(Icons.more_horiz),
              selectedIcon: const Icon(Icons.more_horiz),
              label: l10n.nav_more,
            ),
          ],
        ),
      ),
    );
  }
}
