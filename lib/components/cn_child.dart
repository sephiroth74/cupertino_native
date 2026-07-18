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
  const CNChild({this.paddings, this.tag, this.enabled});

  /// Whether this child is enabled (nil = inherit from parent).
  final bool? enabled;

  /// Optional padding applied around this child.
  final EdgeInsetsGeometry? paddings;

  /// Optional tag to identify this child in callbacks (e.g. menu item pressed).
  final String? tag;

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
    super.enabled,
    super.paddings,
    super.tag,
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
      'tag': tag,
      'enabled': enabled,
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
    super.enabled,
    super.paddings,
    super.tag,
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
      'tag': tag,
      'enabled': enabled,
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
  const CNChildVStack({required this.children, this.alignment = CNAlignment.center, this.spacing, super.enabled, super.paddings, super.tag});

  final CNAlignment alignment;
  final List<CNChild> children;
  final double? spacing;

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {
      'type': 'vstack',
      'tag': tag,
      'enabled': enabled,
      'alignment': alignment.name,
      'spacing': spacing,
      'children': children.map((c) => c.toChildPayload(context)).toList(),
      'paddings': CNChild.serializePaddings(paddings),
    };
  }
}

/// An HStack container child.
class CNChildHStack extends CNChild {
  const CNChildHStack({required this.children, this.alignment = CNAlignment.center, this.spacing, super.enabled, super.paddings, super.tag});

  final CNAlignment alignment;
  final List<CNChild> children;
  final double? spacing;

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {
      'type': 'hstack',
      'tag': tag,
      'enabled': enabled,
      'alignment': alignment.name,
      'spacing': spacing,
      'children': children.map((c) => c.toChildPayload(context)).toList(),
      'paddings': CNChild.serializePaddings(paddings),
    };
  }
}

/// A Group container child (no layout, just grouping).
class CNChildGroup extends CNChild {
  const CNChildGroup({required this.children, super.enabled, super.paddings, super.tag});

  final List<CNChild> children;

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {
      'type': 'group',
      'tag': tag,
      'enabled': enabled,
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
    super.enabled,
    super.paddings,
    super.tag,
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
      'tag': tag,
      'enabled': enabled,
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

/// A Divider child.
class CNChildDivider extends CNChild {
  const CNChildDivider();

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {'type': 'divider'};
  }
}

/// A Button child (for use inside menus or other containers).
///
/// Use [tag] to identify which button was pressed in the callback.
class CNChildButton extends CNChild {
  const CNChildButton({
    required super.tag,
    required this.title,
    this.systemImage,
    this.role,
    this.badge,
    super.enabled,
    super.paddings,
  }) : assert(badge == null || badge is String || badge is int);

  /// Optional badge value (String or int).
  final Object? badge;

  /// Semantic role.
  final CNButtonRole2? role;

  /// Optional SF Symbol icon.
  final String? systemImage;

  /// Button title.
  final String title;

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {
      'type': 'button',
      'tag': tag,
      'enabled': enabled,
      'title': title,
      'systemImage': systemImage,
      'role': role?.name,
      'badge': badge,
      'paddings': CNChild.serializePaddings(paddings),
    };
  }
}

/// A sub-Menu child (for nesting menus).
class CNChildMenu extends CNChild {
  const CNChildMenu({
    required this.items,
    required this.label,
    super.enabled,
    super.tag,
  });

  /// The menu items (buttons, dividers, and nested menus).
  final List<CNChild> items;

  /// Label content for this sub-menu.
  final List<CNChild> label;

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {
      'type': 'menu',
      'tag': tag,
      'enabled': enabled,
      'items': items.map((c) => c.toChildPayload(context)).toList(),
      'label': label.map((c) => c.toChildPayload(context)).toList(),
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
    super.enabled,
    super.paddings,
    super.tag,
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
      'tag': tag,
      'enabled': enabled,
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
