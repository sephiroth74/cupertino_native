// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/components/cn_text_input_formatting.dart';
import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativeTextField2';

/// A native SwiftUI TextField widget controllable via [TextEditingController].
class CNTextField extends CNWidget {
  const CNTextField({
    super.key,
    super.debugLog,
    this.controller,
    this.placeholder,
    this.prompt,
    this.textFieldStyle = CNTextFieldStyle.automatic,
    this.controlSize = CNControlSize.regular,
    this.font,
    this.borderColor,
    this.borderWidth,
    this.autofocus = false,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.shrink = true,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
    this.help,
    this.overlay,
  });

  /// Whether the field should automatically receive focus when created.
  final bool autofocus;

  /// Border color applied via `.border()` modifier.
  final Color? borderColor;

  /// Border width applied via `.border()` modifier.
  final double? borderWidth;

  /// Control size.
  final CNControlSize controlSize;

  /// The text editing controller that controls the text field.
  /// If null, an internal controller is created.
  final TextEditingController? controller;

  /// Font descriptor.
  final CNFont? font;

  /// Optional formatters applied to text reported by the native field,
  /// mirroring [EditableText.inputFormatters]. Applied on the Dart side after
  /// the native [maxLength] hard cap.
  final List<TextInputFormatter>? inputFormatters;

  /// Hard limit on the number of characters, enforced natively (by grapheme
  /// cluster). Prefer this over a [LengthLimitingTextInputFormatter] as it
  /// avoids a Dart round-trip. When null, no native limit is applied.
  final int? maxLength;

  /// Called when the text changes from user input.
  final ValueChanged<String>? onChanged;

  /// Called when the user presses Enter.
  final ValueChanged<String>? onSubmitted;

  /// The label shown in the text field (used by some styles).
  final String? placeholder;

  /// Prompt text shown when the field is empty.
  final String? prompt;

  /// Text field visual style.
  final CNTextFieldStyle textFieldStyle;

  @override
  final BoxConstraints? constraints;

  @override
  final Color? foregroundColor;

  @override
  final String? help;

  @override
  final CNOverlay? overlay;

  @override
  final EdgeInsetsGeometry? paddings;

  @override
  final bool shrink;

  @override
  final Object? tint;

  @override
  State<CNTextField> createState() => _CNTextFieldState();

  @override
  String get nativeViewType => _kNativeViewType;

  bool get enabled => onChanged != null || onSubmitted != null;
}

/// Style for CNTextField2.
enum CNTextFieldStyle {
  /// Automatic style (system default).
  automatic,

  /// Plain style with no border.
  plain,

  /// Rounded border style.
  roundedBorder,
}

class _CNTextFieldState extends CNWidgetState<CNTextField> {
  TextEditingController? _internalController;
  bool _isUpdatingFromNative = false;

  @override
  Size computeDefaultSize() => Size(_defaultWidth(), _defaultHeight());

  @override
  void didUpdateWidget(covariant CNTextField oldWidget) {
    if (oldWidget.controller != widget.controller) {
      final oldController = oldWidget.controller ?? _internalController!;
      oldController.removeListener(_onControllerChanged);

      if (widget.controller == null && _internalController == null) {
        _internalController = TextEditingController(text: oldController.text);
      } else if (widget.controller != null && _internalController != null) {
        _internalController!.dispose();
        _internalController = null;
      }

      _controller.addListener(_onControllerChanged);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _internalController?.dispose();
    _internalController = null;
    super.dispose();
  }

  @override
  Set<Factory<OneSequenceGestureRecognizer>>? get gestureRecognizers => {
    Factory<OneSequenceGestureRecognizer>(() => TapGestureRecognizer()),
  };

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController();
    }
    _controller.addListener(_onControllerChanged);
  }

  @override
  Future<void> onNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'textChanged':
        final rawText = call.arguments as String? ?? '';
        final formatted = applyCNInputFormatters(
          newText: rawText,
          oldValue: _controller.value,
          formatters: widget.inputFormatters,
        );
        logDebug(
          'textChanged: raw="$rawText" formatted="${formatted.text}" (len=${formatted.text.length})',
        );
        _isUpdatingFromNative = true;
        if (formatted.text == rawText) {
          _controller.text = rawText;
        } else {
          _controller.value = formatted;
        }
        _isUpdatingFromNative = false;
        widget.onChanged?.call(_controller.text);
      case 'selectionChanged':
        final args = call.arguments as Map?;
        final base = (args?['base'] as num?)?.toInt();
        final extent = (args?['extent'] as num?)?.toInt();
        logDebug(
          'selectionChanged: base=$base, extent=$extent, textLen=${_controller.text.length}',
        );
        if (base != null && extent != null) {
          _isUpdatingFromNative = true;
          final textLength = _controller.text.length;
          _controller.selection = TextSelection(
            baseOffset: base.clamp(0, textLength),
            extentOffset: extent.clamp(0, textLength),
          );
          _isUpdatingFromNative = false;
        }
      case 'submitted':
        final text = call.arguments as String? ?? _controller.text;
        widget.onSubmitted?.call(text);
    }
  }

  @override
  Map<String, dynamic> toWidgetPayload(
    BuildContext context, {
    required BoxConstraints? constraints,
  }) {
    final selection = _controller.selection;
    final payload = <String, dynamic>{
      'text': _controller.text,
      'selectionBase': selection.isValid ? selection.baseOffset : null,
      'selectionExtent': selection.isValid ? selection.extentOffset : null,
      'placeholder': widget.placeholder,
      'prompt': widget.prompt,
      'textFieldStyle': widget.textFieldStyle.name,
      'controlSize': widget.controlSize.name,
      'font': widget.font?.toMap(),
      'borderColor': resolveColorToArgb(widget.borderColor, context),
      'borderWidth': widget.borderWidth,
      'autofocus': widget.autofocus,
      'maxLength': widget.maxLength,
      'enabled': widget.enabled,
    };

    widget.writeSharedFields(
      context,
      payload: payload,
      constraints: constraints,
      tintFallback: CNTextFieldTheme.of(context).tintColor,
    );
    return payload;
  }

  TextEditingController get _controller =>
      widget.controller ?? _internalController!;

  double _defaultHeight() {
    double resolvedHeight = 26.0; // default height for regular control size

    if (widget.font != null) {
      if (widget.font!.size.points != null) {
        resolvedHeight = widget.font!.size.points! + 14;
      } else if (widget.font!.size.preset != null) {
        switch (widget.font!.size.preset!) {
          case CNFontSizePreset.system:
            resolvedHeight = 26;
            break;
          case CNFontSizePreset.smallSystem:
            resolvedHeight = 24;
            break;
          case CNFontSizePreset.label:
            resolvedHeight = 23;
            break;
        }
      }
    } else {
      switch (widget.controlSize) {
        case CNControlSize.mini:
          resolvedHeight = 21.0;
          break;
        case CNControlSize.small:
          resolvedHeight = 24.0;
          break;
        case CNControlSize.regular:
          resolvedHeight = 26.0;
          break;
        case CNControlSize.large:
          resolvedHeight = 26.0;
          break;
        case CNControlSize.extraLarge:
          resolvedHeight = 26.0;
          break;
      }
    }

    if (widget.textFieldStyle == CNTextFieldStyle.plain) {
      resolvedHeight -= 8.0;
    }

    if (widget.borderWidth != null) {
      resolvedHeight += widget.borderWidth!;
    }

    return resolvedHeight;
  }

  double _defaultWidth() => 200.0;

  void _onControllerChanged() {
    if (_isUpdatingFromNative) return;
    logDebug(
      '_onControllerChanged: text="${_controller.text}" (len=${_controller.text.length}), selection=${_controller.selection}',
    );
    // Programmatic change from Dart — trigger rebuild so the patch system
    // sends the updated text to native via applyPatch.
    setState(() {});
  }
}
