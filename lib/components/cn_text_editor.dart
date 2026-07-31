// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/channel/params.dart';
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
    this.editable = true,
    this.onChanged,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
    this.help,
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

  /// Whether the editor allows editing. When false, the content is
  /// selectable but read-only.
  final bool editable;

  /// Font descriptor applied to the editor's text.
  final CNFont? font;

  /// Called when the text changes from user input.
  final ValueChanged<String>? onChanged;

  @override
  final BoxConstraints? constraints;

  @override
  final Color? foregroundColor;

  @override
  final String? help;

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
        final text = call.arguments as String? ?? '';
        logDebug('textChanged: "$text" (len=${text.length})');
        _isUpdatingFromNative = true;
        _controller.text = text;
        _isUpdatingFromNative = false;
        widget.onChanged?.call(text);
      case 'selectionChanged':
        final args = call.arguments as Map?;
        final base = (args?['base'] as num?)?.toInt();
        final extent = (args?['extent'] as num?)?.toInt();
        logDebug('selectionChanged: base=$base, extent=$extent, textLen=${_controller.text.length}');
        if (base != null && extent != null) {
          _isUpdatingFromNative = true;
          final textLength = _controller.text.length;
          _controller.selection = TextSelection(baseOffset: base.clamp(0, textLength), extentOffset: extent.clamp(0, textLength));
          _isUpdatingFromNative = false;
        }
    }
  }

  @override
  Map<String, dynamic> toWidgetPayload(BuildContext context, {required BoxConstraints? constraints}) {
    final selection = _controller.selection;
    final payload = <String, dynamic>{
      'text': _controller.text,
      'selectionBase': selection.isValid ? selection.baseOffset : null,
      'selectionExtent': selection.isValid ? selection.extentOffset : null,
      'font': widget.font?.toMap(),
      'borderColor': resolveColorToArgb(widget.borderColor, context),
      'borderWidth': widget.borderWidth,
      'autofocus': widget.autofocus,
      'editable': widget.editable,
    };

    widget.writeSharedFields(
      context,
      payload: payload,
      constraints: constraints,
      tintFallback: CNTextFieldTheme.of(context).tintColor,
    );
    return payload;
  }

  TextEditingController get _controller => widget.controller ?? _internalController!;

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
