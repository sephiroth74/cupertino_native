// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativeToggle2';

/// A native SwiftUI Toggle widget.
///
/// The toggle content is specified via a [CNChild] (which can be a
/// VStack, HStack, Group, Text, Image, etc).
class CNToggle extends CNWidget {
  const CNToggle({
    super.key,
    super.debugLog,
    required this.isOn,
    this.content,
    this.onChanged,
    this.toggleStyle = CNToggleStyle.automatic,
    this.controlSize = CNControlSize.regular,
    this.shrink = true,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
    this.help,
  });

  /// The content of the toggle (label area). If null, an empty label is used.
  final CNChild? content;

  /// Control size.
  final CNControlSize controlSize;

  /// Whether the toggle is on.
  final bool isOn;

  /// Called when the toggle value changes.
  /// If null, the toggle is disabled.
  final ValueChanged<bool>? onChanged;

  /// Toggle style.
  final CNToggleStyle toggleStyle;

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
  State<CNToggle> createState() => _CNToggleState();

  @override
  String get nativeViewType => _kNativeViewType;
}

/// Toggle style.
enum CNToggleStyle {
  /// Automatic (system default).
  automatic,

  /// Switch style.
  switchStyle,

  /// Checkbox style.
  checkbox,

  /// Button style.
  button,
}

class _CNToggleState extends CNWidgetState<CNToggle> {
  @override
  Size computeDefaultSize() => Size(_defaultWidth(), _defaultHeight());

  @override
  double computeShrinkHeight({required BoxConstraints constraints, required double defaultHeight, double? intrinsicHeight}) {
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
    // resolvedHeight = parentConstraints.constrainHeight(resolvedHeight);
    return resolvedHeight;
  }

  @override
  Future<void> onNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'valueChanged':
        final args = call.arguments as Map?;
        final value = args?['value'] as bool?;
        if (value != null) {
          widget.onChanged?.call(value);
        }
    }
  }

  @override
  Map<String, dynamic> toWidgetPayload(BuildContext context, {required BoxConstraints? constraints}) {
    final payload = <String, dynamic>{
      'isOn': widget.isOn,
      'enabled': widget.onChanged != null,
      'toggleStyle': widget.toggleStyle.name,
      'controlSize': widget.controlSize.name,
      'content': widget.content?.toChildPayload(context),
    };

    widget.writeSharedFields(context, payload: payload, constraints: constraints);
    return payload;
  }

  double _defaultHeight() {
    switch (widget.toggleStyle) {
      case CNToggleStyle.automatic:
      case CNToggleStyle.switchStyle:
        switch (widget.controlSize) {
          case CNControlSize.mini:
            return 16.0;
          case CNControlSize.small:
            return 20.0;
          case CNControlSize.regular:
            return 24.0;
          case CNControlSize.large:
            return 28.0;
          case CNControlSize.extraLarge:
            return 36.0;
        }
      case CNToggleStyle.checkbox:
        switch (widget.controlSize) {
          case CNControlSize.mini:
            return 12.0;
          case CNControlSize.small:
            return 14.0;
          case CNControlSize.regular:
            return 16.0;
          case CNControlSize.large:
            return 18.0;
          case CNControlSize.extraLarge:
            return 18.0;
        }
      case CNToggleStyle.button:
        switch (widget.controlSize) {
          case CNControlSize.mini:
            return 2.0;
          case CNControlSize.small:
            return 6.0;
          case CNControlSize.regular:
            return 8.0;
          case CNControlSize.large:
            return 12.0;
          case CNControlSize.extraLarge:
            return 20.0;
        }
    }
  }

  double _defaultWidth() {
    switch (widget.toggleStyle) {
      case CNToggleStyle.automatic:
      case CNToggleStyle.switchStyle:
        switch (widget.controlSize) {
          case CNControlSize.mini:
            return 36.0;
          case CNControlSize.small:
            return 44.0;
          case CNControlSize.regular:
            return 54.0;
          case CNControlSize.large:
            return 64.0;
          case CNControlSize.extraLarge:
            return 80.0;
        }
      case CNToggleStyle.checkbox:
        switch (widget.controlSize) {
          case CNControlSize.mini:
            return 12.0;
          case CNControlSize.small:
            return 14.0;
          case CNControlSize.regular:
            return 16.0;
          case CNControlSize.large:
            return 18.0;
          case CNControlSize.extraLarge:
            return 18.0;
        }
      case CNToggleStyle.button:
        switch (widget.controlSize) {
          case CNControlSize.mini:
            return 16.0;
          case CNControlSize.small:
            return 20.0;
          case CNControlSize.regular:
            return 24.0;
          case CNControlSize.large:
            return 28.0;
          case CNControlSize.extraLarge:
            return 36.0;
        }
    }
  }
}
