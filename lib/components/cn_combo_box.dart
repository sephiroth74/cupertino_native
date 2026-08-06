// ignore_for_file: public_member_api_docs

import 'dart:math' as math;

import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Fallback field width used when neither an explicit constraint nor a bounded
/// parent establishes one. Matches [CNTextField]'s default width.
const double _kDefaultWidth = 200.0;

/// Inset between the caret button and the text field's edges, matching the
/// reference AppKit combo box (`caretButtonPadding`).
const double _kCaretInset = 1.5;

/// The visual style of a [CNComboBox]'s trailing disclosure caret, mirroring
/// AppKit's `NSComboBox` button styles.
enum CNComboBoxStyle {
  /// A raised push-button caret filled with the accent color and a single
  /// downward chevron — the default macOS combo box appearance.
  bordered,

  /// A flat caret with a subtle fill and a double (up/down) chevron.
  plain,
}

/// A native macOS combo box: an editable text field paired with a pop-up list
/// of items the user can choose from.
///
/// Unlike a raw `NSComboBox` embedded in a platform view — whose dropdown is
/// driven by an AppKit nested mouse-tracking loop that fights Flutter's event
/// pipeline (the list flashes open then dismisses, or closes on mouse-move) —
/// this widget composes the library's own primitives: a [CNTextField] for the
/// editable value and the plugin's window-level native menu
/// (`showContextMenu2` → `NSMenu`) for the pop-up list. The menu is presented
/// outside the platform view, so it opens reliably on the first click and stays
/// open while the pointer moves.
class CNComboBox extends StatefulWidget {
  const CNComboBox({
    super.key,
    this.debugLog = false,
    this.text = '',
    this.items = const [],
    this.placeholder,
    this.textColor,
    this.font,
    this.style = CNComboBoxStyle.bordered,
    this.completes = false,
    this.editable = true,
    this.onChanged,
    this.onSelectionChanged,
    this.shrink = true,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
    this.help,
    this.overlay,
    this.background,
    this.minMenuWidth = true,
  });

  /// Defines if the context menu size should be at least the width of the combo box field.
  final bool minMenuWidth;

  /// Optional decorative layer drawn on top of the text field (SwiftUI
  final CNOverlay? overlay;

  /// Optional decorative layer drawn behind the text field (SwiftUI
  /// `.background(alignment:content:)`), e.g. a colored fill or shape.
  final CNBackground? background;

  /// Whether the combo box auto-completes the field as the user types,
  /// matching the typed prefix against [items].
  final bool completes;

  /// Optional explicit constraints forwarded to the text field.
  final BoxConstraints? constraints;

  /// When true, enables debug logging for this specific widget instance.
  final bool debugLog;

  /// Whether the user can edit the text field by typing.
  ///
  /// When true (the default), the field behaves like a normal editable combo
  /// box. When false, the field is read-only *and* its content is not
  /// selectable: the field acts purely as a menu trigger, so clicking anywhere
  /// on the control (not just the trailing caret) opens the pop-up list.
  final bool editable;

  /// Optional native font descriptor.
  final CNFont? font;

  /// The foreground color applied to the text field.
  final Color? foregroundColor;

  /// Optional tooltip text shown on hover.
  final String? help;

  /// The items in the combo box pop-up list.
  final List<String> items;

  /// Called whenever the text changes (user typing, selecting, or submitting).
  final ValueChanged<String>? onChanged;

  /// Called when the user selects an item from the pop-up list.
  /// The argument is the index of the selected item in [items].
  final ValueChanged<int>? onSelectionChanged;

  /// Optional padding applied around the control.
  final EdgeInsetsGeometry? paddings;

  /// Placeholder string shown when the field is empty.
  final String? placeholder;

  /// Whether the widget shrinks to fit its intrinsic content size.
  final bool shrink;

  /// The visual style of the trailing disclosure caret.
  ///
  /// Defaults to [CNComboBoxStyle.bordered].
  final CNComboBoxStyle style;

  /// The current text value.
  final String text;

  /// The text color of the combo box field.
  final Color? textColor;

  /// Optional tint applied to the text field.
  final Object? tint;

  @override
  State<CNComboBox> createState() => _CNComboBoxState();

  /// Whether the control is enabled.
  bool get enabled => onChanged != null || onSelectionChanged != null;
}

class _CNComboBoxState extends State<CNComboBox> {
  static const MethodChannel _channel = MethodChannel('cupertino_native');

  late final TextEditingController _controller = TextEditingController(
    text: widget.text,
  );
  final GlobalKey _fieldKey = GlobalKey();
  bool _isUpdatingText = false;

  /// Length of the text last reported by the native field. Used to tell an
  /// insertion (net growth of the typed prefix) from a deletion (backspace /
  /// forward-delete), so autocomplete only extends on real insertions.
  late int _lastLength = widget.text.length;

  bool _menuOpen = false;

  @override
  void didUpdateWidget(CNComboBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reflect programmatic value changes, mirroring the previous native behavior
    // where `text` drove `NSComboBox.stringValue`.
    if (oldWidget.text != widget.text && widget.text != _controller.text) {
      _isUpdatingText = true;
      _controller.text = widget.text;
      _isUpdatingText = false;
      _lastLength = widget.text.length;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _log(String message) {
    if (!widget.debugLog) return;
    debugPrint('[CNComboBox] $message');
  }

  void _handleTextChanged(String value) {
    if (_isUpdatingText) return;
    _log('textChanged: "$value" (lastLen=$_lastLength)');

    // Only extend on a real insertion. A backspace / forward-delete shrinks (or,
    // when it clears a selected suffix, does not grow) the typed prefix, so it
    // must not re-trigger autocomplete — the native field has no Flutter key
    // events to intercept, hence the length heuristic. `_lastLength` tracks the
    // length of the typed prefix the user has committed (never the completed
    // value), so typing over the highlighted suffix still reads as growth.
    final isInsertion = value.length > _lastLength;
    _lastLength = value.length;

    if (widget.completes && isInsertion && value.isNotEmpty) {
      final match = widget.items.firstWhere(
        (e) => e.toLowerCase().startsWith(value.toLowerCase()),
        orElse: () => '',
      );
      if (match.isNotEmpty && match.length != value.length) {
        _isUpdatingText = true;
        _controller.value = TextEditingValue(
          text: match,
          // Highlight the completed suffix. Stored ascending (anchor at the
          // typed-prefix boundary, extent at the match end) so it matches the
          // order the native field reports selections in — otherwise the native
          // round-trip would flip it and jitter. Typing always replaces from the
          // range start, i.e. the insertion point, regardless of stored order.
          selection: TextSelection(
            baseOffset: value.length,
            extentOffset: match.length,
          ),
        );
        _isUpdatingText = false;
        widget.onChanged?.call(match);
        return;
      }
    }

    widget.onChanged?.call(value);
  }

  void _handleSubmitted(String value) {
    _log('submitted: "$value"');
    widget.onChanged?.call(value);
  }

  Future<void> _openMenu() async {
    if (!widget.enabled || _menuOpen || widget.items.isEmpty) return;
    if (defaultTargetPlatform != TargetPlatform.macOS) return;

    final box = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    // Anchor the menu at the field's bottom-left, in Flutter global (logical)
    // coordinates — the same space `CNContextMenuRegion` passes to the handler.
    final origin = box.localToGlobal(Offset.zero);
    final anchorX = origin.dx;
    final anchorY = origin.dy + box.size.height;
    final menuWidth = box.size.width;

    final items = <CNChild>[
      for (var i = 0; i < widget.items.length; i++)
        CNChildButton(tag: '$i', title: widget.items[i]),
    ];

    setState(() => _menuOpen = true);
    _log('openMenu at ($anchorX, $anchorY) with ${items.length} items');

    String? response;
    try {
      response = await _channel.invokeMethod<String>('showContextMenu2', {
        'items': items.map((c) => c.toChildPayload(context)).toList(),
        'x': anchorX,
        'y': anchorY,
        if (widget.minMenuWidth) 'minWidth': menuWidth,
      });
    } on PlatformException catch (e) {
      _log('showContextMenu2 failed: $e');
    }

    if (!mounted) return;
    setState(() => _menuOpen = false);

    final index = int.tryParse(response ?? '');
    if (index != null && index >= 0 && index < widget.items.length) {
      final selected = widget.items[index];
      _log('selected index=$index value="$selected"');
      _isUpdatingText = true;
      _controller.text = selected;
      _isUpdatingText = false;
      _lastLength = selected.length;
      widget.onSelectionChanged?.call(index);
      widget.onChanged?.call(selected);
    }
  }

  /// Resolves a single, content-independent width for the field.
  ///
  /// Preference order: an explicit finite [CNComboBox.constraints] max width →
  /// the bounded parent width → the default field width. The result is clamped
  /// to the incoming parent constraints so the control never overflows.
  double _resolveWidth(BoxConstraints parentConstraints) {
    final explicit = widget.constraints;
    double width;
    if (explicit != null && explicit.maxWidth.isFinite) {
      width = explicit.maxWidth;
    } else if (parentConstraints.hasBoundedWidth) {
      width = parentConstraints.maxWidth;
    } else {
      width = _kDefaultWidth;
    }
    return width.clamp(parentConstraints.minWidth, parentConstraints.maxWidth);
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.macOS) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, parentConstraints) {
        // Establish the field width up front so the text field does not grow or
        // shrink with its content (per keystroke or on selection). With shrink
        // mode the inner CNTextField would otherwise report a content-based
        // intrinsic width; a *tight* width constraint forces
        // `computeShrinkWidth` to clamp to a single stable value regardless of
        // the text. Height is left intrinsic (stable from control size / font).
        final width = _resolveWidth(parentConstraints);

        // The field is editable only when the control is enabled *and* the
        // caller opted into editing. A read-only field emits no text changes,
        // so its `onChanged`/`onSubmitted` handlers are dropped — the pop-up
        // menu still drives value/selection changes.
        final fieldEditable = widget.enabled && widget.editable;

        // A non-editable combo box has no text interaction (neither typing nor
        // selecting), so the whole control acts like the caret: a click
        // anywhere opens the pop-up list, not just the trailing button.
        final wholeFieldOpensMenu = widget.enabled && !fieldEditable;

        Widget content = Stack(
          key: _fieldKey,
          children: [
            CNTextField(
              controller: _controller,
              placeholder: widget.placeholder,
              font: widget.font,
              foregroundColor: widget.textColor ?? widget.foregroundColor,
              tint: widget.tint,
              help: widget.help,
              paddings: widget.paddings,
              shrink: widget.shrink,
              overlay: widget.overlay,
              background: widget.background,
              constraints: BoxConstraints.tightFor(width: width),
              enabled: fieldEditable,
              // Read-only implies non-selectable here: the full-field tap layer
              // owns the clicks, so the text must not steal them for selection.
              selectable: fieldEditable,
              onChanged: fieldEditable ? _handleTextChanged : null,
              onSubmitted: fieldEditable ? _handleSubmitted : null,
            ),
            // The caret spans the full field only when the whole control acts
            // as the menu trigger; otherwise it stays pinned to the trailing
            // edge. Pinning `left: 0` too lets it stretch its near-invisible
            // hit layer across the field while the visible button hugs the
            // right.
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              left: wholeFieldOpensMenu ? 0 : null,
              child: _ComboBoxCaret(
                style: widget.style,
                menuOpen: _menuOpen,
                enabled: widget.enabled,
                fullWidth: wholeFieldOpensMenu,
                accentColor: widget.tint is Color
                    ? widget.tint as Color
                    : CNTheme.of(context).accentColor,
                onTap: _openMenu,
              ),
            ),
          ],
        );

        if (!widget.enabled) {
          content = Opacity(opacity: 0.5, child: AbsorbPointer(child: content));
        }

        return content;
      },
    );
  }
}

/// Corner radius of the caret button, scaled to its side length (a regular
/// ~26pt field yields ~4.5, mirroring the reference combo box's radii).
double _caretRadius(double side) => (side * 0.18).clamp(2.5, 6.0);

/// The disclosure caret button drawn on the trailing edge of a [CNComboBox].
///
/// A pure-Flutter overlay (rather than another native platform view) laid above
/// the [CNTextField]. Because the field is a native platform view, taps only
/// land where Flutter actually composites pixels — a transparent overlay lets
/// the click fall through to the AppKit view underneath. Both styles therefore
/// paint a *filled* square background across the whole caret region, so the
/// entire area (not just the painted chevron) reliably behaves like a button.
///
/// The caret is a square whose side equals the field height, insetted by
/// [_kCaretInset] and pinned to the trailing edge, mirroring AppKit's combo box
/// button. [CNComboBoxStyle.bordered] renders a raised accent-filled push button
/// with a single downward chevron; [CNComboBoxStyle.plain] renders a flat,
/// subtly-filled button with a double (up/down) chevron.
///
/// When [fullWidth] is set the visible button stays square on the trailing
/// edge, but its near-invisible hit background stretches across the entire
/// field so a click anywhere opens the pop-up list.
class _ComboBoxCaret extends StatefulWidget {
  const _ComboBoxCaret({
    required this.style,
    required this.menuOpen,
    required this.enabled,
    required this.accentColor,
    required this.onTap,
    this.fullWidth = false,
  });

  final Color? accentColor;
  final bool enabled;

  /// Whether the caret's clickable area spans the full field width rather than
  /// just the trailing square button.
  final bool fullWidth;

  final bool menuOpen;
  final VoidCallback onTap;
  final CNComboBoxStyle style;

  @override
  State<_ComboBoxCaret> createState() => _ComboBoxCaretState();
}

class _ComboBoxCaretState extends State<_ComboBoxCaret> {
  bool _hovered = false;

  Widget _buildBordered(BuildContext context, double side) {
    final accent =
        widget.accentColor ?? CNColors.blue.resolveFromContext(context);
    final isDark = CNTheme.of(context).isDark;
    // Darken slightly while the menu is open, echoing the pressed push button.
    final background = widget.menuOpen
        ? Color.lerp(accent, CNColors.black, 0.12)!
        : accent;
    // Contrast the chevron against the (accent) fill.
    final arrows = background.computeLuminance() > 0.5
        ? CNColors.black
        : CNColors.white;
    final radius = _caretRadius(side);

    return Padding(
      padding: const EdgeInsets.all(_kCaretInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: (isDark ? CNColors.white : CNColors.black).withValues(
              alpha: 0.12,
            ),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.5),
              blurRadius: 0.5,
              offset: const Offset(0, 0.5),
            ),
          ],
        ),
        // Subtle top-down highlight gradient over the fill.
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                CNColors.white.withValues(alpha: isDark ? 0.05 : 0.17),
                const Color(0x00FFFFFF),
              ],
            ),
          ),
          child: CustomPaint(
            painter: _CaretPainter(
              color: arrows,
              icon: _CaretIcon.disclosureDown,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  Widget _buildPlain(BuildContext context, double side) {
    // Keep a non-transparent fill in every state so the full button area stays
    // clickable over the underlying platform view; strengthen on hover/open.
    final background = (_hovered || widget.menuOpen)
        ? CNColors.fillTertiary.resolveFrom(context)
        : CNColors.fillQuaternary.resolveFrom(context);
    final arrows = CNColors.label.resolveFrom(context);
    final radius = _caretRadius(side);

    return Padding(
      padding: const EdgeInsets.all(_kCaretInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: CustomPaint(
          painter: _CaretPainter(color: arrows, icon: _CaretIcon.arrows),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The Positioned parent forces a tight height equal to the field's; the
        // caret is a square of that height so it fills the trailing edge.
        final side = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 20.0;
        final button = widget.style == CNComboBoxStyle.bordered
            ? _buildBordered(context, side)
            : _buildPlain(context, side);

        // The visible button is always a trailing square. In full-width mode
        // the tappable region extends across the whole field: a near-invisible
        // scrim gives Flutter pixels to hit-test (a fully transparent overlay
        // would let the click fall through to the native field beneath).
        Widget child = SizedBox.square(dimension: side, child: button);
        if (widget.fullWidth) {
          child = ColoredBox(
            color: const Color(0x01000000),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [child],
            ),
          );
        }

        return MouseRegion(
          cursor: widget.enabled ? SystemMouseCursors.click : MouseCursor.defer,
          onEnter: widget.enabled
              ? (_) => setState(() => _hovered = true)
              : null,
          onExit: widget.enabled
              ? (_) => setState(() => _hovered = false)
              : null,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.enabled ? widget.onTap : null,
            child: child,
          ),
        );
      },
    );
  }
}

/// Which chevron glyph the caret paints.
enum _CaretIcon {
  /// A single downward chevron (bordered / push-button style).
  disclosureDown,

  /// A double up-over-down chevron (plain style).
  arrows,
}

/// Paints the combo box caret chevron(s), scaled to the painter's size.
///
/// The path math mirrors the reference AppKit combo box's `IconButtonPainter`.
class _CaretPainter extends CustomPainter {
  const _CaretPainter({required this.color, required this.icon});

  final Color color;
  final _CaretIcon icon;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, size.width / 10)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final half = size.width / 2;
    final midY = size.height / 2;
    final path = Path();

    switch (icon) {
      case _CaretIcon.arrows:
        final arm = size.width / 8.88;
        final gap = size.width / 8.88;
        path
          ..moveTo(half - arm, midY - gap)
          ..lineTo(half, midY - gap - arm)
          ..lineTo(half + arm, midY - gap)
          ..moveTo(half - arm, midY + gap)
          ..lineTo(half, midY + gap + arm)
          ..lineTo(half + arm, midY + gap);
      case _CaretIcon.disclosureDown:
        final armW = size.width / 6.285;
        final armH = size.width / 11;
        path
          ..moveTo(half - armW, midY - armH)
          ..lineTo(half, midY + armH)
          ..lineTo(half + armW, midY - armH);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CaretPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.icon != icon;
}
