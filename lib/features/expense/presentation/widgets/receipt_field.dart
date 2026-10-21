import 'dart:io';

import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/features/expense/domain/receipts/receipt_picker.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:dailytrack/features/expense/presentation/widgets/field_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// EXP-02 receipt (T055): Camera and Gallery, then a thumbnail with Remove.
class ReceiptField extends StatelessWidget {
  const new({
    required this.receiptPath,
    required this.failed,
    required this.onPick,
    required this.onRemove,
    super.key,
  });

  final String? receiptPath;
  final bool failed;
  final ValueChanged<ReceiptSource> onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final path = receiptPath;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.expense_attachReceipt,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: tokens.s8),
        if (path == null)
          Wrap(
            spacing: tokens.s8,
            runSpacing: tokens.s8,
            children: [
              OutlinedButton.icon(
                key: const Key('receipt_camera'),
                onPressed: () => onPick(ReceiptSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(l10n.expense_camera),
              ),
              OutlinedButton.icon(
                key: const Key('receipt_gallery'),
                onPressed: () => onPick(ReceiptSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(l10n.expense_gallery),
              ),
            ],
          )
        else
          Row(
            children: [
              ReceiptThumbnail(relativePath: path),
              SizedBox(width: tokens.s12),
              Expanded(child: Text(l10n.expense_receipt)),
              IconButton(
                key: const Key('receipt_remove'),
                tooltip: l10n.expense_removeReceipt,
                onPressed: onRemove,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        FieldError(failed ? l10n.expense_receiptError : null),
      ],
    );
  }
}

/// A square receipt preview, or a "Receipt not available" placeholder when
/// the file is gone (spec edge case "Receipt file missing").
class ReceiptThumbnail extends ConsumerWidget {
  const new({required this.relativePath, super.key, this.onTap});

  final String relativePath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final size = tokens.s48 + tokens.s16;
    return FutureBuilder<String?>(
      future: ref.read(receiptStoreProvider).resolve(relativePath),
      builder: (context, snapshot) {
        final absolute = snapshot.data;
        final Widget child = absolute == null
            ? Tooltip(
                message: l10n.expense_receiptMissing,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  semanticLabel: l10n.expense_receiptMissing,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : Image.file(
                File(absolute),
                fit: BoxFit.cover,
                semanticLabel: l10n.expense_receipt,
              );
        return InkWell(
          key: const Key('receipt_thumbnail'),
          onTap: absolute == null ? null : onTap,
          borderRadius: BorderRadius.circular(tokens.radiusChip),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radiusChip),
            child: ColoredBox(
              color: theme.colorScheme.surfaceContainerHighest,
              child: SizedBox.square(
                dimension: size,
                child: Center(child: child),
              ),
            ),
          ),
        );
      },
    );
  }
}
