import 'package:flutter/widgets.dart';

class CNSidebar {
  const CNSidebar({
    required this.builder,
    required this.minWidth,
    this.key,
    this.decoration,
    this.isResizable = true,
    this.dragClosed = true,
    double? dragClosedBuffer,
    this.snapToStartBuffer,
    this.maxWidth = 400.0,
    this.startWidth,
    this.padding = EdgeInsets.zero,
    this.windowBreakpoint = 556.0,
    this.shownByDefault = true,
  }) : dragClosedBuffer = dragClosedBuffer ?? minWidth / 2;

  final ScrollableWidgetBuilder builder;
  final BoxDecoration? decoration;
  final bool dragClosed;
  final double dragClosedBuffer;
  final bool? isResizable;
  final Key? key;
  final double? maxWidth;
  final double minWidth;
  final EdgeInsets padding;
  final bool shownByDefault;
  final double? snapToStartBuffer;
  final double? startWidth;
  final double windowBreakpoint;
}
