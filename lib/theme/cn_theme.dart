import 'package:flutter/cupertino.dart';

import 'cn_theme_data.dart';

/// Applies [CNThemeData] to a widget subtree.
class CNTheme extends StatelessWidget {
  /// Creates a theme wrapper for descendants.
  const CNTheme({super.key, required this.data, required this.child});

  /// Child subtree that receives this theme.
  final Widget child;

  /// Theme data exposed to descendants.
  final CNThemeData data;

  /// Returns nearest [CNThemeData], or fallback when absent.
  static CNThemeData of(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_InheritedCNTheme>();
    if (inherited != null) {
      return inherited.theme.data;
    }

    return CNThemeData.fallback(brightness: maybeBrightnessOf(context) ?? Brightness.light);
  }

  /// Returns nearest [CNThemeData], or null if absent.
  static CNThemeData? maybeOf(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_InheritedCNTheme>();
    return inherited?.theme.data;
  }

  /// Returns brightness from [CNTheme] or inherited platform brightness.
  static Brightness brightnessOf(BuildContext context) {
    return maybeBrightnessOf(context) ?? Brightness.light;
  }

  /// Returns brightness from [CNTheme] or [MediaQuery], nullable variant.
  static Brightness? maybeBrightnessOf(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<_InheritedCNTheme>();
    return inherited?.theme.data.brightness ?? MediaQuery.maybeOf(context)?.platformBrightness;
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedCNTheme(theme: this, child: child);
  }
}

class _InheritedCNTheme extends InheritedWidget {
  const _InheritedCNTheme({required this.theme, required super.child});

  final CNTheme theme;

  @override
  bool updateShouldNotify(_InheritedCNTheme oldWidget) {
    return theme.data != oldWidget.theme.data;
  }
}
