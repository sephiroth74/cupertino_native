import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../theme/cn_theme.dart';
import '../split_view.dart';
import '../toolbar/toolbar.dart';

/// Sidebar configuration for [CNMainWindow].
class CNSidebar {
  /// Creates a sidebar configuration.
  const CNSidebar({
    required this.child,
    this.shownByDefault = true,
    this.startWidth = 250,
    this.minWidth = 180,
    this.maxWidth = 420,
  }) : assert(startWidth >= minWidth),
       assert(maxWidth >= startWidth),
       assert(minWidth > 0);

  /// Sidebar content.
  final Widget child;

  /// Maximum width in logical pixels.
  final double maxWidth;

  /// Minimum width in logical pixels.
  final double minWidth;

  /// Initial visibility.
  final bool shownByDefault;

  /// Initial width in logical pixels.
  final double startWidth;
}

/// Runtime state snapshot for [CNMainWindowController].
class CNMainWindowState {
  /// Creates a main window state snapshot.
  const CNMainWindowState({required this.sidebarVisible, required this.trailingSidebarVisible});

  /// Whether leading sidebar is currently visible.
  final bool sidebarVisible;

  /// Whether trailing sidebar is currently visible.
  final bool trailingSidebarVisible;
}

abstract class _CNMainWindowBinding {
  void hideSidebar();

  void hideTrailingSidebar();

  void showSidebar();

  void showTrailingSidebar();

  void toggleSidebar();

  void toggleTrailingSidebar();
}

/// Controller used to control [CNMainWindow] sidebars from toolbar actions.
class CNMainWindowController extends ChangeNotifier {
  _CNMainWindowBinding? _binding;
  CNMainWindowState _state = const CNMainWindowState(sidebarVisible: true, trailingSidebarVisible: false);

  /// Current state snapshot.
  CNMainWindowState get state => _state;

  /// Hides leading sidebar.
  void hideSidebar() => _binding?.hideSidebar();

  /// Hides trailing sidebar.
  void hideTrailingSidebar() => _binding?.hideTrailingSidebar();

  /// Whether leading sidebar is visible.
  bool get isSidebarVisible => _state.sidebarVisible;

  /// Whether trailing sidebar is visible.
  bool get isTrailingSidebarVisible => _state.trailingSidebarVisible;

  /// Shows leading sidebar.
  void showSidebar() => _binding?.showSidebar();

  /// Shows trailing sidebar.
  void showTrailingSidebar() => _binding?.showTrailingSidebar();

  /// Toggles leading sidebar visibility.
  void toggleSidebar() => _binding?.toggleSidebar();

  /// Toggles trailing sidebar visibility.
  void toggleTrailingSidebar() => _binding?.toggleTrailingSidebar();

  void _attach(_CNMainWindowBinding binding) {
    _binding = binding;
  }

  void _detach(_CNMainWindowBinding binding) {
    if (identical(_binding, binding)) {
      _binding = null;
    }
  }

  void _setState(CNMainWindowState value) {
    if (_state.sidebarVisible == value.sidebarVisible && _state.trailingSidebarVisible == value.trailingSidebarVisible) {
      return;
    }
    _state = value;
    notifyListeners();
  }
}

/// Desktop window scaffold inspired by MacosWindow/AppKitWindow patterns.
///
/// - Optional leading and trailing sidebars
/// - Central content area
/// - Optional native toolbar via [CNToolbar]
/// - Programmatic sidebar control through [CNMainWindowController]
class CNMainWindow extends StatefulWidget {
  /// Creates a main desktop window container.
  const CNMainWindow({
    super.key,
    required this.child,
    this.controller,
    this.sidebar,
    this.endSidebar,
    this.backgroundColor,
    this.toolbarColor,
    this.toolbarTitle,
    this.toolbarGroups,
    this.toolbarShowSearch = false,
    this.onToolbarSearchChanged,
    this.onToolbarSearchSubmitted,
    this.clearToolbarOnDispose = true,
  });

  /// Window background color.
  final Color? backgroundColor;

  /// Main content area.
  final Widget child;

  /// Clears toolbar on dispose.
  final bool clearToolbarOnDispose;

  /// Optional external controller.
  final CNMainWindowController? controller;

  /// Optional trailing sidebar.
  final CNSidebar? endSidebar;

  /// Callback for toolbar live-search updates.
  final ValueChanged<String>? onToolbarSearchChanged;

  /// Callback for toolbar search submit.
  final ValueChanged<String>? onToolbarSearchSubmitted;

  /// Optional leading sidebar.
  final CNSidebar? sidebar;

  /// Toolbar color.
  final Color? toolbarColor;

  /// Toolbar groups rendered by native SwiftUI toolbar bridge.
  final List<CNToolbarGroup>? toolbarGroups;

  /// Enables native toolbar search field.
  final bool toolbarShowSearch;

  /// Toolbar title.
  final String? toolbarTitle;

  @override
  State<CNMainWindow> createState() => _CNMainWindowState();
}

class _CNMainWindowState extends State<CNMainWindow> implements _CNMainWindowBinding {
  final CNSplitViewController _leadingSplitController = CNSplitViewController();
  bool _sidebarVisible = true;
  bool _toolbarConfigured = false;
  bool _trailingSidebarVisible = false;
  final CNSplitViewController _trailingSplitController = CNSplitViewController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleToolbarConfiguration();
  }

  @override
  void didUpdateWidget(covariant CNMainWindow oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
      _syncControllerState();
    }

    final toolbarChanged =
        oldWidget.toolbarTitle != widget.toolbarTitle ||
        oldWidget.toolbarShowSearch != widget.toolbarShowSearch ||
        !listEquals(oldWidget.toolbarGroups, widget.toolbarGroups);
    if (toolbarChanged) {
      _toolbarConfigured = false;
      _scheduleToolbarConfiguration();
    }
  }

  @override
  void dispose() {
    _controller?._detach(this);
    _leadingSplitController.dispose();
    _trailingSplitController.dispose();
    if (widget.clearToolbarOnDispose) {
      CNToolbar.remove();
    }
    super.dispose();
  }

  @override
  void hideSidebar() {
    if (widget.sidebar == null || !_sidebarVisible) {
      return;
    }
    _leadingSplitController.collapseFirst();
    _setSidebarVisible(false);
  }

  @override
  void hideTrailingSidebar() {
    if (widget.endSidebar == null || !_trailingSidebarVisible) {
      return;
    }
    _trailingSplitController.collapseSecond();
    _setTrailingSidebarVisible(false);
  }

  @override
  void initState() {
    super.initState();
    _sidebarVisible = widget.sidebar?.shownByDefault ?? false;
    _trailingSidebarVisible = widget.endSidebar?.shownByDefault ?? false;

    _controller?._attach(this);
    _syncControllerState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (!_sidebarVisible && widget.sidebar != null) {
        _leadingSplitController.collapseFirst();
      }
      if (!_trailingSidebarVisible && widget.endSidebar != null) {
        _trailingSplitController.collapseSecond();
      }
    });
  }

  @override
  void showSidebar() {
    if (widget.sidebar == null || _sidebarVisible) {
      return;
    }
    _leadingSplitController.expandFirst();
    _setSidebarVisible(true);
  }

  @override
  void showTrailingSidebar() {
    if (widget.endSidebar == null || _trailingSidebarVisible) {
      return;
    }
    _trailingSplitController.expandSecond();
    _setTrailingSidebarVisible(true);
  }

  @override
  void toggleSidebar() {
    if (_sidebarVisible) {
      hideSidebar();
    } else {
      showSidebar();
    }
  }

  @override
  void toggleTrailingSidebar() {
    if (_trailingSidebarVisible) {
      hideTrailingSidebar();
    } else {
      showTrailingSidebar();
    }
  }

  CNMainWindowController? get _controller => widget.controller;

  void _scheduleToolbarConfiguration() {
    if (_toolbarConfigured || !_canConfigureToolbar) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _toolbarConfigured || !_canConfigureToolbar) {
        return;
      }
      _configureToolbar();
    });
  }

  bool get _canConfigureToolbar {
    if (kIsWeb || !Platform.isMacOS) {
      return false;
    }
    return widget.toolbarTitle != null || (widget.toolbarGroups != null && widget.toolbarGroups!.isNotEmpty);
  }

  Future<void> _configureToolbar() async {
    final groups = widget.toolbarGroups ?? const <CNToolbarGroup>[];
    final title = widget.toolbarTitle ?? '';

    await CNToolbar.create(context: context, title: title, groups: groups, showSearch: widget.toolbarShowSearch, toolbarColor: widget.toolbarColor);

    if (widget.onToolbarSearchChanged != null) {
      CNToolbar.onSearchChanged(widget.onToolbarSearchChanged!);
    }
    if (widget.onToolbarSearchSubmitted != null) {
      CNToolbar.onSearchSubmitted(widget.onToolbarSearchSubmitted!);
    }

    _toolbarConfigured = true;
  }

  void _setSidebarVisible(bool value) {
    if (_sidebarVisible == value) {
      return;
    }
    setState(() {
      _sidebarVisible = value;
    });
    _syncControllerState();
  }

  void _setTrailingSidebarVisible(bool value) {
    if (_trailingSidebarVisible == value) {
      return;
    }
    setState(() {
      _trailingSidebarVisible = value;
    });
    _syncControllerState();
  }

  void _syncControllerState() {
    _controller?._setState(
      CNMainWindowState(
        sidebarVisible: widget.sidebar != null && _sidebarVisible,
        trailingSidebarVisible: widget.endSidebar != null && _trailingSidebarVisible,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final background = widget.backgroundColor ?? CNTheme.of(context).canvasColor;

    Widget content = DecoratedBox(
      decoration: BoxDecoration(color: background),
      child: widget.child,
    );

    if (widget.endSidebar != null) {
      final endSidebar = widget.endSidebar!;
      content = DecoratedBox(
        decoration: BoxDecoration(color: background),
        child: CNSplitView(
          controller: _trailingSplitController,
          initialFraction: 1 - (endSidebar.startWidth / (endSidebar.startWidth + 700)),
          minFraction: 0.3,
          maxFraction: 0.95,
          collapseBehavior: CNSplitCollapseBehavior.secondPane,
          first: CNSplitPane(child: content, minExtent: 320),
          second: CNSplitPane(
            child: DecoratedBox(
              decoration: BoxDecoration(color: background),
              child: endSidebar.child,
            ),
            initialFraction: endSidebar.startWidth / (endSidebar.startWidth + 700),
            minExtent: endSidebar.minWidth,
            maxExtent: endSidebar.maxWidth,
          ),
          onChanged: (metrics) {
            _setTrailingSidebarVisible(!metrics.secondCollapsed);
          },
        ),
      );
    }

    if (widget.sidebar != null) {
      final sidebar = widget.sidebar!;
      content = DecoratedBox(
        decoration: BoxDecoration(color: background),
        child: CNSplitView(
          controller: _leadingSplitController,
          initialFraction: sidebar.startWidth / (sidebar.startWidth + 900),
          minFraction: 0.05,
          maxFraction: 0.7,
          collapseBehavior: CNSplitCollapseBehavior.firstPane,
          first: CNSplitPane(
            child: DecoratedBox(
              decoration: BoxDecoration(color: background),
              child: sidebar.child,
            ),
            initialFraction: sidebar.startWidth / (sidebar.startWidth + 900),
            minExtent: sidebar.minWidth,
            maxExtent: sidebar.maxWidth,
          ),
          second: CNSplitPane(child: content, minExtent: 400),
          onChanged: (metrics) {
            _setSidebarVisible(!metrics.firstCollapsed);
          },
        ),
      );
    }

    return content;
  }
}
