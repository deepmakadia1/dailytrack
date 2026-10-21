import 'dart:io';

import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/empty_state.dart';
import 'package:flutter/material.dart';

/// EXP-03 full-screen receipt with pinch zoom (T075).
class ReceiptViewer extends StatelessWidget {
  const new({required this.absolutePath, super.key});

  final String absolutePath;

  static Future<void> open(BuildContext context, String absolutePath) =>
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => ReceiptViewer(absolutePath: absolutePath),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final file = File(absolutePath);
    return AppScaffold(
      title: l10n.expense_receipt,
      padBody: false,
      body: file.existsSync()
          ? InteractiveViewer(
              key: const Key('receipt_zoom'),
              maxScale: 5,
              child: Center(
                child: Image.file(file, semanticLabel: l10n.expense_receipt),
              ),
            )
          : EmptyState(title: l10n.expense_receiptMissing),
    );
  }
}
