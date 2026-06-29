import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

const double _kDefaultPadding = 16.0;

/// Styles for the [GroupBox] widget, which can be either [GroupBoxStyle.border] or [GroupBoxStyle.borderless].
enum GroupBoxStyle {
  /// The default style for a GroupBox, which includes a border and background.
  borderless,

  /// A style that emphasizes the content without a border or background.
  border,
}

/// Similar to GroupBox in SwiftUI, this widget provides a visual grouping of related content with an optional title. It is typically used to group related form fields or settings in a visually distinct manner.
class GroupBox extends StatelessWidget {
  /// Creates a GroupBox with an optional [label] and required [child] content.
  const GroupBox({
    super.key,
    this.label,
    required this.child,
    this.style = GroupBoxStyle.border,
    this.padding,
    this.borderDecoration,
    this.color,
    this.borderRadius
  });

  /// An optional decoration for the border of the GroupBox.
  final BoxDecoration? borderDecoration;

  /// The border radius of the GroupBox. If not specified, it defaults to 8.0.
  /// If [borderDecoration] is provided, this value will be ignored.
  final double? borderRadius;

  /// The content to be grouped.
  final Widget child;

  /// The background color of the GroupBox. If not specified, it defaults to the system background color.
  /// If [borderDecoration] is provided, this color will be ignored.
  final Color? color;

  /// An optional label to display alongside the title.
  final Widget? label;

  /// The padding around the content of the GroupBox.
  final EdgeInsetsGeometry? padding;

  /// The visual style of the GroupBox, which can be either [GroupBoxStyle.border] or [GroupBoxStyle.borderless].
  final GroupBoxStyle style;

  BoxDecoration _decoration(BuildContext context) {
    switch (style) {
      case GroupBoxStyle.border:
        if (borderDecoration != null) {
          return borderDecoration!;
        }
        return BoxDecoration(
          color: color ?? CupertinoColors.tertiarySystemGroupedBackground,
          border: Border.all(color: CupertinoColors.separator.resolveFrom(context).withAlpha(51), width: 1),
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
        );
      case GroupBoxStyle.borderless:
        return const BoxDecoration();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _decoration(context),
      padding: padding ?? const EdgeInsets.all(_kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[label!, const SizedBox(height: 8)],
          child,
        ],
      ),
    );
  }
}
