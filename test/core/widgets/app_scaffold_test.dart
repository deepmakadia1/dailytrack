import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

void main() {
  Future<void> pumpAt(WidgetTester tester, Size size, Widget child) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(themed(child, wrapInScaffold: false));
  }

  const marker = Key('body');

  testWidgets('pads 16 dp on phones', (tester) async {
    await pumpAt(
      tester,
      const Size(360, 800),
      const AppScaffold(
        title: 'T',
        body: SizedBox.expand(key: marker),
      ),
    );
    expect(tester.getTopLeft(find.byKey(marker)).dx, 16);
    expect(tester.getSize(find.byKey(marker)).width, 360 - 32);
  });

  testWidgets('pads 24 dp and caps content at 600 dp on wide screens', (
    tester,
  ) async {
    await pumpAt(
      tester,
      const Size(900, 800),
      const AppScaffold(
        title: 'T',
        body: SizedBox.expand(key: marker),
      ),
    );
    expect(tester.getSize(find.byKey(marker)).width, 600 - 48);
    expect(tester.getCenter(find.byKey(marker)).dx, 450);
  });

  testWidgets(
    'shows the title, and the banner slot takes no space when empty',
    (tester) async {
      await pumpAt(
        tester,
        const Size(360, 800),
        const AppScaffold(
          title: 'Modules',
          body: SizedBox.expand(key: marker),
        ),
      );
      expect(find.text('Modules'), findsOneWidget);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNull);
    },
  );

  testWidgets('places the FAB above the banner slot', (tester) async {
    const banner = SizedBox(key: Key('banner'), height: 50);
    await pumpAt(
      tester,
      const Size(360, 800),
      AppScaffold(
        title: 'T',
        body: const SizedBox.expand(),
        bannerSlot: banner,
        fab: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ),
    );
    final fabBottom = tester
        .getBottomLeft(find.byType(FloatingActionButton))
        .dy;
    final bannerTop = tester.getTopLeft(find.byKey(const Key('banner'))).dy;
    expect(fabBottom, lessThanOrEqualTo(bannerTop));
  });

  testWidgets('bottomBar stays at the bottom and snackbars appear above it', (
    tester,
  ) async {
    const bar = Key('bottom_bar');
    await pumpAt(
      tester,
      const Size(360, 800),
      AppScaffold(
        title: 'Form',
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Saved'))),
            child: const Text('show'),
          ),
        ),
        bottomBar: const SizedBox(key: bar, height: 56, width: 100),
      ),
    );
    final barTop = tester.getTopLeft(find.byKey(bar)).dy;
    expect(tester.getBottomLeft(find.byKey(bar)).dy, 800);

    await tester.tap(find.text('show'));
    await tester.pumpAndSettle();
    expect(
      tester.getBottomLeft(find.byType(SnackBar)).dy,
      lessThanOrEqualTo(barTop),
      reason: 'a snackbar never covers the sticky Save button',
    );
  });

  testWidgets('bottomBar is lifted above the keyboard', (tester) async {
    const bar = Key('bottom_bar');
    tester.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1
      ..viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      themed(
        const AppScaffold(
          title: 'Form',
          body: SizedBox(),
          bottomBar: SizedBox(key: bar, height: 56, width: 100),
        ),
        wrapInScaffold: false,
      ),
    );
    expect(tester.getBottomLeft(find.byKey(bar)).dy, 500);
  });
}
