import 'package:flutter/widgets.dart';

import '../components/cn_toolbar.dart';

/// Desktop-aware page scaffold for Cupertino Native apps.
///
/// Reserves top padding for an optional [toolBar] and overlays the bar on top of
/// the [child], mirroring `appkit_ui_elements`' `AppKitScaffold`.
class CNPageScaffold extends StatelessWidget {
  /// Creates a page scaffold with an optional Flutter toolbar.
  const CNPageScaffold({
    super.key,
    this.toolBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    required this.child,
  });

  /// Background color for the page.
  ///
  /// If null, the page is transparent (the enclosing window paints the background).
  final Color? backgroundColor;

  /// Main content area.
  final Widget child;

  /// Whether the body should avoid bottom insets like the keyboard.
  final bool resizeToAvoidBottomInset;

  /// Optional Flutter toolbar overlaid at the top of the page.
  final CNToolbar? toolBar;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    Widget paddedContent = child;

    if (toolBar != null) {
      final topPadding = toolBar!.preferredSize.height + mediaQuery.padding.top;
      final bottomPadding = resizeToAvoidBottomInset ? mediaQuery.viewInsets.bottom : 0.0;

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
        decoration: BoxDecoration(color: backgroundColor),
        child: Stack(
          children: [
            paddedContent,
            if (toolBar != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: toolBar!.preferredSize.height,
                child: toolBar!,
              ),
          ],
        ),
      ),
    );
  }
}
