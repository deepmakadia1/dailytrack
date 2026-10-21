import 'dart:io';

import 'package:dailytrack/app/flavor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prod flavor has no debug banner', () {
    final config = FlavorConfig.fromName('prod');
    expect(config.flavor, Flavor.prod);
    expect(config.showDebugBanner, isFalse);
  });

  test('any other flavor name is dev, with the banner', () {
    for (final name in ['dev', null, '', 'staging']) {
      final config = FlavorConfig.fromName(name);
      expect(config.flavor, Flavor.dev, reason: '$name');
      expect(config.showDebugBanner, isTrue);
    }
  });

  test('lib/ contains no real AdMob ids (only Google test ids)', () {
    const testPublisher = 'ca-app-pub-3940256099942544';
    final pattern = RegExp(r'ca-app-pub-\d+');
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      for (final match in pattern.allMatches(file.readAsStringSync())) {
        if (match.group(0) != testPublisher) {
          offenders.add('${file.path}: ${match.group(0)}');
        }
      }
    }
    expect(offenders, isEmpty);
  });
}
