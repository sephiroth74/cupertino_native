// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativeSearchField2';

/// Callback invoked when the native search field needs suggestions.
typedef CNSearchSuggestionsCallback = FutureOr<List<String>> Function(
  String query,
);

/// A native macOS search field backed by NSSearchField.
///
/// Suggestions are provided via [onSuggestionsRequested]. When the user types,
/// native code calls this callback and displays the returned strings as
/// completion suggestions. If null, no suggestions are shown.
class CNSearchField2 extends CNWidget {
  const CNSearchField2({
    super.key,
    super.debugLog,
    required this.text,
    this.placeholder,
    this.textColor,
    this.placeholderColor,
    this.font,
    this.controlSize = CNControlSize.regular,
    this.bezelStyle = CNTextFieldBezelStyle.round,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.onSuggestionsRequested,
    this.shrink = true,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
    this.help,
  });

  /// Whether the field should automatically receive focus when created.
  final bool autofocus;

  /// The border/bezel style of the search field.
  final CNTextFieldBezelStyle bezelStyle;

  /// The size of the native AppKit control.
  final CNControlSize controlSize;

  /// Optional native NSFont descriptor.
  final CNFont? font;

  /// Called whenever the user changes the search text.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the search text (presses Enter or selects a suggestion).
  final ValueChanged<String>? onSubmitted;

  /// Callback used to provide suggestions while the user types.
  /// Return an empty list to show no suggestions.
  /// If null, suggestions are disabled entirely.
  final CNSearchSuggestionsCallback? onSuggestionsRequested;

  /// Placeholder string shown when the field is empty.
  final String? placeholder;

  /// The placeholder color of the search field.
  final Color? placeholderColor;

  /// The current text shown in the field.
  final String? text;

  /// The text color of the search field.
  final Color? textColor;

  @override
  final BoxConstraints? constraints;

  @override
  final Color? foregroundColor;

  @override
  final String? help;

  @override
  final EdgeInsetsGeometry? paddings;

  @override
  final bool shrink;

  @override
  final Object? tint;

  @override
  State<CNSearchField2> createState() => _CNSearchField2State();

  @override
  String get nativeViewType => _kNativeViewType;

  /// Whether the native control accepts user interaction.
  bool get enabled => onChanged != null || onSubmitted != null;
}

class _CNSearchField2State extends CNWidgetState<CNSearchField2> {
  @override
  Size computeDefaultSize() => const Size(double.infinity, 24.0);

  @override
  Set<Factory<OneSequenceGestureRecognizer>>? get gestureRecognizers => {
    Factory<OneSequenceGestureRecognizer>(() => TapGestureRecognizer()),
  };

  @override
  Future<dynamic> onNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'textChanged':
        final text = call.arguments as String? ?? '';
        logDebug('textChanged: "$text"');
        widget.onChanged?.call(text);
      case 'submitted':
        final text = call.arguments as String? ?? '';
        logDebug('submitted: "$text"');
        widget.onSubmitted?.call(text);
      case 'requestSuggestions':
        final args = call.arguments as Map?;
        final query = (args?['query'] as String?) ?? '';
        logDebug('requestSuggestions: query="$query"');
        if (widget.onSuggestionsRequested != null) {
          final results = await widget.onSuggestionsRequested!(query);
          logDebug('requestSuggestions: returning ${results.length} suggestions');
          return results;
        }
        return <String>[];
    }
    return null;
  }

  @override
  Map<String, dynamic> toWidgetPayload(
    BuildContext context, {
    required BoxConstraints? constraints,
  }) {
    final payload = <String, dynamic>{
      'text': widget.text,
      'placeholder': widget.placeholder,
      'textColor': resolveColorToArgb(widget.textColor, context),
      'placeholderColor': resolveColorToArgb(widget.placeholderColor, context),
      'font': widget.font?.toMap(),
      'controlSize': widget.controlSize.name,
      'bezelStyle': widget.bezelStyle.name,
      'autofocus': widget.autofocus,
      'enabled': widget.enabled,
      'hasSuggestions': widget.onSuggestionsRequested != null,
    };

    widget.writeSharedFields(context, payload: payload, constraints: constraints);
    return payload;
  }
}
