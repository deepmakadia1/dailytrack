import 'package:freezed_annotation/freezed_annotation.dart';

part 'modules_state.freezed.dart';

/// SET-06 screen state (T088, contracts/screens.md).
@freezed
abstract class ModulesState with _$ModulesState {
  const factory({
    /// Registered modules in the user's order.
    required List<ModuleRow> rows,

    /// ARB key of the inline "keep one module on" message, if shown.
    String? messageKey,
  }) = _ModulesState;
}

@freezed
abstract class ModuleRow with _$ModuleRow {
  const factory({required String id, required bool enabled}) = _ModuleRow;
}
