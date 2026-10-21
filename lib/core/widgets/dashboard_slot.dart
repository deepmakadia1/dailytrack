import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// One Home (DSH-01) slot: the card gap above [child] only while the child
/// has height, and an animated height change when content appears or leaves
/// (feature 006 research R3, §15.6 "no layout shift"). A hidden section
/// (`SizedBox.shrink()`) therefore leaves no gap.
class DashboardSlot extends StatelessWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final slot = _GapIfNonEmpty(gap: tokens.cardGap, child: child);
    // AnimatedSize cannot run with a zero duration, so "Remove animations"
    // skips it and heights change at once.
    if (MediaQuery.disableAnimationsOf(context)) return slot;
    return AnimatedSize(
      duration: tokens.motionSize,
      curve: Easing.standard,
      alignment: Alignment.topCenter,
      child: slot,
    );
  }
}

/// Lays out the child first, then reports `child height + gap` and paints
/// the child below the gap, or reports 0 when the child is empty. A
/// `LayoutBuilder` cannot do this: it cannot know the child's size before
/// layout.
class _GapIfNonEmpty extends SingleChildRenderObjectWidget {
  const new({required this.gap, required super.child});

  final double gap;

  @override
  _RenderGapIfNonEmpty createRenderObject(BuildContext context) =>
      _RenderGapIfNonEmpty(gap);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderGapIfNonEmpty renderObject,
  ) => renderObject.gap = gap;
}

class _RenderGapIfNonEmpty extends RenderProxyBox {
  new(this._gap);

  double _gap;

  double get gap => _gap;

  set gap(double value) {
    if (value == _gap) return;
    _gap = value;
    markNeedsLayout();
  }

  /// The child's vertical offset: [gap] when it has height, else 0.
  double get _dy => (child?.size.height ?? 0) > 0 ? _gap : 0;

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    final maxHeight = constraints.maxHeight == double.infinity
        ? double.infinity
        : (constraints.maxHeight - _gap).clamp(0, double.infinity).toDouble();
    child.layout(
      BoxConstraints(
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
        maxHeight: maxHeight,
      ),
      parentUsesSize: true,
    );
    final height = child.size.height;
    size = constraints.constrain(
      Size(child.size.width, height > 0 ? height + _gap : 0),
    );
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    final h = super.computeMinIntrinsicHeight(width);
    return h > 0 ? h + _gap : 0;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final h = super.computeMaxIntrinsicHeight(width);
    return h > 0 ? h + _gap : 0;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final child = this.child;
    if (child == null || child.size.height <= 0) return;
    context.paintChild(child, offset + Offset(0, _dy));
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final child = this.child;
    if (child == null || child.size.height <= 0) return false;
    return result.addWithPaintOffset(
      offset: Offset(0, _dy),
      position: position,
      hitTest: (result, transformed) =>
          child.hitTest(result, position: transformed),
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.translateByDouble(0, _dy, 0, 1);
  }
}
