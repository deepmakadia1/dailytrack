import 'package:dailytrack/core/security/external_activity_guard.dart';
import 'package:dailytrack/core/share/image_sharer.dart';
import 'package:dailytrack/core/share/text_sharer.dart';
import 'package:dailytrack/core/support/app_review_service.dart';
import 'package:dailytrack/core/support/external_launcher.dart';
import 'package:dailytrack/features/expense/data/receipts/image_receipt_picker.dart';
import 'package:dailytrack/features/expense/expense_bindings.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every way out of the app tells the lock first, so the trip does not
/// lock the app (feature 007 T035, research R15).
void main() {
  late int calls;
  late ProviderContainer container;

  setUp(() {
    calls = 0;
    container = ProviderContainer(
      overrides: [
        ...expenseOverrides(),
        externalActivityGuardProvider.overrideWithValue(
          ExternalActivityGuard(() => calls++),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  test('the text sharer calls the guard', () {
    (container.read(
      textSharerProvider,
    ) as SharePlusTextSharer).beforeLeaving!();
    expect(calls, 1);
  });

  test('the image sharer calls the guard', () {
    (container.read(
      imageSharerProvider,
    ) as SharePlusImageSharer).beforeLeaving!();
    expect(calls, 1);
  });

  test('the in-app review calls the guard', () {
    (container.read(
      appReviewServiceProvider,
    ) as PlayAppReviewService).beforeLeaving!();
    expect(calls, 1);
  });

  test('the external launcher calls the guard', () {
    (container.read(
      externalLauncherProvider,
    ) as UrlLauncherExternalLauncher).beforeLeaving!();
    expect(calls, 1);
  });

  test('the receipt picker calls the guard', () {
    (container.read(
      receiptPickerProvider,
    ) as ImageReceiptPicker).beforeLeaving!();
    expect(calls, 1);
  });
}
