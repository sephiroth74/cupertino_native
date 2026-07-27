// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativeColorWell2';
const double _kDefaultWidth = 44.0;
const double _kDefaultHeight = 24.0;

class CNColorWell2 extends CNWidget {
  const CNColorWell2({
    super.key,
    super.debugLog,
    this.color,
    this.onColorChanged,
    this.style = CNColorWellStyle.regular,
    this.supportsAlpha = true,
    this.shrink = true,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
    this.help,
  });

  /// The current color.
  final Color? color;

  /// Called when the user picks a new color.
  final ValueChanged<Color>? onColorChanged;

  /// The style of the color well.
  final CNColorWellStyle style;

  /// Whether the color picker shows an alpha slider.
  final bool supportsAlpha;

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
  State<CNColorWell2> createState() => _CNColorWell2State();

  @override
  String get nativeViewType => _kNativeViewType;
}

class _CNColorWell2State extends CNWidgetState<CNColorWell2> {
  @override
  Size computeDefaultSize() => const Size(_kDefaultWidth, _kDefaultHeight);

  @override
  Set<Factory<OneSequenceGestureRecognizer>> get gestureRecognizers => {
    Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
  };

  @override
  Future<void> onNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'colorChanged':
        final colorValue = call.arguments as int?;
        if (colorValue != null) {
          widget.onColorChanged?.call(Color(colorValue));
        }
    }
  }

  @override
  Map<String, dynamic> toWidgetPayload(BuildContext context, {required BoxConstraints? constraints}) {
    final payload = <String, dynamic>{
      'color': resolveColorToArgb(widget.color, context),
      'style': widget.style.name,
      'enabled': widget.onColorChanged != null,
      'supportsAlpha': widget.supportsAlpha,
    };

    widget.writeSharedFields(context, payload: payload, constraints: constraints);
    return payload;
  }
}
