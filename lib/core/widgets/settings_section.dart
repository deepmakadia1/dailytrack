import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// A titled group of settings rows (SET-01, SET-04, SET-05; feature 007
/// contracts/screens.md). The title is a semantics header, so TalkBack can
/// jump between sections.
class SettingsSection extends StatelessWidget {
  const new({required this.title, required this.children, super.key});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            tokens.screenPadding,
            tokens.s16,
            tokens.screenPadding,
            tokens.s8,
          ),
          // Its own node, so TalkBack can jump between headers and the
          // header is never merged with the rows below.
          child: Semantics(
            header: true,
            container: true,
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
