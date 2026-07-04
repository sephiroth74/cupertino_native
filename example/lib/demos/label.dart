import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class LabelDemoPage extends StatelessWidget {
  const LabelDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Label')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('SwiftUI Label Examples'),
            const SizedBox(height: 12),
            const Text('Single text + icon'),
            const SizedBox(height: 12),
            const CNLabel(
              CNText('First'),
              icon: CNImage(systemSymbolName: 'bolt.fill'),
            ),
            const SizedBox(height: 12),
            const CNLabel(
              CNText('Second'),
              icon: CNImage(systemSymbolName: 'bolt.fill'),
            ),
            const SizedBox(height: 12),
            const Text('Two inner Text + optional Image'),
            const SizedBox(height: 12),
            Container(
              child: CNLabel(
                const CNText(
                  'Alessandro',
                  font: CNFont.system(CNFontSize.preset(CNFontSizePreset.system), weight: CNFontWeight.regular),
                  color: CupertinoColors.label,
                ),
                secondaryText: const CNText(
                  'Crugnola',
                  font: CNFont.system(CNFontSize.preset(CNFontSizePreset.smallSystem), weight: CNFontWeight.regular),
                  color: CupertinoColors.secondaryLabel,
                ),
                icon: const CNImage(systemSymbolName: 'microphone.fill', tint: CupertinoColors.systemBrown),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
