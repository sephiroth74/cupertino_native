import 'package:cupertino_native/theme/cn_scrollbar_theme.dart';
import 'package:cupertino_native/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const double _kScrollbarMinLength = 36.0;
const double _kScrollbarMinOverscrollLength = 8.0;
const Duration _kScrollbarTimeToFade = Duration(milliseconds: 1200);
const Duration _kScrollbarFadeDuration = Duration(milliseconds: 250);
const Duration _kScrollbarResizeDuration = Duration(milliseconds: 100);
const double _kScrollbarMainAxisMargin = 3.0;
const double _kScrollbarCrossAxisMargin = 2.0;

/// Scrollbar for MacOS
class CNScrollbar extends StatelessWidget {
  /// Creates a [CNScrollbar] that wraps a scrollable widget and provides a scrollbar for it.
  const CNScrollbar({
    super.key,
    required this.child,
    this.controller,
    this.thumbVisibility,
    this.thickness,
    this.thicknessWhileHovering,
    this.radius,
    this.notificationPredicate,
    this.scrollbarOrientation,
  });

  /// The child widget that will be wrapped by the scrollbar.
  final Widget child;

  /// The [ScrollController] that controls the scrollable widget.
  final ScrollController? controller;

  /// The predicate that determines which scroll notifications should be handled by the scrollbar.
  final ScrollNotificationPredicate? notificationPredicate;

  /// The radius of the scrollbar thumb.
  final Radius? radius;

  /// The orientation of the scrollbar.
  final ScrollbarOrientation? scrollbarOrientation;

  /// The thickness of the scrollbar track and thumb.
  final double? thickness;

  /// The thickness of the scrollbar track and thumb while hovering.
  final double? thicknessWhileHovering;

  /// Whether the scrollbar thumb is always visible.
  final bool? thumbVisibility;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasCNTheme(context));
    final scrollbarTheme = CNScrollbarTheme.of(context);
    assert(scrollbarTheme.thickness != null);
    assert(scrollbarTheme.thicknessWhileHovering != null);

    return _RawMacosScrollBar(
      controller: controller,
      thumbVisibility: thumbVisibility ?? scrollbarTheme.thumbVisibility,
      thickness: thickness ?? scrollbarTheme.thickness,
      thicknessWhileHovering: thicknessWhileHovering ?? scrollbarTheme.thicknessWhileHovering!,
      notificationPredicate: notificationPredicate,
      scrollbarOrientation: scrollbarOrientation,
      effectiveThumbColor: scrollbarTheme.thumbColor!,
      radius: radius ?? scrollbarTheme.radius,
      child: child,
    );
  }
}

class _RawMacosScrollBar extends RawScrollbar {
  const _RawMacosScrollBar({
    required super.child,
    super.controller,
    bool? thumbVisibility,
    super.thickness,
    required this.thicknessWhileHovering,
    ScrollNotificationPredicate? notificationPredicate,
    super.scrollbarOrientation,
    required this.effectiveThumbColor,
    super.radius,
  }) : assert(thickness != null && thickness < double.infinity),
       assert(thicknessWhileHovering < double.infinity),
       super(
         thumbVisibility: thumbVisibility ?? false,
         fadeDuration: _kScrollbarFadeDuration,
         timeToFade: _kScrollbarTimeToFade,
         notificationPredicate: notificationPredicate ?? defaultScrollNotificationPredicate,
       );

  final Color effectiveThumbColor;
  final double thicknessWhileHovering;

  @override
  RawScrollbarState<_RawMacosScrollBar> createState() => _RawMacosScrollBarState();
}

class _RawMacosScrollBarState extends RawScrollbarState<_RawMacosScrollBar> {
  bool _hoverIsActive = false;
  late AnimationController _thumbThicknessAnimationController;
  late AnimationController _trackColorAnimationController;
  late Animation _trackColorTween;

  @override
  void dispose() {
    _thumbThicknessAnimationController.dispose();
    _trackColorAnimationController.dispose();
    super.dispose();
  }

  @override
  void handleHover(PointerHoverEvent event) {
    super.handleHover(event);
    if (isPointerOverScrollbar(event.position, event.kind, forHover: true)) {
      setState(() => _hoverIsActive = true);
      _thumbThicknessAnimationController.forward();
      _trackColorAnimationController.forward();
    } else if (_hoverIsActive) {
      setState(() => _hoverIsActive = false);
      _thumbThicknessAnimationController.reverse();
      _trackColorAnimationController.reverse();
    }
  }

  @override
  void handleHoverExit(PointerExitEvent event) {
    super.handleHoverExit(event);
    setState(() => _hoverIsActive = false);
    _thumbThicknessAnimationController.reverse();
    _trackColorAnimationController.reverse();
  }

  @override
  void initState() {
    super.initState();
    _thumbThicknessAnimationController = AnimationController(vsync: this, duration: _kScrollbarResizeDuration);
    _trackColorAnimationController = AnimationController(vsync: this, duration: _kScrollbarResizeDuration);
    _trackColorTween = ColorTween(
      begin: Colors.transparent,
      end: widget.effectiveThumbColor.withValues(alpha: 0.15),
    ).animate(_trackColorAnimationController);
    _thumbThicknessAnimationController.addListener(() {
      updateScrollbarPainter();
    });
    _trackColorAnimationController.addListener(() {
      updateScrollbarPainter();
    });
  }

  @override
  void updateScrollbarPainter() {
    scrollbarPainter
      ..color = widget.effectiveThumbColor
      ..trackColor = _trackColorTween.value
      ..textDirection = Directionality.of(context)
      ..thickness = _thickness
      ..mainAxisMargin = _kScrollbarMainAxisMargin
      ..crossAxisMargin = _kScrollbarCrossAxisMargin
      ..radius = widget.radius
      ..padding = MediaQuery.of(context).padding
      ..minLength = _kScrollbarMinLength
      ..minOverscrollLength = _kScrollbarMinOverscrollLength
      ..scrollbarOrientation = widget.scrollbarOrientation;
  }

  double get _thickness {
    return widget.thickness! + _thumbThicknessAnimationController.value * (widget.thicknessWhileHovering - widget.thickness!);
  }
}
