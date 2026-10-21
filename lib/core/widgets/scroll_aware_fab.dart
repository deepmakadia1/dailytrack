import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A FAB that hides while the user scrolls down and returns on scroll up
/// (§15.3, feature 006 research R12). Wrap the screen with it: [builder]
/// gets the animated FAB to place (usually through `AppScaffold.fab`), and
/// vertical [UserScrollNotification]s from the screen's scroll view drive
/// it. Horizontal lists inside the screen are ignored.
class ScrollAwareFab extends StatefulWidget {
  const new({required this.fab, required this.builder, super.key});

  final Widget fab;
  final Widget Function(BuildContext context, Widget fab) builder;

  @override
  State<ScrollAwareFab> createState() => _ScrollAwareFabState();
}

class _ScrollAwareFabState extends State<ScrollAwareFab> {
  bool _visible = true;

  bool _onScroll(UserScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    final visible = switch (n.direction) {
      ScrollDirection.reverse => false,
      ScrollDirection.forward => true,
      ScrollDirection.idle => _visible,
    };
    if (visible != _visible) setState(() => _visible = visible);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : tokens.motionSize;
    final fab = IgnorePointer(
      ignoring: !_visible,
      child: ExcludeSemantics(
        excluding: !_visible,
        child: AnimatedSlide(
          offset: _visible ? Offset.zero : const Offset(0, 2),
          duration: duration,
          curve: Easing.standard,
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: duration,
            curve: Easing.standard,
            child: widget.fab,
          ),
        ),
      ),
    );
    return NotificationListener<UserScrollNotification>(
      onNotification: _onScroll,
      child: widget.builder(context, fab),
    );
  }
}
