// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/widgets.dart';

/// Alignment for SwiftUI stacks.
enum CNAlignment { leading, center, trailing, top, bottom }

/// A child widget that can be serialized as inline content for a container widget.
///
/// These are NOT platform views — they are pure data that the native side
/// reconstructs as SwiftUI views inside a parent widget's content closure.
sealed class CNChild {
  const CNChild({this.paddings});

  /// Optional padding applied around this child.
  final EdgeInsetsGeometry? paddings;

  /// Serializes this child into a payload map for the native side.
  Map<String, dynamic> toChildPayload(BuildContext context);

  /// Serializes paddings to a map for the channel.
  static Map<String, double>? serializePaddings(EdgeInsetsGeometry? p) {
    if (p == null) return null;
    final resolved = p.resolve(TextDirection.ltr);
    return {
      'top': resolved.top,
      'bottom': resolved.bottom,
      'leading': resolved.left,
      'trailing': resolved.right,
    };
  }
}

/// A text child.
class CNChildText extends CNChild {
  const CNChildText(
    this.text, {
    this.font,
    this.foregroundColor,
    this.lineLimit,
    this.lineLimitReservesSpace,
    this.textScale,
    this.truncationMode,
    super.paddings,
  });

  final CNFont? font;
  final Color? foregroundColor;
  final int? lineLimit;
  final bool? lineLimitReservesSpace;
  final String text;
  final CNTextScale? textScale;
  final CNTextTruncationMode? truncationMode;

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {
      'type': 'text',
      'text': text,
      'font': font?.toMap(),
      'foregroundColor': resolveColorToArgb(foregroundColor, context),
      'lineLimit': lineLimit,
      'lineLimitReservesSpace': lineLimitReservesSpace,
      'textScale': textScale?.name,
      'truncationMode': truncationMode?.name,
      'paddings': CNChild.serializePaddings(paddings),
    };
  }
}

/// An SF Symbol image child.
class CNChildImage extends CNChild {
  const CNChildImage(
    this.systemSymbolName, {
    this.font,
    this.foregroundColor,
    this.symbolRenderingMode,
    this.symbolColorRenderingMode,
    this.foregroundStyleColors,
    super.paddings,
  });

  final CNFont? font;
  final Color? foregroundColor;
  final List<Color>? foregroundStyleColors;
  final CNSymbolColorRenderingMode? symbolColorRenderingMode;
  final CNSymbolRenderingMode? symbolRenderingMode;
  final String systemSymbolName;

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {
      'type': 'image',
      'systemSymbolName': systemSymbolName,
      'font': font?.toMap(),
      'foregroundColor': resolveColorToArgb(foregroundColor, context),
      'symbolRenderingMode': symbolRenderingMode?.name,
      'symbolColorRenderingMode': symbolColorRenderingMode?.name,
      'foregroundStyleColors': foregroundStyleColors?.map((c) => resolveColorToArgb(c, context)).toList(),
      'paddings': CNChild.serializePaddings(paddings),
    };
  }
}

/// A VStack container child.
class CNChildVStack extends CNChild {
  const CNChildVStack({required this.children, this.alignment = CNAlignment.center, this.spacing, super.paddings});

  final CNAlignment alignment;
  final List<CNChild> children;
  final double? spacing;

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {
      'type': 'vstack',
      'alignment': alignment.name,
      'spacing': spacing,
      'children': children.map((c) => c.toChildPayload(context)).toList(),
      'paddings': CNChild.serializePaddings(paddings),
    };
  }
}

/// An HStack container child.
class CNChildHStack extends CNChild {
  const CNChildHStack({required this.children, this.alignment = CNAlignment.center, this.spacing, super.paddings});

  final CNAlignment alignment;
  final List<CNChild> children;
  final double? spacing;

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {
      'type': 'hstack',
      'alignment': alignment.name,
      'spacing': spacing,
      'children': children.map((c) => c.toChildPayload(context)).toList(),
      'paddings': CNChild.serializePaddings(paddings),
    };
  }
}

/// A Group container child (no layout, just grouping).
class CNChildGroup extends CNChild {
  const CNChildGroup({required this.children, super.paddings});

  final List<CNChild> children;

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {
      'type': 'group',
      'children': children.map((c) => c.toChildPayload(context)).toList(),
      'paddings': CNChild.serializePaddings(paddings),
    };
  }
}

/// A ProgressView child.
class CNChildProgressView extends CNChild {
  const CNChildProgressView({
    this.value,
    this.total = 1.0,
    this.style = CNProgressViewStyle.linear,
    this.controlSize = CNControlSize.regular,
    this.tint,
    this.constraints,
    super.paddings,
  });

  final BoxConstraints? constraints;
  final CNControlSize controlSize;
  final CNProgressViewStyle style;
  final Color? tint;
  final double total;
  final double? value;

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {
      'type': 'progressView',
      'value': value,
      'total': total,
      'style': style.name,
      'controlSize': controlSize.name,
      'tint': resolveColorToArgb(tint, context),
      'constraints': constraints != null
          ? {
              'minWidth': constraints!.minWidth.isFinite ? constraints!.minWidth : null,
              'maxWidth': constraints!.maxWidth.isFinite ? constraints!.maxWidth : null,
              'minHeight': constraints!.minHeight.isFinite ? constraints!.minHeight : null,
              'maxHeight': constraints!.maxHeight.isFinite ? constraints!.maxHeight : null,
            }
          : null,
      'paddings': CNChild.serializePaddings(paddings),
    };
  }
}

/// A Label child — SwiftUI `Label("title", systemImage: "icon")`.
class CNChildLabel extends CNChild {
  const CNChildLabel(
    this.title, {
    this.systemImage,
    this.font,
    this.foregroundColor,
    this.symbolRenderingMode,
    this.symbolColorRenderingMode,
    this.foregroundStyleColors,
    this.labelReservedIconWidth,
    this.labelIconToTitleSpacing,
    this.labelStyle = CNLabel2Style.automatic,
    super.paddings,
  });

  final CNFont? font;
  final Color? foregroundColor;
  final List<Color>? foregroundStyleColors;
  final double? labelIconToTitleSpacing;
  final double? labelReservedIconWidth;
  final CNLabel2Style labelStyle;
  final CNSymbolColorRenderingMode? symbolColorRenderingMode;
  final CNSymbolRenderingMode? symbolRenderingMode;
  final String? systemImage;
  final String title;

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {
      'type': 'label',
      'title': title,
      'systemImage': systemImage,
      'font': font?.toMap(),
      'foregroundColor': resolveColorToArgb(foregroundColor, context),
      'symbolRenderingMode': symbolRenderingMode?.name,
      'symbolColorRenderingMode': symbolColorRenderingMode?.name,
      'foregroundStyleColors': foregroundStyleColors?.map((c) => resolveColorToArgb(c, context)).toList(),
      'labelReservedIconWidth': labelReservedIconWidth,
      'labelIconToTitleSpacing': labelIconToTitleSpacing,
      'labelStyle': labelStyle.name,
      'paddings': CNChild.serializePaddings(paddings),
    };
  }
}
