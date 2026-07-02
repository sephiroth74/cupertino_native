import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show ThemeMode;

import '../../theme/cn_theme.dart';
import '../../theme/cn_theme_data.dart';

/// App-level wrapper for desktop-first Cupertino Native applications.
///
/// This mirrors desktop app wrappers like macos_ui/AppKit style containers
/// while applying [CNThemeData] at the root.
class CNDesktopApp extends StatelessWidget {
  /// Creates a desktop app wrapper.
  const CNDesktopApp({
    super.key,
    required this.home,
    this.title = '',
    this.debugShowCheckedModeBanner = false,
    this.theme,
    this.themeMode = ThemeMode.system,
    this.navigatorKey,
    this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.localizationsDelegates,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.locale,
    this.builder,
  });

  /// Optional app-level transition builder.
  final TransitionBuilder? builder;

  /// Whether to show debug banner.
  final bool debugShowCheckedModeBanner;

  /// Root page widget.
  final Widget home;

  /// Initial route.
  final String? initialRoute;

  /// Locale override.
  final Locale? locale;

  /// Localization delegates.
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  /// Navigator key.
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Route generator.
  final RouteFactory? onGenerateRoute;

  /// Unknown route handler.
  final RouteFactory? onUnknownRoute;

  /// Named routes table.
  final Map<String, WidgetBuilder> routes;

  /// Supported locales.
  final Iterable<Locale> supportedLocales;

  /// Optional Cupertino Native theme data for the entire app.
  ///
  /// If omitted, a default [CNThemeData] is created from [themeMode].
  final CNThemeData? theme;

  /// Theme mode used to resolve the effective brightness.
  final ThemeMode themeMode;

  /// App title.
  final String title;

  Brightness _resolveBrightness() {
    switch (themeMode) {
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = _resolveBrightness();
    final resolvedTheme = (theme ?? CNThemeData.fallback(brightness: brightness)).copyWith(brightness: brightness);

    Widget app = WidgetsApp(
      title: title,
      color: resolvedTheme.primaryColor,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner,
      navigatorKey: navigatorKey,
      routes: routes,
      initialRoute: initialRoute,
      onGenerateRoute: onGenerateRoute,
      onUnknownRoute: onUnknownRoute,
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) {
        return PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionDuration: const Duration(milliseconds: 260),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
            return FadeTransition(opacity: Tween<double>(begin: 0.94, end: 1).animate(curved), child: child);
          },
        );
      },
      localizationsDelegates: localizationsDelegates,
      supportedLocales: supportedLocales,
      locale: locale,
      builder: builder,
      home: home,
    );

    app = CNTheme(data: resolvedTheme, child: app);

    return app;
  }
}
