import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../theme/cn_theme.dart';

/// A preferred-size widget that can tell whether it fully obstructs content.
abstract class CNObstructingPreferredSizeWidget implements PreferredSizeWidget {
  /// Whether this widget fully obstructs content behind it.
  bool shouldFullyObstruct(BuildContext context);
}

/// A Cupertino-Native navigation bar replacement.
class CNNavigationBar extends StatelessWidget implements CNObstructingPreferredSizeWidget {
  /// Creates a navigation bar.
  const CNNavigationBar({
    super.key,
    this.leading,
    this.middle,
    this.trailing,
    this.backgroundColor,
    this.enableBackgroundFilterBlur = false,
    this.height = 44,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  /// Optional background color.
  final Color? backgroundColor;

  /// Whether to apply a background blur layer.
  final bool enableBackgroundFilterBlur;

  /// Content height excluding top safe area.
  final double height;

  /// Leading widget.
  final Widget? leading;

  /// Middle/title widget.
  final Widget? middle;

  /// Horizontal padding.
  final EdgeInsets padding;

  /// Trailing widget.
  final Widget? trailing;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  bool shouldFullyObstruct(BuildContext context) {
    final resolved = backgroundColor;
    return resolved?.a == 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);
    final resolvedBackground = backgroundColor;
    final topInset = MediaQuery.of(context).padding.top;

    Widget bar = Container(
      color: resolvedBackground,
      padding: padding,
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            SizedBox(
              width: 160,
              child: Align(alignment: Alignment.topCenter, child: leading),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: DefaultTextStyle(
                  style: TextStyle(color: theme.labelColor, fontSize: 18, fontWeight: FontWeight.w600),
                  child: middle ?? const SizedBox.shrink(),
                ),
              ),
            ),
            SizedBox(
              width: 220,
              child: Align(alignment: Alignment.centerRight, child: trailing),
            ),
          ],
        ),
      ),
    );

    if (enableBackgroundFilterBlur) {
      bar = ClipRect(
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: bar),
      );
    }

    return SizedBox(
      height: topInset + height,
      child: Padding(
        padding: EdgeInsets.only(top: topInset),
        child: bar,
      ),
    );
  }
}

/// Back button matching the CN navigation bar style.
class CNNavigationBarBackButton extends StatelessWidget {
  /// Creates a back button.
  const CNNavigationBarBackButton({super.key, this.onPressed, this.label = 'Back'});

  /// Button label.
  final String label;

  /// Callback when pressed.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);
    final callback = onPressed ?? () => Navigator.of(context).maybePop();

    return GestureDetector(
      onTap: callback,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '‹',
            style: TextStyle(color: theme.primaryColor, fontSize: 22, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: theme.primaryColor, fontSize: 15)),
        ],
      ),
    );
  }
}
