import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:dailytrack/core/export/export_dataset.dart';
import 'package:dailytrack/core/export/export_document.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock_repository.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/provider_reader.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/settings/domain/export/export_use_case.dart';
import 'package:dailytrack/features/settings/domain/export/pdf_report_builder.dart';
import 'package:dailytrack/features/settings/domain/export/shaped_text_renderer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes.dart';
import 'export_test_documents.dart';

final class _Dataset implements ExportDataset {
  new(this.doc);

  ExportDocument doc;
  StateError? error;

  @override
  String get id => 'transactions';

  @override
  String label(AppLocalizations l10n) => 'Transactions';

  @override
  List<ExportFilterSpec> get filters => const [];

  @override
  Future<ExportDocument> build(
    ExportRequest request,
    ExportContext context,
    ProviderReader read,
  ) async {
    if (error case final e?) throw e;
    return doc;
  }
}

final class _Unlocks implements UnlockRepository {
  final consumed = <FeatureKey>[];

  @override
  Future<bool> consumeOne(FeatureKey key) async {
    consumed.add(key);
    return true;
  }

  @override
  Stream<List<Unlock>> watchLive() => const Stream.empty();

  @override
  Future<Unlock> grant(
    FeatureKey key, {
    required UnlockSource source,
    DateTime? expiresAt,
  }) => throw UnimplementedError();

  @override
  Future<void> revoke(String unlockId) async {}
}

final class _Renderer implements ShapedTextRenderer {
  final texts = <String>[];

  /// A valid 1×1 PNG.
  static final Uint8List png = base64.decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR4nGNgAAIAAAUAAXpe'
    'qz8AAAAASUVORK5CYII=',
  );

  @override
  Future<ShapedImage> render(ShapedTextRequest request) async {
    texts.add(request.text);
    return ShapedImage(png: png, widthPt: 20, heightPt: 8);
  }
}

/// SET-03 export run (feature 008 T089, FR-030 – FR-032, data-model §9,
/// clarification Q2): locked, empty, and failed exports keep a one-time
/// unlock; only a written file uses it up.
void main() {
  late Directory cache;
  late FakeFeatureGate gate;
  late _Unlocks unlocks;
  late _Renderer renderer;
  late _Dataset dataset;

  setUp(() async {
    cache = await Directory.systemTemp.createTemp('export_uc');
    gate = FakeFeatureGate(
      unlocked: {FeatureKey.exportCsv: true, FeatureKey.exportPdf: true},
    );
    unlocks = _Unlocks();
    renderer = _Renderer();
    dataset = _Dataset(sampleDocument());
  });
  tearDown(() => cache.delete(recursive: true));

  ExportUseCase useCase() => ExportUseCase(
    gate: gate,
    unlocks: unlocks,
    cacheDir: () async => cache,
    fonts: () async => PdfFonts(
      regular: File('assets/fonts/NotoSans-Regular.ttf').readAsBytesSync(),
      bold: File('assets/fonts/NotoSans-SemiBold.ttf').readAsBytesSync(),
    ),
    renderer: renderer,
  );

  Future<ExportOutcome> run(ExportFormat format) => useCase().run(
    dataset,
    ExportRequest(
      datasetId: 'transactions',
      period: MonthPeriod(DateTime(2026, 10)),
      format: format,
    ),
    ExportContext(
      l10n: lookupAppLocalizations(const Locale('en')),
      locale: 'en',
      currencyCode: 'INR',
      dateFormat: FullDateFormat.dMMMy,
      clock: Clock.fixed(DateTime(2026, 10, 21)),
    ),
    <T>(p) => throw UnimplementedError(),
  );

  test('SET-03 US5-7 locked: no file and no unlock used', () async {
    gate.set(FeatureKey.exportCsv, unlocked: false);
    expect(await run(ExportFormat.csv), isA<ExportLocked>());
    expect(Directory('${cache.path}/exports').existsSync(), isFalse);
    expect(unlocks.consumed, isEmpty);
  });

  test(
    'SET-03 US5-6 nothing to export: no file and the unlock is kept',
    () async {
      dataset.doc = const ExportDocument(
        title: 't',
        periodLabel: 'p',
        summary: [],
        columns: [],
        rows: [],
      );
      expect(await run(ExportFormat.csv), isA<ExportNothing>());
      expect(unlocks.consumed, isEmpty);
    },
  );

  test('a failure keeps the unlock and shares nothing', () async {
    dataset.error = StateError('disk');
    expect(await run(ExportFormat.csv), isA<ExportFailed>());
    expect(unlocks.consumed, isEmpty);
  });

  test('SET-03 US5-2 Q2 a CSV is written, named by dataset and month, then '
      'one CSV unlock is used', () async {
    final outcome = await run(ExportFormat.csv);
    final ready = outcome as ExportReady;
    expect(ready.path, endsWith('dailytrack_transactions_2026-10.csv'));
    expect(ready.mimeType, 'text/csv');
    expect(File(ready.path).readAsBytesSync().sublist(0, 3), [
      0xEF,
      0xBB,
      0xBF,
    ]);
    expect(unlocks.consumed, [FeatureKey.exportCsv]);
  });

  test('SET-03 US5-3 a PDF sends the Hindi and Gujarati text to the shaping '
      'renderer and uses one PDF unlock', () async {
    final outcome = await run(ExportFormat.pdf) as ExportReady;
    expect(outcome.path, endsWith('.pdf'));
    expect(outcome.mimeType, 'application/pdf');
    expect(
      File(outcome.path).readAsBytesSync().sublist(0, 4),
      '%PDF'.codeUnits,
    );
    expect(renderer.texts, containsAll([gujaratiNote, hindiNote]));
    expect(unlocks.consumed, [FeatureKey.exportPdf]);
  });

  test('a new export replaces the old file', () async {
    final first = await run(ExportFormat.csv) as ExportReady;
    final second = await run(ExportFormat.pdf) as ExportReady;
    expect(File(first.path).existsSync(), isFalse);
    expect(File(second.path).existsSync(), isTrue);
  });

  test('periodSlug names months, years, days, and ranges', () {
    expect(periodSlug(MonthPeriod(DateTime(2026, 9))), '2026-09');
    expect(periodSlug(YearPeriod(DateTime(2026))), '2026');
    expect(periodSlug(SingleDayPeriod(DateTime(2026, 9, 3))), '2026-09-03');
    expect(
      periodSlug(CustomPeriod(DateTime(2026, 9), DateTime(2026, 9, 21))),
      '2026-09-01_2026-09-21',
    );
  });
}
