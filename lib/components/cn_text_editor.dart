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

const _kNativeViewType = 'CupertinoNativeTextEditor';

/// A native SwiftUI [TextEditor](https://developer.apple.com/documentation/swiftui/texteditor)
/// widget controllable via a [TextEditingController].
///
/// Unlike [CNTextField], the text editor is a multi-line control that always
/// fills the constraints it is given — it does not support `shrink`. Place it
/// inside a bounded parent (e.g. an [Expanded], [SizedBox], or a widget with
/// explicit [constraints]) so it has finite dimensions to expand into.
class CNTextEditor extends CNWidget {
  const CNTextEditor({
    super.key,
    super.debugLog,
    this.controller,
    this.font,
    this.borderColor,
    this.borderWidth,
    this.autofocus = false,
    this.enabled = true,
    this.selectable = true,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onFocusChange,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
    this.help,
    this.overlay,
    this.background,
  });

  /// Whether the editor should automatically receive focus when created.
  final bool autofocus;

  /// Border color applied via the `.border()` modifier.
  final Color? borderColor;

  /// Border width applied via the `.border()` modifier.
  final double? borderWidth;

  /// The text editing controller that controls the editor's contents.
  /// If null, an internal controller is created.
  final TextEditingController? controller;

  /// Whether the editor allows editing. When false, the editor is read-only.
  ///
  /// The content remains selectable (and copyable) while read-only unless
  /// [selectable] is also set to false, which disables the control entirely.
  final bool enabled;

  /// Whether the editor's content can be selected while read-only.
  ///
  /// Only has an effect when [enabled] is false. When true (the default), a
  /// read-only editor still lets the user select and copy its text. When
  /// false, the control is disabled and its content cannot be selected.
  final bool selectable;

  /// Font descriptor applied to the editor's text.
  final CNFont? font;

  /// Optional formatters applied to text reported by the native editor,
  /// mirroring [EditableText.inputFormatters]. Applied on the Dart side after
  /// the native [maxLength] hard cap.
  final List<TextInputFormatter>? inputFormatters;

  /// Hard limit on the number of characters, enforced natively (by grapheme
  /// cluster). Prefer this over a [LengthLimitingTextInputFormatter] as it
  /// avoids a Dart round-trip. When null, no native limit is applied.
  final int? maxLength;

  /// Called when the editor gains (`true`) or loses (`false`) focus.
  final ValueChanged<bool>? onFocusChange;

  /// Called when the text changes from user input.
  final ValueChanged<String>? onChanged;

  @override
  final BoxConstraints? constraints;

  @override
  final Color? foregroundColor;

  @override
  final String? help;

  @override
  final CNOverlay? overlay;

  @override
  final CNBackground? background;

  @override
  final EdgeInsetsGeometry? paddings;

  @override
  final Object? tint;

  @override
  State<CNTextEditor> createState() => _CNTextEditorState();

  @override
  String get nativeViewType => _kNativeViewType;

  /// The text editor never shrinks — it always fills its constraints.
  @override
  bool get shrink => false;
}

class _CNTextEditorState extends CNWidgetState<CNTextEditor> {
  TextEditingController? _internalController;
  bool _isUpdatingFromNative = false;

  @override
  Size computeDefaultSize() => const Size(200, 100);

  @override
  void didUpdateWidget(covariant CNTextEditor oldWidget) {
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
    Factory<OneSequenceGestureRecognizer>(() => PanGestureRecognizer()),
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
        // When the formatter did not alter the text, preserve the native
        // selection (a separate selectionChanged follows); only override the
        // caret when the text actually changed.
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
      case 'focusChanged':
        final focused = call.arguments as bool? ?? false;
        logDebug('focusChanged: $focused');
        widget.onFocusChange?.call(focused);
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
      'font': widget.font?.toMap(),
      'borderColor': resolveColorToArgb(widget.borderColor, context),
      'borderWidth': widget.borderWidth,
      'autofocus': widget.autofocus,
      'enabled': widget.enabled,
      'selectable': widget.selectable,
      'maxLength': widget.maxLength,
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
