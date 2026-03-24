import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class ColorWellDemoPage extends StatefulWidget {
  const ColorWellDemoPage({super.key});

  @override
  State<ColorWellDemoPage> createState() => _ColorWellDemoPageState();
}

class _ColorWellDemoPageState extends State<ColorWellDemoPage> {
  Color _color = CupertinoColors.systemBlue;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Color Well')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Styles'),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 44,
                  height: 24,
                  child: CNColorWell(
                    color: _color,
                    style: CNColorWellStyle.regular,
                    onColorChanged: (color) {
                      setState(() => _color = color);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                CNColorWell(
                  color: _color,
                  style: CNColorWellStyle.expanded,
                  onColorChanged: (color) {
                    setState(() => _color = color);
                  },
                ),
                const SizedBox(width: 12),
                CNColorWell(
                  color: _color,
                  style: CNColorWellStyle.minimal,
                  supportsAlpha: false,
                  onColorChanged: (color) {
                    setState(() => _color = color);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Current color preview'),
            const SizedBox(height: 12),
            Container(
              height: 64,
              decoration: BoxDecoration(
                color: _color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: CupertinoColors.separator),
              ),
            ),
            const SizedBox(height: 12),
            Text('ARGB: 0x${_color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}'),
          ],
        ),
      ),
    );
  }
}
