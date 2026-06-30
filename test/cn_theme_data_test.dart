import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CNThemeData', () {
    test('light factory provides expected defaults', () {
      final theme = CNThemeData.light();

      expect(theme.brightness, Brightness.light);
      expect(theme.typography.body.fontSize, 13);
      expect(theme.typography.largeTitle.fontSize, 26);
      expect(theme.typography.caption2.fontWeight, FontWeight.w500);
      expect(theme.fillPrimaryColor, isNotNull);
      expect(theme.materialMedium.blurRadius, CNGlassMaterial.medium.blurRadius);
      expect(theme.toggleTheme.tint, theme.accentColor);
    });

    test('copyWith overrides selected fields', () {
      final base = CNThemeData.light();
      final updated = base.copyWith(primaryColor: CupertinoColors.systemGreen.color);

      expect(updated.primaryColor, CupertinoColors.systemGreen.color);
      expect(updated.secondaryColor, base.secondaryColor);
      expect(updated.brightness, base.brightness);
      expect(updated.toggleTheme.tint, base.toggleTheme.tint);
    });

    test('toggle theme can override tint independently', () {
      final base = CNThemeData.light();
      final updated = base.copyWith(toggleTheme: const CNToggleThemeData(tint: Color(0xFF123456)));

      expect(updated.toggleTheme.tint, const Color(0xFF123456));
      expect(updated.accentColor, base.accentColor);
    });

    test('merge overrides with other theme values', () {
      final light = CNThemeData.light();
      final dark = CNThemeData.dark();
      final merged = light.merge(dark);

      expect(merged.brightness, Brightness.dark);
      expect(merged.primaryColor, dark.primaryColor);
      expect(merged.materialThick.opacity, dark.materialThick.opacity);
    });

    test('lerp interpolates colors and typography', () {
      final a = CNThemeData.light();
      final b = CNThemeData.dark();
      final lerped = CNThemeData.lerp(a, b, 0.5);

      expect(lerped.primaryColor, Color.lerp(a.primaryColor, b.primaryColor, 0.5));
      expect(lerped.typography.body.fontSize, closeTo(13, 0.001));
      expect(lerped.brightness, Brightness.dark);
    });
  });

  group('CNTypography', () {
    test('styleFor maps role correctly', () {
      final typography = CNTypography.darkOpaque();

      expect(typography.styleFor(CNTypographyRole.body), typography.body);
      expect(typography.styleFor(CNTypographyRole.headline), typography.headline);
      expect(typography.styleFor(CNTypographyRole.caption2), typography.caption2);
    });

    test('emphasizedFor maps to expected weight', () {
      final typography = CNTypography.darkOpaque();

      expect(typography.emphasizedFor(CNTypographyRole.largeTitle).fontWeight, FontWeight.w700);
      expect(typography.emphasizedFor(CNTypographyRole.title3).fontWeight, FontWeight.w600);
      expect(typography.emphasizedFor(CNTypographyRole.caption1).fontWeight, FontWeight.w500);
      expect(typography.emphasizedFor(CNTypographyRole.headline).fontWeight, FontWeight.w800);
    });

    test('lerp interpolates color', () {
      final a = CNTypography(color: const Color(0xFF000000));
      final b = CNTypography(color: const Color(0xFFFFFFFF));
      final lerped = CNTypography.lerp(a, b, 0.5);

      expect(lerped.color, Color.lerp(a.color, b.color, 0.5));
    });
  });
}
