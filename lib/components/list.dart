import 'package:flutter/cupertino.dart';

import '../theme/cn_theme.dart';

/// Chevron indicator commonly used in trailing slot for list rows.
class CNListTileChevron extends StatelessWidget {
  /// Creates a chevron indicator.
  const CNListTileChevron({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);
    return Text(
      '›',
      style: TextStyle(color: theme.secondaryLabelColor, fontSize: 22, fontWeight: FontWeight.w400),
    );
  }
}

/// A basic row tile for list-based navigation.
class CNListTile extends StatelessWidget {
  /// Creates a list tile.
  const CNListTile({
    super.key,
    this.leading,
    required this.title,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    this.selected = false,
  });

  /// Optional leading widget.
  final Widget? leading;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Content padding.
  final EdgeInsets padding;

  /// Whether the tile is selected.
  final bool selected;

  /// Main title widget.
  final Widget title;

  /// Optional trailing widget.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: padding,
        decoration: selected ? BoxDecoration(
          color: theme.accentColor,
          borderRadius: BorderRadius.circular(12),
        ) : null,
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: DefaultTextStyle(
                style: theme.typography.title3.copyWith(color: selected ? CupertinoColors.label.darkColor : isDark ? CupertinoColors.label.darkColor : CupertinoColors.label.color),
                child: title,
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// A grouped list section similar to desktop settings/catalog lists.
class CNListSection extends StatelessWidget {
  /// Creates an inset grouped list section.
  const CNListSection.insetGrouped({
    super.key,
    this.header,
    this.backgroundColor,
    required this.children,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  /// Section background color.
  final Color? backgroundColor;

  /// Row children.
  final List<Widget> children;

  /// Optional section header.
  final Widget? header;

  /// Outer margin.
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);
    final sectionColor = backgroundColor;

    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
              child: DefaultTextStyle(
                style: theme.typography.title1,
                child: header!,
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(color: sectionColor, borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }
}
