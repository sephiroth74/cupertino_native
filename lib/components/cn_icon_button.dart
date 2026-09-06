import 'dart:math' show min;

import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

/// A highly customizable icon button rendering either a Flutter [IconData] or a
/// native SF Symbol (via [CNImage]).
///
/// The button reacts to hover, press, selection and disabled states. Every
/// visual aspect — per-state foreground/background colors, border, shape,
/// corner radius, icon size, font and padding — can be set directly on the widget or,
/// for app-wide consistency, through [CNIconButtonTheme] / [CNThemeData.iconButtonTheme].
///
/// Resolution order for every visual property is:
/// explicit widget parameter → [CNIconButtonTheme] override → [CNTheme] semantic default.
///
/// The colors are [WidgetStateProperty] objects resolved against
/// [WidgetState.disabled], [WidgetState.pressed], [WidgetState.hovered] and
/// [WidgetState.selected]. The first three are mutually exclusive — a pressed
/// button never reports `hovered` and a disabled one reports neither — while
/// `selected` can combine with any of them. Order the keys of a
/// [WidgetStateProperty.fromMap] accordingly (the built-in defaults resolve
/// disabled → pressed → hovered → selected → idle).
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
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.shape,
    this.borderRadius,
    this.iconSizeRatio,
    this.padding,
    this.animationDuration,
    this.font,
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

  /// Per-state background fill. Overrides the theme for every state it
  /// resolves; see [foregroundColor] for how partial properties layer.
  ///
  /// Defaults to no fill while idle and disabled, [CNThemeData.fillPrimaryColor]
  /// while pressed, [CNThemeData.fillSecondaryColor] while hovered and a
  /// translucent accent tint while selected.
  final WidgetStateProperty<Color?>? backgroundColor;

  /// Border stroke color. Overrides the theme when non-null.
  final Color? borderColor;

  /// Corner radius used when the resolved shape is [CNIconButtonShape.roundedRectangle].
  final double? borderRadius;

  /// Border stroke width. Overrides the theme when non-null.
  final double? borderWidth;

  /// Optional font used to draw the glyph. Overrides the theme when non-null.
  ///
  /// When the font carries an explicit point size ([CNFontSize.points]) that
  /// size wins over [iconSizeRatio]: the glyph box grows or shrinks to fit it,
  /// never past [size]. With a [CNFontSize.preset] size the box still comes from
  /// [iconSizeRatio] and the native side resolves the preset.
  ///
  /// For the [systemSymbolName] path the whole font (kind, weight, size) is
  /// forwarded to the native [CNImage], so this is how you get a bolder or
  /// lighter SF Symbol. For the [icon] path only the point size applies —
  /// Flutter's bundled icon fonts have no weight axis.
  final CNFont? font;

  /// Per-state icon color. Overrides the theme for every state it resolves.
  ///
  /// The property resolves to a nullable [Color], so it can cover a subset of
  /// the states and leave the others to the layers below — the ambient
  /// [CNIconButtonTheme] first, then the [CNTheme] semantic defaults:
  ///
  /// ```dart
  /// // Only the pressed color is overridden; idle, hovered, selected and
  /// // disabled keep coming from the theme.
  /// CNIconButton(
  ///   size: 28,
  ///   icon: CupertinoIcons.share,
  ///   onTap: () {},
  ///   foregroundColor: WidgetStateProperty<Color?>.fromMap({
  ///     WidgetState.pressed: CupertinoColors.activeBlue,
  ///   }),
  /// )
  /// ```
  ///
  /// Conversely a [WidgetStatePropertyAll] applies to *every* state, which also
  /// flattens the hover / press feedback.
  ///
  /// Defaults to the resolved [CNColors.label], tinted with the accent color
  /// while hovered, pressed or selected and faded while disabled.
  final WidgetStateProperty<Color?>? foregroundColor;

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
  /// Fraction of the glyph box used as the SF Symbol point size: the native
  /// symbol is inset so it fits the reported icon box like the AppKit metric.
  static const double _kSymbolFontRatio = 0.8;

  bool _hovered = false;
  bool _pressed = false;

  bool get _interactive => widget.enabled;

  Widget _buildGlyph({
    required BuildContext context,
    required double iconSize,
    required Color foreground,
    required CNFont? font,
  }) {
    // An explicit point size wins over iconSizeRatio, clamped to the button so
    // an oversized font can't paint outside it.
    final double? points = font?.size.points;

    if (widget.icon != null) {
      final IconData effectiveIcon =
          (widget.isSelected ? widget.selectedIcon : null) ?? widget.icon!;
      // A Flutter glyph is drawn at its em size, so no symbol inset applies.
      return Icon(
        effectiveIcon,
        size: points == null ? iconSize : min(points, widget.size),
        color: foreground,
      );
    }

    final String symbol = widget.isSelected
        ? (widget.selectedSystemSymbolName ?? widget.systemSymbolName!)
        : widget.systemSymbolName!;

    final double box = points == null
        ? iconSize
        : min(points / _kSymbolFontRatio, widget.size);

    return SizedBox(
      width: box,
      height: box,
      child: CNImage(
        systemSymbolName: symbol,
        shrink: false,
        foregroundColor: foreground,
        symbolRenderingMode: widget.symbolRenderingMode,
        font: font ?? CNFont.system(CNFontSize.points(box * _kSymbolFontRatio)),
        constraints: BoxConstraints.tightFor(width: box, height: box),
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

  /// The [CNTheme] semantic fallback for the background fill, used for the
  /// states neither the widget nor the [CNIconButtonTheme] resolves.
  ///
  /// The keys are listed in precedence order, so the resolution stays
  /// disabled → pressed → hovered → selected → idle even when the caller
  /// reports several states at once. Idle and disabled resolve to null: an icon
  /// button has no fill of its own until one is themed in.
  WidgetStateProperty<Color?> _defaultBackground({
    required CNThemeData theme,
    required Color? accent,
  }) {
    return WidgetStateProperty<Color?>.fromMap({
      WidgetState.disabled: null,
      WidgetState.pressed: theme.fillPrimaryColor,
      WidgetState.hovered: theme.fillSecondaryColor,
      WidgetState.selected:
          accent?.withValues(alpha: 0.15) ?? theme.fillSecondaryColor,
      WidgetState.any: null,
    });
  }

  /// The [CNTheme] semantic fallback for the icon color. Keys are in the same
  /// precedence order as [_defaultBackground]; every state resolves to a color,
  /// so this layer always terminates the chain.
  WidgetStateProperty<Color?> _defaultForeground({
    required Color idle,
    required Color? accent,
  }) {
    return WidgetStateProperty<Color?>.fromMap({
      WidgetState.disabled: idle.withValues(alpha: 0.3),
      WidgetState.pressed: accent?.withLuminance(0.4) ?? idle,
      WidgetState.hovered: accent?.withLuminance(0.3) ?? idle,
      WidgetState.selected: accent ?? idle,
      WidgetState.any: idle,
    });
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
    // disabled / pressed / hovered are mutually exclusive by construction (see
    // above); selected is orthogonal and may join any of them.
    final Set<WidgetState> states = <WidgetState>{
      if (disabled) WidgetState.disabled,
      if (pressed) WidgetState.pressed,
      if (hovered) WidgetState.hovered,
      if (widget.isSelected) WidgetState.selected,
    };

    final Color idle = CNColors.label.resolveFromContext(context);
    final Color foreground =
        CNStateColor.resolve(states, [
          widget.foregroundColor,
          buttonTheme.foregroundColor,
          _defaultForeground(idle: idle, accent: accent),
        ]) ??
        idle;
    final Color? background = CNStateColor.resolve(states, [
      widget.backgroundColor,
      buttonTheme.backgroundColor,
      _defaultBackground(theme: theme, accent: accent),
    ]);

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
    final CNFont? font = widget.font ?? buttonTheme.font;

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
      font: font,
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
