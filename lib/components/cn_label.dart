// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativeLabel2';

/// A native SwiftUI Label widget.
///
/// A Label is composed of a [title] (a [CNChildText] with full text properties)
/// and an optional [image] (a [CNChildImage] with full image properties).
class CNLabel extends CNWidget {
  const CNLabel({
    super.key,
    super.debugLog,
    required this.title,
    this.image,
    this.font,
    this.labelStyle = CNLabelStyle.automatic,
    this.labelReservedIconWidth,
    this.labelIconToTitleSpacing,
    this.shrink = true,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
    this.help,
  });

  /// Convenience constructor that accepts plain strings.
  const factory CNLabel.simple(
    String titleText, {
    Key? key,
    bool debugLog,
    String? systemImage,
    CNFont? font,
    Color? foregroundColor,
    CNLabelStyle labelStyle,
    double? labelReservedIconWidth,
    double? labelIconToTitleSpacing,
    bool shrink,
    BoxConstraints? constraints,
    Color? tint,
    EdgeInsetsGeometry? paddings,
  }) = _CNLabelSimple;

  /// Optional font applied to the entire label.
  final CNFont? font;

  /// Optional image (icon) for the label.
  final CNChildImage? image;

  /// Optional spacing between icon and title.
  final double? labelIconToTitleSpacing;

  /// Optional reserved width for icon area.
  final double? labelReservedIconWidth;

  /// Visual style applied to the SwiftUI label.
  final CNLabelStyle labelStyle;

  /// The title of the label.
  final CNChildText title;

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
  State<CNLabel> createState() => _CNLabelState();

  @override
  String get nativeViewType => _kNativeViewType;
}

/// Style options for [CNLabel].
enum CNLabelStyle {
  /// Let SwiftUI choose the most appropriate style.
  automatic,

  /// Show both title and icon.
  titleAndIcon,

  /// Show only title.
  titleOnly,

  /// Show only icon.
  iconOnly,
}

class _CNLabelSimple extends CNLabel {
  const _CNLabelSimple(
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

class _CNLabelState extends CNWidgetState<CNLabel> {
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
