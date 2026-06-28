import 'package:cupertino_native/components/image.dart';
import 'package:flutter/widgets.dart';

/// Similar to GroupBox in SwiftUI, this widget provides a visual grouping of related content with an optional title. It is typically used to group related form fields or settings in a visually distinct manner.

class GroupBox extends StatelessWidget {
  const GroupBox({super.key, this.title, this.icon, required this.child});

  /// The content to be grouped.
  final Widget child;

  /// An optional icon to display alongside the title.
  final CNImage? icon;

  /// The title of the group box.
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFB0B0B0)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || icon != null)
            Row(
              children: [
                if (icon != null) icon!,
                if (icon != null && title != null) const SizedBox(width: 4),
                if (title != null)
                  Text(
                    title!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          if (title != null || icon != null) const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}