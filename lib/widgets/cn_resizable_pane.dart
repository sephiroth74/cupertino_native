import 'dart:math' as math show max, min;

import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/services.dart' show SystemMouseCursor;
import 'package:flutter/widgets.dart';

const double _kResizeThresholdSize = 6.0;

/// Resizable sides for [CNResizablePane].
enum CNResizableSide {
  /// The pane can be resized from the left edge.
  left,

  /// The pane can be resized from the right edge.
  right,

  /// The pane can be resized from the top edge.
  top,
}

/// A widget that represents a resizable pane in the AppKit UI.
///
/// This widget is a stateful widget that allows users to resize the pane
/// within the application. It is part of the `appkit_ui_elements` library.
///
/// Usage:
/// ```dart
/// CNResizablePane(
///   minSize: 180,
///   startSize: 200,
///   windowBreakpoint: 700,
///   resizableSide: CNResizableSide.right,
///   builder: (_, __) {
///     return const Center(
///       child: Text('Left Resizable Pane'),
///     );
///   },
/// );
/// ```
///
class CNResizablePane extends StatefulWidget {
  /// Creates a resizable pane with the given parameters.
  const CNResizablePane({
    super.key,
    required ScrollableWidgetBuilder this.builder,
    this.decoration,
    this.maxSize = 500.0,
    required this.minSize,
    this.isResizable = true,
    required this.resizableSide,
    this.windowBreakpoint,
    required this.startSize,
  }) : child = null,
       useScrollBar = true,
       assert(maxSize >= minSize, 'minSize should not be more than maxSize.'),
       assert(
         (startSize >= minSize) && (startSize <= maxSize),
         'startSize must not be less than minSize or more than maxWidth',
       );

  /// Creates a resizable pane without a scroll bar.
  const CNResizablePane.noScrollBar({
    super.key,
    required Widget this.child,
    this.decoration,
    this.maxSize = 500.0,
    required this.minSize,
    this.isResizable = true,
    required this.resizableSide,
    this.windowBreakpoint,
    required this.startSize,
  }) : builder = null,
       useScrollBar = false,
       assert(maxSize >= minSize, 'minSize should not be more than maxSize.'),
       assert(
         (startSize >= minSize) && (startSize <= maxSize),
         'startSize must not be less than minSize or more than maxWidth',
       );

  /// The builder function for the content of the resizable pane.
  final ScrollableWidgetBuilder? builder;

  /// The child widget for the content of the resizable pane.
  final Widget? child;

  /// The decoration for the resizable pane.
  final BoxDecoration? decoration;

  /// Whether the pane can be resized by the user.
  final bool isResizable;

  /// The maximum size of the resizable pane.
  final double maxSize;

  /// The minimum size of the resizable pane.
  final double minSize;

  /// The side of the pane that can be resized by the user.
  final CNResizableSide resizableSide;

  /// The initial size of the resizable pane.
  final double startSize;

  /// Whether to use a scroll bar for the content of the resizable pane.
  final bool useScrollBar;

  /// The window breakpoint for the resizable pane.
  final double? windowBreakpoint;

  @override
  State<CNResizablePane> createState() => _CNResizablePaneState();
}

class _CNResizablePaneState extends State<CNResizablePane> {
  late SystemMouseCursor _cursor;
  late double _dragStartPosition;
  late double _dragStartSize;
  final _scrollController = ScrollController();
  late double _size;

  @override
  void didUpdateWidget(covariant CNResizablePane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.windowBreakpoint != widget.windowBreakpoint ||
        oldWidget.minSize != widget.minSize ||
        oldWidget.maxSize != widget.maxSize ||
        oldWidget.resizableSide != widget.resizableSide) {
      if (widget.minSize > _size) _size = widget.minSize;
      if (widget.maxSize < _size) _size = widget.maxSize;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _cursor = _resizeOnTop
        ? SystemMouseCursors.resizeRow
        : SystemMouseCursors.resizeColumn;
    _size = widget.startSize;
    _scrollController.addListener(() => setState(() {}));
  }

  Color get _dividerColor => CNTheme.of(context).separatorColor;

  bool get _resizeOnRight => widget.resizableSide == CNResizableSide.right;

  bool get _resizeOnTop => widget.resizableSide == CNResizableSide.top;

  BoxDecoration get _decoration {
    final borderSide = BorderSide(color: _dividerColor);
    final right = Border(right: borderSide);
    final left = Border(left: borderSide);
    final top = Border(top: borderSide);
    return BoxDecoration(
      border: _resizeOnTop ? top : (_resizeOnRight ? right : left),
    ).copyWith(
      color: widget.decoration?.color,
      border: widget.decoration?.border,
      borderRadius: widget.decoration?.borderRadius,
      boxShadow: widget.decoration?.boxShadow,
      backgroundBlendMode: widget.decoration?.backgroundBlendMode,
      gradient: widget.decoration?.gradient,
      image: widget.decoration?.image,
      shape: widget.decoration?.shape,
    );
  }

  BoxConstraints get _boxConstraint {
    if (_resizeOnTop) {
      return BoxConstraints(
        maxHeight: widget.maxSize,
        minHeight: widget.minSize,
      ).normalize();
    }
    return BoxConstraints(
      maxWidth: widget.maxSize,
      minWidth: widget.minSize,
    ).normalize();
  }

  Widget get _resizeArea {
    return _resizeOnTop
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: MouseRegion(
              cursor: _cursor,
              child: const SizedBox(width: _kResizeThresholdSize),
            ),
            onVerticalDragStart: (details) {
              _dragStartSize = _size;
              _dragStartPosition = details.globalPosition.dy;
            },
            onVerticalDragUpdate: (details) {
              setState(() {
                final newHeight =
                    _dragStartSize +
                    (_dragStartPosition - details.globalPosition.dy);
                _size = math.max(
                  widget.minSize,
                  math.min(widget.maxSize, newHeight),
                );
                if (_size == widget.minSize) {
                  _cursor = SystemMouseCursors.resizeUp;
                } else if (_size == widget.maxSize) {
                  _cursor = SystemMouseCursors.resizeDown;
                } else {
                  _cursor = SystemMouseCursors.resizeRow;
                }
              });
            },
          )
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: MouseRegion(
              cursor: _cursor,
              child: const SizedBox(width: _kResizeThresholdSize),
            ),
            onHorizontalDragStart: (details) {
              _dragStartSize = _size;
              _dragStartPosition = details.globalPosition.dx;
            },
            onHorizontalDragUpdate: (details) {
              setState(() {
                final newWidth = _resizeOnRight
                    ? _dragStartSize -
                          (_dragStartPosition - details.globalPosition.dx)
                    : _dragStartSize +
                          (_dragStartPosition - details.globalPosition.dx);
                _size = math.max(
                  widget.minSize,
                  math.min(widget.maxSize, newWidth),
                );
                if (_size == widget.minSize) {
                  _cursor = _resizeOnRight
                      ? SystemMouseCursors.resizeRight
                      : SystemMouseCursors.resizeLeft;
                } else if (_size == widget.maxSize) {
                  _cursor = _resizeOnRight
                      ? SystemMouseCursors.resizeLeft
                      : SystemMouseCursors.resizeRight;
                } else {
                  _cursor = SystemMouseCursors.resizeColumn;
                }
              });
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxHeight = media.size.height;
    final maxWidth = media.size.width;

    if (_resizeOnTop) {
      if (widget.windowBreakpoint != null &&
          maxHeight <= widget.windowBreakpoint!) {
        return const SizedBox.shrink();
      }
    } else {
      if (widget.windowBreakpoint != null &&
          maxWidth <= widget.windowBreakpoint!) {
        return const SizedBox.shrink();
      }
    }

    return Container(
      width: _resizeOnTop ? maxWidth : _size,
      height: _resizeOnTop ? _size : maxHeight,
      decoration: _decoration,
      constraints: _boxConstraint,
      child: Stack(
        children: [
          SafeArea(
            left: false,
            right: false,
            child: widget.useScrollBar
                ? CNScrollbar(
                    controller: _scrollController,
                    child: widget.builder!(context, _scrollController),
                  )
                : widget.child!,
          ),
          if (widget.isResizable && !_resizeOnRight && !_resizeOnTop)
            Positioned(
              left: 0,
              width: _kResizeThresholdSize,
              height: maxHeight,
              child: _resizeArea,
            ),
          if (widget.isResizable && _resizeOnRight)
            Positioned(
              right: 0,
              width: _kResizeThresholdSize,
              height: maxHeight,
              child: _resizeArea,
            ),
          if (widget.isResizable && _resizeOnTop)
            Positioned(
              top: 0,
              width: maxWidth,
              height: _kResizeThresholdSize,
              child: _resizeArea,
            ),
        ],
      ),
    );
  }
}
