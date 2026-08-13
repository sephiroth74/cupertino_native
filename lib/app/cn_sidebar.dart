import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:macos_window_utils/macos_window_utils.dart';

/// The smallest width a sidebar separator (divider) is allowed to have.
///
/// Anything thinner would leave no room for the resize grip and would be
/// impossible to see against the sidebar background.
const double kCNSidebarMinSeparatorWidth = 2.0;

/// Configuration for a resizable sidebar panel in a [CNWindow].
class CNSidebar {
  /// Creates a sidebar configuration.
  const CNSidebar({
    required this.builder,
    required this.minWidth,
    this.key,
    this.backgroundColor,
    this.isResizable = true,
    this.dragClosed = true,
    double? dragClosedBuffer,
    this.snapToStartBuffer,
    this.maxWidth = 400.0,
    this.startWidth,
    this.padding = EdgeInsets.zero,
    this.windowBreakpoint = 556.0,
    this.shownByDefault = true,
    this.separatorColor,
    this.separatorWidth = 8.0,
    this.gripColor,
    this.material = NSVisualEffectViewMaterial.sidebar,
    this.slideDuration = const Duration(milliseconds: 300),
  }) : assert(
         separatorWidth >= kCNSidebarMinSeparatorWidth,
         'separatorWidth must be at least $kCNSidebarMinSeparatorWidth',
       ),
       dragClosedBuffer = dragClosedBuffer ?? minWidth / 2;

  /// Optional background color applied to the sidebar container.
  final Color? backgroundColor;

  /// The builder function that constructs the sidebar content.
  final WidgetBuilder builder;

  /// Whether dragging the sidebar below its minimum width closes it.
  final bool dragClosed;

  /// The distance below [minWidth] at which dragging closes the sidebar.
  final double dragClosedBuffer;

  /// Whether the sidebar can be resized by dragging its edge.
  final bool? isResizable;

  /// Optional key to identify the sidebar for state preservation.
  final Key? key;

  /// The material to use for the sidebar's visual effect view. Defaults to [NSVisualEffectViewMaterial.sidebar].
  final NSVisualEffectViewMaterial material;

  /// The maximum width the sidebar can be resized to.
  final double? maxWidth;

  /// The minimum width of the sidebar.
  final double minWidth;

  /// Padding applied inside the sidebar.
  final EdgeInsets padding;

  /// Optional color for the separator line between the sidebar and the main content.
  final Color? separatorColor;

  /// Optional color for the grip area used to resize the sidebar.
  final Color? gripColor;

  /// Width of the separator (divider) drawn between the sidebar and the main
  /// content, in logical pixels.
  ///
  /// Must be at least [kCNSidebarMinSeparatorWidth]; read it back through
  /// [effectiveSeparatorWidth], which clamps to that minimum in release builds
  /// too. The pointer grab area is widened independently, so a thin separator is
  /// still comfortable to drag.
  final double separatorWidth;

  /// Duration of the show/hide slide animation when the sidebar is toggled.
  ///
  /// Defaults to 300ms. Set to [Duration.zero] to disable the animation and
  /// toggle instantly. In the default split layout the main content area is
  /// resized in step with the slide, so a long duration is inherently more
  /// expensive (the native content view relayouts every frame); shortening this
  /// — or using [Duration.zero] — reduces or removes that cost. Only affects the
  /// toggle animation; resize drags remain instantaneous.
  final Duration slideDuration;

  /// Whether the sidebar is shown by default when the window opens.
  final bool shownByDefault;

  /// The snap buffer around [startWidth] for snapping during drag.
  final double? snapToStartBuffer;

  /// The initial width of the sidebar. Defaults to [minWidth] if null.
  final double? startWidth;

  /// The window width below which the sidebar is automatically hidden.
  final double windowBreakpoint;

  /// [separatorWidth] clamped to [kCNSidebarMinSeparatorWidth].
  double get effectiveSeparatorWidth =>
      math.max(kCNSidebarMinSeparatorWidth, separatorWidth);
}
