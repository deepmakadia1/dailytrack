import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/widgets/undo_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

void main() {
  late int undos;

  Future<void> show(WidgetTester tester) async {
    undos = 0;
    await tester.pumpWidget(
      themed(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => UndoSnackBar.show(
              context,
              message: 'Deleted',
              onUndo: () => undos++,
            ),
            child: const Text('delete'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('delete'));
    await tester.pumpAndSettle();
  }

  testWidgets('Undo calls back', (tester) async {
    await show(tester);
    expect(find.text('Deleted'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(undos, 1);
  });

  testWidgets('lasts 5 seconds, then hides itself', (tester) async {
    await show(tester);
    final bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(bar.duration, const Duration(seconds: 5));

    await tester.pump(const Duration(milliseconds: 4900));
    expect(find.text('Deleted'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(find.text('Deleted'), findsNothing);
    expect(undos, 0);
  });

  testWidgets('with a messenger it outlives the route that raised it', (
    tester,
  ) async {
    final messengerKey = GlobalKey<ScaffoldMessengerState>();
    var undone = 0;
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: messengerKey,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => Scaffold(
                    body: TextButton(
                      onPressed: () {
                        UndoSnackBar.show(
                          context,
                          message: 'Saved',
                          onUndo: () => undone++,
                          messenger: messengerKey.currentState,
                        );
                        Navigator.of(context).pop();
                      },
                      child: const Text('save'),
                    ),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();

    expect(find.text('save'), findsNothing, reason: 'the route was popped');
    expect(find.text('Saved'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    expect(undone, 1);
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  });
}
