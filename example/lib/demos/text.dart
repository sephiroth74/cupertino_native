import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class TextDemoPage extends StatelessWidget {
  const TextDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);

    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('CNText')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'CNText is the reusable SwiftUI text bridge used by future widgets.',
              style: theme.typography.body.copyWith(color: theme.labelColor),
            ),
            const SizedBox(height: 24),
            const Text('Default rendering', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const CNText('The quick brown fox jumps over the lazy dog.'),
            const SizedBox(height: 24),
            const Text('Custom font and color', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const CNText(
              'Monospaced title with a stronger accent color.',
              font: CNFont.monospacedSystem(CNFontSize.points(20), weight: CNFontWeight.semibold),
              color: CupertinoColors.systemBlue,
            ),
            const SizedBox(height: 24),
            const Text('Line limit and truncation', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const SizedBox(
              width: 120,
              child: CNText(
                'This sentence is intentionally long so the demo can show how a line limit and truncation behave when the available width is constrained.',
                lineLimit: 2,
                truncationMode: CNTextTruncationMode.tail,
                width: 120,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Reserved space', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const SizedBox(
              width: 320,
              child: CNText(
                'The widget can reserve space for multiple lines even when the content is short.',
                lineLimit: 2,
                lineLimitReservesSpace: true,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Text scale variants', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const CNText('Default scale', textScale: CNTextScale.defaultScale),
            const SizedBox(height: 8),
            const CNText('Secondary scale', textScale: CNTextScale.secondary),
            const SizedBox(height: 24),
            const Text('Reusable inside layout', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.groupedBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.separatorColor),
              ),
              child: const CNText(
                'This same widget can be embedded in future controls without coupling the payload model to the view wrapper.',
                width: 360,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
