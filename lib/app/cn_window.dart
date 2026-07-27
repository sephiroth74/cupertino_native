import 'dart:math' as math;

import 'package:cupertino_native/app/cn_brightness_override_handler.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:macos_window_utils/widgets/visual_effect_subview_container/visual_effect_subview_container.dart';

/// A [CNWindowScope] serves as a scope for its descendants to rely on
/// values needed for the layout of the descendants.
///
/// It is embedded in the [CNWindow] and available to the widgets just below
/// it in the widget tree. The [CNWindowScope] passes down the values which
/// are calculated inside [CNWindow] to its descendants.
///
/// Descendants of the [CNWindowScope] automatically work with the values
/// they need, so you will hardly need to manually use the [CNWindowScope].
class CNWindowScope extends InheritedWidget {
  /// Creates a widget that manages the layout of the [CNWindow].
  ///
  /// [ResizablePane] and [ContentArea] are other widgets that depend
  /// on the [CNWindowScope] for layout.
  ///
  /// The [constraints], [contentAreaWidth], [child], [valueNotifier]
  /// and [_scaffoldState] arguments are required and must not be null.
  const CNWindowScope({
    super.key,
    required this.constraints,
    required super.child,
    required this.isSidebarShown,
    required this.isEndSidebarShown,
    required VoidCallback sidebarToggler,
    required VoidCallback endSidebarToggler,
  }) : _sidebarToggler = sidebarToggler,
       _endSidebarToggler = endSidebarToggler;

  /// Provides the constraints from the [CNWindow] to its descendants.
  final BoxConstraints constraints;

  /// Provides the current visible state of the end [Sidebar].
  final bool isEndSidebarShown;

  /// Provides the current visible state of the [Sidebar].
  final bool isSidebarShown;

  /// Provides a callback which will be used to privately toggle the sidebar.
  final Function _endSidebarToggler;

  /// Provides a callback which will be used to privately toggle the sidebar.
  final Function _sidebarToggler;

  @override
  bool updateShouldNotify(CNWindowScope oldWidget) {
    return constraints != oldWidget.constraints || isSidebarShown != oldWidget.isSidebarShown;
  }

  /// Toggles the [endSidebar] of the [CNWindow].
  ///
  /// This does not change the current width of the [endSidebar]. It only
  /// hides or shows it.
  void toggleEndSidebar() {
    _endSidebarToggler();
  }

  /// Toggles the [Sidebar] of the [CNWindow].
  ///
  /// This does not change the current width of the [Sidebar]. It only
  /// hides or shows it.
  void toggleSidebar() {
    _sidebarToggler();
  }

  /// Returns a [CNWindowScope] of the [CNWindow] that most tightly
  /// encloses the given [context]. The result can be null.
  ///
  /// If this [context] does not have a [CNWindow] as its ancestor, the result
  /// returned is null.
  ///
  /// The [context] argument must not be null.
  static CNWindowScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CNWindowScope>();
  }

  /// Returns the [CNWindowScope] of the [CNWindow] that most tightly encloses
  /// the given [context].
  ///
  /// If the [context] does not have a [CNWindow] as its ancestor, an assertion
  /// is thrown.
  ///
  /// The [context] argument must not be null.
  static CNWindowScope of(BuildContext context) {
    final CNWindowScope? result = context.dependOnInheritedWidgetOfExactType<CNWindowScope>();
    assert(result != null, 'No MacosWindowScope found in context');
    return result!;
  }
}

/// A widget that represents a window in a macOS application.
class CNWindow extends StatefulWidget {
  /// Creates a [CNWindow] widget.
  const CNWindow({
    super.key,
    this.child,
    this.sidebar,
    this.backgroundColor,
    this.endSidebar,
    this.state = NSVisualEffectViewState.followsWindowActiveState,
  });

  /// The background color of the window. If null, the default canvas color from the current [CNTheme] is used.
  final Color? backgroundColor;

  /// The child widget to be displayed in the window.
  final Widget? child;

  /// Whether to disable wallpaper tinting for the window. Defaults to false.
  final CNSidebar? endSidebar;

  /// Whether to disable wallpaper tinting for the window. Defaults to false.
  final CNSidebar? sidebar;

  /// Whether to disable wallpaper tinting for the window. Defaults to false.
  final NSVisualEffectViewState state;

  @override
  State<CNWindow> createState() => _CNWindowState();
}

class _CNWindowState extends State<CNWindow> {
  SystemMouseCursor _endSidebarCursor = SystemMouseCursors.resizeLeft;
  double _endSidebarDragStartPosition = 0.0;
  double _endSidebarDragStartWidth = 0.0;
  var _endSidebarScrollController = ScrollController();
  double _endSidebarWidth = 0.0;
  late bool _showEndSidebar = widget.endSidebar?.shownByDefault ?? false;
  bool _showSidebar = true;
  SystemMouseCursor _sidebarCursor = SystemMouseCursors.resizeColumn;
  double _sidebarDragStartPosition = 0.0;
  double _sidebarDragStartWidth = 0.0;
  var _sidebarScrollController = ScrollController();
  int _sidebarSlideDuration = 0;
  double _sidebarWidth = 0.0;

  @override
  void didUpdateWidget(covariant CNWindow old) {
    super.didUpdateWidget(old);
    final sidebar = widget.sidebar;
    if (sidebar == null) {
      _sidebarWidth = 0.0;
    } else if (sidebar.minWidth != old.sidebar!.minWidth || sidebar.maxWidth != old.sidebar!.maxWidth) {
      if (sidebar.minWidth > _sidebarWidth) {
        _sidebarWidth = sidebar.minWidth;
      }
      if (sidebar.maxWidth! < _sidebarWidth) {
        _sidebarWidth = sidebar.maxWidth!;
      }
    }
    if (sidebar?.key != old.sidebar?.key) {
      _sidebarScrollController.dispose();
      _sidebarScrollController = ScrollController();
      _addSidebarScrollControllerListenerIfNeeded();
    }
    final endSidebar = widget.endSidebar;
    if (endSidebar == null) {
      _endSidebarWidth = 0.0;
    } else if (endSidebar.minWidth != old.endSidebar!.minWidth || endSidebar.maxWidth != old.endSidebar!.maxWidth) {
      if (endSidebar.minWidth > _endSidebarWidth) {
        _endSidebarWidth = endSidebar.minWidth;
      }
      if (endSidebar.maxWidth! < _endSidebarWidth) {
        _endSidebarWidth = endSidebar.maxWidth!;
      }
    }
    if (endSidebar?.key != old.endSidebar?.key) {
      _endSidebarScrollController.dispose();
      _endSidebarScrollController = ScrollController();
      _addEndSidebarScrollControllerListenerIfNeeded();
    }
  }

  @override
  void dispose() {
    _sidebarScrollController.dispose();
    _endSidebarScrollController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _sidebarWidth = (widget.sidebar?.startWidth ?? widget.sidebar?.minWidth) ?? _sidebarWidth;
    _endSidebarWidth = (widget.endSidebar?.startWidth ?? widget.endSidebar?.minWidth) ?? _endSidebarWidth;
    _addSidebarScrollControllerListenerIfNeeded();
    _addEndSidebarScrollControllerListenerIfNeeded();
  }

  void _addEndSidebarScrollControllerListenerIfNeeded() {
    if (widget.endSidebar?.builder != null) {
      _endSidebarScrollController.addListener(() => setState(() {}));
    }
  }

  void _addSidebarScrollControllerListenerIfNeeded() {
    if (widget.sidebar?.builder != null) {
      _sidebarScrollController.addListener(() => setState(() {}));
    }
  }

  @override
  // ignore: code-metrics
  Widget build(BuildContext context) {
    assert(debugCheckHasCNTheme(context));
    final sidebar = widget.sidebar;
    final endSidebar = widget.endSidebar;
    if (sidebar?.startWidth != null) {
      assert((sidebar!.startWidth! >= sidebar.minWidth) && (sidebar.startWidth! <= sidebar.maxWidth!));
    }
    if (endSidebar?.startWidth != null) {
      assert((endSidebar!.startWidth! >= endSidebar.minWidth) && (endSidebar.startWidth! <= endSidebar.maxWidth!));
    }
    final theme = CNTheme.of(context);
    late Color backgroundColor = widget.backgroundColor ?? theme.canvasColor;
    late Color endSidebarBackgroundColor;
    Color dividerColor = theme.separatorColor;

    // Respect the sidebar color override from parent if one is given
    if (sidebar?.decoration?.color != null) {
      sidebar!.decoration!.color!;
    } else {
    }

    // Set the application window's brightness on macOS
    CNBrightnessOverrideHandler.ensureMatchingBrightness(theme.brightness);

    // Respect the end sidebar color override from parent if one is given
    if (endSidebar?.decoration?.color != null) {
      endSidebarBackgroundColor = endSidebar!.decoration!.color!;
    } else {
      endSidebarBackgroundColor = theme.canvasColor;
    }

    const curve = Curves.linearToEaseOut;
    final duration = Duration(milliseconds: _sidebarSlideDuration);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final isAtBreakpoint = width <= (sidebar?.windowBreakpoint ?? 0);
        final isAtEndBreakpoint = width <= (endSidebar?.windowBreakpoint ?? 0);
        final canShowSidebar = _showSidebar && !isAtBreakpoint && sidebar != null;
        final canShowEndSidebar = _showEndSidebar && !isAtEndBreakpoint && endSidebar != null;
        final visibleSidebarWidth = canShowSidebar ? _sidebarWidth : 0.0;
        final visibleEndSidebarWidth = canShowEndSidebar ? _endSidebarWidth : 0.0;
        final state = widget.state;

        final layout = Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Background color
            AnimatedPositioned(
              curve: curve,
              duration: duration,
              height: height,
              left: visibleSidebarWidth,
              width: width,
              child: ColoredBox(color: backgroundColor),
            ),

            // Sidebar (slides in/out, width stays fixed)
            if (sidebar != null)
              AnimatedPositioned(
                key: sidebar.key,
                curve: curve,
                duration: duration,
                height: height,
                left: canShowSidebar ? 0.0 : -_sidebarWidth,
                width: _sidebarWidth,
                child: VisualEffectSubviewContainer(
                  state: state,
                  material: NSVisualEffectViewMaterial.sidebar,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 1.0), backgroundBlendMode: BlendMode.clear),
                    child: CNScrollbar(
                      controller: _sidebarScrollController,
                      child: Padding(padding: sidebar.padding, child: sidebar.builder(context, _sidebarScrollController)),
                    ),
                  ),
                ),
              ),

            // Content Area
            AnimatedPositioned(
              curve: curve,
              duration: duration,
              left: visibleSidebarWidth,
              width: width - visibleSidebarWidth - visibleEndSidebarWidth,
              height: height,
              child: ClipRect(
                child: VisualEffectSubviewContainer(
                  material: NSVisualEffectViewMaterial.fullScreenUI,
                  state: state,
                  child: widget.child ?? const SizedBox.shrink(),
                ),
              ),
            ),

            // Sidebar resizer
            if (sidebar?.isResizable ?? false)
              AnimatedPositioned(
                curve: curve,
                duration: duration,
                left: visibleSidebarWidth - 4,
                width: 7,
                height: height,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragStart: (details) {
                    _sidebarDragStartWidth = _sidebarWidth;
                    _sidebarDragStartPosition = details.globalPosition.dx;
                  },
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      var newWidth = _sidebarDragStartWidth + details.globalPosition.dx - _sidebarDragStartPosition;

                      if (sidebar!.startWidth != null &&
                          sidebar.snapToStartBuffer != null &&
                          (newWidth - sidebar.startWidth!).abs() <= sidebar.snapToStartBuffer!) {
                        newWidth = sidebar.startWidth!;
                      }

                      if (sidebar.dragClosed) {
                        final closeBelow = sidebar.minWidth - sidebar.dragClosedBuffer;
                        _showSidebar = newWidth >= closeBelow;
                      }

                      _sidebarWidth = math.max(sidebar.minWidth, math.min(sidebar.maxWidth!, newWidth));

                      if (_sidebarWidth == sidebar.minWidth) {
                        _sidebarCursor = SystemMouseCursors.resizeRight;
                      } else if (_sidebarWidth == sidebar.maxWidth) {
                        _sidebarCursor = SystemMouseCursors.resizeLeft;
                      } else {
                        _sidebarCursor = SystemMouseCursors.resizeColumn;
                      }
                    });
                  },
                  child: MouseRegion(
                    cursor: _sidebarCursor,
                    child: Align(
                      alignment: Alignment.center,
                      child: VerticalDivider(thickness: 1, width: 1, color: dividerColor),
                    ),
                  ),
                ),
              ),

            // End sidebar (slides in/out from right)
            if (endSidebar != null)
              AnimatedPositioned(
                key: endSidebar.key,
                left: canShowEndSidebar ? width - _endSidebarWidth : width,
                curve: curve,
                duration: duration,
                height: height,
                width: _endSidebarWidth,
                child: Container(
                  color: endSidebarBackgroundColor,
                  constraints: BoxConstraints(
                    minWidth: endSidebar.minWidth,
                    maxWidth: endSidebar.maxWidth!,
                    minHeight: height,
                    maxHeight: height,
                  ).normalize(),
                  child: CNScrollbar(
                    controller: _endSidebarScrollController,
                    child: Padding(padding: endSidebar.padding, child: endSidebar.builder(context, _endSidebarScrollController)),
                  ),
                ),
              ),

            // End sidebar resizer
            if (endSidebar?.isResizable ?? false)
              AnimatedPositioned(
                curve: curve,
                duration: duration,
                right: visibleEndSidebarWidth - 4,
                width: 7,
                height: height,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragStart: (details) {
                    _endSidebarDragStartWidth = _endSidebarWidth;
                    _endSidebarDragStartPosition = details.globalPosition.dx;
                  },
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      var newWidth = _endSidebarDragStartWidth - details.globalPosition.dx + _endSidebarDragStartPosition;

                      if (endSidebar!.startWidth != null &&
                          endSidebar.snapToStartBuffer != null &&
                          (newWidth + endSidebar.startWidth!).abs() <= endSidebar.snapToStartBuffer!) {
                        newWidth = endSidebar.startWidth!;
                      }

                      if (endSidebar.dragClosed) {
                        final closeBelow = endSidebar.minWidth - endSidebar.dragClosedBuffer;
                        _showEndSidebar = newWidth >= closeBelow;
                      }

                      _endSidebarWidth = math.max(endSidebar.minWidth, math.min(endSidebar.maxWidth!, newWidth));

                      if (_endSidebarWidth == endSidebar.minWidth) {
                        _endSidebarCursor = SystemMouseCursors.resizeLeft;
                      } else if (_endSidebarWidth == endSidebar.maxWidth) {
                        _endSidebarCursor = SystemMouseCursors.resizeRight;
                      } else {
                        _endSidebarCursor = SystemMouseCursors.resizeColumn;
                      }
                    });
                  },
                  child: MouseRegion(
                    cursor: _endSidebarCursor,
                    child: Align(
                      alignment: Alignment.center,
                      child: VerticalDivider(thickness: 1, width: 1, color: dividerColor),
                    ),
                  ),
                ),
              ),
          ],
        );

        return CNWindowScope(
          constraints: constraints,
          isSidebarShown: canShowSidebar,
          isEndSidebarShown: canShowEndSidebar,
          sidebarToggler: () async {
            setState(() => _sidebarSlideDuration = 300);
            setState(() => _showSidebar = !_showSidebar);
            await Future.delayed(Duration(milliseconds: _sidebarSlideDuration));
            if (mounted) {
              setState(() => _sidebarSlideDuration = 0);
            }
          },
          endSidebarToggler: () async {
            setState(() => _sidebarSlideDuration = 300);
            setState(() => _showEndSidebar = !_showEndSidebar);
            await Future.delayed(Duration(milliseconds: _sidebarSlideDuration));
            if (mounted) {
              setState(() => _sidebarSlideDuration = 0);
            }
          },
          child: layout,
        );
      },
    );
  }
}
