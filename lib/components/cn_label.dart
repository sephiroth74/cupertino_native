// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativeLabel2';

/// Style options for [CNLabel2].
enum CNLabel2Style {
  /// Let SwiftUI choose the most appropriate style.
  automatic,

  /// Show both title and icon.
  titleAndIcon,

  /// Show only title.
  titleOnly,

  /// Show only icon.
  iconOnly,
}

/// A native SwiftUI Label widget.
///
/// A Label is composed of a [title] (a [CNChildText] with full text properties)
/// and an optional [image] (a [CNChildImage] with full image properties).
class CNLabel2 extends CNWidget {
  const CNLabel2({
    super.key,
    super.debugLog,
    required this.title,
    this.image,
    this.font,
    this.labelStyle = CNLabel2Style.automatic,
    this.labelReservedIconWidth,
    this.labelIconToTitleSpacing,
    this.shrink = true,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
  });

  /// Convenience constructor that accepts plain strings.
  const factory CNLabel2.simple(
    String titleText, {
    Key? key,
    bool debugLog,
    String? systemImage,
    CNFont? font,
    Color? foregroundColor,
    CNLabel2Style labelStyle,
    double? labelReservedIconWidth,
    double? labelIconToTitleSpacing,
    bool shrink,
    BoxConstraints? constraints,
    Color? tint,
    EdgeInsetsGeometry? paddings,
  }) = _CNLabel2Simple;

  /// Optional font applied to the entire label.
  final CNFont? font;

  /// Optional image (icon) for the label.
  final CNChildImage? image;

  /// Optional spacing between icon and title.
  final double? labelIconToTitleSpacing;

  /// Optional reserved width for icon area.
  final double? labelReservedIconWidth;

  /// Visual style applied to the SwiftUI label.
  final CNLabel2Style labelStyle;

  /// The title of the label.
  final CNChildText title;

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
  State<CNLabel2> createState() => _CNLabel2State();

  @override
  String get nativeViewType => _kNativeViewType;
}

class _CNLabel2Simple extends CNLabel2 {
  const _CNLabel2Simple(
    String titleText, {
    super.key,
    super.debugLog,
    String? systemImage,
    super.font,
    super.foregroundColor,
    super.labelStyle,
    super.labelReservedIconWidth,
    super.labelIconToTitleSpacing,
    super.shrink,
    super.constraints,
    super.tint,
    super.paddings,
  }) : _titleText = titleText,
       _font = font,
       _foregroundColor2 = foregroundColor,
       _systemImage = systemImage,
       super(title: const CNChildText(''));

  final CNFont? _font;
  final Color? _foregroundColor2;
  final String? _systemImage;
  final String _titleText;

  @override
  CNChildImage? get image => _systemImage != null ? CNChildImage(_systemImage) : null;

  @override
  CNChildText get title => CNChildText(_titleText, font: _font, foregroundColor: _foregroundColor2);
}

class _CNLabel2State extends CNWidgetState<CNLabel2> {
  @override
  Size computeDefaultSize() => const Size(80.0, 20.0);

  @override
  Map<String, dynamic> toWidgetPayload(BuildContext context, {required BoxConstraints? constraints}) {
    final payload = <String, dynamic>{
      'title': widget.title.toChildPayload(context),
      'image': widget.image?.toChildPayload(context),
      'font': widget.font?.toMap(),
      'labelStyle': widget.labelStyle.name,
      'labelReservedIconWidth': widget.labelReservedIconWidth,
      'labelIconToTitleSpacing': widget.labelIconToTitleSpacing,
    };

    widget.writeSharedFields(context, payload: payload, constraints: constraints);
    return payload;
  }
}
