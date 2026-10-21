import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

/// A starter habit offered on the empty HAB-01 (research R16). Name and unit
/// are ARB keys. Not stored.
@immutable
final class HabitTemplate {
  const new({
    required this.id,
    required this.nameKey,
    required this.iconKey,
    required this.colorHex,
    required this.kind,
    required this.target,
    this.unitKey,
  });

  final String id;
  final String nameKey;
  final String iconKey;
  final String colorHex;
  final HabitKind kind;
  final int target;
  final String? unitKey;
}
