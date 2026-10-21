import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/dashboard_slot.dart';
import 'package:dailytrack/core/widgets/scroll_aware_fab.dart';
import 'package:dailytrack/core/widgets/undo_snack_bar.dart';
import 'package:dailytrack/features/dashboard/presentation/controllers/home_controller.dart';
import 'package:dailytrack/features/dashboard/presentation/widgets/coming_soon_card.dart';
import 'package:dailytrack/features/dashboard/presentation/widgets/home_app_bar.dart';
import 'package:dailytrack/features/dashboard/presentation/widgets/insight_card.dart';
import 'package:dailytrack/features/dashboard/presentation/widgets/quick_add_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// DSH-01 Home (`docs/spec.md` §7, feature 006 contracts/screens.md).
///
/// Top to bottom: module cards in SET-06 order, every visible module's
/// sections, the daily insight, and the Coming soon card. Each slot sits in
/// a [DashboardSlot], so a hidden one leaves no gap. Home reaches modules
/// only through `TrackerModule` (FR-005). No ad slot (feature 008).
class HomeScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final state = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);

    void dismissComingSoon() {
      controller.dismissComingSoon().ignore();
      UndoSnackBar.show(
        context,
        message: l10n.home_comingSoonDismissed,
        onUndo: () => controller.undoDismissComingSoon().ignore(),
      );
    }

    final slots = [
      for (final m in state.modules)
        DashboardSlot(
          key: ValueKey('slot_card_${m.id}'),
          child: KeyedSubtree(
            key: Key('home_card_${m.id}'),
            child: Builder(builder: m.dashboardCard),
          ),
        ),
      for (final m in state.modules)
        for (final section in m.dashboardSections())
          DashboardSlot(
            key: ValueKey('slot_section_${section.id}'),
            child: KeyedSubtree(
              key: Key('home_section_${section.id}'),
              child: Builder(builder: section.build),
            ),
          ),
      DashboardSlot(
        key: const ValueKey('slot_insight'),
        child: InsightCard(insight: state.insight),
      ),
      DashboardSlot(
        key: const ValueKey('slot_coming_soon'),
        child: state.comingSoon.isEmpty
            ? const SizedBox.shrink()
            : ComingSoonCard(
                modules: state.comingSoon,
                onDismiss: dismissComingSoon,
              ),
      ),
    ];

    final scrollView = RefreshIndicator(
      onRefresh: controller.refreshInsights,
      child: CustomScrollView(
        key: const Key('home_scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            // The first slot adds the 12 dp card gap; together 16 dp on top.
            // At the bottom, room for the FAB (56 dp + 16 dp margin).
            padding: EdgeInsets.only(
              top: tokens.s4,
              bottom: state.quickAdds.isEmpty
                  ? tokens.s16
                  : tokens.s48 + tokens.s32,
            ),
            sliver: SliverList.list(children: slots),
          ),
        ],
      ),
    );

    Widget scaffold(Widget? fab) => AppScaffold(
      title: l10n.nav_home,
      titleWidget: HomeAppBarTitle(
        greeting: state.greeting,
        today: state.today,
      ),
      toolbarHeight: HomeAppBarTitle.toolbarHeight(context),
      showBack: false,
      actions: homeBadges(context, state.modules),
      fab: fab,
      body: scrollView,
    );

    if (state.quickAdds.isEmpty) return scaffold(null);
    return ScrollAwareFab(
      fab: QuickAddMenu(actions: state.quickAdds),
      builder: (context, fab) => scaffold(fab),
    );
  }
}
