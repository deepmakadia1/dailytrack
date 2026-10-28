import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/features/account/presentation/screens/account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../features/account/account_test_app.dart';
import '../../features/expense/expense_test_app.dart';

/// The ACC-01 route (feature 010 T058, spec §5, contracts/routes.md):
/// `/more/account`, pushed in the More tab.
void main() {
  testWidgets('ACC-01 /more/account opens in the More tab, and back returns '
      'to More', (tester) async {
    await pumpAccountApp(tester);
    expect(find.byType(AccountScreen), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      3,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(locationOf(tester), Routes.more);
  });

  testWidgets('SET-02 the Drive card email opens ACC-01', (tester) async {
    await pumpAccountApp(tester, location: Routes.backup);
    await tapKey(tester, 'backup_account');
    expect(find.byType(AccountScreen), findsOneWidget);
  });
}
