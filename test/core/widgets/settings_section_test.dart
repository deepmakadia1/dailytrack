import 'package:dailytrack/core/widgets/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

/// SettingsSection (feature 007 T022).
void main() {
  testWidgets('shows the title as a semantics header above its rows', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      themed(
        const SettingsSection(
          title: 'General',
          children: [
            ListTile(title: Text('Language')),
            ListTile(title: Text('Currency')),
          ],
        ),
      ),
    );
    expect(
      tester.getSemantics(find.text('General')),
      matchesSemantics(label: 'General', isHeader: true),
    );
    expect(
      tester.getTopLeft(find.text('General')).dy,
      lessThan(tester.getTopLeft(find.text('Language')).dy),
    );
    expect(find.text('Currency'), findsOneWidget);
    handle.dispose();
  });
}
