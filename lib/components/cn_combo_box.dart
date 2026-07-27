// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativeComboBox';

/// A native macOS combo box backed by NSComboBox.
///
/// Combines a text field with a pop-up list of items the user can choose from.
/// The user can either select from the list or type a custom value.
class CNComboBox extends CNWidget {
  const CNComboBox({
    super.key,
    super.debugLog,
    this.text = '',
    this.items = const [],
    this.placeholder,
    this.textColor,
    this.font,
    this.controlSize = CNControlSize.regular,
    this.numberOfVisibleItems = 5,
    this.completes = false,
    this.enabled = true,
    this.onChanged,
    this.onSelectionChanged,
    this.shrink = true,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
    this.help,
  });

  /// Whether the combo box auto-completes as the user types.
  final bool completes;

  /// The size of the native AppKit control.
  final CNControlSize controlSize;

  /// Whether the control is enabled.
  final bool enabled;

  /// Optional native NSFont descriptor.
  final CNFont? font;

  /// The items in the combo box pop-up list.
  final List<String> items;

  /// Number of visible items in the pop-up list (default: 5).
  final int numberOfVisibleItems;

  /// Called whenever the text changes (user typing or selecting).
  final ValueChanged<String>? onChanged;

  /// Called when the user selects an item from the pop-up list.
  /// The argument is the index of the selected item.
  final ValueChanged<int>? onSelectionChanged;

  /// Placeholder string shown when the field is empty.
  final String? placeholder;

  /// The current text value.
  final String text;

  /// The text color of the combo box.
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
  State<CNComboBox> createState() => _CNComboBoxState();

  @override
  String get nativeViewType => _kNativeViewType;
}

class _CNComboBoxState extends CNWidgetState<CNComboBox> {
  @override
  Size computeDefaultSize() => const Size(200, 26);

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
      case 'selectionChanged':
        final index = call.arguments as int? ?? -1;
        logDebug('selectionChanged: $index');
        widget.onSelectionChanged?.call(index);
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
      'items': widget.items,
      'placeholder': widget.placeholder,
      'textColor': resolveColorToArgb(widget.textColor, context),
      'font': widget.font?.toMap(),
      'controlSize': widget.controlSize.name,
      'numberOfVisibleItems': widget.numberOfVisibleItems,
      'completes': widget.completes,
      'enabled': widget.enabled,
    };

    widget.writeSharedFields(context, payload: payload, constraints: constraints);
    return payload;
  }
}
