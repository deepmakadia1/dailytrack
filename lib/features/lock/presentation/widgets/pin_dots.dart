import 'dart:math' as math;

import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// The 4 PIN dots of SYS-03 and SYS-04. They shake when [shakeCount]
/// changes (wrong PIN, mismatch), unless animations are off. Semantics say
/// only how many digits are entered, never which.
class PinDots extends StatefulWidget {
  const new({
    required this.filled,
    super.key,
    this.length = 4,
    this.shakeCount = 0,
  });

  final int filled;
  final int length;

  /// Each change plays the shake once.
  final int shakeCount;

  @override
  State<PinDots> createState() => _PinDotsState();
}

class _PinDotsState extends State<PinDots> with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  @override
  void didUpdateWidget(PinDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shakeCount != oldWidget.shakeCount &&
        !MediaQuery.disableAnimationsOf(context)) {
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final size = tokens.s16;

    return Semantics(
      key: const Key('pin_dots'),
      label: l10n.lock_dotsLabel(widget.filled),
      liveRegion: true,
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _shake,
        builder: (context, child) => Transform.translate(
          // Three quick side-to-side swings that settle.
          offset: Offset(
            math.sin(_shake.value * math.pi * 6) *
                tokens.s8 *
                (1 - _shake.value),
            0,
          ),
          child: child,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.length; i++)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: tokens.s8),
                child: AnimatedContainer(
                  duration: tokens.motionShort,
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < widget.filled ? scheme.primary : null,
                    border: Border.all(color: scheme.primary, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
