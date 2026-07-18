// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativePicker2';

/// Visual style for [CNPicker2].
enum CNPickerStyle2 {
  /// Automatic picker style.
  automatic,

  /// Inline picker (shows all items).
  inline,

  /// Menu picker (dropdown).
  menu,

  /// Segmented picker.
  segmented,

  /// Radio group picker.
  radioGroup,

  /// Palette picker.
  palette,
}

/// Allowed child types for picker items.
typedef CNPickerChild = CNChild;

/// A native SwiftUI Picker widget.
///
/// Each item in [children] must be a [CNChildText], [CNChildImage], or
/// [CNChildLabel]. The item's [CNChild.tag] determines the selection value.
class CNPicker2 extends CNWidget {
  CNPicker2({
    super.key,
    super.debugLog,
    required this.children,
    required this.selection,
    this.label,
    this.onChanged,
    this.pickerStyle = CNPickerStyle2.automatic,
    this.controlSize,
    this.font,
    this.shrink = true,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
  }) : assert(
         children.every((c) => c is CNChildText || c is CNChildImage || c is CNChildLabel || c is CNChildDivider),
         'CNPicker2 children must be CNChildText, CNChildImage, CNChildLabel, or CNChildDivider',
       );

  /// Picker items. Each must have a non-null [CNChild.tag].
  final List<CNPickerChild> children;

  /// Control size.
  final CNControlSize? controlSize;

  /// Font applied to the picker.
  final CNFont? font;

  /// Optional label content (shown alongside the picker).
  final List<CNChild>? label;

  /// Called when the selection changes, with the new tag value.
  final ValueChanged<String>? onChanged;

  /// Visual style for the picker.
  final CNPickerStyle2 pickerStyle;

  /// The currently selected tag value.
  final String selection;

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
  State<CNPicker2> createState() => _CNPicker2State();

  @override
  String get nativeViewType => _kNativeViewType;

  bool get enabled => onChanged != null;
}

class _CNPicker2State extends CNWidgetState<CNPicker2> {
  @override
  Size computeDefaultSize() {
    switch (widget.pickerStyle) {
      case CNPickerStyle2.automatic:
      case CNPickerStyle2.menu:
        switch (widget.controlSize) {
          case CNControlSize.mini:
            return const Size(100, 16);
          case CNControlSize.small:
            return const Size(100, 20);
          case CNControlSize.regular:
            return const Size(100, 24);
          case CNControlSize.large:
            return const Size(100, 28);
          default:
            return const Size(100, 36);
        }
      case CNPickerStyle2.segmented:
      case CNPickerStyle2.palette:
        switch (widget.controlSize) {
          case CNControlSize.mini:
            return const Size(double.infinity, 16);
          case CNControlSize.small:
            return const Size(double.infinity, 20);
          case CNControlSize.regular:
            return const Size(double.infinity, 24);
          case CNControlSize.large:
            return const Size(double.infinity, 28);
          default:
            return const Size(double.infinity, 36);
        }

      default:
        return const Size(100, 24);
    }
  }

  @override
  double computeShrinkHeight({
    required BoxConstraints constraints,
    required BoxConstraints parentConstraints,
    required double defaultHeight,
    double? intrinsicHeight,
  }) {
    double resolvedHeight;
    if (intrinsicHeight != null) {
      resolvedHeight = intrinsicHeight;
      logDebug('shrink mode: using intrinsicHeight');
    } else if (constraints.tightHeight != null) {
      resolvedHeight = constraints.tightHeight!;
      logDebug('shrink mode: using tightHeight from constraints');
    } else {
      resolvedHeight = defaultHeight;
      logDebug('shrink mode: using defaultSize.height: $defaultHeight');
    }
    resolvedHeight = parentConstraints.constrainHeight(resolvedHeight);
    return resolvedHeight;
  }

  @override
  Future<dynamic> onNativeMethodCall(MethodCall call) async {
    if (call.method == 'valueChanged') {
      final tag = call.arguments as String?;
      if (tag != null) {
        widget.onChanged?.call(tag);
      }
    }
    return null;
  }

  @override
  Map<String, dynamic> toWidgetPayload(BuildContext context, {required BoxConstraints? constraints}) {
    final payload = <String, dynamic>{
      'children': widget.children.map((c) => c.toChildPayload(context)).toList(),
      'selection': widget.selection,
      'label': widget.label?.map((c) => c.toChildPayload(context)).toList(),
      'pickerStyle': widget.pickerStyle.name,
      'controlSize': widget.controlSize?.name,
      'font': widget.font?.toMap(),
      'enabled': widget.enabled,
    };

    widget.writeSharedFields(context, payload: payload, constraints: constraints);
    return payload;
  }
}
