import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// A destructive confirmation that needs a typed word (§15.5 "irreversible
/// actions use a ConfirmDialog"; feature 007 FR-047). The button stays
/// disabled until the field matches [word] exactly, case included.
class TypedConfirmDialog extends StatefulWidget {
  const new({
    required this.title,
    required this.word,
    required this.confirmLabel,
    super.key,
    this.hint,
  });

  final String title;

  /// What must be typed, e.g. `DELETE` (not translated).
  final String word;
  final String confirmLabel;

  /// Field hint; defaults to [word].
  final String? hint;

  /// True only when the user typed [word] and confirmed.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String word,
    required String confirmLabel,
    String? hint,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => TypedConfirmDialog(
          title: title,
          word: word,
          confirmLabel: confirmLabel,
          hint: hint,
        ),
      ) ??
      false;

  @override
  State<TypedConfirmDialog> createState() => _TypedConfirmDialogState();
}

class _TypedConfirmDialogState extends State<TypedConfirmDialog> {
  final TextEditingController _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(widget.title),
      content: Padding(
        padding: EdgeInsets.only(top: tokens.s8),
        child: TextField(
          key: const Key('typed_confirm_field'),
          controller: _text,
          autofocus: true,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(hintText: widget.hint ?? widget.word),
          onChanged: (_) => setState(() {}),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(
          key: const Key('typed_confirm_button'),
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          onPressed: _text.text == widget.word
              ? () => Navigator.of(context).pop(true)
              : null,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
