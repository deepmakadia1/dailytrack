import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';

/// Asks for a new backup password twice, with the "can't be recovered"
/// warning (SET-02 "Encrypt backup", FR-021). Returns the password, or null
/// when cancelled. The caller stores it; it is never kept here.
Future<String?> showNewBackupPasswordSheet(
  BuildContext context, {
  required bool changing,
}) {
  final l10n = AppLocalizations.of(context);
  return AppBottomSheet.show<String>(
    context,
    title: changing
        ? l10n.backup_passwordChangeTitle
        : l10n.backup_passwordTitle,
    child: const _NewPasswordForm(),
  );
}

/// Asks for an existing backup's password (restore). [error] is shown under
/// the field, e.g. after a wrong password. Returns null when cancelled.
Future<String?> showBackupPasswordPrompt(
  BuildContext context, {
  String? error,
}) {
  final l10n = AppLocalizations.of(context);
  return AppBottomSheet.show<String>(
    context,
    title: l10n.restore_passwordTitle,
    child: _PasswordPrompt(error: error),
  );
}

class _NewPasswordForm extends StatefulWidget {
  const new();

  @override
  State<_NewPasswordForm> createState() => _NewPasswordFormState();
}

class _NewPasswordFormState extends State<_NewPasswordForm> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _mismatch =>
      _confirm.text.isNotEmpty && _confirm.text != _password.text;

  bool get _canSave =>
      _password.text.isNotEmpty && _confirm.text == _password.text;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.backup_passwordWarning,
          key: const Key('backup_password_warning'),
        ),
        SizedBox(height: tokens.s16),
        TextField(
          key: const Key('backup_password_field'),
          controller: _password,
          obscureText: true,
          autofocus: true,
          enableSuggestions: false,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(labelText: l10n.backup_passwordField),
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: tokens.s12),
        TextField(
          key: const Key('backup_password_confirm'),
          controller: _confirm,
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: l10n.backup_passwordConfirm,
            errorText: _mismatch ? l10n.backup_passwordMismatch : null,
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) {
            if (_canSave) Navigator.of(context).pop(_password.text);
          },
        ),
        SizedBox(height: tokens.s24),
        FilledButton(
          key: const Key('backup_password_save'),
          onPressed: _canSave
              ? () => Navigator.of(context).pop(_password.text)
              : null,
          child: Text(l10n.backup_passwordSave),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.common_cancel),
        ),
      ],
    );
  }
}

class _PasswordPrompt extends StatefulWidget {
  const new({this.error});

  final String? error;

  @override
  State<_PasswordPrompt> createState() => _PasswordPromptState();
}

class _PasswordPromptState extends State<_PasswordPrompt> {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    void submit() {
      if (_password.text.isNotEmpty) Navigator.of(context).pop(_password.text);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('restore_password_field'),
          controller: _password,
          obscureText: true,
          autofocus: true,
          enableSuggestions: false,
          autocorrect: false,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: l10n.backup_passwordField,
            errorText: widget.error,
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => submit(),
        ),
        SizedBox(height: tokens.s24),
        FilledButton(
          key: const Key('restore_password_open'),
          onPressed: _password.text.isEmpty ? null : submit,
          child: Text(l10n.restore_open),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.common_cancel),
        ),
      ],
    );
  }
}
