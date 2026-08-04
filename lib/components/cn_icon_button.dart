import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

/// A highly customizable icon button rendering either a Flutter [IconData] or a
/// native SF Symbol (via [CNImage]).
///
/// The button reacts to hover, press, selection and disabled states. Every
/// visual aspect — per-state foreground/background colors, border, shape,
/// corner radius, icon size and padding — can be set directly on the widget or,
/// for app-wide consistency, through [CNIconButtonTheme] / [CNThemeData.iconButtonTheme].
///
/// Resolution order for every visual property is:
/// explicit widget parameter → [CNIconButtonTheme] override → [CNTheme] semantic default.
///
/// Provide exactly one of [icon] or [systemSymbolName], and optionally a
/// [selectedIcon] / [selectedSystemSymbolName] to swap the glyph while
/// [isSelected] is true.
class CNIconButton extends StatefulWidget {
  /// Creates a [CNIconButton].
  const CNIconButton({
    super.key,
    required this.size,
    this.icon,
    this.selectedIcon,
    this.systemSymbolName,
    this.selectedSystemSymbolName,
    this.onTap,
    this.onLongPress,
    this.onHover,
    this.isSelected = false,
    this.symbolRenderingMode,
    this.foregroundColor,
    this.hoveredForegroundColor,
    this.selectedForegroundColor,
    this.pressedForegroundColor,
    this.disabledForegroundColor,
    this.backgroundColor,
    this.hoveredBackgroundColor,
    this.selectedBackgroundColor,
    this.pressedBackgroundColor,
    this.disabledBackgroundColor,
    this.borderColor,
    this.borderWidth,
    this.shape,
    this.borderRadius,
    this.iconSizeRatio,
    this.padding,
    this.animationDuration,
  }) : assert(
         icon != null || systemSymbolName != null,
         'Either icon or systemSymbolName must be provided.',
       ),
       assert(
         !(icon != null && systemSymbolName != null),
         'Only one of icon or systemSymbolName can be provided.',
       ),
       assert(
         !(selectedIcon != null && selectedSystemSymbolName != null),
         'Only one of selectedIcon or selectedSystemSymbolName can be provided.',
       ),
       assert(
         iconSizeRatio == null || (iconSizeRatio > 0 && iconSizeRatio <= 1),
         'iconSizeRatio must be in the (0, 1] range.',
       );

  /// Transition duration for state (hover/press/selection) changes.
  final Duration? animationDuration;

  /// Background fill in the idle state. Overrides the theme when non-null.
  final Color? backgroundColor;

  /// Border stroke color. Overrides the theme when non-null.
  final Color? borderColor;

  /// Corner radius used when the resolved shape is [CNIconButtonShape.roundedRectangle].
  final double? borderRadius;

  /// Border stroke width. Overrides the theme when non-null.
  final double? borderWidth;

  /// Background fill while disabled. Overrides the theme when non-null.
  final Color? disabledBackgroundColor;

  /// Icon color while disabled. Overrides the theme when non-null.
  final Color? disabledForegroundColor;

  /// Icon color in the idle state. Overrides the theme when non-null.
  final Color? foregroundColor;

  /// Background fill while hovered. Overrides the theme when non-null.
  final Color? hoveredBackgroundColor;

  /// Icon color while hovered. Overrides the theme when non-null.
  final Color? hoveredForegroundColor;

  /// The icon to display inside the button. Cannot be used with [systemSymbolName].
  final IconData? icon;

  /// Icon size expressed as a fraction of [size]. Overrides the theme when non-null.
  final double? iconSizeRatio;

  /// Whether the button is selected.
  final bool isSelected;

  /// The callback invoked when the button is hovered (true) or unhovered (false).
  final ValueChanged<bool>? onHover;

  /// The callback invoked when the button is long-pressed.
  final VoidCallback? onLongPress;

  /// The callback invoked when the button is pressed.
  final VoidCallback? onTap;

  /// Extra padding around the icon inside the button. Overrides the theme when non-null.
  final EdgeInsetsGeometry? padding;

  /// Background fill while pressed. Overrides the theme when non-null.
  final Color? pressedBackgroundColor;

  /// Icon color while pressed. Overrides the theme when non-null.
  final Color? pressedForegroundColor;

  /// Background fill while selected. Overrides the theme when non-null.
  final Color? selectedBackgroundColor;

  /// Icon color while selected. Overrides the theme when non-null.
  final Color? selectedForegroundColor;

  /// The icon to display when selected. Cannot be used with [systemSymbolName].
  final IconData? selectedIcon;

  /// The SF Symbol to display when selected. Cannot be used with [selectedIcon].
  final String? selectedSystemSymbolName;

  /// The overall background / hit-target shape. Overrides the theme when non-null.
  final CNIconButtonShape? shape;

  /// The size (width and height) of the button.
  final double size;

  /// Optional SF Symbol rendering mode, forwarded to the native [CNImage]
  /// (only used for the [systemSymbolName] path).
  final CNSymbolRenderingMode? symbolRenderingMode;

  /// The system symbol name to display. Cannot be used with [icon].
  final String? systemSymbolName;

  @override
  State<CNIconButton> createState() => _CNIconButtonState();

  /// Whether the button is interactive. When false the button shows its
  /// disabled appearance and ignores pointer input.
  bool get enabled => onTap != null || onLongPress != null;
}

class _CNIconButtonState extends State<CNIconButton> {
  bool _hovered = false;
  bool _pressed = false;

  bool get _interactive => widget.enabled;

  Widget _buildGlyph({
    required BuildContext context,
    required double iconSize,
    required Color foreground,
  }) {
    if (widget.icon != null) {
      final IconData effectiveIcon =
          (widget.isSelected ? widget.selectedIcon : null) ?? widget.icon!;
      return Icon(effectiveIcon, size: iconSize, color: foreground);
    }

    final String symbol = widget.isSelected
        ? (widget.selectedSystemSymbolName ?? widget.systemSymbolName!)
        : widget.systemSymbolName!;

    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: CNImage(
        systemSymbolName: symbol,
        shrink: false,
        foregroundColor: foreground,
        symbolRenderingMode: widget.symbolRenderingMode,
        // Slightly inset so the glyph fits the reported icon box like the AppKit metric.
        font: CNFont.system(CNFontSize.points(iconSize - (iconSize * 0.2))),
        constraints: BoxConstraints.tightFor(width: iconSize, height: iconSize),
      ),
    );
  }

  BoxDecoration _decoration({
    required CNIconButtonShape shape,
    required Color? background,
    required Border? border,
    required CNIconButtonThemeData buttonTheme,
  }) {
    // Always render as a rectangle with a corner radius (never BoxShape.circle):
    // the button is square, so a circle is simply `size / 2`. This keeps
    // AnimatedContainer's BoxDecoration.lerp valid across shape changes — mixing
    // `shape: circle` with a non-null borderRadius trips a framework assertion.
    final double radius;
    switch (shape) {
      case CNIconButtonShape.circle:
      case CNIconButtonShape.capsule:
        radius = widget.size / 2;
        break;
      case CNIconButtonShape.roundedRectangle:
        radius =
            widget.borderRadius ?? buttonTheme.borderRadius ?? widget.size / 8;
        break;
    }
    return BoxDecoration(
      color: background,
      border: border,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  Color? _resolveBackground({
    required BuildContext context,
    required CNThemeData theme,
    required CNIconButtonThemeData buttonTheme,
    required Color? accent,
    required bool disabled,
    required bool pressed,
    required bool hovered,
  }) {
    if (disabled) {
      return widget.disabledBackgroundColor ??
          buttonTheme.disabledBackgroundColor;
    }
    if (pressed) {
      return widget.pressedBackgroundColor ??
          buttonTheme.pressedBackgroundColor ??
          theme.fillPrimaryColor;
    }
    if (hovered) {
      return widget.hoveredBackgroundColor ??
          buttonTheme.hoveredBackgroundColor ??
          theme.fillSecondaryColor;
    }
    if (widget.isSelected) {
      return widget.selectedBackgroundColor ??
          buttonTheme.selectedBackgroundColor ??
          accent?.withValues(alpha: 0.15) ??
          theme.fillSecondaryColor;
    }
    return widget.backgroundColor ?? buttonTheme.backgroundColor;
  }

  Color _resolveForeground({
    required BuildContext context,
    required CNThemeData theme,
    required CNIconButtonThemeData buttonTheme,
    required Color? accent,
    required bool disabled,
    required bool pressed,
    required bool hovered,
  }) {
    final Color idle = CNColors.label.resolveFromContext(context);
    if (disabled) {
      return widget.disabledForegroundColor ??
          buttonTheme.disabledForegroundColor ??
          idle.withValues(alpha: 0.3);
    }
    if (pressed) {
      return widget.pressedForegroundColor ??
          buttonTheme.pressedForegroundColor ??
          accent?.withLuminance(0.4) ??
          idle;
    }
    if (hovered) {
      return widget.hoveredForegroundColor ??
          buttonTheme.hoveredForegroundColor ??
          accent?.withLuminance(0.3) ??
          idle;
    }
    if (widget.isSelected) {
      return widget.selectedForegroundColor ??
          buttonTheme.selectedForegroundColor ??
          accent ??
          idle;
    }
    return widget.foregroundColor ?? buttonTheme.foregroundColor ?? idle;
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
    widget.onHover?.call(value);
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);
    final buttonTheme = CNIconButtonTheme.of(context);
    final accent = theme.accentColor;

    final bool disabled = !widget.enabled;
    // Precedence for the effective visual state: disabled → pressed → hovered → selected → idle.
    final bool pressed = _interactive && _pressed;
    final bool hovered = _interactive && _hovered && !pressed;

    final Color foreground = _resolveForeground(
      context: context,
      theme: theme,
      buttonTheme: buttonTheme,
      accent: accent,
      disabled: disabled,
      pressed: pressed,
      hovered: hovered,
    );
    final Color? background = _resolveBackground(
      context: context,
      theme: theme,
      buttonTheme: buttonTheme,
      accent: accent,
      disabled: disabled,
      pressed: pressed,
      hovered: hovered,
    );

    final double iconSizeRatio =
        widget.iconSizeRatio ?? buttonTheme.iconSizeRatio ?? 0.75;
    final double iconSize = widget.size * iconSizeRatio;
    final EdgeInsetsGeometry padding =
        widget.padding ?? buttonTheme.padding ?? EdgeInsets.zero;
    final Duration duration =
        widget.animationDuration ??
        buttonTheme.animationDuration ??
        const Duration(milliseconds: 100);
    final CNIconButtonShape shape =
        widget.shape ?? buttonTheme.shape ?? CNIconButtonShape.roundedRectangle;

    final Color? borderColor = widget.borderColor ?? buttonTheme.borderColor;
    final double borderWidth =
        widget.borderWidth ?? buttonTheme.borderWidth ?? 0.0;
    final Border? border = (borderColor != null && borderWidth > 0)
        ? Border.all(color: borderColor, width: borderWidth)
        : null;

    final BoxDecoration decoration = _decoration(
      shape: shape,
      background: background,
      border: border,
      buttonTheme: buttonTheme,
    );

    final Widget glyph = _buildGlyph(
      context: context,
      iconSize: iconSize,
      foreground: foreground,
    );

    final Widget content = AnimatedContainer(
      duration: duration,
      curve: Curves.easeOut,
      width: widget.size,
      height: widget.size,
      alignment: Alignment.center,
      padding: padding,
      decoration: decoration,
      child: glyph,
    );

    // The interactive layer is stacked ABOVE the visual content. This matters
    // for the SF-symbol path, whose glyph is a native AppKit platform view
    // (CNImage) that would otherwise consume pointer events before an ancestor
    // GestureDetector could see them. Painting the gesture layer on top lets
    // Flutter win the hit test over the native view.
    final Widget interactionLayer = Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _interactive ? (_) => _setPressed(true) : null,
        onTapUp: _interactive ? (_) => _setPressed(false) : null,
        onTapCancel: _interactive ? () => _setPressed(false) : null,
        onTap: _interactive ? widget.onTap : null,
        onLongPress: _interactive ? widget.onLongPress : null,
        child: const SizedBox.expand(),
      ),
    );

    return MouseRegion(
      cursor: _interactive ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: Semantics(
        button: true,
        enabled: _interactive,
        selected: widget.isSelected,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            fit: StackFit.passthrough,
            children: [content, interactionLayer],
          ),
        ),
      ),
    );
  }
}
