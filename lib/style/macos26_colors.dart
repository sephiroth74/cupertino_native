import 'package:flutter/cupertino.dart';

/// macOS 26 (Liquid Glass era) color palette extracted from the
/// Apple community Figma file «macOS 26 — Community».
///
/// Each color is exposed as a [CupertinoDynamicColor] so it adapts
/// automatically to light / dark mode via [CupertinoDynamicColor.resolve].
///
/// Usage:
/// ```dart
/// final color = MacOS26Colors.red.resolveFrom(context);
/// ```
abstract final class MacOS26Colors {
  // -------------------------------------------------------------------------
  // Accent / Opaque Tint Colors
  // -------------------------------------------------------------------------

  /// Standard red accent — light: #FF4245 · dark: #FF383C
  static const CupertinoDynamicColor red = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFF4245),
    darkColor: Color(0xFFFF383C),
  );

  /// Standard orange accent — light: #FF9230 · dark: #FF8D28
  static const CupertinoDynamicColor orange = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFF9230),
    darkColor: Color(0xFFFF8D28),
  );

  /// Standard yellow accent — light: #FFD600 · dark: #FFCC00
  static const CupertinoDynamicColor yellow = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFFD600),
    darkColor: Color(0xFFFFCC00),
  );

  /// Standard green accent — light: #30D158 · dark: #34C759
  static const CupertinoDynamicColor green = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF30D158),
    darkColor: Color(0xFF34C759),
  );

  /// Standard mint accent — light: #00DAC3 · dark: #00C8B3
  static const CupertinoDynamicColor mint = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF00DAC3),
    darkColor: Color(0xFF00C8B3),
  );

  /// Standard teal accent — light: #00D2E0 · dark: #00C3D0
  static const CupertinoDynamicColor teal = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF00D2E0),
    darkColor: Color(0xFF00C3D0),
  );

  /// Standard cyan accent — light: #3CD3FE · dark: #00C0E8
  static const CupertinoDynamicColor cyan = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF3CD3FE),
    darkColor: Color(0xFF00C0E8),
  );

  /// Standard blue accent — light: #0091FF · dark: #0088FF
  static const CupertinoDynamicColor blue = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF0091FF),
    darkColor: Color(0xFF0088FF),
  );

  /// Standard indigo accent — light: #6D7CFF · dark: #6155F5
  static const CupertinoDynamicColor indigo = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF6D7CFF),
    darkColor: Color(0xFF6155F5),
  );

  /// Standard purple accent — light: #DB34F2 · dark: #CB30E0
  static const CupertinoDynamicColor purple = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFDB34F2),
    darkColor: Color(0xFFCB30E0),
  );

  /// Standard pink accent — light: #FF375F · dark: #FF2D55
  static const CupertinoDynamicColor pink = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFFF375F),
    darkColor: Color(0xFFFF2D55),
  );

  /// Standard brown accent — light: #B78A66 · dark: #AC7F5E
  static const CupertinoDynamicColor brown = CupertinoDynamicColor.withBrightness(
    color: Color(0xFFB78A66),
    darkColor: Color(0xFFAC7F5E),
  );

  /// Standard gray accent — light: #98989F · dark: #8E8E93
  static const CupertinoDynamicColor gray = CupertinoDynamicColor.withBrightness(
    color: Color(0xFF98989F),
    darkColor: Color(0xFF8E8E93),
  );

  // -------------------------------------------------------------------------
  // Fills — Opaque System Colors
  // These are semi-transparent overlays on top of backgrounds.
  // -------------------------------------------------------------------------

  /// Primary fill — light: black/10% · dark: white/10%
  static const CupertinoDynamicColor fillPrimary = CupertinoDynamicColor.withBrightness(
    color: Color(0x1A000000), // rgba(0,0,0,0.10)
    darkColor: Color(0x1AFFFFFF), // rgba(255,255,255,0.10)
  );

  /// Secondary fill — light: black/8% · dark: white/8%
  static const CupertinoDynamicColor fillSecondary = CupertinoDynamicColor.withBrightness(
    color: Color(0x14000000), // rgba(0,0,0,0.08)
    darkColor: Color(0x14FFFFFF), // rgba(255,255,255,0.08)
  );

  /// Tertiary fill — light: black/5% · dark: white/5%
  static const CupertinoDynamicColor fillTertiary = CupertinoDynamicColor.withBrightness(
    color: Color(0x0D000000), // rgba(0,0,0,0.05)
    darkColor: Color(0x0DFFFFFF), // rgba(255,255,255,0.05)
  );

  /// Quaternary fill — light: black/3% · dark: white/3%
  static const CupertinoDynamicColor fillQuaternary = CupertinoDynamicColor.withBrightness(
    color: Color(0x08000000), // rgba(0,0,0,0.03)
    darkColor: Color(0x08FFFFFF), // rgba(255,255,255,0.03)
  );

  /// Quinary fill — light: black/2% · dark: white/2%
  static const CupertinoDynamicColor fillQuinary = CupertinoDynamicColor.withBrightness(
    color: Color(0x05000000), // rgba(0,0,0,0.02)
    darkColor: Color(0x05FFFFFF), // rgba(255,255,255,0.02)
  );

  // -------------------------------------------------------------------------
  // Convenience: all accent colors as a list (same order as Figma palette)
  // -------------------------------------------------------------------------

  /// All accent colors in palette order:
  /// red, orange, yellow, green, mint, teal, cyan, blue, indigo, purple, pink, brown, gray.
  static const List<CupertinoDynamicColor> accents = [
    red,
    orange,
    yellow,
    green,
    mint,
    teal,
    cyan,
    blue,
    indigo,
    purple,
    pink,
    brown,
    gray,
  ];

  /// All fill levels in order from most opaque to least opaque.
  static const List<CupertinoDynamicColor> fills = [fillPrimary, fillSecondary, fillTertiary, fillQuaternary, fillQuinary];
}
