import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Architecture and styling guard rails (Constitution II and V, tasks T020).
/// These scan source text, so they also catch code no other test exercises.

List<File> _dartFiles(String dir) {
  final root = Directory(dir);
  if (!root.existsSync()) return const [];
  return root
      .listSync(recursive: true)
      .whereType<File>()
      .where(
        (f) =>
            f.path.endsWith('.dart') &&
            !f.path.endsWith('.g.dart') &&
            !f.path.endsWith('.freezed.dart'),
      )
      .toList();
}

String _rel(File f) => f.path.replaceAll(r'\', '/');

List<String> _importsOf(File f) => RegExp(
  r'''^import\s+'([^']+)';''',
  multiLine: true,
).allMatches(f.readAsStringSync()).map((m) => m.group(1)!).toList();

void main() {
  final styledFiles = [
    ..._dartFiles('lib/features'),
    ..._dartFiles('lib/core/widgets'),
    ..._dartFiles('lib/app'),
  ];

  test('no hard-coded colors or raw paddings outside app_colors.dart', () {
    final colorLiteral = RegExp(r'Color\(0x|\bColors\.');
    final rawPadding = RegExp(
      r'EdgeInsets\.(all|symmetric|only|fromLTRB)\(\s*(\w+:\s*)?\d',
    );
    // Self-check: catches raw colors but not the AppColors design system.
    expect(colorLiteral.hasMatch('color: Colors.red'), isTrue);
    expect(colorLiteral.hasMatch('Color(0xFF000000)'), isTrue);
    expect(colorLiteral.hasMatch('AppColors.palette'), isFalse);
    expect(rawPadding.hasMatch('EdgeInsets.all(16)'), isTrue);
    expect(rawPadding.hasMatch('EdgeInsets.all(tokens.s16)'), isFalse);
    final offenders = <String>[];
    for (final f in styledFiles) {
      final src = f.readAsStringSync();
      if (colorLiteral.hasMatch(src)) {
        offenders.add('${_rel(f)}: color literal');
      }
      if (rawPadding.hasMatch(src)) offenders.add('${_rel(f)}: raw padding');
    }
    expect(offenders, isEmpty);
  });

  test('core/ never imports features/, except app_database.dart', () {
    final offenders = [
      for (final f in _dartFiles('lib/core'))
        if (!_rel(f).endsWith('lib/core/database/app_database.dart') &&
            _importsOf(f)
                .any((i) => i.startsWith('package:dailytrack/features/')))
          _rel(f),
    ];
    expect(offenders, isEmpty);
  });

  // Feature 005 T004 (f): the habit tables and enums join the expense ones.
  test('app_database.dart imports only Expense and Habit tables and enums', () {
    final f = File('lib/core/database/app_database.dart');
    if (!f.existsSync()) return;
    final allowed = RegExp(
      '^package:dailytrack/features/(expense|habit)/'
      r'(data/tables/[a-z_]+_table|domain/enums)\.dart$',
    );
    final bad = _importsOf(f).where(
      (i) =>
          i.startsWith('package:dailytrack/features/') && !allowed.hasMatch(i),
    );
    expect(bad, isEmpty);
  });

  test('features/ import nothing from app/ except app/router/routes.dart', () {
    final offenders = [
      for (final f in _dartFiles('lib/features'))
        for (final i in _importsOf(f))
          if (i.startsWith('package:dailytrack/app/') &&
              i != 'package:dailytrack/app/router/routes.dart')
            '${_rel(f)} -> $i',
    ];
    expect(offenders, isEmpty);
  });

  test('app/router/routes.dart has no imports', () {
    final f = File('lib/app/router/routes.dart');
    if (!f.existsSync()) return;
    expect(_importsOf(f), isEmpty);
  });

  test(
    'presentation never imports data/, drift, or the notifications plugin',
    () {
      final offenders = [
        for (final f in _dartFiles('lib/features'))
          if (_rel(f).contains('/presentation/'))
            for (final i in _importsOf(f))
              if (i.contains('/data/') ||
                  i.startsWith('package:drift') ||
                  i.startsWith('package:flutter_local_notifications') ||
                  i.endsWith('local_notification_permission.dart'))
                '${_rel(f)} -> $i',
      ];
      expect(offenders, isEmpty);
    },
  );

  test('settings_providers.dart stays free of data/ and drift', () {
    final f = File('lib/core/settings/settings_providers.dart');
    if (!f.existsSync()) return;
    final bad = _importsOf(f).where(
      (i) => i.contains('/settings/data/') || i.startsWith('package:drift'),
    );
    expect(bad, isEmpty);
  });

  test('only the composition root and settings/data/ import '
      'SettingsRepositoryImpl', () {
    final offenders = [
      for (final f in _dartFiles('lib'))
        if (_rel(f) != 'lib/app/production_overrides.dart' &&
            !_rel(f).contains('lib/core/settings/data/') &&
            _importsOf(f)
                .any((i) => i.endsWith('settings_repository_impl.dart')))
          _rel(f),
    ];
    expect(offenders, isEmpty);
  });

  // --- 002-expense-core (T004) ---

  const devicePlugins = [
    'package:image_picker',
    'package:flutter_image_compress',
    'package:path_provider',
    'package:share_plus',
  ];

  test('(a) presentation never imports device plugins', () {
    final offenders = [
      for (final f in _dartFiles('lib'))
        if (_rel(f).contains('/presentation/'))
          for (final i in _importsOf(f))
            if (devicePlugins.any(i.startsWith)) '${_rel(f)} -> $i',
    ];
    expect(offenders, isEmpty);
  });

  test('(b) only the composition root imports expense_bindings.dart', () {
    final offenders = [
      for (final f in _dartFiles('lib'))
        if (_rel(f) != 'lib/app/production_overrides.dart' &&
            _importsOf(f).any((i) => i.endsWith('expense_bindings.dart')))
          _rel(f),
    ];
    expect(offenders, isEmpty);
  });

  test('(c) share_plus is imported only under lib/core/share/', () {
    final offenders = [
      for (final f in _dartFiles('lib'))
        if (!_rel(f).startsWith('lib/core/share/') &&
            _importsOf(f).any((i) => i.startsWith('package:share_plus')))
          _rel(f),
    ];
    expect(offenders, isEmpty);
  });

  test('(d) the expense domain is pure Dart', () {
    final offenders = [
      for (final f in _dartFiles('lib/features/expense/domain'))
        for (final i in _importsOf(f))
          if (i.startsWith('package:flutter') ||
              i.startsWith('package:drift') ||
              devicePlugins.any(i.startsWith) ||
              i.contains('/data/') ||
              i.contains('/presentation/') ||
              i.contains('/core/widgets/'))
            '${_rel(f)} -> $i',
    ];
    expect(offenders, isEmpty);
  });

  test('(e) the expense feature never imports ad code (FR-038)', () {
    final offenders = [
      for (final f in _dartFiles('lib/features/expense'))
        for (final i in _importsOf(f))
          if (i.contains('/core/ads/') ||
              i.startsWith('package:google_mobile_ads'))
            '${_rel(f)} -> $i',
    ];
    expect(offenders, isEmpty);
  });

  // --- 003-budgets-recurring-reports (T004) ---

  /// Files in lib/ that import [package], except those [allowed].
  List<String> importersOf(
    String package, {
    required bool Function(String) allowed,
  }) => [
    for (final f in _dartFiles('lib'))
      if (!allowed(_rel(f)) && _importsOf(f).any((i) => i.startsWith(package)))
        _rel(f),
  ];

  test('(a) no DateTime.now( anywhere in lib/', () {
    final offenders = [
      for (final f in _dartFiles('lib'))
        if (f.readAsStringSync().contains('DateTime.now(')) _rel(f),
    ];
    expect(offenders, isEmpty);
  });

  test('(b) workmanager only in the background scheduler and dispatcher', () {
    expect(
      importersOf(
        'package:workmanager',
        allowed: (p) =>
            p == 'lib/core/background/workmanager_background_scheduler.dart' ||
            p == 'lib/app/background_dispatcher.dart',
      ),
      isEmpty,
    );
  });

  // Generalized to every feature by 005 T004 (c).
  test('(c) fl_chart only under presentation/widgets/charts/', () {
    expect(
      importersOf(
        'package:fl_chart',
        allowed: (p) =>
            RegExp('^lib/features/[a-z_]+/presentation/widgets/charts/')
                .hasMatch(p),
      ),
      isEmpty,
    );
  });

  test(
    '(d) flutter_local_notifications only in core/notifications/local_*',
    () {
      expect(
        importersOf(
          'package:flutter_local_notifications',
          allowed: (p) =>
              p.startsWith('lib/core/notifications/') &&
              p.split('/').last.startsWith('local_'),
        ),
        isEmpty,
      );
    },
  );

  test('(e) controllers never import fl_chart', () {
    final offenders = [
      for (final f in _dartFiles('lib/features'))
        if (_rel(f).contains('/presentation/controllers/') &&
            _importsOf(f).any((i) => i.startsWith('package:fl_chart')))
          _rel(f),
    ];
    expect(offenders, isEmpty);
  });

  test('(f) features never import app/flavor.dart', () {
    final offenders = [
      for (final f in _dartFiles('lib/features'))
        if (_importsOf(f).any((i) => i.endsWith('app/flavor.dart'))) _rel(f),
    ];
    expect(offenders, isEmpty);
  });

  // --- 005-habit-module (T004, contracts/routes_and_module.md) ---

  test('(a) the habit domain is pure Dart', () {
    final offenders = [
      for (final f in _dartFiles('lib/features/habit/domain'))
        for (final i in _importsOf(f))
          if (i.startsWith('package:flutter') ||
              i.startsWith('package:drift') ||
              i.contains('/data/'))
            '${_rel(f)} -> $i',
    ];
    expect(offenders, isEmpty);
  });

  test('(b) habit presentation imports no data/, Drift, or plugins', () {
    const banned = [
      'package:drift',
      'package:share_plus',
      'package:flutter_local_notifications',
      'package:timezone',
    ];
    final offenders = [
      for (final f in _dartFiles('lib/features/habit/presentation'))
        for (final i in _importsOf(f))
          if (i.contains('/data/') || banned.any(i.startsWith))
            '${_rel(f)} -> $i',
    ];
    expect(offenders, isEmpty);
  });

  test('(d) timezone only in core/notifications/local_*', () {
    expect(
      importersOf(
        'package:timezone',
        allowed: (p) =>
            p.startsWith('lib/core/notifications/') &&
            p.split('/').last.startsWith('local_'),
      ),
      isEmpty,
    );
  });

  test('(g) only the composition root imports habit_bindings.dart', () {
    final offenders = [
      for (final f in _dartFiles('lib'))
        if (_rel(f) != 'lib/app/production_overrides.dart' &&
            _importsOf(f).any((i) => i.endsWith('habit_bindings.dart')))
          _rel(f),
    ];
    expect(offenders, isEmpty);
  });
  // Feature 006 T006 (research R17): Home reaches modules only through
  // TrackerModule, insight rules stay pure Dart, and nothing new goes online.
  test('(006-a) dashboard imports no other feature, drift, or data layer', () {
    final offenders = [
      for (final f in _dartFiles('lib/features/dashboard'))
        for (final i in _importsOf(f))
          if ((i.startsWith('package:dailytrack/features/') &&
                  !i.startsWith('package:dailytrack/features/dashboard/')) ||
              i.startsWith('package:drift') ||
              i.contains('/data/'))
            '${_rel(f)} -> $i',
    ];
    expect(offenders, isEmpty);
  });

  test('(006-b) insight rules and Insight import no Flutter or Riverpod', () {
    final files = [
      for (final f in _dartFiles('lib/features'))
        if (_rel(f).contains('/domain/insights/')) f,
      File('lib/core/module/insight.dart'),
    ];
    expect(files.length, greaterThan(1));
    final offenders = [
      for (final f in files)
        for (final i in _importsOf(f))
          if (i.startsWith('package:flutter/') ||
              i.startsWith('package:flutter_riverpod'))
            '${_rel(f)} -> $i',
    ];
    expect(offenders, isEmpty);
  });

  test('(006-c) Home and insights make no network imports (SC-008)', () {
    const banned = ['package:http', 'dart:io', 'package:dio'];
    final offenders = [
      for (final f in [
        ..._dartFiles('lib/features/dashboard'),
        for (final f in _dartFiles('lib/features'))
          if (_rel(f).contains('/insights/')) f,
      ])
        for (final i in _importsOf(f))
          if (banned.any(i.startsWith)) '${_rel(f)} -> $i',
    ];
    expect(offenders, isEmpty);
  });

  // --- 007-settings-themes-app-lock (T012, research R20) ---

  test('(007-a) SET-01 support plugins only under lib/core/support/', () {
    const plugins = [
      'package:in_app_review',
      'package:package_info_plus',
      'package:url_launcher',
    ];
    final offenders = [
      for (final f in _dartFiles('lib'))
        if (!_rel(f).startsWith('lib/core/support/'))
          for (final i in _importsOf(f))
            if (plugins.any(i.startsWith)) '${_rel(f)} -> $i',
    ];
    expect(offenders, isEmpty);
  });

  test('(007-b) webview_flutter only in the web page screen', () {
    final offenders = [
      for (final f in _dartFiles('lib'))
        if (_rel(f) !=
            'lib/features/settings/presentation/screens/web_page_screen.dart')
          for (final i in _importsOf(f))
            if (i.startsWith('package:webview_flutter')) '${_rel(f)} -> $i',
    ];
    expect(offenders, isEmpty);
  });

  test('(007-c) settings imports no other feature, drift, or data layer', () {
    final offenders = [
      for (final f in _dartFiles('lib/features/settings'))
        for (final i in _importsOf(f))
          if ((i.startsWith('package:dailytrack/features/') &&
                  !i.startsWith('package:dailytrack/features/settings/')) ||
              i.startsWith('package:drift') ||
              i.contains('/data/'))
            '${_rel(f)} -> $i',
    ];
    expect(offenders, isEmpty);
  });

  test('(007-e) lock plugins only in core/security/data/', () {
    const plugins = [
      'package:local_auth',
      'package:flutter_secure_storage',
      'package:cryptography',
    ];
    final offenders = [
      for (final f in _dartFiles('lib'))
        if (!_rel(f).startsWith('lib/core/security/data/') &&
            // PBKDF2 itself is pure Dart and lives in the domain hasher.
            _rel(f) != 'lib/core/security/domain/pin_hasher.dart')
          for (final i in _importsOf(f))
            if (plugins.any(i.startsWith)) '${_rel(f)} -> $i',
    ];
    expect(offenders, isEmpty);
  });

  test('(007-f) the security domain is pure Dart', () {
    final offenders = [
      for (final f in _dartFiles('lib/core/security/domain'))
        for (final i in _importsOf(f))
          if (i.startsWith('package:flutter/') ||
              i.startsWith('package:flutter_riverpod') ||
              i.startsWith('package:local_auth') ||
              i.startsWith('package:flutter_secure_storage'))
            '${_rel(f)} -> $i',
    ];
    expect(offenders, isEmpty);
  });

  test('(007-g) the lock feature imports no other feature and no data '
      'layer', () {
    final offenders = [
      for (final f in _dartFiles('lib/features/lock'))
        for (final i in _importsOf(f))
          if ((i.startsWith('package:dailytrack/features/') &&
                  !i.startsWith('package:dailytrack/features/lock/')) ||
              i.contains('/data/'))
            '${_rel(f)} -> $i',
    ];
    expect(offenders, isEmpty);
  });

  test('(007-d) full dates use the SET-01 date format, not a fixed one '
      '(research R13)', () {
    final fixed = RegExp(r'DateFormat\.(yMMMd|yMMMEd|yMd)\(');
    final offenders = [
      for (final f in _dartFiles('lib/features'))
        if (fixed.hasMatch(f.readAsStringSync())) _rel(f),
    ];
    expect(offenders, isEmpty);
  });
}
