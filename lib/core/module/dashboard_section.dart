import 'package:flutter/widgets.dart';

/// An extra Home section a module shows below all module cards
/// (`TrackerModule.dashboardSections()`, feature 006 data-model.md §2).
final class DashboardSection {
  const new({required this.id, required this.build});

  /// Unique app-wide (`expense.recentTransactions`). Used as the widget key.
  final String id;

  /// Returns the section, or `SizedBox.shrink()` when it has nothing to
  /// show. Adds no outer spacing: Home's slot adds the gap.
  final WidgetBuilder build;
}
