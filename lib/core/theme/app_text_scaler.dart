import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// How much larger text is with SET-04 font size "Large".
const double largeFontFactor = 1.15;

/// The combined scale "Large" never goes past, so the 200% test envelope
/// (§12, §15.10) stays the worst case (feature 007 research R11).
const double largeFontMaxScale = 2;

/// The app's text scaler: [system] unchanged for Default, or 15% larger for
/// Large, capped at 200% but never smaller than [system] itself.
TextScaler appTextScaler(TextScaler system, {required bool large}) =>
    large ? _LargeTextScaler(system) : system;

@immutable
final class _LargeTextScaler extends TextScaler {
  const new(this.system);

  final TextScaler system;

  @override
  double scale(double fontSize) {
    final base = system.scale(fontSize);
    final capped = math.min(
      base * largeFontFactor,
      fontSize * largeFontMaxScale,
    );
    return math.max(base, capped);
  }

  @override
  double get textScaleFactor => scale(1);

  @override
  bool operator ==(Object other) =>
      other is _LargeTextScaler && other.system == system;

  @override
  int get hashCode => Object.hash(_LargeTextScaler, system);
}
