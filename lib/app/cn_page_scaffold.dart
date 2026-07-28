import 'package:flutter/widgets.dart';

import '../theme/cn_theme.dart';
import '../components/cn_navigation_bar.dart';

/// Desktop-aware page scaffold for Cupertino Native apps.
class CNPageScaffold extends StatelessWidget {
  /// Creates a page scaffold with optional navigation bar.
  const CNPageScaffold({
    super.key,
    this.navigationBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    required this.child,
  });

  /// Background color for the page.
  ///
  /// If null, this resolves to [CNTheme.of] `canvasColor`.
  final Color? backgroundColor;

  /// Main content area.
  final Widget child;

  /// Optional top navigation bar.
  final CNObstructingPreferredSizeWidget? navigationBar;

  /// Whether the body should avoid bottom insets like keyboard.
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final resolvedBackground = backgroundColor;
    final mediaQuery = MediaQuery.of(context);

    Widget paddedContent = child;

    if (navigationBar != null) {
      final topPadding = navigationBar!.preferredSize.height + mediaQuery.padding.top;
      final bottomPadding = resizeToAvoidBottomInset ? mediaQuery.viewInsets.bottom : 0.0;

      if (navigationBar!.shouldFullyObstruct(context)) {
        paddedContent = MediaQuery(
          data: mediaQuery
              .removePadding(removeTop: true)
              .copyWith(viewInsets: resizeToAvoidBottomInset ? mediaQuery.viewInsets.copyWith(bottom: 0.0) : mediaQuery.viewInsets),
          child: Padding(
            padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
            child: paddedContent,
          ),
        );
      } else {
        paddedContent = MediaQuery(
          data: mediaQuery.copyWith(
            padding: mediaQuery.padding.copyWith(top: topPadding),
            viewInsets: resizeToAvoidBottomInset ? mediaQuery.viewInsets.copyWith(bottom: 0.0) : mediaQuery.viewInsets,
          ),
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: paddedContent,
          ),
        );
      }
    } else if (resizeToAvoidBottomInset) {
      paddedContent = MediaQuery(
        data: mediaQuery.copyWith(viewInsets: mediaQuery.viewInsets.copyWith(bottom: 0)),
        child: Padding(
          padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
          child: paddedContent,
        ),
      );
    }

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(color: resolvedBackground),
        child: Stack(
          children: [
            paddedContent,
            if (navigationBar != null) Positioned(top: 0, left: 0, right: 0, child: navigationBar!),
          ],
        ),
      ),
    );
  }
}
