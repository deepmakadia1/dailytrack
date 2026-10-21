import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The SYS-03/SYS-04 PIN keypad (feature 007 contracts/screens.md): 1–9,
/// a biometric key (or a blank), 0, and delete. Keys are at least 64 dp,
/// labeled for TalkBack, and give a light haptic. Unlike the amount keypad
/// there are no operators or decimal point.
class PinKeypad extends StatelessWidget {
  const new({
    required this.onDigit,
    required this.onBackspace,
    super.key,
    this.onBiometric,
    this.enabled = true,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  /// Shown as the bottom-left key when not null.
  final VoidCallback? onBiometric;

  /// False while locked out or checking: the digit and delete keys ignore
  /// taps. The biometric key stays usable, since fingerprint unlock works
  /// during a PIN lockout (clarification Q3).
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);

    Widget key({
      required String id,
      required String label,
      required VoidCallback onTap,
      required Widget child,
      bool alwaysEnabled = false,
    }) {
      final active = enabled || alwaysEnabled;
      return Expanded(
        child: Padding(
          padding: EdgeInsets.all(tokens.s4),
          child: Semantics(
            button: true,
            enabled: active,
            label: label,
            excludeSemantics: true,
            child: InkWell(
              key: Key('pin_key_$id'),
              customBorder: const CircleBorder(),
              onTap: !active
                  ? null
                  : () {
                      _haptic();
                      onTap();
                    },
              child: SizedBox(
                height: tokens.s48 + tokens.s16,
                child: Center(child: child),
              ),
            ),
          ),
        ),
      );
    }

    Widget digit(String d) => key(
      id: d,
      label: d,
      onTap: () => onDigit(d),
      child: Text(d, style: Theme.of(context).textTheme.headlineSmall),
    );

    Widget row(List<Widget> keys) => Row(children: keys);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row([digit('1'), digit('2'), digit('3')]),
        row([digit('4'), digit('5'), digit('6')]),
        row([digit('7'), digit('8'), digit('9')]),
        row([
          if (onBiometric case final bio?)
            key(
              id: 'biometric',
              label: l10n.lock_useBiometric,
              onTap: bio,
              alwaysEnabled: true,
              child: const Icon(Icons.fingerprint),
            )
          else
            const Expanded(child: SizedBox.shrink()),
          digit('0'),
          key(
            id: 'backspace',
            label: l10n.lock_delete,
            onTap: onBackspace,
            child: const Icon(Icons.backspace_outlined),
          ),
        ]),
      ],
    );
  }

  static void _haptic() {
    // Fire and forget; a missing haptic engine is fine.
    HapticFeedback.lightImpact().ignore();
  }
}
