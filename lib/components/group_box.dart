import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

enum GroupBoxStyle {
  /// The default style for a GroupBox, which includes a border and background.
  borderless,

  /// A style that emphasizes the content without a border or background.
  border,
}

/// Similar to GroupBox in SwiftUI, this widget provides a visual grouping of related content with an optional title. It is typically used to group related form fields or settings in a visually distinct manner.
class GroupBox extends StatelessWidget {
  /// Creates a GroupBox with an optional [label] and required [child] content.
  const GroupBox({super.key, this.label, required this.child, this.padding = const EdgeInsets.all(8.0), this.style = GroupBoxStyle.border});

  /// Creates a GroupBox with a [label] and required [child] content.
  factory GroupBox.label(String label, {required Widget child, EdgeInsetsGeometry padding = const EdgeInsets.all(8.0)}) {
    return GroupBox(
      label: CNLabel(text: label),
      padding: padding,
      style: GroupBoxStyle.border,
      child: child,
    );
  }

  final GroupBoxStyle style;

  /// The content to be grouped.
  final Widget child;

  /// An optional label to display alongside the title.
  final CNLabel? label;

  /// The padding around the content of the GroupBox.
  final EdgeInsetsGeometry padding;

  BoxDecoration _decoration(BuildContext context) {
    switch (style) {
      case GroupBoxStyle.border:
        return BoxDecoration(
          color: CupertinoColors.tertiarySystemGroupedBackground,
          border: Border.all(color: CupertinoColors.separator.resolveFrom(context).withAlpha(51), width: 1),
          borderRadius: BorderRadius.circular(8),
        );
      case GroupBoxStyle.borderless:
        return const BoxDecoration();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _decoration(context),
      padding: const EdgeInsets.all(8),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null) ...[label!, const SizedBox(height: 8)],
            child,
          ],
        ),
      ),
    );
  }
}
