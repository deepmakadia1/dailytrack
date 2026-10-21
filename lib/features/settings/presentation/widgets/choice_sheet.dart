import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';

/// One option in a [showChoiceSheet] list.
typedef Choice<T> = ({T value, String label, Key key});

/// A SET-01 single-choice picker in an `AppBottomSheet`: one row per
/// option, the current one checked and selected. Returns the chosen value,
/// or null when dismissed. A `null` option value is wrapped so "System
/// default" can be chosen.
Future<({T value})?> showChoiceSheet<T>(
  BuildContext context, {
  required String title,
  required List<Choice<T>> choices,
  required T selected,
}) => AppBottomSheet.show<({T value})>(
  context,
  title: title,
  child: ListView(
    shrinkWrap: true,
    children: [
      for (final c in choices)
        Builder(
          builder: (context) {
            final isSelected = c.value == selected;
            return ListTile(
              key: c.key,
              contentPadding: EdgeInsets.zero,
              title: Text(c.label),
              selected: isSelected,
              trailing: isSelected
                  ? Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
              onTap: () => Navigator.of(context).pop((value: c.value)),
            );
          },
        ),
    ],
  ),
);
