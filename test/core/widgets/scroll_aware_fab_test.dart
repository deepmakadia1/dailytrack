import 'package:dailytrack/core/widgets/scroll_aware_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

/// ScrollAwareFab (T011, feature 006 research R12): hides on scroll down,
/// returns on scroll up.
void main() {
  Widget app({bool disableAnimations = false}) => themed(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: ScrollAwareFab(
        fab: FloatingActionButton(
          key: const Key('fab'),
          tooltip: 'Quick add',
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
        builder: (context, fab) => Scaffold(
          floatingActionButton: fab,
          body: ListView(
            children: [
              for (var i = 0; i < 60; i++)
                SizedBox(height: 60, child: Text('row $i')),
            ],
          ),
        ),
      ),
    ),
    wrapInScaffold: false,
  );

  bool shown(WidgetTester tester) =>
      tester
          .widget<AnimatedOpacity>(
            find.ancestor(
              of: find.byKey(const Key('fab')),
              matching: find.byType(AnimatedOpacity),
            ),
          )
          .opacity ==
      1;

  void notify(WidgetTester tester, ScrollDirection direction) {
    final element = tester.element(find.text('row 0'));
    final position = Scrollable.of(element).position;
    UserScrollNotification(
      metrics: position.copyWith(),
      context: element,
      direction: direction,
    ).dispatch(element);
  }

  testWidgets('hides after a reverse scroll and shows after a forward one', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    expect(shown(tester), isTrue);
    notify(tester, ScrollDirection.reverse);
    await tester.pumpAndSettle();
    expect(shown(tester), isFalse);
    notify(tester, ScrollDirection.forward);
    await tester.pumpAndSettle();
    expect(shown(tester), isTrue);
  });

  testWidgets('a real drag down hides it', (tester) async {
    await tester.pumpWidget(app());
    await tester.drag(find.text('row 3'), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(shown(tester), isFalse);
  });

  testWidgets('a hidden FAB ignores taps', (tester) async {
    await tester.pumpWidget(app());
    notify(tester, ScrollDirection.reverse);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<IgnorePointer>(
            find
                .ancestor(
                  of: find.byKey(const Key('fab')),
                  matching: find.byType(IgnorePointer),
                )
                .first,
          )
          .ignoring,
      isTrue,
    );
  });

  testWidgets('has a 48 dp+ target and a label', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(app());
    final size = tester.getSize(find.byKey(const Key('fab')));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
    expect(
      tester
          .getSemantics(find.byKey(const Key('fab')))
          .getSemanticsData()
          .tooltip,
      'Quick add',
    );
    semantics.dispose();
  });

  testWidgets('uses no animation when disableAnimations is set', (
    tester,
  ) async {
    await tester.pumpWidget(app(disableAnimations: true));
    notify(tester, ScrollDirection.reverse);
    await tester.pump();
    final opacity = tester.widget<AnimatedOpacity>(
      find.ancestor(
        of: find.byKey(const Key('fab')),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    expect(opacity.duration, Duration.zero);
    expect(opacity.opacity, 0);
  });
}
