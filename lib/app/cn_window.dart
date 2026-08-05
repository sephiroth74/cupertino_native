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
  const CNWindowScope({
    super.key,
    required this.constraints,
    required super.child,
    required this.isSidebarShown,
    required this.isEndSidebarShown,
    required this.isStatusBarExpanded,
    required this.visibleSidebarWidth,
    required this.visibleEndSidebarWidth,
    required this.toolbarSpansFullWidth,
    required VoidCallback sidebarToggler,
    required VoidCallback endSidebarToggler,
    required VoidCallback statusBarToggler,
  }) : _sidebarToggler = sidebarToggler,
       _endSidebarToggler = endSidebarToggler,
       _statusBarToggler = statusBarToggler;

  /// Provides the constraints from the [CNWindow] to its descendants.
  final BoxConstraints constraints;

  /// Provides the current visible state of the end [Sidebar].
  final bool isEndSidebarShown;

  /// Provides the current visible state of the [Sidebar].
  final bool isSidebarShown;

  /// Whether the status bar expanded panel is currently shown.
  final bool isStatusBarExpanded;

  /// Whether the page toolbar spans the full window width (see
  /// [CNWindow.toolbarSpansFullWidth]). When true, `CNPageScaffold` insets its
  /// body by the visible sidebar widths so content clears the sidebars while the
  /// toolbar strip still runs edge to edge.
  final bool toolbarSpansFullWidth;

  /// Current on-screen width of the end sidebar (0 when hidden). Used by
  /// `CNPageScaffold` to inset its body in [toolbarSpansFullWidth] mode.
  final double visibleEndSidebarWidth;

  /// Current on-screen width of the leading sidebar (0 when hidden). Used by
  /// `CNPageScaffold` to inset its body in [toolbarSpansFullWidth] mode.
  final double visibleSidebarWidth;

  final Function _endSidebarToggler;
  final Function _sidebarToggler;
  final Function _statusBarToggler;

  @override
  bool updateShouldNotify(CNWindowScope oldWidget) {
    return constraints != oldWidget.constraints ||
        isSidebarShown != oldWidget.isSidebarShown ||
        isEndSidebarShown != oldWidget.isEndSidebarShown ||
        isStatusBarExpanded != oldWidget.isStatusBarExpanded ||
        visibleSidebarWidth != oldWidget.visibleSidebarWidth ||
        visibleEndSidebarWidth != oldWidget.visibleEndSidebarWidth ||
        toolbarSpansFullWidth != oldWidget.toolbarSpansFullWidth;
  }

  /// Toggles the [endSidebar] of the [CNWindow].
  void toggleEndSidebar() {
    _endSidebarToggler();
  }

  /// Toggles the [Sidebar] of the [CNWindow].
  void toggleSidebar() {
    debugPrint('toggleSidebar: $isSidebarShown -> ${!isSidebarShown}');
    _sidebarToggler();
  }

  /// Toggles the status bar expanded panel.
  void toggleStatusBar() {
    _statusBarToggler();
  }

  /// Returns a [CNWindowScope] of the [CNWindow] that most tightly
  /// encloses the given [context]. The result can be null.
  static CNWindowScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CNWindowScope>();
  }

  /// Returns the [CNWindowScope] of the [CNWindow] that most tightly encloses
  /// the given [context].
  static CNWindowScope of(BuildContext context) {
    final CNWindowScope? result = context
        .dependOnInheritedWidgetOfExactType<CNWindowScope>();
    assert(result != null, 'No CNWindowScope found in context');
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
    this.statusBar,
    this.state = NSVisualEffectViewState.followsWindowActiveState,
    this.toolbarSpansFullWidth = false,
    this.childMaterial = NSVisualEffectViewMaterial.fullScreenUI,
  });

  /// The material of the child widget. This is used to determine the background color of the window.
  final NSVisualEffectViewMaterial childMaterial;

  /// The background color of the window. If null, the default canvas color from the current [CNTheme] is used.
  final Color? backgroundColor;

  /// The child widget to be displayed in the window.
  final Widget? child;

  /// The end sidebar configuration (right side).
  final CNSidebar? endSidebar;

  /// The sidebar configuration (left side).
  final CNSidebar? sidebar;

  /// The visual effect state for the window.
  final NSVisualEffectViewState state;

  /// The status bar configuration (bottom).
  final CNStatusBar? statusBar;

  /// Whether the page toolbar should span the full window width instead of
  /// being confined to the content area (i.e. "split" by the sidebar).
  ///
  /// When true, the content area — which carries the toolbar via
  /// `CNPageScaffold` — extends across the whole window, so its toolbar strip
  /// runs edge to edge over the sidebar. The sidebars are dropped below the
  /// toolbar strip (offset down by [kCNToolbarHeight]) and painted on top of
  /// the content, mirroring macOS's unified-titlebar layout.
  ///
  /// When false (the default), the toolbar starts at the sidebar's trailing
  /// edge, preserving the classic split-titlebar look.
  final bool toolbarSpansFullWidth;

  @override
  State<CNWindow> createState() => _CNWindowState();
}

class _CNWindowState extends State<CNWindow> {
  /// While a resize drag is in progress, holds the cursor to force across the
  /// whole window. A fast drag moves the pointer outside the thin resizer's
  /// [MouseRegion], which would otherwise revert the cursor to the default;
  /// a full-window overlay keeps this cursor until the drag ends or is
  /// cancelled. Null when no resize is active.
  SystemMouseCursor? _activeResizeCursor;

  SystemMouseCursor _endSidebarCursor = SystemMouseCursors.resizeLeft;
  double _endSidebarDragStartPosition = 0.0;
  double _endSidebarDragStartWidth = 0.0;
  double _endSidebarWidth = 0.0;
  late bool _showEndSidebar = widget.endSidebar?.shownByDefault ?? false;
  bool _showSidebar = true;
  late bool _showStatusBarPanel = widget.statusBar?.shownByDefault ?? false;
  SystemMouseCursor _sidebarCursor = SystemMouseCursors.resizeColumn;
  double _sidebarDragStartPosition = 0.0;
  double _sidebarDragStartWidth = 0.0;
  double _sidebarWidth = 0.0;
  // Duration currently driving the AnimatedPositioned children. Held at
  // [Duration.zero] except while a toggle is in flight, so resize drags stay
  // instantaneous; the active toggler sets it to the triggering panel's
  // slideDuration and resets it once the slide completes.
  Duration _slideDuration = Duration.zero;
  SystemMouseCursor _statusBarCursor = SystemMouseCursors.resizeUp;
  double _statusBarDragStartPosition = 0.0;
  double _statusBarDragStartSize = 0.0;
  double _statusBarPanelHeight = 0.0;

  @override
  void didUpdateWidget(covariant CNWindow old) {
    super.didUpdateWidget(old);
    final sidebar = widget.sidebar;
    if (sidebar == null) {
      _sidebarWidth = 0.0;
    } else if (sidebar.minWidth != old.sidebar!.minWidth ||
        sidebar.maxWidth != old.sidebar!.maxWidth) {
      if (sidebar.minWidth > _sidebarWidth) {
        _sidebarWidth = sidebar.minWidth;
      }
      if (sidebar.maxWidth! < _sidebarWidth) {
        _sidebarWidth = sidebar.maxWidth!;
      }
    }
    final endSidebar = widget.endSidebar;
    if (endSidebar == null) {
      _endSidebarWidth = 0.0;
    } else if (endSidebar.minWidth != old.endSidebar!.minWidth ||
        endSidebar.maxWidth != old.endSidebar!.maxWidth) {
      if (endSidebar.minWidth > _endSidebarWidth) {
        _endSidebarWidth = endSidebar.minWidth;
      }
      if (endSidebar.maxWidth! < _endSidebarWidth) {
        _endSidebarWidth = endSidebar.maxWidth!;
      }
    }
  }

  /// Drives a panel toggle with its slide animation: sets [_slideDuration] to
  /// the triggering panel's duration, flips its visibility, then resets the
  /// duration to zero once the slide completes so subsequent resize drags stay
  /// instantaneous. A [Duration.zero] duration toggles instantly (no animation).
  Future<void> _animateToggle(Duration duration, VoidCallback toggle) async {
    setState(() {
      _slideDuration = duration;
      toggle();
    });
    await Future<void>.delayed(duration);
    if (mounted) {
      setState(() => _slideDuration = Duration.zero);
    }
  }

  @override
  void initState() {
    super.initState();
    _sidebarWidth =
        (widget.sidebar?.startWidth ?? widget.sidebar?.minWidth) ??
        _sidebarWidth;
    _endSidebarWidth =
        (widget.endSidebar?.startWidth ?? widget.endSidebar?.minWidth) ??
        _endSidebarWidth;
    _statusBarPanelHeight =
        (widget.statusBar?.expandedStartHeight ??
            widget.statusBar?.expandedMinHeight) ??
        _statusBarPanelHeight;
  }

  @override
  // ignore: code-metrics
  Widget build(BuildContext context) {
    assert(debugCheckHasCNTheme(context));
    final sidebar = widget.sidebar;
    final endSidebar = widget.endSidebar;
    final statusBar = widget.statusBar;
    if (sidebar?.startWidth != null) {
      assert(
        (sidebar!.startWidth! >= sidebar.minWidth) &&
            (sidebar.startWidth! <= sidebar.maxWidth!),
      );
    }
    if (endSidebar?.startWidth != null) {
      assert(
        (endSidebar!.startWidth! >= endSidebar.minWidth) &&
            (endSidebar.startWidth! <= endSidebar.maxWidth!),
      );
    }
    final theme = CNTheme.of(context);
    late Color backgroundColor = widget.backgroundColor ?? theme.canvasColor;
    Color dividerColor = theme.separatorColor;
    CNBrightnessOverrideHandler.ensureMatchingBrightness(theme.brightness);
    const curve = Curves.linearToEaseOut;
    final duration = _slideDuration;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final isAtBreakpoint = width <= (sidebar?.windowBreakpoint ?? 0);
        final isAtEndBreakpoint = width <= (endSidebar?.windowBreakpoint ?? 0);
        final canShowSidebar =
            _showSidebar && !isAtBreakpoint && sidebar != null;
        final canShowEndSidebar =
            _showEndSidebar && !isAtEndBreakpoint && endSidebar != null;
        final visibleSidebarWidth = canShowSidebar ? _sidebarWidth : 0.0;
        final visibleEndSidebarWidth = canShowEndSidebar
            ? _endSidebarWidth
            : 0.0;
        final state = widget.state;

        final statusBarHeight = statusBar?.height ?? 0.0;
        final hasStatusBar = statusBar != null;
        final expansionMode =
            statusBar?.expansionMode ?? CNStatusBarExpansionMode.overContent;
        final presentationStyle =
            statusBar?.presentationStyle ?? CNStatusBarPresentationStyle.push;
        final isFloating =
            presentationStyle == CNStatusBarPresentationStyle.floating;

        // In push mode, panel height reduces the content area. In floating mode, it doesn't.
        final visiblePanelHeight = (_showStatusBarPanel && !isFloating)
            ? _statusBarPanelHeight
            : 0.0;

        // Horizontal bounds for the panel based on expansion mode
        final panelIsOverAll =
            expansionMode == CNStatusBarExpansionMode.overAll;
        final panelLeft = panelIsOverAll ? 0.0 : visibleSidebarWidth;
        final panelRight = panelIsOverAll ? 0.0 : visibleEndSidebarWidth;

        // The height available for the main Stack (excludes the status bar)
        final stackHeight = height - (hasStatusBar ? statusBarHeight : 0.0);

        // In overAll push mode the expanded panel spans the full window width
        // and sits below everything, so the sidebars must shrink from the
        // bottom too (otherwise their full-height native subviews overlap the
        // panel). In overContent mode the panel is inset to the content area,
        // so sidebars keep their full height.
        final sidebarHeight =
            stackHeight - (panelIsOverAll ? visiblePanelHeight : 0.0);

        // Full-width toolbar mode: the content area (which carries the toolbar
        // via CNPageScaffold) spans the whole window, so the toolbar strip runs
        // edge to edge. The sidebars drop below that strip and are painted on
        // top of the content's blurred gutters; CNPageScaffold insets its body
        // by the sidebar widths (via CNWindowScope) so content clears them.
        final toolbarSpans = widget.toolbarSpansFullWidth;
        final toolbarStripHeight = toolbarSpans ? kCNToolbarHeight : 0.0;
        final effectiveSidebarHeight = sidebarHeight - toolbarStripHeight;
        final contentLeft = toolbarSpans ? 0.0 : visibleSidebarWidth;
        final contentWidth = toolbarSpans
            ? width
            : width - visibleSidebarWidth - visibleEndSidebarWidth;
        final backgroundLeft = toolbarSpans ? 0.0 : visibleSidebarWidth;

        // The leading sidebar. In full-width mode it drops below the toolbar
        // strip and paints on top of the content area's left gutter, so it is
        // added to the stack AFTER the content area; in split mode it sits
        // beside the content and is added before it (so the content slides over
        // it when the sidebar is dismissed).
        final Widget? leadingSidebar = sidebar == null
            ? null
            : AnimatedPositioned(
                key: sidebar.key,
                curve: curve,
                duration: duration,
                top: toolbarStripHeight,
                height: effectiveSidebarHeight,
                left: canShowSidebar ? 0.0 : -_sidebarWidth,
                width: _sidebarWidth,
                child: VisualEffectSubviewContainer(
                  state: state,
                  material: sidebar.material,
                  child: Container(
                    color: sidebar.backgroundColor ?? theme.canvasColor,
                    child: Padding(
                      padding: sidebar.padding,
                      child: sidebar.builder(context),
                    ),
                  ),
                ),
              );

        final mainStack = Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Background color
            AnimatedPositioned(
              curve: curve,
              duration: duration,
              height: stackHeight,
              left: backgroundLeft,
              width: width,
              child: ColoredBox(color: backgroundColor),
            ),

            // Leading sidebar (beside the content in split mode).
            if (!toolbarSpans && leadingSidebar != null) leadingSidebar,

            // Content Area (reduced by expanded panel height in push mode).
            // Anchored with explicit top/bottom so the panel space is truly
            // reserved below the content (a height-only Positioned is only
            // aligned, which lets the native content subview overlap the panel).
            // In full-width mode it spans the whole window so its toolbar strip
            // runs edge to edge; the sidebars are overlaid on its gutters below.
            AnimatedPositioned(
              curve: curve,
              duration: duration,
              left: contentLeft,
              width: contentWidth,
              top: 0,
              bottom: visiblePanelHeight,
              child: ClipRect(
                child: VisualEffectSubviewContainer(
                  material: widget.childMaterial,
                  state: state,
                  child: widget.child ?? const SizedBox.shrink(),
                ),
              ),
            ),

            // Leading sidebar (overlaid on the content's left gutter, below the
            // toolbar strip) in full-width mode.
            if (toolbarSpans && leadingSidebar != null) leadingSidebar,

            // Sidebar resizer
            if (sidebar?.isResizable ?? false)
              AnimatedPositioned(
                curve: curve,
                duration: duration,
                top: toolbarStripHeight,
                left: visibleSidebarWidth - 4,
                width: 7,
                height: effectiveSidebarHeight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragStart: (details) {
                    _sidebarDragStartWidth = _sidebarWidth;
                    _sidebarDragStartPosition = details.globalPosition.dx;
                    setState(() => _activeResizeCursor = _sidebarCursor);
                  },
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      var newWidth =
                          _sidebarDragStartWidth +
                          details.globalPosition.dx -
                          _sidebarDragStartPosition;

                      if (sidebar!.startWidth != null &&
                          sidebar.snapToStartBuffer != null &&
                          (newWidth - sidebar.startWidth!).abs() <=
                              sidebar.snapToStartBuffer!) {
                        newWidth = sidebar.startWidth!;
                      }

                      if (sidebar.dragClosed) {
                        final closeBelow =
                            sidebar.minWidth - sidebar.dragClosedBuffer;
                        _showSidebar = newWidth >= closeBelow;
                      }

                      _sidebarWidth = math.max(
                        sidebar.minWidth,
                        math.min(sidebar.maxWidth!, newWidth),
                      );
                      _sidebarCursor = SystemMouseCursors.resizeColumn;
                      _activeResizeCursor = _sidebarCursor;
                    });
                  },
                  onHorizontalDragEnd: (_) =>
                      setState(() => _activeResizeCursor = null),
                  onHorizontalDragCancel: () =>
                      setState(() => _activeResizeCursor = null),
                  child: MouseRegion(
                    cursor: _sidebarCursor,
                    child: Align(
                      alignment: Alignment.center,
                      child: VerticalDivider(
                        thickness: 1,
                        width: 1,
                        color: sidebar?.separatorColor ?? dividerColor,
                      ),
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
                top: toolbarStripHeight,
                height: effectiveSidebarHeight,
                width: _endSidebarWidth,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: endSidebar.minWidth,
                    maxWidth: endSidebar.maxWidth!,
                    minHeight: effectiveSidebarHeight,
                    maxHeight: effectiveSidebarHeight,
                  ).normalize(),
                  child: VisualEffectSubviewContainer(
                    state: state,
                    material: endSidebar.material,
                    child: Container(
                      color: endSidebar.backgroundColor ?? theme.canvasColor,
                      child: Padding(
                        padding: endSidebar.padding,
                        child: endSidebar.builder(context),
                      ),
                    ),
                  ),
                ),
              ),

            // End sidebar resizer
            if (endSidebar?.isResizable ?? false)
              AnimatedPositioned(
                curve: curve,
                duration: duration,
                top: toolbarStripHeight,
                right: visibleEndSidebarWidth - 4,
                width: 7,
                height: effectiveSidebarHeight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragStart: (details) {
                    _endSidebarDragStartWidth = _endSidebarWidth;
                    _endSidebarDragStartPosition = details.globalPosition.dx;
                    setState(() => _activeResizeCursor = _endSidebarCursor);
                  },
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      var newWidth =
                          _endSidebarDragStartWidth -
                          details.globalPosition.dx +
                          _endSidebarDragStartPosition;

                      if (endSidebar!.startWidth != null &&
                          endSidebar.snapToStartBuffer != null &&
                          (newWidth + endSidebar.startWidth!).abs() <=
                              endSidebar.snapToStartBuffer!) {
                        newWidth = endSidebar.startWidth!;
                      }

                      if (endSidebar.dragClosed) {
                        final closeBelow =
                            endSidebar.minWidth - endSidebar.dragClosedBuffer;
                        _showEndSidebar = newWidth >= closeBelow;
                      }

                      _endSidebarWidth = math.max(
                        endSidebar.minWidth,
                        math.min(endSidebar.maxWidth!, newWidth),
                      );

                      if (_endSidebarWidth == endSidebar.minWidth) {
                        _endSidebarCursor = SystemMouseCursors.resizeLeft;
                      } else if (_endSidebarWidth == endSidebar.maxWidth) {
                        _endSidebarCursor = SystemMouseCursors.resizeRight;
                      } else {
                        _endSidebarCursor = SystemMouseCursors.resizeColumn;
                      }
                      _activeResizeCursor = _endSidebarCursor;
                    });
                  },
                  onHorizontalDragEnd: (_) =>
                      setState(() => _activeResizeCursor = null),
                  onHorizontalDragCancel: () =>
                      setState(() => _activeResizeCursor = null),
                  child: MouseRegion(
                    cursor: _endSidebarCursor,
                    child: Align(
                      alignment: Alignment.center,
                      child: VerticalDivider(
                        thickness: 1,
                        width: 1,
                        color: dividerColor,
                      ),
                    ),
                  ),
                ),
              ),

            // Status bar expanded panel. Push and floating share the exact same
            // flat presentation (a bottom-anchored panel with a top divider).
            // They differ only in whether they reserve space: push shrinks the
            // content area via `visiblePanelHeight`, so the panel fills the freed
            // space; floating leaves the content full-height and paints on top.
            if (hasStatusBar && statusBar.expandedBuilder != null)
              AnimatedPositioned(
                curve: curve,
                duration: duration,
                left: panelLeft,
                right: panelRight,
                bottom: 0,
                height: _showStatusBarPanel ? _statusBarPanelHeight : 0.0,
                child: ClipRect(
                  child: ColoredBox(
                    color:
                        statusBar.expandedColor ??
                        statusBar.color ??
                        theme.canvasColor,
                    child: _showStatusBarPanel
                        ? Column(
                            children: [
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: dividerColor,
                              ),
                              Expanded(
                                child: statusBar.expandedBuilder!(context),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),

            // Status bar panel resizer (shared by push and floating: the panel
            // is bottom-anchored in both, so the drag handle sits on its top edge).
            if (hasStatusBar &&
                statusBar.isResizable &&
                statusBar.expandedBuilder != null &&
                _showStatusBarPanel)
              AnimatedPositioned(
                curve: curve,
                duration: duration,
                left: panelLeft,
                right: panelRight,
                bottom: _statusBarPanelHeight - 4,
                height: 7,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragStart: (details) {
                    _statusBarDragStartSize = _statusBarPanelHeight;
                    _statusBarDragStartPosition = details.globalPosition.dy;
                    setState(() => _activeResizeCursor = _statusBarCursor);
                  },
                  onVerticalDragUpdate: (details) {
                    setState(() {
                      var newHeight =
                          _statusBarDragStartSize -
                          (details.globalPosition.dy -
                              _statusBarDragStartPosition);

                      if (statusBar.dragClosed) {
                        final closeBelow =
                            statusBar.expandedMinHeight -
                            statusBar.dragClosedBuffer;
                        _showStatusBarPanel = newHeight >= closeBelow;
                      }

                      _statusBarPanelHeight = math.max(
                        statusBar.expandedMinHeight,
                        math.min(statusBar.expandedMaxHeight, newHeight),
                      );

                      if (_statusBarPanelHeight ==
                          statusBar.expandedMinHeight) {
                        _statusBarCursor = SystemMouseCursors.resizeUp;
                      } else if (_statusBarPanelHeight ==
                          statusBar.expandedMaxHeight) {
                        _statusBarCursor = SystemMouseCursors.resizeDown;
                      } else {
                        _statusBarCursor = SystemMouseCursors.resizeRow;
                      }
                      _activeResizeCursor = _statusBarCursor;
                    });
                  },
                  onVerticalDragEnd: (_) =>
                      setState(() => _activeResizeCursor = null),
                  onVerticalDragCancel: () =>
                      setState(() => _activeResizeCursor = null),
                  child: MouseRegion(
                    cursor: _statusBarCursor,
                    child: Align(
                      alignment: Alignment.center,
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: dividerColor,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );

        final layout = Column(
          children: [
            Expanded(child: mainStack),
            if (hasStatusBar)
              SizedBox(
                height: statusBarHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: statusBar.color ?? theme.canvasColor,
                    border: Border(
                      top: BorderSide(
                        color: statusBar.dividerColor ?? dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: _StatusBarContent(
                    leftItems: statusBar.leftItems,
                    rightItems: statusBar.rightItems,
                    isExpanded: _showStatusBarPanel,
                    paddingStart: statusBar.paddingStart,
                    paddingEnd: statusBar.paddingEnd,
                  ),
                ),
              ),
          ],
        );

        // While a resize drag is in progress, overlay a full-window MouseRegion
        // that pins the resize cursor. A fast drag can move the pointer outside
        // the thin resizer's own MouseRegion; because the drag is owned by the
        // GestureDetector's recognizer (which keeps receiving pointer moves via
        // pointer capture), this opaque top-most region keeps the cursor stable
        // until the drag ends or is cancelled, without stealing the drag.
        //
        // The Stack is ALWAYS present (the overlay is only added/removed as a
        // trailing child) so `layout`'s element — and the active drag recognizer
        // inside it — is never torn down mid-drag by a change of the subtree's
        // widget type.
        final resizeCursor = _activeResizeCursor;
        final windowContent = Stack(
          children: [
            layout,
            if (resizeCursor != null)
              Positioned.fill(child: MouseRegion(cursor: resizeCursor)),
          ],
        );

        return CNWindowScope(
          constraints: constraints,
          isSidebarShown: canShowSidebar,
          isEndSidebarShown: canShowEndSidebar,
          isStatusBarExpanded: _showStatusBarPanel,
          visibleSidebarWidth: visibleSidebarWidth,
          visibleEndSidebarWidth: visibleEndSidebarWidth,
          toolbarSpansFullWidth: widget.toolbarSpansFullWidth,
          sidebarToggler: () => _animateToggle(
            sidebar?.slideDuration ?? Duration.zero,
            () => _showSidebar = !_showSidebar,
          ),
          endSidebarToggler: () => _animateToggle(
            endSidebar?.slideDuration ?? Duration.zero,
            () => _showEndSidebar = !_showEndSidebar,
          ),
          statusBarToggler: () => _animateToggle(
            statusBar?.slideDuration ?? Duration.zero,
            () => _showStatusBarPanel = !_showStatusBarPanel,
          ),
          child: windowContent,
        );
      },
    );
  }
}

class _StatusBarContent extends StatelessWidget {
  const _StatusBarContent({
    required this.leftItems,
    required this.rightItems,
    required this.isExpanded,
    this.paddingStart = 8.0,
    this.paddingEnd = 8.0,
  });

  final bool isExpanded;
  final CNStatusBarItemsBuilder? leftItems;
  final double paddingEnd;
  final double paddingStart;
  final CNStatusBarItemsBuilder? rightItems;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leftItems != null)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: paddingStart),
              child: leftItems!(context, isExpanded),
            ),
          ),
        if (rightItems != null)
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: paddingEnd),
                child: rightItems!(context, isExpanded),
              ),
            ),
          ),
      ],
    );
  }
}
