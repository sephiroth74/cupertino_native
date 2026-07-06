import 'package:cupertino_native/theme/cn_theme.dart';
import 'package:flutter/cupertino.dart';

class RightSideOptionContainer extends StatelessWidget {
  const RightSideOptionContainer({super.key, this.title, required this.options});

  final Map<String, Widget> options;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 350,
        decoration: BoxDecoration(
          color: CNTheme.of(context).fillPrimaryColor,
          border: Border.all(color: CNTheme.of(context).separatorColor, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(title!, style: CNTheme.of(context).typography.title1),
              ),
            if (options.isNotEmpty) ...[
              const SizedBox(height: 16),
              for (var entry in options.entries)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(child: Text(entry.key)),
                      entry.value,
                    ],
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
