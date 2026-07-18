// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativeButton2';

/// Semantic role for button actions.
enum CNButtonRole2 {
  /// Default role.
  none,

  /// Cancel role.
  cancel,

  /// Destructive role.
  destructive,
}

/// A native SwiftUI Button widget.
///
/// The button's label is built from [children], which can be any combination of
/// [CNChild] elements (text, image, label, stacks, etc.).
class CNButton2 extends CNWidget {
  const CNButton2({
    super.key,
    super.debugLog,
    required this.children,
    this.onPressed,
    this.buttonStyle = CNButtonStyle.automatic,
    this.role = CNButtonRole2.none,
    this.controlSize,
    this.labelStyle,
    this.shrink = true,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
  });

  /// Visual style for the button.
  final CNButtonStyle buttonStyle;

  /// Content views inside the button's label closure.
  final List<CNChild> children;

  /// Control size.
  final CNControlSize? controlSize;

  /// Label style applied inside the button.
  final CNLabel2Style? labelStyle;

  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// Semantic role for the button action.
  final CNButtonRole2 role;

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
  State<CNButton2> createState() => _CNButton2State();

  @override
  String get nativeViewType => _kNativeViewType;
}

class _CNButton2State extends CNWidgetState<CNButton2> {
  @override
  Size computeDefaultSize() => const Size(80.0, 32.0);

  @override
  Future<dynamic> onNativeMethodCall(MethodCall call) async {
    if (call.method == 'pressed') {
      widget.onPressed?.call();
    }
    return null;
  }

  @override
  Map<String, dynamic> toWidgetPayload(BuildContext context, {required BoxConstraints? constraints}) {
    final payload = <String, dynamic>{
      'children': widget.children.map((c) => c.toChildPayload(context)).toList(),
      'buttonStyle': widget.buttonStyle.name,
      'role': widget.role.name,
      'controlSize': widget.controlSize?.name,
      'labelStyle': widget.labelStyle?.name,
      'enabled': enabled,
    };

    widget.writeSharedFields(context, payload: payload, constraints: constraints);
    return payload;
  }

  bool get enabled => widget.onPressed != null;
}
