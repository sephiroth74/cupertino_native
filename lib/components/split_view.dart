import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Layout axis for [CNSplitView].
enum CNSplitAxis {
  /// Places panes left/right.
  horizontal,

  /// Places panes top/bottom.
  vertical,
}

/// Controls which pane can be collapsed programmatically.
enum CNSplitCollapseBehavior {
  /// Collapse is disabled.
  none,

  /// Only first pane can collapse.
  firstPane,

  /// Only second pane can collapse.
  secondPane,

  /// Either pane can collapse.
  eitherPane,
}

/// Action executed when the divider is double-clicked.
enum CNSplitDividerDoubleTapAction {
  /// Do nothing on double-click.
  none,

  /// Toggle the first pane collapsed state.
  toggleFirst,

  /// Toggle the second pane collapsed state.
  toggleSecond,

  /// Reset split fraction to initial configuration.
  reset,
}

/// macOS-specific visual style for the split divider.
enum CNSplitMacOSDividerStyle {
  /// Follows platform best defaults.
  automatic,

  /// Uses only the plain divider line.
  plain,

  /// Uses a subtle grabber-like decoration in addition to divider line.
  grabber,
}

/// Describes one pane inside a [CNSplitView].
class CNSplitPane {
  /// Creates a pane.
  const CNSplitPane({
    required this.child,
    this.initialFraction,
    this.minExtent = 120.0,
    this.maxExtent,
    this.collapsible = true,
    this.id,
  }) : assert(minExtent >= 0),
       assert(maxExtent == null || maxExtent >= 0);

  /// Widget rendered inside the pane.
  final Widget child;

  /// Optional pane-specific initial fraction override.
  ///
  /// If provided, it takes precedence over [CNSplitView.initialFraction].
  final double? initialFraction;

  /// Minimum pane extent in logical pixels.
  final double minExtent;

  /// Optional maximum pane extent in logical pixels.
  final double? maxExtent;

  /// Whether this pane may be collapsed.
  final bool collapsible;

  /// Optional stable identifier.
  final String? id;
}

/// Runtime metrics for [CNSplitView].
class CNSplitMetrics {
  /// Creates metrics.
  const CNSplitMetrics({
    required this.axis,
    required this.totalExtent,
    required this.firstExtent,
    required this.secondExtent,
    required this.dividerThickness,
    required this.firstCollapsed,
    required this.secondCollapsed,
  });

  /// Current split axis.
  final CNSplitAxis axis;

  /// Total available extent along the split axis.
  final double totalExtent;

  /// First pane extent.
  final double firstExtent;

  /// Second pane extent.
  final double secondExtent;

  /// Divider thickness.
  final double dividerThickness;

  /// Whether first pane is collapsed.
  final bool firstCollapsed;

  /// Whether second pane is collapsed.
  final bool secondCollapsed;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CNSplitMetrics &&
        other.axis == axis &&
        other.totalExtent == totalExtent &&
        other.firstExtent == firstExtent &&
        other.secondExtent == secondExtent &&
        other.dividerThickness == dividerThickness &&
        other.firstCollapsed == firstCollapsed &&
        other.secondCollapsed == secondCollapsed;
  }

  @override
  int get hashCode => Object.hash(
    axis,
    totalExtent,
    firstExtent,
    secondExtent,
    dividerThickness,
    firstCollapsed,
    secondCollapsed,
  );
}

/// Controller for querying and changing [CNSplitView] state.
class CNSplitViewController extends ChangeNotifier {
  CNSplitMetrics? _metrics;
  _SplitViewControllerBinding? _binding;

  /// Latest metrics reported by the attached split view.
  CNSplitMetrics? get metrics => _metrics;

  void _attach(_SplitViewControllerBinding binding) {
    _binding = binding;
  }

  void _detach(_SplitViewControllerBinding binding) {
    if (identical(_binding, binding)) {
      _binding = null;
    }
  }

  void _setMetrics(CNSplitMetrics value) {
    if (_metrics == value) {
      return;
    }
    _metrics = value;
    notifyListeners();
  }

  /// Sets split fraction where $0$ is fully second pane and $1$ fully first pane.
  void setFraction(double value) {
    _binding?.setFraction(value);
  }

  /// Sets first pane extent in logical pixels.
  void setFirstExtent(double value) {
    _binding?.setFirstExtent(value);
  }

  /// Sets second pane extent in logical pixels.
  void setSecondExtent(double value) {
    _binding?.setSecondExtent(value);
  }

  /// Collapses first pane.
  void collapseFirst() {
    _binding?.collapseFirst();
  }

  /// Collapses second pane.
  void collapseSecond() {
    _binding?.collapseSecond();
  }

  /// Expands first pane if collapsed.
  void expandFirst() {
    _binding?.expandFirst();
  }

  /// Expands second pane if collapsed.
  void expandSecond() {
    _binding?.expandSecond();
  }

  /// Toggles first pane collapsed state.
  void toggleFirst() {
    _binding?.toggleFirst();
  }

  /// Toggles second pane collapsed state.
  void toggleSecond() {
    _binding?.toggleSecond();
  }
}

abstract class _SplitViewControllerBinding {
  void setFraction(double value);

  void setFirstExtent(double value);

  void setSecondExtent(double value);

  void collapseFirst();

  void collapseSecond();

  void expandFirst();

  void expandSecond();

  void toggleFirst();

  void toggleSecond();
}

/// Flutter-first split view engine for desktop-style two-pane layouts.
class CNSplitView extends StatefulWidget {
  /// Creates a split view with two panes.
  CNSplitView({
    super.key,
    required this.first,
    required this.second,
    this.axis = CNSplitAxis.horizontal,
    this.controller,
    this.dividerThickness = 6.0,
    this.dividerInteractiveThickness = 14.0,
    this.dividerSemanticLabel = 'Split view divider',
    this.dividerDoubleTapAction = CNSplitDividerDoubleTapAction.none,
    this.macOSDividerStyle = CNSplitMacOSDividerStyle.automatic,
    this.enableMacOSDividerVisualEffects = true,
    this.paneClipBehavior = Clip.hardEdge,
    this.enableKeyboardShortcuts = true,
    this.autofocusKeyboardShortcuts = false,
    this.keyboardResizeStep = 24.0,
    this.minFraction = 0.15,
    this.maxFraction = 0.85,
    this.initialFraction = 0.3,
    this.collapseBehavior = CNSplitCollapseBehavior.eitherPane,
    this.snapFractions = const <double>[],
    this.snapThreshold = 0.02,
    this.snapReleaseThreshold,
    this.onChanged,
  }) : assert(dividerThickness > 0),
       assert(dividerInteractiveThickness > 0),
       assert(keyboardResizeStep > 0),
       assert(minFraction > 0 && minFraction < 1),
       assert(maxFraction > 0 && maxFraction < 1),
       assert(minFraction <= maxFraction),
       assert(initialFraction >= minFraction && initialFraction <= maxFraction),
       assert(snapThreshold >= 0),
       assert(snapReleaseThreshold == null || snapReleaseThreshold > 0),
       assert(
         snapReleaseThreshold == null || snapReleaseThreshold >= snapThreshold,
       ),
       assert(snapFractions.every((value) => value > 0 && value < 1));

  /// First pane descriptor.
  final CNSplitPane first;

  /// Second pane descriptor.
  final CNSplitPane second;

  /// Split axis.
  final CNSplitAxis axis;

  /// Optional external controller.
  final CNSplitViewController? controller;

  /// Divider visual thickness.
  final double dividerThickness;

  /// Divider interactive thickness used for hit-testing drag gestures.
  ///
  /// This can be larger than [dividerThickness] to make dragging easier.
  final double dividerInteractiveThickness;

  /// Semantic label exposed to assistive technologies for the divider.
  final String dividerSemanticLabel;

  /// Action to trigger on divider double-click.
  final CNSplitDividerDoubleTapAction dividerDoubleTapAction;

  /// macOS-specific divider style.
  final CNSplitMacOSDividerStyle macOSDividerStyle;

  /// Enables macOS-only divider visual effects while preserving Flutter layout.
  final bool enableMacOSDividerVisualEffects;

  /// Clip behavior applied to pane content.
  ///
  /// Useful to keep complex children constrained during aggressive resizes.
  final Clip paneClipBehavior;

  /// Enables built-in keyboard shortcuts for pane resizing/collapsing.
  final bool enableKeyboardShortcuts;

  /// Whether keyboard shortcuts should autofocus when the widget appears.
  final bool autofocusKeyboardShortcuts;

  /// Number of logical pixels moved by each keyboard resize command.
  final double keyboardResizeStep;

  /// Global minimum fraction for first pane.
  final double minFraction;

  /// Global maximum fraction for first pane.
  final double maxFraction;

  /// Initial fraction for first pane.
  final double initialFraction;

  /// Pane collapse policy.
  final CNSplitCollapseBehavior collapseBehavior;

  /// Optional snap points for upcoming drag interactions.
  final List<double> snapFractions;

  /// Snap threshold for drag interactions.
  final double snapThreshold;

  /// Optional release threshold for snap hysteresis.
  ///
  /// If null, the release threshold is computed automatically to provide
  /// a smooth "magnetic" snap without sticky behavior.
  final double? snapReleaseThreshold;

  /// Emitted when split metrics change.
  final ValueChanged<CNSplitMetrics>? onChanged;

  @override
  State<CNSplitView> createState() => _CNSplitViewState();
}

class _CNSplitViewState extends State<CNSplitView>
    implements _SplitViewControllerBinding {
  late double _fraction;
  double? _lastAvailableExtent;
  double? _dragStartFraction;
  double? _dragRawFraction;
  double? _activeSnapFraction;
  bool _isDividerDragging = false;
  bool _firstCollapsed = false;
  bool _secondCollapsed = false;
  double? _restoreFraction;
  CNSplitMetrics? _lastPublishedMetrics;

  CNSplitViewController? get _controller => widget.controller;

  double get _effectiveDividerThickness =>
      math.max(widget.dividerThickness, widget.dividerInteractiveThickness);

  bool get _isMacOS => defaultTargetPlatform == TargetPlatform.macOS;

  MouseCursor get _resizeCursor => widget.axis == CNSplitAxis.horizontal
      ? SystemMouseCursors.resizeColumn
      : SystemMouseCursors.resizeRow;

  double get _defaultInitialFraction =>
      (widget.first.initialFraction ?? widget.initialFraction)
          .clamp(widget.minFraction, widget.maxFraction)
          .toDouble();

  @override
  void initState() {
    super.initState();
    _fraction = _defaultInitialFraction;
    _restoreFraction = _fraction;
    _controller?._attach(this);
  }

  @override
  void didUpdateWidget(covariant CNSplitView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }

    // Keep current state but enforce updated global bounds.
    _fraction = _fraction
        .clamp(widget.minFraction, widget.maxFraction)
        .toDouble();
    _restoreFraction = _normalizedFraction(_restoreFraction ?? _fraction);
  }

  @override
  void dispose() {
    _controller?._detach(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = MouseRegion(
      cursor: _isDividerDragging ? _resizeCursor : MouseCursor.defer,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalAxisExtent = widget.axis == CNSplitAxis.horizontal
              ? constraints.maxWidth
              : constraints.maxHeight;

          final availableExtent = math.max<double>(
            0.0,
            totalAxisExtent - _effectiveDividerThickness,
          );
          _lastAvailableExtent = availableExtent;

          final computed = _computeExtents(availableExtent);
          final firstExtent = computed.firstExtent;
          final secondExtent = computed.secondExtent;

          final metrics = CNSplitMetrics(
            axis: widget.axis,
            totalExtent: availableExtent,
            firstExtent: firstExtent,
            secondExtent: secondExtent,
            dividerThickness: widget.dividerThickness,
            firstCollapsed: _firstCollapsed,
            secondCollapsed: _secondCollapsed,
          );

          _publishMetrics(metrics);

          final divider = _buildDivider(context);
          if (widget.axis == CNSplitAxis.horizontal) {
            return Row(
              children: [
                SizedBox(
                  width: firstExtent,
                  child: _buildPane(widget.first.child),
                ),
                divider,
                SizedBox(
                  width: secondExtent,
                  child: _buildPane(widget.second.child),
                ),
              ],
            );
          }

          return Column(
            children: [
              SizedBox(
                height: firstExtent,
                child: _buildPane(widget.first.child),
              ),
              divider,
              SizedBox(
                height: secondExtent,
                child: _buildPane(widget.second.child),
              ),
            ],
          );
        },
      ),
    );

    if (!widget.enableKeyboardShortcuts) {
      return base;
    }

    return Focus(
      autofocus: widget.autofocusKeyboardShortcuts,
      canRequestFocus: true,
      child: CallbackShortcuts(bindings: _buildShortcutBindings(), child: base),
    );
  }

  Map<ShortcutActivator, VoidCallback> _buildShortcutBindings() {
    final bindings = <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.digit1, alt: true): toggleFirst,
      const SingleActivator(LogicalKeyboardKey.digit2, alt: true): toggleSecond,
    };

    if (widget.axis == CNSplitAxis.horizontal) {
      bindings[const SingleActivator(
        LogicalKeyboardKey.arrowLeft,
        alt: true,
      )] = () =>
          _nudgeFirstPane(-widget.keyboardResizeStep);
      bindings[const SingleActivator(
        LogicalKeyboardKey.arrowRight,
        alt: true,
      )] = () =>
          _nudgeFirstPane(widget.keyboardResizeStep);
    } else {
      bindings[const SingleActivator(
        LogicalKeyboardKey.arrowUp,
        alt: true,
      )] = () =>
          _nudgeFirstPane(-widget.keyboardResizeStep);
      bindings[const SingleActivator(
        LogicalKeyboardKey.arrowDown,
        alt: true,
      )] = () =>
          _nudgeFirstPane(widget.keyboardResizeStep);
    }

    return bindings;
  }

  void _nudgeFirstPane(double deltaPixels) {
    final extent = _lastAvailableExtent;
    if (extent == null || extent <= 0) {
      return;
    }

    final currentFirstExtent = _firstCollapsed
        ? 0.0
        : _secondCollapsed
        ? extent
        : (_fraction * extent);

    setFirstExtent(currentFirstExtent + deltaPixels);
  }

  Widget _buildPane(Widget child) {
    return RepaintBoundary(
      child: ClipRect(clipBehavior: widget.paneClipBehavior, child: child),
    );
  }

  _ComputedExtents _computeExtents(double availableExtent) {
    if (availableExtent <= 0) {
      return const _ComputedExtents(firstExtent: 0, secondExtent: 0);
    }

    if (_firstCollapsed && _secondCollapsed) {
      _secondCollapsed = false;
    }

    if (_firstCollapsed) {
      return _ComputedExtents(firstExtent: 0, secondExtent: availableExtent);
    }
    if (_secondCollapsed) {
      return _ComputedExtents(firstExtent: availableExtent, secondExtent: 0);
    }

    final clampedFraction = _clampFractionForExtent(_fraction, availableExtent);
    _fraction = clampedFraction;
    _restoreFraction = clampedFraction;

    final firstExtent = clampedFraction * availableExtent;
    final secondExtent = availableExtent - firstExtent;

    return _ComputedExtents(
      firstExtent: firstExtent,
      secondExtent: secondExtent,
    );
  }

  double _normalizedFraction(double value) {
    final extent = _lastAvailableExtent;
    if (extent == null || extent <= 0) {
      return value.clamp(widget.minFraction, widget.maxFraction).toDouble();
    }
    return _clampFractionForExtent(value, extent);
  }

  double _clampFractionForExtent(double value, double availableExtent) {
    final firstMin = widget.first.minExtent / availableExtent;
    final secondMin = widget.second.minExtent / availableExtent;

    final firstMax = widget.first.maxExtent == null
        ? 1.0
        : widget.first.maxExtent! / availableExtent;
    final secondMax = widget.second.maxExtent == null
        ? 1.0
        : widget.second.maxExtent! / availableExtent;

    var lower = widget.minFraction;
    var upper = widget.maxFraction;

    lower = math.max(lower, firstMin);
    upper = math.min(upper, firstMax);

    lower = math.max(lower, 1.0 - secondMax);
    upper = math.min(upper, 1.0 - secondMin);

    if (lower > upper) {
      // Impossible constraints: choose deterministic midpoint fallback.
      final fallback = ((lower + upper) / 2.0).clamp(0.0, 1.0).toDouble();
      return fallback;
    }

    return value.clamp(lower, upper).toDouble();
  }

  Widget _buildDivider(BuildContext context) {
    final color = CupertinoDynamicColor.resolve(
      CupertinoColors.separator,
      context,
    );
    final grabberColor = CupertinoDynamicColor.resolve(
      CupertinoColors.tertiaryLabel,
      context,
    ).withValues(alpha: 0.55);

    final plainLine = Center(
      child: SizedBox(
        width: widget.axis == CNSplitAxis.horizontal
            ? widget.dividerThickness
            : double.infinity,
        height: widget.axis == CNSplitAxis.vertical
            ? widget.dividerThickness
            : double.infinity,
        child: ColoredBox(color: color),
      ),
    );

    final useGrabber =
        _isMacOS &&
        widget.enableMacOSDividerVisualEffects &&
        (widget.macOSDividerStyle == CNSplitMacOSDividerStyle.grabber ||
            widget.macOSDividerStyle == CNSplitMacOSDividerStyle.automatic);

    final dividerBody = Stack(
      fit: StackFit.expand,
      children: [
        plainLine,
        if (useGrabber)
          Center(
            child: _MacOSDividerGrabber(axis: widget.axis, color: grabberColor),
          ),
      ],
    );
    final dividerHandle = Semantics(
      label: widget.dividerSemanticLabel,
      hint: _dividerSemanticHint,
      value: 'First pane ${(_fraction * 100).round()}%',
      increasedValue: 'First pane grows',
      decreasedValue: 'First pane shrinks',
      onIncrease: () => _nudgeFirstPane(widget.keyboardResizeStep),
      onDecrease: () => _nudgeFirstPane(-widget.keyboardResizeStep),
      child: MouseRegion(
        cursor: _resizeCursor,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: _onDividerDoubleTap,
          onHorizontalDragStart: widget.axis == CNSplitAxis.horizontal
              ? _onDividerDragStart
              : null,
          onHorizontalDragUpdate: widget.axis == CNSplitAxis.horizontal
              ? _onDividerDragUpdate
              : null,
          onHorizontalDragEnd: widget.axis == CNSplitAxis.horizontal
              ? _onDividerDragEnd
              : null,
          onHorizontalDragCancel: widget.axis == CNSplitAxis.horizontal
              ? _onDividerDragCancel
              : null,
          onVerticalDragStart: widget.axis == CNSplitAxis.vertical
              ? _onDividerDragStart
              : null,
          onVerticalDragUpdate: widget.axis == CNSplitAxis.vertical
              ? _onDividerDragUpdate
              : null,
          onVerticalDragEnd: widget.axis == CNSplitAxis.vertical
              ? _onDividerDragEnd
              : null,
          onVerticalDragCancel: widget.axis == CNSplitAxis.vertical
              ? _onDividerDragCancel
              : null,
          child: dividerBody,
        ),
      ),
    );

    if (widget.axis == CNSplitAxis.horizontal) {
      return SizedBox(width: _effectiveDividerThickness, child: dividerHandle);
    }

    return SizedBox(height: _effectiveDividerThickness, child: dividerHandle);
  }

  String get _dividerSemanticHint {
    if (widget.axis == CNSplitAxis.horizontal) {
      return 'Drag left or right to resize panes';
    }
    return 'Drag up or down to resize panes';
  }

  void _onDividerDoubleTap() {
    switch (widget.dividerDoubleTapAction) {
      case CNSplitDividerDoubleTapAction.none:
        return;
      case CNSplitDividerDoubleTapAction.toggleFirst:
        toggleFirst();
        return;
      case CNSplitDividerDoubleTapAction.toggleSecond:
        toggleSecond();
        return;
      case CNSplitDividerDoubleTapAction.reset:
        setFraction(_defaultInitialFraction);
        return;
    }
  }

  void _onDividerDragStart(DragStartDetails details) {
    _dragStartFraction = _normalizedFraction(_fraction);
    setState(() {
      _isDividerDragging = true;
      _dragRawFraction = _dragStartFraction;
      _activeSnapFraction = null;
      if (_firstCollapsed || _secondCollapsed) {
        _firstCollapsed = false;
        _secondCollapsed = false;
        _fraction = _normalizedFraction(_restoreFraction ?? _fraction);
        _dragRawFraction = _fraction;
      }
    });
  }

  void _onDividerDragUpdate(DragUpdateDetails details) {
    final extent = _lastAvailableExtent;
    if (extent == null || extent <= 0) {
      return;
    }

    final delta = widget.axis == CNSplitAxis.horizontal
        ? details.delta.dx
        : details.delta.dy;
    final rawBase = _dragRawFraction ?? _fraction;
    final rawNext = rawBase + (delta / extent);
    final clampedRaw = _clampFractionForExtent(rawNext, extent);
    _dragRawFraction = clampedRaw;
    final snapped = _applySnapIfNeeded(clampedRaw, extent);

    setState(() {
      _firstCollapsed = false;
      _secondCollapsed = false;
      _fraction = snapped;
      _restoreFraction = snapped;
    });
  }

  void _onDividerDragEnd(DragEndDetails details) {
    final dragStartFraction = _dragStartFraction;
    final extent = _lastAvailableExtent;
    if (extent == null || extent <= 0) {
      setState(() {
        _dragStartFraction = null;
        _dragRawFraction = null;
        _activeSnapFraction = null;
        _isDividerDragging = false;
      });
      return;
    }

    final snapped = _applySnapIfNeeded(_dragRawFraction ?? _fraction, extent);
    _dragStartFraction = null;
    _dragRawFraction = null;
    _activeSnapFraction = null;
    final unchangedFromStart =
        dragStartFraction != null &&
        (_fraction - dragStartFraction).abs() < 0.0001;
    if ((_fraction - snapped).abs() < 0.0001 && unchangedFromStart) {
      if (_isDividerDragging) {
        setState(() {
          _isDividerDragging = false;
        });
      }
      return;
    }

    setState(() {
      _isDividerDragging = false;
      _fraction = snapped;
      _restoreFraction = snapped;
    });
  }

  void _onDividerDragCancel() {
    if (!_isDividerDragging &&
        _dragStartFraction == null &&
        _dragRawFraction == null) {
      return;
    }
    setState(() {
      _isDividerDragging = false;
      _dragStartFraction = null;
      _dragRawFraction = null;
      _activeSnapFraction = null;
    });
  }

  double _applySnapIfNeeded(double fraction, double availableExtent) {
    if (widget.snapFractions.isEmpty || widget.snapThreshold <= 0) {
      _activeSnapFraction = null;
      return fraction;
    }

    final snapCandidates = _effectiveSnapCandidates(availableExtent);
    if (snapCandidates.isEmpty) {
      _activeSnapFraction = null;
      return fraction;
    }

    final engageThreshold = widget.snapThreshold;
    final autoReleaseThreshold = math.max(
      widget.snapThreshold * 2.0,
      widget.snapThreshold + (8.0 / availableExtent),
    );
    final releaseThreshold =
        (widget.snapReleaseThreshold ?? autoReleaseThreshold)
            .clamp(engageThreshold, 1.0)
            .toDouble();

    final activeSnap = _activeSnapFraction;
    if (activeSnap != null) {
      final nearestToActive = _nearestSnap(activeSnap, snapCandidates);
      if ((nearestToActive - activeSnap).abs() <= 0.0001) {
        final activeDistance = (fraction - activeSnap).abs();
        if (activeDistance <= releaseThreshold) {
          return activeSnap;
        }
      }
      _activeSnapFraction = null;
    }

    final nearest = _nearestSnap(fraction, snapCandidates);
    final nearestDistance = (fraction - nearest).abs();

    if (nearestDistance <= engageThreshold) {
      _activeSnapFraction = nearest;
      return nearest;
    }

    return fraction;
  }

  double _nearestSnap(double value, List<double> candidates) {
    var nearest = candidates.first;
    var nearestDistance = (value - nearest).abs();
    for (final candidate in candidates.skip(1)) {
      final distance = (value - candidate).abs();
      if (distance < nearestDistance) {
        nearest = candidate;
        nearestDistance = distance;
      }
    }
    return nearest;
  }

  List<double> _effectiveSnapCandidates(double availableExtent) {
    final normalized =
        widget.snapFractions
            .map((value) => _clampFractionForExtent(value, availableExtent))
            .toList()
          ..sort();

    if (normalized.isEmpty) {
      return const <double>[];
    }

    final deduped = <double>[normalized.first];
    for (final value in normalized.skip(1)) {
      if ((value - deduped.last).abs() > 0.0001) {
        deduped.add(value);
      }
    }

    return deduped;
  }

  void _publishMetrics(CNSplitMetrics metrics) {
    if (_lastPublishedMetrics == metrics) {
      return;
    }
    _lastPublishedMetrics = metrics;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _controller?._setMetrics(metrics);
      widget.onChanged?.call(metrics);
    });
  }

  bool _canCollapseFirst() {
    if (!widget.first.collapsible) {
      return false;
    }
    return switch (widget.collapseBehavior) {
      CNSplitCollapseBehavior.none => false,
      CNSplitCollapseBehavior.firstPane => true,
      CNSplitCollapseBehavior.secondPane => false,
      CNSplitCollapseBehavior.eitherPane => true,
    };
  }

  bool _canCollapseSecond() {
    if (!widget.second.collapsible) {
      return false;
    }
    return switch (widget.collapseBehavior) {
      CNSplitCollapseBehavior.none => false,
      CNSplitCollapseBehavior.firstPane => false,
      CNSplitCollapseBehavior.secondPane => true,
      CNSplitCollapseBehavior.eitherPane => true,
    };
  }

  @override
  void setFraction(double value) {
    final extent = _lastAvailableExtent;
    final clamped = extent == null || extent <= 0
        ? value.clamp(widget.minFraction, widget.maxFraction).toDouble()
        : _clampFractionForExtent(value, extent);

    setState(() {
      _firstCollapsed = false;
      _secondCollapsed = false;
      _fraction = clamped;
      _restoreFraction = clamped;
      _dragStartFraction = null;
      _dragRawFraction = null;
      _activeSnapFraction = null;
      _isDividerDragging = false;
    });
  }

  @override
  void setFirstExtent(double value) {
    final extent = _lastAvailableExtent;
    if (extent == null || extent <= 0) {
      return;
    }
    setFraction((value / extent).clamp(0.0, 1.0).toDouble());
  }

  @override
  void setSecondExtent(double value) {
    final extent = _lastAvailableExtent;
    if (extent == null || extent <= 0) {
      return;
    }
    setFraction((1.0 - (value / extent)).clamp(0.0, 1.0).toDouble());
  }

  @override
  void collapseFirst() {
    if (!_canCollapseFirst()) {
      return;
    }
    setState(() {
      if (_firstCollapsed) {
        return;
      }
      _restoreFraction = _normalizedFraction(_fraction);
      _firstCollapsed = true;
      _secondCollapsed = false;
    });
  }

  @override
  void collapseSecond() {
    if (!_canCollapseSecond()) {
      return;
    }
    setState(() {
      if (_secondCollapsed) {
        return;
      }
      _restoreFraction = _normalizedFraction(_fraction);
      _secondCollapsed = true;
      _firstCollapsed = false;
    });
  }

  @override
  void expandFirst() {
    if (!_firstCollapsed) {
      return;
    }
    final fallback = _normalizedFraction(
      _restoreFraction ?? _defaultInitialFraction,
    );
    setState(() {
      _firstCollapsed = false;
      _fraction = fallback;
      _restoreFraction = fallback;
    });
  }

  @override
  void expandSecond() {
    if (!_secondCollapsed) {
      return;
    }
    final fallback = _normalizedFraction(
      _restoreFraction ?? _defaultInitialFraction,
    );
    setState(() {
      _secondCollapsed = false;
      _fraction = fallback;
      _restoreFraction = fallback;
    });
  }

  @override
  void toggleFirst() {
    if (_firstCollapsed) {
      expandFirst();
      return;
    }
    collapseFirst();
  }

  @override
  void toggleSecond() {
    if (_secondCollapsed) {
      expandSecond();
      return;
    }
    collapseSecond();
  }
}

class _ComputedExtents {
  const _ComputedExtents({
    required this.firstExtent,
    required this.secondExtent,
  });

  final double firstExtent;
  final double secondExtent;
}

class _MacOSDividerGrabber extends StatelessWidget {
  const _MacOSDividerGrabber({required this.axis, required this.color});

  final CNSplitAxis axis;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isHorizontalSplit = axis == CNSplitAxis.horizontal;

    final dots = List<Widget>.generate(
      3,
      (_) => Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(1.5),
        ),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: CupertinoColors.systemFill.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: isHorizontalSplit
            ? Column(mainAxisSize: MainAxisSize.min, children: dots)
            : Row(mainAxisSize: MainAxisSize.min, children: dots),
      ),
    );
  }
}
