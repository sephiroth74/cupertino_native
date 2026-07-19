// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativeText2';
const double _kDefaultTextWidth = 20.0;
const double _kDefaultTextHeight = 24.0;

class CNText2 extends CNWidget {
  const CNText2(
    this.text, {
    super.key,
    super.debugLog,
    this.shrink = false,
    this.constraints,
    this.font,
    this.foregroundColor,
    this.tint,
    this.paddings,
    this.lineLimit,
    this.lineLimitReservesSpace,
    this.textScale,
    this.truncationMode,
  });

  /// Optional font descriptor.
  final CNFont? font;

  /// Maximum number of lines.
  final int? lineLimit;

  /// Whether the text should reserve space for [lineLimit].
  final bool? lineLimitReservesSpace;

  /// The text content to display.
  final String text;

  /// Optional SwiftUI text scale.
  final CNTextScale? textScale;

  /// Optional SwiftUI truncation mode.
  final CNTextTruncationMode? truncationMode;

  @override
  final BoxConstraints? constraints;

  @override
  final Color? foregroundColor;

  @override
  final EdgeInsetsGeometry? paddings;

  @override
  final bool shrink;

  @override
  final Object? tint;

  @override
  State<CNText2> createState() => _CNText2State();

  @override
  String get nativeViewType => _kNativeViewType;
}

class _CNText2State extends CNWidgetState<CNText2> {
  @override
  Size computeDefaultSize() {
    double defaultWidth = _kDefaultTextWidth;
    double defaultHeight = _kDefaultTextHeight;

    if (widget.font != null) {
      if (widget.font!.size.points != null) {
        defaultHeight = widget.font!.size.points! + 8;
      } else if (widget.font!.size.preset != null) {
        switch (widget.font!.size.preset!) {
          case CNFontSizePreset.system:
            defaultHeight = 22;
            break;
          case CNFontSizePreset.smallSystem:
            defaultHeight = 18;
            break;
          case CNFontSizePreset.label:
            defaultHeight = 17;
            break;
        }
      }
    }

    defaultWidth += (widget.paddings?.horizontal ?? 0);
    defaultHeight += (widget.paddings?.vertical ?? 0);
    return Size(defaultWidth, defaultHeight);
  }

  @override
  Map<String, dynamic> toWidgetPayload(BuildContext context, {required BoxConstraints? constraints}) {
    final payload = <String, dynamic>{
      'text': widget.text,
      'font': widget.font?.toMap(),
      'lineLimit': widget.lineLimit,
      'lineLimitReservesSpace': widget.lineLimitReservesSpace,
      'textScale': widget.textScale?.name,
      'truncationMode': widget.truncationMode?.name,
    };

    widget.writeSharedFields(context, payload: payload, constraints: constraints);
    return payload;
  }
}
