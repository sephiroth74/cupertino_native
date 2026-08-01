import 'package:flutter/widgets.dart';

/// The horizontal scope of the expanded status bar panel.
///
/// Determines which portion of the window the expanded panel spans.
enum CNStatusBarExpansionMode {
  /// The expanded panel sits above the content area only, leaving sidebars intact.
  overContent,

  /// The expanded panel covers the full window width including sidebars.
  overAll,
}

/// How the expanded status bar panel is rendered.
///
/// This is orthogonal to [CNStatusBarExpansionMode]: the mode determines the
/// horizontal scope, while the style determines the visual presentation.
enum CNStatusBarPresentationStyle {
  /// The panel takes space from the content area (Column-like split).
  /// Content shrinks vertically to make room for the panel.
  push,

  /// The panel floats above the content as an overlay (Stack-like),
  /// without pushing or resizing surrounding content.
  floating,
}

/// Builder for status bar items that receives the current expansion state.
typedef CNStatusBarItemsBuilder = Widget Function(BuildContext context, bool isExpanded);

/// Configuration for a status bar at the bottom of a [CNWindow].
class CNStatusBar {
  /// Creates a status bar configuration.
  const CNStatusBar({
    this.leftItems,
    this.rightItems,
    this.color,
    this.dividerColor,
    this.expandedColor,
    this.height = 22.0,
    this.expandedBuilder,
    this.expandedMinHeight = 100.0,
    this.expandedMaxHeight = 400.0,
    this.expandedStartHeight,
    this.expansionMode = CNStatusBarExpansionMode.overContent,
    this.presentationStyle = CNStatusBarPresentationStyle.push,
    this.floatingMargin = const EdgeInsets.only(bottom: 8, right: 8),
    this.dragClosed = true,
    double? dragClosedBuffer,
    this.isResizable = true,
    this.shownByDefault = false,
    this.paddingStart = 8.0,
    this.paddingEnd = 8.0,
  }) : dragClosedBuffer = dragClosedBuffer ?? expandedMinHeight / 2;

  /// Background color of the status bar. If null, uses the theme's canvas color.
  final Color? color;

  /// Color of the divider line above the status bar. If null, uses the theme's separator color.
  final Color? dividerColor;

  /// Whether dragging the expanded panel below its minimum size closes it.
  final bool dragClosed;

  /// The distance below the minimum size at which dragging closes the panel.
  final double dragClosedBuffer;

  /// The builder for the expanded panel content.
  final WidgetBuilder? expandedBuilder;

  /// Background color of the expanded panel. If null, uses [color] or the theme's canvas color.
  final Color? expandedColor;

  /// The maximum height the expanded panel can be resized to.
  final double expandedMaxHeight;

  /// The minimum height of the expanded panel.
  final double expandedMinHeight;

  /// The initial height of the expanded panel. Defaults to [expandedMinHeight].
  final double? expandedStartHeight;

  /// The horizontal scope of the expanded panel.
  ///
  /// [CNStatusBarExpansionMode.overContent] leaves sidebars intact.
  /// [CNStatusBarExpansionMode.overAll] spans the full window width.
  final CNStatusBarExpansionMode expansionMode;

  /// Margin around the floating panel (only used with [CNStatusBarPresentationStyle.floating]).
  final EdgeInsets floatingMargin;

  /// Height of the collapsed status bar.
  final double height;

  /// Whether the expanded panel can be resized by dragging its edge.
  final bool isResizable;

  /// Builder for items on the left side of the status bar.
  final CNStatusBarItemsBuilder? leftItems;

  /// Padding at the end (right) of the status bar items row.
  final double paddingEnd;

  /// Padding at the start (left) of the status bar items row.
  final double paddingStart;

  /// How the expanded panel is presented visually.
  ///
  /// [CNStatusBarPresentationStyle.push] makes the content shrink to accommodate the panel.
  /// [CNStatusBarPresentationStyle.floating] overlays the panel on top of the content.
  final CNStatusBarPresentationStyle presentationStyle;

  /// Builder for items on the right side of the status bar.
  final CNStatusBarItemsBuilder? rightItems;

  /// Whether the expanded panel is shown by default.
  final bool shownByDefault;
}
