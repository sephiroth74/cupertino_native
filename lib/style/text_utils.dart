import 'package:cupertino_native/style/font.dart';
import 'package:cupertino_native/style/text.dart';
import 'package:flutter/cupertino.dart';

/// Creates a declarative `CNFont` from a Flutter `TextStyle`.
CNFont cnFontFromTextStyle(TextStyle style) {
  return CNFont.system(
    CNFontSize.points(style.fontSize ?? 13.0),
    weight: cnFontWeightFromFlutter(style.fontWeight),
  );
}

/// Converts a Flutter `FontWeight` to the matching `CNFontWeight`.
CNFontWeight cnFontWeightFromFlutter(FontWeight? weight) {
  switch (weight) {
    case FontWeight.w100:
      return CNFontWeight.ultraLight;
    case FontWeight.w200:
      return CNFontWeight.thin;
    case FontWeight.w300:
      return CNFontWeight.light;
    case FontWeight.w400:
      return CNFontWeight.regular;
    case FontWeight.w500:
      return CNFontWeight.medium;
    case FontWeight.w600:
      return CNFontWeight.semibold;
    case FontWeight.w700:
      return CNFontWeight.bold;
    case FontWeight.w800:
      return CNFontWeight.heavy;
    case FontWeight.w900:
      return CNFontWeight.black;
    case null:
      return CNFontWeight.regular;
    default:
      throw ArgumentError.value(weight, 'weight');
  }
}

/// Converts a `CNFontWeight` back to the closest Flutter `FontWeight`.
FontWeight fontWeightFromCNFontWeight(CNFontWeight? weight) {
  switch (weight) {
    case CNFontWeight.ultraLight:
      return FontWeight.w100;
    case CNFontWeight.thin:
      return FontWeight.w200;
    case CNFontWeight.light:
      return FontWeight.w300;
    case CNFontWeight.regular:
      return FontWeight.w400;
    case CNFontWeight.medium:
      return FontWeight.w500;
    case CNFontWeight.semibold:
      return FontWeight.w600;
    case CNFontWeight.bold:
      return FontWeight.w700;
    case CNFontWeight.heavy:
      return FontWeight.w800;
    case CNFontWeight.black:
      return FontWeight.w900;
    case null:
      return FontWeight.w400;
  }
}

/// Maps a truncation mode to Flutter's `TextOverflow` behavior.
TextOverflow overflowFromTruncationMode(CNTextTruncationMode? mode) {
  switch (mode) {
    case CNTextTruncationMode.head:
    case CNTextTruncationMode.middle:
    case CNTextTruncationMode.tail:
      return TextOverflow.ellipsis;
    case null:
      return TextOverflow.clip;
  }
}
