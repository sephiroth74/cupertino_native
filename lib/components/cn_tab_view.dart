// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/components/cn_segmented_control.dart';
import 'package:cupertino_native/model/control_size.dart';
import 'package:flutter/widgets.dart';

/// Where the segmented control tabs are placed relative to the content.
enum CNTabPosition {
  /// Tabs appear above the content.
  top,

  /// Tabs appear below the content.
  bottom,
}

/// How the tab content is rendered.
enum CNTabContentMode {
  /// All children are kept alive in an [IndexedStack].
  indexedStack,

  /// Only the selected child is in the tree, wrapped in a [KeyedSubtree].
  keyedSubtree,
}

/// Controls the selected tab for a [CNTabView].
///
/// Similar to Flutter's [TabController]. Holds the current index, notifies
/// listeners on changes, and provides programmatic tab switching.
class CNTabController extends ChangeNotifier {
  CNTabController({required this.length, int initialIndex = 0})
      : assert(length > 0),
        assert(initialIndex >= 0 && initialIndex < length),
        _index = initialIndex;

  /// The total number of tabs.
  final int length;

  int _index;

  /// The currently selected tab index.
  int get index => _index;

  set index(int value) {
    assert(value >= 0 && value < length);
    if (_index == value) return;
    _index = value;
    notifyListeners();
  }
}

/// Provides a [CNTabController] to descendant [CNTabView] widgets that don't
/// have an explicit controller.
///
/// Wrap a subtree with this to avoid managing a [CNTabController] manually:
/// ```dart
/// DefaultCNTabController(
///   length: 3,
///   child: CNTabView(
///     tabs: [...],
///     children: [...],
///   ),
/// )
/// ```
class DefaultCNTabController extends StatefulWidget {
  const DefaultCNTabController({
    super.key,
    required this.length,
    this.initialIndex = 0,
    required this.child,
  });

  final Widget child;
  final int initialIndex;
  final int length;

  @override
  State<DefaultCNTabController> createState() => _DefaultCNTabControllerState();

  static CNTabController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_CNTabControllerScope>();
    assert(scope != null, 'No DefaultCNTabController found in the widget tree');
    return scope!.controller;
  }
}

class _DefaultCNTabControllerState extends State<DefaultCNTabController> {
  late CNTabController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = CNTabController(length: widget.length, initialIndex: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return _CNTabControllerScope(controller: _controller, child: widget.child);
  }
}

class _CNTabControllerScope extends InheritedWidget {
  const _CNTabControllerScope({required this.controller, required super.child});

  final CNTabController controller;

  @override
  bool updateShouldNotify(_CNTabControllerScope oldWidget) => controller != oldWidget.controller;
}

/// A tabbed container that uses [CNSegmentedControl] for tab switching.
///
/// Requires a [CNTabController] — either passed explicitly via [controller],
/// or provided by a [DefaultCNTabController] ancestor.
class CNTabView extends StatefulWidget {
  const CNTabView({
    super.key,
    this.controller,
    required this.tabs,
    required this.children,
    this.tabPosition = CNTabPosition.top,
    this.contentMode = CNTabContentMode.indexedStack,
    this.contentPadding = EdgeInsets.zero,
    this.tabPadding = EdgeInsets.zero,
    this.segmentStyle = CNSegmentStyle.automatic,
    this.segmentDistribution = CNSegmentDistribution.fit,
    this.controlSize = CNControlSize.regular,
    this.enabled = true,
    this.tint,
    this.foregroundColor,
  });

  /// The tab content widgets, one per segment.
  final List<Widget> children;

  /// How the tab content is rendered.
  final CNTabContentMode contentMode;

  /// Padding between the segmented control and the content area.
  final EdgeInsetsGeometry contentPadding;

  /// The size of the native AppKit control.
  final CNControlSize controlSize;

  /// The tab controller. If null, uses [DefaultCNTabController.of(context)].
  final CNTabController? controller;

  /// Whether the control is enabled.
  final bool enabled;

  /// The foreground color of the segmented control.
  final Color? foregroundColor;

  /// The segment distribution strategy.
  final CNSegmentDistribution segmentDistribution;

  /// The visual style of the segmented control.
  final CNSegmentStyle segmentStyle;

  /// Padding around the segmented control itself.
  final EdgeInsetsGeometry tabPadding;

  /// Where the tabs are placed relative to the content.
  final CNTabPosition tabPosition;

  /// The segment definitions.
  final List<CNSegment> tabs;

  /// The tint color of the segmented control.
  final Object? tint;

  @override
  State<CNTabView> createState() => _CNTabViewState();
}

class _CNTabViewState extends State<CNTabView> {
  CNTabController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscribeToController();
  }

  @override
  void didUpdateWidget(CNTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller?.removeListener(_onControllerChanged);
      _controller = widget.controller ?? DefaultCNTabController.of(context);
      _controller!.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller;
      _controller!.addListener(_onControllerChanged);
    }
  }

  CNTabController get _effectiveController =>
      widget.controller ?? DefaultCNTabController.of(context);

  bool get _isFillDistribution =>
      widget.segmentDistribution == CNSegmentDistribution.fill ||
      widget.segmentDistribution == CNSegmentDistribution.fillEqually ||
      widget.segmentDistribution == CNSegmentDistribution.fillProportionally;

  void _subscribeToController() {
    final newController = widget.controller ?? DefaultCNTabController.of(context);
    if (newController != _controller) {
      _controller?.removeListener(_onControllerChanged);
      _controller = newController;
      _controller!.addListener(_onControllerChanged);
    }
  }

  void _onControllerChanged() {
    setState(() {});
  }

  Widget _buildContent() {
    final index = _effectiveController.index;
    switch (widget.contentMode) {
      case CNTabContentMode.indexedStack:
        return IndexedStack(index: index, children: widget.children);
      case CNTabContentMode.keyedSubtree:
        return KeyedSubtree(key: ValueKey(index), child: widget.children[index]);
    }
  }

  Widget _buildTabBar() {
    final controller = _effectiveController;

    Widget segmented;

    if (_isFillDistribution) {
      segmented = LayoutBuilder(
        builder: (context, constraints) {
          return CNSegmentedControl(
            segments: widget.tabs,
            selectedIndex: controller.index,
            segmentStyle: widget.segmentStyle,
            trackingMode: CNSegmentTrackingMode.selectOne,
            segmentDistribution: widget.segmentDistribution,
            controlSize: widget.controlSize,
            tint: widget.tint,
            foregroundColor: widget.foregroundColor,
            shrink: true,
            constraints: BoxConstraints.tightFor(width: constraints.maxWidth),
            onChanged: widget.enabled ? (index) => controller.index = index : null,
          );
        },
      );
    } else {
      segmented = CNSegmentedControl(
        segments: widget.tabs,
        selectedIndex: controller.index,
        segmentStyle: widget.segmentStyle,
        trackingMode: CNSegmentTrackingMode.selectOne,
        segmentDistribution: widget.segmentDistribution,
        controlSize: widget.controlSize,
        tint: widget.tint,
        foregroundColor: widget.foregroundColor,
        onChanged: widget.enabled ? (index) => controller.index = index : null,
      );
    }

    return Padding(padding: widget.tabPadding, child: segmented);
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.tabs.length == widget.children.length,
      'tabs and children must have the same length',
    );
    assert(
      widget.tabs.length == _effectiveController.length,
      'tabs length must match controller length',
    );

    final tabBar = _buildTabBar();
    final content = Expanded(
      child: Padding(padding: widget.contentPadding, child: _buildContent()),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widget.tabPosition == CNTabPosition.top
          ? [tabBar, content]
          : [content, tabBar],
    );
  }
}
