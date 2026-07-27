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
  const CNChild({this.constraints, this.paddings, this.tag, this.enabled, this.tint, this.foregroundColor, this.help});

  /// Optional layout constraints applied to this child.
  final BoxConstraints? constraints;

  /// Whether this child is enabled (nil = inherit from parent).
  final bool? enabled;

  /// Optional foreground color applied to this child.
  final Color? foregroundColor;

  /// Optional tooltip text shown on hover (SwiftUI `.help()`).
  final String? help;

  /// Optional padding applied around this child.
  final EdgeInsetsGeometry? paddings;

  /// Optional tag to identify this child in callbacks (e.g. menu item pressed).
  final String? tag;

  /// Optional tint color applied to this child.
  final Color? tint;

  /// Serializes this child into a payload map for the native side.
  Map<String, dynamic> toChildPayload(BuildContext context);

  /// Serializes constraints to a map for the channel.
  static Map<String, double?>? serializeConstraints(BoxConstraints? c) {
    if (c == null) return null;
    return {
      'minWidth': c.minWidth.isFinite ? c.minWidth : null,
      'maxWidth': c.maxWidth.isFinite ? c.maxWidth : null,
      'minHeight': c.minHeight.isFinite ? c.minHeight : null,
      'maxHeight': c.maxHeight.isFinite ? c.maxHeight : null,
    };
  }

  /// Serializes paddings to a map for the channel.
  static Map<String, double>? serializePaddings(EdgeInsetsGeometry? p) {
    if (p == null) return null;
    final resolved = p.resolve(TextDirection.ltr);
    return {'top': resolved.top, 'bottom': resolved.bottom, 'leading': resolved.left, 'trailing': resolved.right};
  }
}

/// A text child.
class CNChildText extends CNChild {
  const CNChildText(
    this.text, {
    this.font,
    super.foregroundColor,
    this.lineLimit,
    this.lineLimitReservesSpace,
    this.textScale,
    this.truncationMode,
    super.enabled,
    super.tint,
    super.constraints,
    super.paddings,
    super.tag,
    super.help,
  });

  final CNFont? font;
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
      'help': help,
      'tint': resolveColorToArgb(tint, context),
      'foregroundColor': resolveColorToArgb(foregroundColor, context),
      'text': text,
      'font': font?.toMap(),
      'lineLimit': lineLimit,
      'lineLimitReservesSpace': lineLimitReservesSpace,
      'textScale': textScale?.name,
      'truncationMode': truncationMode?.name,
      'constraints': CNChild.serializeConstraints(constraints),
      'paddings': CNChild.serializePaddings(paddings),
    };
  }
}

/// An SF Symbol image child.
class CNChildImage extends CNChild {
  const CNChildImage(
    this.systemSymbolName, {
    this.font,
    super.foregroundColor,
    this.symbolRenderingMode,
    this.symbolColorRenderingMode,
    this.foregroundStyleColors,
    super.enabled,
    super.tint,
    super.constraints,
    super.paddings,
    super.tag,
    super.help,
  });

  final CNFont? font;
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
      'help': help,
      'tint': resolveColorToArgb(tint, context),
      'foregroundColor': resolveColorToArgb(foregroundColor, context),
      'systemSymbolName': systemSymbolName,
      'font': font?.toMap(),
      'symbolRenderingMode': symbolRenderingMode?.name,
      'symbolColorRenderingMode': symbolColorRenderingMode?.name,
      'foregroundStyleColors': foregroundStyleColors?.map((c) => resolveColorToArgb(c, context)).toList(),
      'constraints': CNChild.serializeConstraints(constraints),
      'paddings': CNChild.serializePaddings(paddings),
    };
  }
}

/// A VStack container child.
class CNChildVStack extends CNChild {
  const CNChildVStack({
    required this.children,
    this.alignment = CNAlignment.center,
    this.spacing,
    super.enabled,
    super.tint,
    super.foregroundColor,
    super.constraints,
    super.paddings,
    super.tag,
    super.help,
  });

  final CNAlignment alignment;
  final List<CNChild> children;
  final double? spacing;

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {
      'type': 'vstack',
      'tag': tag,
      'enabled': enabled,
      'help': help,
      'tint': resolveColorToArgb(tint, context),
      'foregroundColor': resolveColorToArgb(foregroundColor, context),
      'alignment': alignment.name,
      'spacing': spacing,
      'children': children.map((c) => c.toChildPayload(context)).toList(),
      'constraints': CNChild.serializeConstraints(constraints),
      'paddings': CNChild.serializePaddings(paddings),
    };
  }
}

/// An HStack container child.
class CNChildHStack extends CNChild {
  const CNChildHStack({
    required this.children,
    this.alignment = CNAlignment.center,
    this.spacing,
    super.enabled,
    super.tint,
    super.foregroundColor,
    super.constraints,
    super.paddings,
    super.tag,
    super.help,
  });

  final CNAlignment alignment;
  final List<CNChild> children;
  final double? spacing;

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {
      'type': 'hstack',
      'tag': tag,
      'enabled': enabled,
      'help': help,
      'tint': resolveColorToArgb(tint, context),
      'foregroundColor': resolveColorToArgb(foregroundColor, context),
      'alignment': alignment.name,
      'spacing': spacing,
      'children': children.map((c) => c.toChildPayload(context)).toList(),
      'constraints': CNChild.serializeConstraints(constraints),
      'paddings': CNChild.serializePaddings(paddings),
    };
  }
}

/// A Group container child (no layout, just grouping).
class CNChildGroup extends CNChild {
  const CNChildGroup({required this.children, super.enabled, super.tint, super.foregroundColor, super.constraints, super.paddings, super.tag, super.help});

  final List<CNChild> children;

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {
      'type': 'group',
      'tag': tag,
      'enabled': enabled,
      'help': help,
      'tint': resolveColorToArgb(tint, context),
      'foregroundColor': resolveColorToArgb(foregroundColor, context),
      'children': children.map((c) => c.toChildPayload(context)).toList(),
      'constraints': CNChild.serializeConstraints(constraints),
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
    super.tint,
    super.foregroundColor,
    super.constraints,
    super.enabled,
    super.paddings,
    super.tag,
    super.help,
  });

  final CNControlSize controlSize;
  final CNProgressViewStyle style;
  final double total;
  final double? value;

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {
      'type': 'progressView',
      'tag': tag,
      'enabled': enabled,
      'help': help,
      'tint': resolveColorToArgb(tint, context),
      'foregroundColor': resolveColorToArgb(foregroundColor, context),
      'value': value,
      'total': total,
      'style': style.name,
      'controlSize': controlSize.name,
      'constraints': CNChild.serializeConstraints(constraints),
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
    this.labelStyle,
    super.enabled,
    super.tint,
    super.foregroundColor,
    super.constraints,
    super.paddings,
    super.help,
  }) : assert(badge == null || badge is String || badge is int);

  /// Optional badge value (String or int).
  final Object? badge;

  /// Label style (titleOnly, iconOnly, titleAndIcon).
  final CNLabel2Style? labelStyle;

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
      'help': help,
      'tint': resolveColorToArgb(tint, context),
      'foregroundColor': resolveColorToArgb(foregroundColor, context),
      'title': title,
      'systemImage': systemImage,
      'role': role?.name,
      'badge': badge,
      'labelStyle': labelStyle?.name,
      'constraints': CNChild.serializeConstraints(constraints),
      'paddings': CNChild.serializePaddings(paddings),
    };
  }
}

/// A sub-Menu child (for nesting menus).
class CNChildMenu extends CNChild {
  const CNChildMenu({required this.items, required this.label, super.enabled, super.tint, super.foregroundColor, super.constraints, super.paddings, super.tag, super.help});

  factory CNChildMenu.simple(
    String title, {
    required List<CNChild> items,
    String? tag,
    Color? tint,
    Color? foregroundColor,
    bool? enabled,
  }) {
    return CNChildMenu(
      items: items,
      label: [CNChildText(title)],
      tag: tag,
      tint: tint,
      foregroundColor: foregroundColor,
      enabled: enabled,
    );
  }

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
      'help': help,
      'tint': resolveColorToArgb(tint, context),
      'foregroundColor': resolveColorToArgb(foregroundColor, context),
      'items': items.map((c) => c.toChildPayload(context)).toList(),
      'label': label.map((c) => c.toChildPayload(context)).toList(),
      'constraints': CNChild.serializeConstraints(constraints),
      'paddings': CNChild.serializePaddings(paddings),
    };
  }
}

/// A Picker child for inline use in toolbars and other containers.
class CNChildPicker extends CNChild {
  const CNChildPicker({
    required super.tag,
    required this.children,
    required this.selection,
    this.label,
    this.labelStyle,
    this.pickerStyle = 'menu',
    this.controlSize,
    this.font,
    super.enabled,
    super.tint,
    super.foregroundColor,
    super.constraints,
    super.paddings,
    super.help,
  });

  /// Picker items (should be CNChildText, CNChildImage, or CNChildLabel with tags).
  final List<CNChild> children;

  /// Control size.
  final String? controlSize;

  /// Font.
  final CNFont? font;

  /// Optional label content.
  final List<CNChild>? label;

  /// Label style (titleOnly, iconOnly, titleAndIcon).
  final CNLabel2Style? labelStyle;

  /// Picker style (menu, segmented, radioGroup, inline, palette).
  final String pickerStyle;

  /// Currently selected tag value.
  final String selection;

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {
      'type': 'picker',
      'tag': tag,
      'enabled': enabled,
      'help': help,
      'tint': resolveColorToArgb(tint, context),
      'foregroundColor': resolveColorToArgb(foregroundColor, context),
      'children': children.map((c) => c.toChildPayload(context)).toList(),
      'selection': selection,
      if (label != null) 'label': label!.map((c) => c.toChildPayload(context)).toList(),
      'labelStyle': labelStyle?.name,
      'pickerStyle': pickerStyle,
      'controlSize': controlSize,
      'font': font?.toMap(),
      'constraints': CNChild.serializeConstraints(constraints),
      'paddings': CNChild.serializePaddings(paddings),
    };
  }
}

/// A Toggle child for inline use in toolbars and other containers.
class CNChildToggle extends CNChild {
  const CNChildToggle({
    required super.tag,
    required this.isOn,
    this.label,
    this.systemImage,
    this.toggleStyle = 'switch',
    this.controlSize,
    super.enabled,
    super.tint,
    super.foregroundColor,
    super.constraints,
    super.paddings,
    super.help,
  });

  /// Control size.
  final String? controlSize;

  /// Whether the toggle is on.
  final bool isOn;

  /// Label text.
  final String? label;

  /// Optional SF Symbol for the label.
  final String? systemImage;

  /// Toggle style (switch, button, checkbox).
  final String toggleStyle;

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {
      'type': 'toggle',
      'tag': tag,
      'enabled': enabled,
      'help': help,
      'tint': resolveColorToArgb(tint, context),
      'foregroundColor': resolveColorToArgb(foregroundColor, context),
      'isOn': isOn,
      'label': label,
      'systemImage': systemImage,
      'toggleStyle': toggleStyle,
      'controlSize': controlSize,
      'constraints': CNChild.serializeConstraints(constraints),
      'paddings': CNChild.serializePaddings(paddings),
    };
  }
}

/// A TextField child for inline use in toolbars and other containers.
class CNChildTextField extends CNChild {
  const CNChildTextField({
    required super.tag,
    this.text = '',
    this.placeholder,
    this.font,
    this.controlSize,
    super.enabled,
    super.tint,
    super.foregroundColor,
    super.constraints,
    super.paddings,
    super.help,
  });

  /// Control size.
  final String? controlSize;

  /// Font.
  final CNFont? font;

  /// Placeholder text.
  final String? placeholder;

  /// Current text value.
  final String text;

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {
      'type': 'textField',
      'tag': tag,
      'enabled': enabled,
      'help': help,
      'tint': resolveColorToArgb(tint, context),
      'foregroundColor': resolveColorToArgb(foregroundColor, context),
      'text': text,
      'placeholder': placeholder,
      'font': font?.toMap(),
      'controlSize': controlSize,
      'constraints': CNChild.serializeConstraints(constraints),
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
    super.foregroundColor,
    this.symbolRenderingMode,
    this.symbolColorRenderingMode,
    this.foregroundStyleColors,
    this.labelReservedIconWidth,
    this.labelIconToTitleSpacing,
    this.labelStyle = CNLabel2Style.automatic,
    super.enabled,
    super.tint,
    super.constraints,
    super.paddings,
    super.tag,
    super.help,
  });

  final CNFont? font;
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
      'help': help,
      'tint': resolveColorToArgb(tint, context),
      'foregroundColor': resolveColorToArgb(foregroundColor, context),
      'title': title,
      'systemImage': systemImage,
      'font': font?.toMap(),
      'symbolRenderingMode': symbolRenderingMode?.name,
      'symbolColorRenderingMode': symbolColorRenderingMode?.name,
      'foregroundStyleColors': foregroundStyleColors?.map((c) => resolveColorToArgb(c, context)).toList(),
      'labelReservedIconWidth': labelReservedIconWidth,
      'labelIconToTitleSpacing': labelIconToTitleSpacing,
      'labelStyle': labelStyle.name,
      'constraints': CNChild.serializeConstraints(constraints),
      'paddings': CNChild.serializePaddings(paddings),
    };
  }
}
