// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativeSecureField';

/// A native SwiftUI SecureField widget controllable via [TextEditingController].
///
/// Unlike [CNTextField2], SecureField does not expose text selection.
class CNSecureField extends CNWidget {
  const CNSecureField({
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
    this.onChanged,
    this.onSubmitted,
    this.shrink = true,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
  });

  /// Border color applied via `.border()` modifier.
  final Color? borderColor;

  /// Border width applied via `.border()` modifier.
  final double? borderWidth;

  /// Control size.
  final CNControlSize controlSize;

  /// The text editing controller.
  /// If null, an internal controller is created.
  final TextEditingController? controller;

  /// Font descriptor.
  final CNFont? font;

  /// Called when the text changes from user input.
  final ValueChanged<String>? onChanged;

  /// Called when the user presses Enter.
  final ValueChanged<String>? onSubmitted;

  /// The label shown in the secure field.
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
  final EdgeInsetsGeometry? paddings;

  @override
  final bool shrink;

  @override
  final Color? tint;

  @override
  State<CNSecureField> createState() => _CNSecureFieldState();

  @override
  String get nativeViewType => _kNativeViewType;
}

class _CNSecureFieldState extends CNWidgetState<CNSecureField> {
  TextEditingController? _internalController;
  bool _isUpdatingFromNative = false;

  @override
  Size computeDefaultSize() => Size(_defaultWidth(), _defaultHeight());

  @override
  void didUpdateWidget(covariant CNSecureField oldWidget) {
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
        final text = call.arguments as String? ?? '';
        _isUpdatingFromNative = true;
        _controller.text = text;
        _isUpdatingFromNative = false;
        widget.onChanged?.call(text);
      case 'submitted':
        final text = call.arguments as String? ?? _controller.text;
        widget.onSubmitted?.call(text);
    }
  }

  @override
  Map<String, dynamic> toWidgetPayload(BuildContext context, {required BoxConstraints? constraints}) {
    final payload = <String, dynamic>{
      'text': _controller.text,
      'placeholder': widget.placeholder,
      'prompt': widget.prompt,
      'textFieldStyle': widget.textFieldStyle.name,
      'controlSize': widget.controlSize.name,
      'font': widget.font?.toMap(),
      'borderColor': resolveColorToArgb(widget.borderColor, context),
      'borderWidth': widget.borderWidth,
    };

    widget.writeSharedFields(context, payload: payload, constraints: constraints);
    return payload;
  }

  TextEditingController get _controller => widget.controller ?? _internalController!;

  void _onControllerChanged() {
    if (_isUpdatingFromNative) return;
    setState(() {});
  }

  double _defaultWidth() => 200.0;

  double _defaultHeight() {
    double resolvedHeight = 26.0;

    if (widget.font != null) {
      if (widget.font!.size.points != null) {
        resolvedHeight = widget.font!.size.points! + 14;
      } else if (widget.font!.size.preset != null) {
        switch (widget.font!.size.preset!) {
          case CNFontSizePreset.system:
            resolvedHeight = 26;
          case CNFontSizePreset.smallSystem:
            resolvedHeight = 24;
          case CNFontSizePreset.label:
            resolvedHeight = 23;
        }
      }
    } else {
      switch (widget.controlSize) {
        case CNControlSize.mini:
          resolvedHeight = 21.0;
        case CNControlSize.small:
          resolvedHeight = 24.0;
        case CNControlSize.regular:
          resolvedHeight = 26.0;
        case CNControlSize.large:
          resolvedHeight = 26.0;
        case CNControlSize.extraLarge:
          resolvedHeight = 26.0;
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
}
