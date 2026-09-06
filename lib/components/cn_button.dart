// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativeButton2';

/// A native SwiftUI Button widget.
///
/// The button's label is built from [children], which can be any combination of
/// [CNChild] elements (text, image, label, stacks, etc.).
class CNButton extends CNWidget {
  const CNButton({
    super.key,
    super.debugLog,
    required this.children,
    this.onPressed,
    this.buttonStyle = CNButtonStyle.automatic,
    this.role = CNButtonRole.none,
    this.controlSize,
    this.labelStyle,
    this.shrink = true,
    this.fixedSize = false,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
    this.help,
    this.overlay,
    this.background,
  });

  /// Visual style for the button.
  final CNButtonStyle buttonStyle;

  /// Content views inside the button's label closure.
  final List<CNChild> children;

  /// Control size.
  final CNControlSize? controlSize;

  /// When true, the native control adopts its natural (ideal) size and ignores
  /// the size proposed by its container (SwiftUI `.fixedSize()`).
  ///
  /// Use this to place the control in a fixed band (e.g. a toolbar) without it
  /// stretching to fill the band; the parent can then center the naturally-sized
  /// control. Leave false for normal in-flow sizing.
  final bool fixedSize;

  /// Label style applied inside the button.
  final CNLabelStyle? labelStyle;

  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// Semantic role for the button action.
  final CNButtonRole role;

  @override
  final CNBackground? background;

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
  State<CNButton> createState() => _CNButton2State();

  @override
  String get nativeViewType => _kNativeViewType;
}

/// Semantic role for button actions.
enum CNButtonRole {
  /// Default role.
  none,

  /// Cancel role.
  cancel,

  /// Destructive role.
  destructive,
}

class _CNButton2State extends CNWidgetState<CNButton> {
  @override
  Size computeDefaultSize() => const Size(80.0, 32.0);

  // Il pulsante è interattivo: senza questi recognizer i tap non raggiungono la
  // view AppKit quando il widget è dentro uno scrollable (la drag dello scroll
  // vince l'arena dei gesti).
  @override
  Set<Factory<OneSequenceGestureRecognizer>>? get gestureRecognizers => {
    Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
  };

  @override
  Future<dynamic> onNativeMethodCall(MethodCall call) async {
    if (call.method == 'pressed') {
      widget.onPressed?.call();
    }
    return null;
  }

  @override
  Map<String, dynamic> toWidgetPayload(
    BuildContext context, {
    required BoxConstraints? constraints,
  }) {
    final payload = <String, dynamic>{
      'children': widget.children
          .map((c) => c.toChildPayload(context))
          .toList(),
      'buttonStyle': widget.buttonStyle.name,
      'role': widget.role.name,
      'controlSize': widget.controlSize?.name,
      'labelStyle': widget.labelStyle?.name,
      'enabled': enabled,
      'fixedSize': widget.fixedSize,
    };

    widget.writeSharedFields(
      context,
      payload: payload,
      constraints: constraints,
      tintFallback: CNButtonTheme.of(context).tintColor,
    );
    return payload;
  }

  bool get enabled => widget.onPressed != null;
}
