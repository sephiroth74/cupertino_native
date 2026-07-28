import 'package:flutter/widgets.dart';

/// A Cupertino-Native page route replacement.
class CNPageRoute<T> extends PageRouteBuilder<T> {
  /// Creates a route with a subtle slide+fade transition.
  CNPageRoute({required WidgetBuilder builder, super.settings, super.fullscreenDialog})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => builder(context),
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);

          return FadeTransition(
            opacity: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.015, 0), end: Offset.zero).animate(curved),
              child: child,
            ),
          );
        },
      );
}
