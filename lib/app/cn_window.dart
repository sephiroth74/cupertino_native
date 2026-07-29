import 'dart:math' as math;

import 'package:cupertino_native/app/cn_brightness_override_handler.dart';
import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native/utils/utils.dart';
import 'package:flutter/foundation.dart';
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

  final Function _endSidebarToggler;
  final Function _sidebarToggler;
  final Function _statusBarToggler;

  @override
  bool updateShouldNotify(CNWindowScope oldWidget) {
    return constraints != oldWidget.constraints ||
        isSidebarShown != oldWidget.isSidebarShown ||
        isEndSidebarShown != oldWidget.isEndSidebarShown ||
        isStatusBarExpanded != oldWidget.isStatusBarExpanded;
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
    final CNWindowScope? result = context.dependOnInheritedWidgetOfExactType<CNWindowScope>();
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
    this.toolbar,
    this.state = NSVisualEffectViewState.followsWindowActiveState,
  });

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

  /// The native toolbar configuration.
  final CNToolbarConfig? toolbar;

  @override
  State<CNWindow> createState() => _CNWindowState();
}

class _CNWindowState extends State<CNWindow> {
  static const bool _debugToolbar = true;
  static const MethodChannel _toolbarChannel = MethodChannel('cupertino_native');

  SystemMouseCursor _endSidebarCursor = SystemMouseCursors.resizeLeft;
  double _endSidebarDragStartPosition = 0.0;
  double _endSidebarDragStartWidth = 0.0;
  var _endSidebarScrollController = ScrollController();
  double _endSidebarWidth = 0.0;
  bool _isUpdatingSearchFromNative = false;
  Map<String, dynamic>? _lastToolbarPayload;
  final GlobalKey _scopeChildKey = GlobalKey();
  late bool _showEndSidebar = widget.endSidebar?.shownByDefault ?? false;
  bool _showSidebar = true;
  late bool _showStatusBarPanel = widget.statusBar?.shownByDefault ?? false;
  SystemMouseCursor _sidebarCursor = SystemMouseCursors.resizeColumn;
  double _sidebarDragStartPosition = 0.0;
  double _sidebarDragStartWidth = 0.0;
  var _sidebarScrollController = ScrollController();
  int _sidebarSlideDuration = 0;
  double _sidebarWidth = 0.0;
  SystemMouseCursor _statusBarCursor = SystemMouseCursors.resizeUp;
  double _statusBarDragStartPosition = 0.0;
  double _statusBarDragStartSize = 0.0;
  double _statusBarPanelHeight = 0.0;
  final _statusBarScrollController = ScrollController();

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
    _syncToolbar();
  }

  @override
  void dispose() {
    _clearToolbar();
    _toolbarChannel.setMethodCallHandler(null);
    _sidebarScrollController.dispose();
    _endSidebarScrollController.dispose();
    _statusBarScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _sidebarWidth = (widget.sidebar?.startWidth ?? widget.sidebar?.minWidth) ?? _sidebarWidth;
    _endSidebarWidth = (widget.endSidebar?.startWidth ?? widget.endSidebar?.minWidth) ?? _endSidebarWidth;
    _statusBarPanelHeight = (widget.statusBar?.expandedStartHeight ?? widget.statusBar?.expandedMinHeight) ?? _statusBarPanelHeight;
    _addSidebarScrollControllerListenerIfNeeded();
    _addEndSidebarScrollControllerListenerIfNeeded();
    _toolbarChannel.setMethodCallHandler(_handleToolbarCall);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncToolbar());
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

  void _logToolbar(String message) {
    if (_debugToolbar) debugPrint('[CNWindow:toolbar] $message');
  }

  Future<void> _handleToolbarCall(MethodCall call) async {
    final toolbar = widget.toolbar;
    if (toolbar == null) return;
    switch (call.method) {
      case 'toolbarItemPressed':
        final tag = call.arguments as String?;
        _logToolbar('toolbarItemPressed: tag=$tag');
        if (tag != null) {
          final scopeContext = _scopeChildKey.currentContext ?? context;
          toolbar.onItemPressed?.call(scopeContext, tag);
        }
      case 'toolbarSearchChanged':
        final text = call.arguments as String? ?? '';
        _logToolbar('toolbarSearchChanged: "$text" (fromNative)');
        _isUpdatingSearchFromNative = true;
        final scopeContext = _scopeChildKey.currentContext ?? context;
        toolbar.onSearchChanged?.call(scopeContext, text);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _isUpdatingSearchFromNative = false;
        });
    }
  }

  void _syncToolbar() {
    if (defaultTargetPlatform != TargetPlatform.macOS) return;
    final toolbar = widget.toolbar;
    if (toolbar == null) {
      if (_lastToolbarPayload != null) {
        _logToolbar('_syncToolbar: no config, clearing');
        _clearToolbar();
        _lastToolbarPayload = null;
      }
      return;
    }
    if (_isUpdatingSearchFromNative) {
      _logToolbar('_syncToolbar: skipped (updating from native)');
      return;
    }

    final payload = <String, dynamic>{
      if (toolbar.title != null) 'title': toolbar.title!.toChildPayload(context),
      'titleDisplayMode': toolbar.titleDisplayMode.name,
      'searchable': toolbar.searchable,
      'groups': toolbar.groups.map((g) => g.toPayload(context)).toList(),
      if (toolbar.toolbarBackground != null) 'toolbarBackground': resolveColorToArgb(toolbar.toolbarBackground, context),
      'toolbarBlurEnabled': toolbar.toolbarBlurEnabled,
      if (toolbar.toolbarBlurMaterial != null) 'toolbarBlurMaterial': toolbar.toolbarBlurMaterial!.name,
    };

    if (_lastToolbarPayload != null && _toolbarPayloadEquals(_lastToolbarPayload!, payload)) {
      _logToolbar('_syncToolbar: skipped (payload unchanged)');
      return;
    }

    _logToolbar('_syncToolbar: syncing');
    _lastToolbarPayload = payload;
    _toolbarChannel.invokeMethod<void>('makeToolbar', payload);

    // Send searchText separately after toolbar recreation so the field isn't reset
    if (toolbar.searchText != null && toolbar.searchText!.isNotEmpty) {
      _logToolbar('_syncToolbar: restoring searchText="${toolbar.searchText}"');
      _toolbarChannel.invokeMethod<void>('setToolbarSearchText', toolbar.searchText);
    }
  }

  bool _toolbarPayloadEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      final va = a[key];
      final vb = b[key];
      if (va is Map && vb is Map) {
        if (!_mapEquals(va, vb)) return false;
      } else if (va is List && vb is List) {
        if (!_listEquals(va, vb)) return false;
      } else if (va != vb) {
        return false;
      }
    }
    return true;
  }

  bool _mapEquals(Map a, Map b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      final va = a[key];
      final vb = b[key];
      if (va is Map && vb is Map) {
        if (!_mapEquals(va, vb)) return false;
      } else if (va is List && vb is List) {
        if (!_listEquals(va, vb)) return false;
      } else if (va != vb) {
        return false;
      }
    }
    return true;
  }

  bool _listEquals(List a, List b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final va = a[i];
      final vb = b[i];
      if (va is Map && vb is Map) {
        if (!_mapEquals(va, vb)) return false;
      } else if (va is List && vb is List) {
        if (!_listEquals(va, vb)) return false;
      } else if (va != vb) {
        return false;
      }
    }
    return true;
  }

  void _clearToolbar() {
    if (defaultTargetPlatform != TargetPlatform.macOS) return;
    _logToolbar('_clearToolbar');
    _toolbarChannel.invokeMethod<void>('clearToolbar');
  }

  @override
  // ignore: code-metrics
  Widget build(BuildContext context) {
    assert(debugCheckHasCNTheme(context));
    final sidebar = widget.sidebar;
    final endSidebar = widget.endSidebar;
    final statusBar = widget.statusBar;
    if (sidebar?.startWidth != null) {
      assert((sidebar!.startWidth! >= sidebar.minWidth) && (sidebar.startWidth! <= sidebar.maxWidth!));
    }
    if (endSidebar?.startWidth != null) {
      assert((endSidebar!.startWidth! >= endSidebar.minWidth) && (endSidebar.startWidth! <= endSidebar.maxWidth!));
    }
    final theme = CNTheme.of(context);
    late Color backgroundColor = widget.backgroundColor ?? theme.canvasColor;
    Color dividerColor = theme.separatorColor;
    CNBrightnessOverrideHandler.ensureMatchingBrightness(theme.brightness);
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

        final statusBarHeight = statusBar?.height ?? 0.0;
        final hasStatusBar = statusBar != null;
        final expansionMode = statusBar?.expansionMode ?? CNStatusBarExpansionMode.overContent;
        final presentationStyle = statusBar?.presentationStyle ?? CNStatusBarPresentationStyle.push;
        final isFloating = presentationStyle == CNStatusBarPresentationStyle.floating;

        // In push mode, panel height reduces the content area. In floating mode, it doesn't.
        final visiblePanelHeight = (_showStatusBarPanel && !isFloating) ? _statusBarPanelHeight : 0.0;

        // Horizontal bounds for the panel based on expansion mode
        final panelIsOverAll = expansionMode == CNStatusBarExpansionMode.overAll;
        final panelLeft = panelIsOverAll ? 0.0 : visibleSidebarWidth;
        final panelRight = panelIsOverAll ? 0.0 : visibleEndSidebarWidth;

        // The height available for the main Stack (excludes the status bar)
        final stackHeight = height - (hasStatusBar ? statusBarHeight : 0.0);

        final mainStack = Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Background color
            AnimatedPositioned(
              curve: curve,
              duration: duration,
              height: stackHeight,
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
                height: stackHeight,
                left: canShowSidebar ? 0.0 : -_sidebarWidth,
                width: _sidebarWidth,
                child: VisualEffectSubviewContainer(
                  state: state,
                  material: sidebar.material,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 1.0), backgroundBlendMode: BlendMode.clear),
                    child: Container(
                      color: sidebar.backgroundColor ?? theme.canvasColor,
                      child: CNScrollbar(
                        controller: _sidebarScrollController,
                        child: Padding(padding: sidebar.padding, child: sidebar.builder(context, _sidebarScrollController)),
                      ),
                    ),
                  ),
                ),
              ),

            // Content Area (reduced by expanded panel height in push mode)
            AnimatedPositioned(
              curve: curve,
              duration: duration,
              left: visibleSidebarWidth,
              width: width - visibleSidebarWidth - visibleEndSidebarWidth,
              height: stackHeight - visiblePanelHeight,
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
                height: stackHeight,
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
                      _sidebarCursor = SystemMouseCursors.resizeColumn;
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
                height: stackHeight,
                width: _endSidebarWidth,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: endSidebar.minWidth,
                    maxWidth: endSidebar.maxWidth!,
                    minHeight: stackHeight,
                    maxHeight: stackHeight,
                  ).normalize(),
                  child: VisualEffectSubviewContainer(
                    state: state,
                    material: endSidebar.material,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 1.0), backgroundBlendMode: BlendMode.clear),
                      child: Container(
                        color: endSidebar.backgroundColor ?? theme.canvasColor,
                        child: CNScrollbar(
                          controller: _endSidebarScrollController,
                          child: Padding(
                            padding: endSidebar.padding,
                            child: endSidebar.builder(context, _endSidebarScrollController),
                          ),
                        ),
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
                right: visibleEndSidebarWidth - 4,
                width: 7,
                height: stackHeight,
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

            // Status bar expanded panel: push mode (takes space from content)
            if (hasStatusBar && statusBar.expandedBuilder != null && !isFloating)
              AnimatedPositioned(
                curve: curve,
                duration: duration,
                left: panelLeft,
                right: panelRight,
                bottom: 0,
                height: _showStatusBarPanel ? _statusBarPanelHeight : 0.0,
                child: ClipRect(
                  child: ColoredBox(
                    color: statusBar.expandedColor ?? statusBar.color ?? theme.canvasColor,
                    child: _showStatusBarPanel
                        ? Column(
                            children: [
                              Divider(height: 1, thickness: 1, color: dividerColor),
                              Expanded(
                                child: CNScrollbar(
                                  controller: _statusBarScrollController,
                                  child: statusBar.expandedBuilder!(context, _statusBarScrollController),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),

            // Status bar expanded panel: floating mode (overlay, no layout impact)
            if (hasStatusBar && statusBar.expandedBuilder != null && isFloating && _showStatusBarPanel)
              AnimatedPositioned(
                curve: curve,
                duration: duration,
                left: panelLeft + statusBar.floatingMargin.left,
                right: panelRight + statusBar.floatingMargin.right,
                bottom: statusBar.floatingMargin.bottom,
                height: _statusBarPanelHeight,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(8),
                  clipBehavior: Clip.antiAlias,
                  color: statusBar.expandedColor ?? statusBar.color ?? theme.canvasColor,
                  child: CNScrollbar(
                    controller: _statusBarScrollController,
                    child: statusBar.expandedBuilder!(context, _statusBarScrollController),
                  ),
                ),
              ),

            // Status bar panel resizer: push mode (vertical drag)
            if (hasStatusBar && statusBar.isResizable && statusBar.expandedBuilder != null && _showStatusBarPanel && !isFloating)
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
                  },
                  onVerticalDragUpdate: (details) {
                    setState(() {
                      var newHeight = _statusBarDragStartSize - (details.globalPosition.dy - _statusBarDragStartPosition);

                      if (statusBar.dragClosed) {
                        final closeBelow = statusBar.expandedMinHeight - statusBar.dragClosedBuffer;
                        _showStatusBarPanel = newHeight >= closeBelow;
                      }

                      _statusBarPanelHeight = math.max(
                        statusBar.expandedMinHeight,
                        math.min(statusBar.expandedMaxHeight, newHeight),
                      );

                      if (_statusBarPanelHeight == statusBar.expandedMinHeight) {
                        _statusBarCursor = SystemMouseCursors.resizeUp;
                      } else if (_statusBarPanelHeight == statusBar.expandedMaxHeight) {
                        _statusBarCursor = SystemMouseCursors.resizeDown;
                      } else {
                        _statusBarCursor = SystemMouseCursors.resizeRow;
                      }
                    });
                  },
                  child: MouseRegion(
                    cursor: _statusBarCursor,
                    child: Align(
                      alignment: Alignment.center,
                      child: Divider(height: 1, thickness: 1, color: dividerColor),
                    ),
                  ),
                ),
              ),

            // Status bar panel resizer: floating mode (vertical drag on top edge)
            if (hasStatusBar && statusBar.isResizable && statusBar.expandedBuilder != null && _showStatusBarPanel && isFloating)
              AnimatedPositioned(
                curve: curve,
                duration: duration,
                left: panelLeft + statusBar.floatingMargin.left,
                right: panelRight + statusBar.floatingMargin.right,
                bottom: statusBar.floatingMargin.bottom + _statusBarPanelHeight - 4,
                height: 7,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragStart: (details) {
                    _statusBarDragStartSize = _statusBarPanelHeight;
                    _statusBarDragStartPosition = details.globalPosition.dy;
                  },
                  onVerticalDragUpdate: (details) {
                    setState(() {
                      var newHeight = _statusBarDragStartSize - (details.globalPosition.dy - _statusBarDragStartPosition);

                      if (statusBar.dragClosed) {
                        final closeBelow = statusBar.expandedMinHeight - statusBar.dragClosedBuffer;
                        _showStatusBarPanel = newHeight >= closeBelow;
                      }

                      _statusBarPanelHeight = math.max(
                        statusBar.expandedMinHeight,
                        math.min(statusBar.expandedMaxHeight, newHeight),
                      );

                      if (_statusBarPanelHeight == statusBar.expandedMinHeight) {
                        _statusBarCursor = SystemMouseCursors.resizeUp;
                      } else if (_statusBarPanelHeight == statusBar.expandedMaxHeight) {
                        _statusBarCursor = SystemMouseCursors.resizeDown;
                      } else {
                        _statusBarCursor = SystemMouseCursors.resizeRow;
                      }
                    });
                  },
                  child: MouseRegion(cursor: _statusBarCursor, child: const SizedBox.expand()),
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
                child: ColoredBox(
                  color: statusBar.color ?? theme.canvasColor,
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

        return CNWindowScope(
          constraints: constraints,
          isSidebarShown: canShowSidebar,
          isEndSidebarShown: canShowEndSidebar,
          isStatusBarExpanded: _showStatusBarPanel,
          sidebarToggler: () async {
            debugPrint('toggleSidebar: $_showSidebar -> ${!_showSidebar}');
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
          statusBarToggler: () async {
            setState(() => _sidebarSlideDuration = 300);
            setState(() => _showStatusBarPanel = !_showStatusBarPanel);
            await Future.delayed(Duration(milliseconds: _sidebarSlideDuration));
            if (mounted) {
              setState(() => _sidebarSlideDuration = 0);
            }
          },
          child: KeyedSubtree(key: _scopeChildKey, child: layout),
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
