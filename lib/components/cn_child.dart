// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/widgets.dart';

/// Alignment for SwiftUI stacks.
enum CNAlignment {
  leading,
  center,
  trailing,
  top,
  bottom,
}

/// A child widget that can be serialized as inline content for a container widget.
///
/// These are NOT platform views — they are pure data that the native side
/// reconstructs as SwiftUI views inside a parent widget's content closure.
sealed class CNChild {
  const CNChild();

  /// Serializes this child into a payload map for the native side.
  Map<String, dynamic> toChildPayload(BuildContext context);
}

/// A text child.
class CNChildText extends CNChild {
  const CNChildText(
    this.text, {
    this.font,
    this.foregroundColor,
    this.lineLimit,
  });

  final CNFont? font;
  final Color? foregroundColor;
  final int? lineLimit;
  final String text;

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {
      'type': 'text',
      'text': text,
      'font': font?.toMap(),
      'foregroundColor': resolveColorToArgb(foregroundColor, context),
      'lineLimit': lineLimit,
    };
  }
}

/// An SF Symbol image child.
class CNChildImage extends CNChild {
  const CNChildImage(
    this.systemSymbolName, {
    this.font,
    this.foregroundColor,
  });

  final CNFont? font;
  final Color? foregroundColor;
  final String systemSymbolName;

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {
      'type': 'image',
      'systemSymbolName': systemSymbolName,
      'font': font?.toMap(),
      'foregroundColor': resolveColorToArgb(foregroundColor, context),
    };
  }
}

/// A VStack container child.
class CNChildVStack extends CNChild {
  const CNChildVStack({
    required this.children,
    this.alignment = CNAlignment.center,
    this.spacing,
  });

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
    };
  }
}

/// An HStack container child.
class CNChildHStack extends CNChild {
  const CNChildHStack({
    required this.children,
    this.alignment = CNAlignment.center,
    this.spacing,
  });

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
    };
  }
}

/// A Group container child (no layout, just grouping).
class CNChildGroup extends CNChild {
  const CNChildGroup({required this.children});

  final List<CNChild> children;

  @override
  Map<String, dynamic> toChildPayload(BuildContext context) {
    return {
      'type': 'group',
      'children': children.map((c) => c.toChildPayload(context)).toList(),
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
  });

  final CNFont? font;
  final Color? foregroundColor;
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
    };
  }
}
