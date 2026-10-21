import 'package:dailytrack/core/theme/app_colors.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

void main() {
  testWidgets('is a 40 dp circle with a 24 dp icon and a semantic label', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(
        Center(
          child: CategoryAvatar(
            icon: Icons.restaurant,
            color: AppColors.palette.first,
            semanticLabel: 'Food',
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(CategoryAvatar)), const Size(40, 40));
    expect(tester.widget<Icon>(find.byType(Icon)).size, 24);
    expect(find.bySemanticsLabel('Food'), findsOneWidget);
  });
}
