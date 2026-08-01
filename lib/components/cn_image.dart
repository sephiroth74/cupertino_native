// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativeImage2';

class CNImage extends CNWidget {
  const CNImage({
    super.key,
    super.debugLog,
    required this.systemSymbolName,
    this.shrink = false,
    this.constraints,
    this.font,
    this.foregroundColor,
    this.tint,
    this.symbolRenderingMode,
    this.symbolColorRenderingMode,
    this.foregroundStyleColors,
    this.paddings,
    this.help,
    this.overlay,
  });

  /// Optional font to apply to the image.
  final CNFont? font;

  /// Optional list of colors for the image's foreground style.
  final List<Color>? foregroundStyleColors;

  /// Optional SwiftUI symbol color rendering mode.
  final CNSymbolColorRenderingMode? symbolColorRenderingMode;

  /// Optional SwiftUI symbol rendering mode.
  final CNSymbolRenderingMode? symbolRenderingMode;

  /// The SF Symbols name to display.
  final String systemSymbolName;

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
  State<CNImage> createState() => _CNImageState();

  @override
  String get nativeViewType => _kNativeViewType;
}

class _CNImageState extends CNWidgetState<CNImage> {
  @override
  Size computeDefaultSize() {
    final double fontSize;
    if (widget.font != null) {
      if (widget.font!.size.points != null) {
        fontSize = widget.font!.size.points! + 4;
      } else if (widget.font!.size.preset != null) {
        switch (widget.font!.size.preset!) {
          case CNFontSizePreset.system:
            fontSize = 18;
            break;
          case CNFontSizePreset.smallSystem:
            fontSize = 15;
            break;
          case CNFontSizePreset.label:
            fontSize = 14;
            break;
        }
      } else {
        fontSize = 36;
      }
    } else {
      fontSize = 36;
    }

    final double defaultWidth = fontSize + (widget.paddings?.horizontal ?? 0);
    final double defaultHeight = fontSize + (widget.paddings?.vertical ?? 0);

    return Size(defaultWidth, defaultHeight);
  }

  @override
  Map<String, dynamic> toWidgetPayload(BuildContext context, {required BoxConstraints? constraints}) {
    final payload = <String, dynamic>{
      'systemSymbolName': widget.systemSymbolName,
      'font': widget.font?.toMap(),
      'symbolRenderingMode': widget.symbolRenderingMode?.name,
      'symbolColorRenderingMode': widget.symbolColorRenderingMode?.name,
      'foregroundStyleColors': widget.foregroundStyleColors?.map((c) => resolveColorToArgb(c, context)).toList(),
    };

    widget.writeSharedFields(context, payload: payload, constraints: constraints);
    return payload;
  }
}
