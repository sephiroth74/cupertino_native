import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class LabelDemoPage extends StatelessWidget {
  const LabelDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Label')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Native SwiftUI Label'),
            const SizedBox(height: 12),
            const CNLabel(text: 'Simple label'),
            const SizedBox(height: 12),
            const CNLabel(text: 'Label with icon', icon: CNSymbol('star.fill', size: 18)),
            const SizedBox(height: 12),
            CNLabel(text: 'Colored label', icon: const CNSymbol('heart.fill', size: 18), color: CupertinoColors.systemPink),
            const SizedBox(height: 12),
            const CNLabel(text: 'Title only', icon: CNSymbol('moon.fill', size: 18), labelStyle: CNLabelStyle.titleOnly),
            const SizedBox(height: 12),
            const CNLabel(text: 'Icon only', icon: CNSymbol('sun.max.fill', size: 18), labelStyle: CNLabelStyle.iconOnly),
            const SizedBox(height: 12),
            CNLabel(
              text: 'Custom font',
              icon: const CNSymbol('textformat', size: 18),
              color: CupertinoColors.systemBlue,
              font: const CNFont.system(CNFontSize.points(18), weight: CNFontWeight.semibold),
            ),
          ],
        ),
      ),
    );
  }
}
