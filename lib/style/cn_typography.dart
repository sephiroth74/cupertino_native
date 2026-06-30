import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

const _kDefaultFontFamily = '.AppleSystemUIFont';

/// Semantic macOS text roles aligned with Apple HIG built-in styles.
enum CNTypographyRole {
  /// Large-title role for top-level page headings.
  largeTitle,

  /// First-level title role.
  title1,

  /// Second-level title role.
  title2,

  /// Third-level title role.
  title3,

  /// Headline role for emphasized short labels.
  headline,

  /// Default multi-line body text role.
  body,

  /// Callout role for compact prominent text.
  callout,

  /// Subheadline role for supporting metadata.
  subheadline,

  /// Footnote role for fine-print supporting content.
  footnote,

  /// Caption role for short helper text.
  caption1,

  /// Alternate caption role.
  caption2,
}

/// macOS typography tokens aligned with Apple HIG text styles.
class CNTypography extends Equatable {
  /// Creates typography using HIG defaults for the given text [color].
  factory CNTypography({
    required Color color,
    TextStyle? largeTitle,
    TextStyle? title1,
    TextStyle? title2,
    TextStyle? title3,
    TextStyle? headline,
    TextStyle? body,
    TextStyle? callout,
    TextStyle? subheadline,
    TextStyle? footnote,
    TextStyle? caption1,
    TextStyle? caption2,
  }) {
    largeTitle ??= _style(color: color, size: 26, leading: 32, weight: FontWeight.w400, tracking: 0.22);
    title1 ??= _style(color: color, size: 22, leading: 26, weight: FontWeight.w400, tracking: -0.26);
    title2 ??= _style(color: color, size: 17, leading: 22, weight: FontWeight.w400, tracking: -0.43);
    title3 ??= _style(color: color, size: 15, leading: 20, weight: FontWeight.w400, tracking: -0.23);
    headline ??= _style(color: color, size: 13, leading: 16, weight: FontWeight.w700, tracking: -0.08);
    body ??= _style(color: color, size: 13, leading: 16, weight: FontWeight.w400, tracking: 0.06);
    callout ??= _style(color: color, size: 12, leading: 15, weight: FontWeight.w400, tracking: 0.0);
    subheadline ??= _style(color: color, size: 11, leading: 14, weight: FontWeight.w400, tracking: 0.06);
    footnote ??= _style(color: color, size: 10, leading: 13, weight: FontWeight.w400, tracking: 0.12);
    caption1 ??= _style(color: color, size: 10, leading: 13, weight: FontWeight.w400, tracking: 0.12);
    caption2 ??= _style(color: color, size: 10, leading: 13, weight: FontWeight.w500, tracking: 0.12);

    return CNTypography.raw(
      color: color,
      largeTitle: largeTitle,
      title1: title1,
      title2: title2,
      title3: title3,
      headline: headline,
      body: body,
      callout: callout,
      subheadline: subheadline,
      footnote: footnote,
      caption1: caption1,
      caption2: caption2,
    );
  }

  /// Default dark-on-light typography.
  factory CNTypography.darkOpaque() => CNTypography(color: CupertinoColors.label.color);

  /// Default light-on-dark typography.
  factory CNTypography.lightOpaque() => CNTypography(color: CupertinoColors.label.darkColor);

  /// Creates a typography token set from exact styles.
  const CNTypography.raw({
    required this.color,
    required this.largeTitle,
    required this.title1,
    required this.title2,
    required this.title3,
    required this.headline,
    required this.body,
    required this.callout,
    required this.subheadline,
    required this.footnote,
    required this.caption1,
    required this.caption2,
  });

  /// Body text style.
  final TextStyle body;

  /// Callout text style.
  final TextStyle callout;

  /// Caption 1 text style.
  final TextStyle caption1;

  /// Caption 2 text style.
  final TextStyle caption2;

  /// Base color used by the style set.
  final Color color;

  /// Footnote text style.
  final TextStyle footnote;

  /// Headline text style.
  final TextStyle headline;

  /// Large-title text style.
  final TextStyle largeTitle;

  /// Subheadline text style.
  final TextStyle subheadline;

  /// Title 1 text style.
  final TextStyle title1;

  /// Title 2 text style.
  final TextStyle title2;

  /// Title 3 text style.
  final TextStyle title3;

  @override
  List<Object?> get props => [
    color,
    largeTitle,
    title1,
    title2,
    title3,
    headline,
    body,
    callout,
    subheadline,
    footnote,
    caption1,
    caption2,
  ];

  /// Returns the text style for a semantic role.
  TextStyle styleFor(CNTypographyRole role) {
    switch (role) {
      case CNTypographyRole.largeTitle:
        return largeTitle;
      case CNTypographyRole.title1:
        return title1;
      case CNTypographyRole.title2:
        return title2;
      case CNTypographyRole.title3:
        return title3;
      case CNTypographyRole.headline:
        return headline;
      case CNTypographyRole.body:
        return body;
      case CNTypographyRole.callout:
        return callout;
      case CNTypographyRole.subheadline:
        return subheadline;
      case CNTypographyRole.footnote:
        return footnote;
      case CNTypographyRole.caption1:
        return caption1;
      case CNTypographyRole.caption2:
        return caption2;
    }
  }

  /// Returns the emphasized variant for a semantic role.
  TextStyle emphasizedFor(CNTypographyRole role) {
    final base = styleFor(role);
    switch (role) {
      case CNTypographyRole.largeTitle:
      case CNTypographyRole.title1:
      case CNTypographyRole.title2:
        return base.copyWith(fontWeight: FontWeight.w700);
      case CNTypographyRole.title3:
      case CNTypographyRole.body:
      case CNTypographyRole.callout:
      case CNTypographyRole.subheadline:
      case CNTypographyRole.footnote:
      case CNTypographyRole.caption2:
        return base.copyWith(fontWeight: FontWeight.w600);
      case CNTypographyRole.caption1:
        return base.copyWith(fontWeight: FontWeight.w500);
      case CNTypographyRole.headline:
        return base.copyWith(fontWeight: FontWeight.w800);
    }
  }

  /// Returns a copy with selected values replaced.
  CNTypography copyWith({
    Color? color,
    TextStyle? largeTitle,
    TextStyle? title1,
    TextStyle? title2,
    TextStyle? title3,
    TextStyle? headline,
    TextStyle? body,
    TextStyle? callout,
    TextStyle? subheadline,
    TextStyle? footnote,
    TextStyle? caption1,
    TextStyle? caption2,
  }) {
    return CNTypography.raw(
      color: color ?? this.color,
      largeTitle: largeTitle ?? this.largeTitle,
      title1: title1 ?? this.title1,
      title2: title2 ?? this.title2,
      title3: title3 ?? this.title3,
      headline: headline ?? this.headline,
      body: body ?? this.body,
      callout: callout ?? this.callout,
      subheadline: subheadline ?? this.subheadline,
      footnote: footnote ?? this.footnote,
      caption1: caption1 ?? this.caption1,
      caption2: caption2 ?? this.caption2,
    );
  }

  /// Merges another typography object into this one.
  CNTypography merge(CNTypography? other) {
    if (other == null) return this;
    return CNTypography.raw(
      color: other.color,
      largeTitle: largeTitle.merge(other.largeTitle),
      title1: title1.merge(other.title1),
      title2: title2.merge(other.title2),
      title3: title3.merge(other.title3),
      headline: headline.merge(other.headline),
      body: body.merge(other.body),
      callout: callout.merge(other.callout),
      subheadline: subheadline.merge(other.subheadline),
      footnote: footnote.merge(other.footnote),
      caption1: caption1.merge(other.caption1),
      caption2: caption2.merge(other.caption2),
    );
  }

  /// Linearly interpolates between two typographies.
  static CNTypography lerp(CNTypography a, CNTypography b, double t) {
    return CNTypography.raw(
      color: Color.lerp(a.color, b.color, t)!,
      largeTitle: TextStyle.lerp(a.largeTitle, b.largeTitle, t)!,
      title1: TextStyle.lerp(a.title1, b.title1, t)!,
      title2: TextStyle.lerp(a.title2, b.title2, t)!,
      title3: TextStyle.lerp(a.title3, b.title3, t)!,
      headline: TextStyle.lerp(a.headline, b.headline, t)!,
      body: TextStyle.lerp(a.body, b.body, t)!,
      callout: TextStyle.lerp(a.callout, b.callout, t)!,
      subheadline: TextStyle.lerp(a.subheadline, b.subheadline, t)!,
      footnote: TextStyle.lerp(a.footnote, b.footnote, t)!,
      caption1: TextStyle.lerp(a.caption1, b.caption1, t)!,
      caption2: TextStyle.lerp(a.caption2, b.caption2, t)!,
    );
  }
}

TextStyle _style({
  required Color color,
  required double size,
  required double leading,
  required FontWeight weight,
  required double tracking,
}) {
  return TextStyle(
    fontFamily: _kDefaultFontFamily,
    color: color,
    fontSize: size,
    height: leading / size,
    fontWeight: weight,
    letterSpacing: tracking,
  );
}
