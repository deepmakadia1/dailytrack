import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Modal bottom sheet for pickers and small forms (§15.4): drag handle,
/// 28 dp top corners, and content lifted above the keyboard.
class AppBottomSheet extends StatelessWidget {
  const new({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final tokens = AppTokens.of(context);
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens.radiusSheet),
        ),
      ),
      builder: (context) => AppBottomSheet(title: title, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: tokens.screenPadding,
        right: tokens.screenPadding,
        bottom: MediaQuery.viewInsetsOf(context).bottom + tokens.s16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          SizedBox(height: tokens.s16),
          Flexible(child: child),
        ],
      ),
    );
  }
}
