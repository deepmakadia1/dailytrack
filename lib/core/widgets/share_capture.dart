import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Renders the [RepaintBoundary] under [key] to PNG bytes (feature 005
/// research R12), for the streak card and heatmap shares. Returns null when
/// the boundary is not in the tree.
Future<Uint8List?> captureBoundaryPng(
  GlobalKey key, {
  double pixelRatio = 3,
}) async {
  final object = key.currentContext?.findRenderObject();
  if (object is! RenderRepaintBoundary) return null;
  final image = await object.toImage(pixelRatio: pixelRatio);
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}
