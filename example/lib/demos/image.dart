import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class ImageDemoPage extends StatelessWidget {
  const ImageDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Image')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Default'),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(width: 48, height: 48, child: CNImage(systemSymbolName: 'heart')),
                SizedBox(width: 48, height: 48, child: CNImage(systemSymbolName: 'star')),
                SizedBox(width: 48, height: 48, child: CNImage(systemSymbolName: 'bell')),
                SizedBox(width: 48, height: 48, child: CNImage(systemSymbolName: 'figure.walk')),
              ],
            ),

            const SizedBox(height: 24),

            const Text('Monochrome colors'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 48, height: 48,
                  child: CNImage(
                    systemSymbolName: 'star.fill',
                    symbolConfiguration: CNSymbolConfiguration.monochrome(CupertinoColors.systemPink),
                  ),
                ),
                SizedBox(
                  width: 48, height: 48,
                  child: CNImage(
                    systemSymbolName: 'star.fill',
                    symbolConfiguration: CNSymbolConfiguration.monochrome(CupertinoColors.systemBlue),
                  ),
                ),
                SizedBox(
                  width: 48, height: 48,
                  child: CNImage(
                    systemSymbolName: 'star.fill',
                    symbolConfiguration: CNSymbolConfiguration.monochrome(CupertinoColors.systemGreen),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            const Text('Hierarchical'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 48, height: 48,
                  child: CNImage(
                    systemSymbolName: 'rectangle.and.pencil.and.ellipsis',
                    symbolConfiguration: CNSymbolConfiguration.hierarchical(CupertinoColors.systemBlue),
                  ),
                ),
                SizedBox(
                  width: 48, height: 48,
                  child: CNImage(
                    systemSymbolName: 'person.3.sequence',
                    symbolConfiguration: CNSymbolConfiguration.hierarchical(CupertinoColors.systemBlue),
                  ),
                ),
                SizedBox(
                  width: 48, height: 48,
                  child: CNImage(
                    systemSymbolName: 'speaker.wave.2.bubble',
                    symbolConfiguration: CNSymbolConfiguration.hierarchical(CupertinoColors.systemBlue),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            const Text('Palette'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                 SizedBox(
                  width: 48, height: 48,
                  child: CNImage(
                    systemSymbolName: 'person.3.sequence',
                    symbolConfiguration: CNSymbolConfiguration.palette(const [CupertinoColors.systemRed, CupertinoColors.systemGreen, CupertinoColors.systemBlue]),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            const Text('Multicolor'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 48, height: 48,
                  child: CNImage(
                    systemSymbolName: 'paintpalette.fill',
                    symbolConfiguration: CNSymbolConfiguration.multicolor(),
                  ),
                ),
                SizedBox(
                  width: 48, height: 48,
                  child: CNImage(
                    systemSymbolName: 'sun.rain.fill',
                    symbolConfiguration: CNSymbolConfiguration.multicolor(),
                  ),
                ),
                SizedBox(
                  width: 48, height: 48,
                  child: CNImage(
                    systemSymbolName: 'rainbow',
                    symbolConfiguration: CNSymbolConfiguration.multicolor(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
