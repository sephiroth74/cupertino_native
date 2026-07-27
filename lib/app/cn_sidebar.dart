import 'package:flutter/widgets.dart';

/// Configuration for a resizable sidebar panel in a [CNWindow].
class CNSidebar {
  /// Creates a sidebar configuration.
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

  /// The builder function that constructs the sidebar content.
  final ScrollableWidgetBuilder builder;

  /// Optional decoration applied to the sidebar container.
  final BoxDecoration? decoration;

  /// Whether dragging the sidebar below its minimum width closes it.
  final bool dragClosed;

  /// The distance below [minWidth] at which dragging closes the sidebar.
  final double dragClosedBuffer;

  /// Whether the sidebar can be resized by dragging its edge.
  final bool? isResizable;

  /// Optional key to identify the sidebar for state preservation.
  final Key? key;

  /// The maximum width the sidebar can be resized to.
  final double? maxWidth;

  /// The minimum width of the sidebar.
  final double minWidth;

  /// Padding applied inside the sidebar.
  final EdgeInsets padding;

  /// Whether the sidebar is shown by default when the window opens.
  final bool shownByDefault;

  /// The snap buffer around [startWidth] for snapping during drag.
  final double? snapToStartBuffer;

  /// The initial width of the sidebar. Defaults to [minWidth] if null.
  final double? startWidth;

  /// The window width below which the sidebar is automatically hidden.
  final double windowBreakpoint;
}
