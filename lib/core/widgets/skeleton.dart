import 'dart:async';

import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Loading placeholder shaped like a card (§15.6). Pulses gently unless the
/// user has turned animations off.
class SkeletonCard extends StatefulWidget {
  const new({super.key, this.height = 72});

  final double height;

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.5,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return FadeTransition(
      opacity: _controller,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(tokens.radiusCard),
        ),
      ),
    );
  }
}

/// A column of [SkeletonCard]s separated by the card gap.
class SkeletonList extends StatelessWidget {
  const new({super.key, this.itemCount = 3, this.itemHeight = 72});

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < itemCount; i++) ...[
          if (i > 0) SizedBox(height: tokens.cardGap),
          SkeletonCard(height: itemHeight),
        ],
      ],
    );
  }
}

/// Shows [child] only after [delay], so fast local loads never flash a
/// skeleton (§15.6: skeletons only if loading takes over 300 ms).
class DelayedSkeleton extends StatefulWidget {
  const new({
    required this.child,
    super.key,
    this.delay = const Duration(milliseconds: 300),
  });

  final Widget child;
  final Duration delay;

  @override
  State<DelayedSkeleton> createState() => _DelayedSkeletonState();
}

class _DelayedSkeletonState extends State<DelayedSkeleton> {
  Timer? _timer;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _visible ? widget.child : const SizedBox.shrink();
}
