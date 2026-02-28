import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class ButtonDemoPage extends StatefulWidget {
  const ButtonDemoPage({super.key});

  @override
  State<ButtonDemoPage> createState() => _ButtonDemoPageState();
}

class _ButtonDemoPageState extends State<ButtonDemoPage> {
  String _last = 'None';
  ControlSize _controlSize = ControlSize.regular;
  bool _shrinkWrap = true;
  final List<ControlSize> _sizes = ControlSize.values;
  Color _color = CupertinoColors.systemBlue;

  void _set(String what) => setState(() => _last = what);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Button')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Text('Control Size'),
                const SizedBox(width: 12),
                CNPopupMenuButton.icon(
                  buttonIcon: const CNSymbol('chevron.down', size: 18),
                  buttonStyle: CNButtonStyle.plain,
                  size: 44.0,
                  items: _sizes
                      .map(
                        (e) => CNPopupMenuItem(
                          label: e.name,
                          checked: _controlSize == e,
                        ),
                      )
                      .toList(),
                  onSelected: (value) {
                    print("value: $value");
                    print("_sizes: ${_sizes}");
                    print("_sizes[value]: ${_sizes[value]}");

                    setState(() => _controlSize = _sizes[value]);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Text buttons'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                CNButton(
                  label: 'Plain',
                  style: CNButtonStyle.plain,
                  onPressed: () => _set('Plain'),
                  shrinkWrap: _shrinkWrap,
                  controlSize: _controlSize,
                ),
                CNButton(
                  label: 'Gray',
                  style: CNButtonStyle.gray,
                  onPressed: () => _set('Gray'),
                  shrinkWrap: _shrinkWrap,
                  controlSize: _controlSize,
                ),
                CNButton(
                  label: 'Tinted',
                  style: CNButtonStyle.tinted,
                  onPressed: () => _set('Tinted'),
                  shrinkWrap: _shrinkWrap,
                  controlSize: _controlSize,
                  tint: CupertinoTheme.of(context).primaryColor,
                ),
                CNButton(
                  label: 'Bordered',
                  style: CNButtonStyle.bordered,
                  onPressed: () => _set('Bordered'),
                  shrinkWrap: _shrinkWrap,
                  controlSize: _controlSize,
                ),
                CNButton(
                  label: 'BorderedProminent',
                  style: CNButtonStyle.borderedProminent,
                  onPressed: () => _set('BorderedProminent'),
                  shrinkWrap: _shrinkWrap,
                  controlSize: _controlSize,
                ),
                CNButton(
                  label: 'Filled',
                  style: CNButtonStyle.filled,
                  onPressed: () => _set('Filled'),
                  shrinkWrap: _shrinkWrap,
                  controlSize: _controlSize,
                ),
                CNButton(
                  label: 'Glass',
                  style: CNButtonStyle.glass,
                  onPressed: () => _set('Glass'),
                  shrinkWrap: _shrinkWrap,
                  controlSize: _controlSize,
                ),
                CNButton(
                  label: 'ProminentGlass',
                  style: CNButtonStyle.prominentGlass,
                  onPressed: () => _set('ProminentGlass'),
                  shrinkWrap: _shrinkWrap,
                  controlSize: _controlSize,
                ),
                CNButton(
                  label: 'Disabled',
                  style: CNButtonStyle.bordered,
                  onPressed: null,
                  shrinkWrap: _shrinkWrap,
                  controlSize: _controlSize,
                ),
              ],
            ),
            // const SizedBox(height: 48),
            // const Text('Icon buttons'),
            // const SizedBox(height: 12),
            // Wrap(
            //   spacing: 12,
            //   runSpacing: 12,
            //   alignment: WrapAlignment.center,
            //   children: [
            //     CNButton.icon(
            //       icon: const CNSymbol('heart.fill', size: 18),
            //       style: CNButtonStyle.plain,
            //       onPressed: () => _set('Icon Plain'),
            //     ),
            //     CNButton.icon(
            //       icon: const CNSymbol('heart.fill', size: 18),
            //       style: CNButtonStyle.gray,
            //       onPressed: () => _set('Icon Gray'),
            //     ),
            //     CNButton.icon(
            //       icon: const CNSymbol('heart.fill', size: 18),
            //       style: CNButtonStyle.tinted,
            //       onPressed: () => _set('Icon Tinted'),
            //     ),
            //     CNButton.icon(
            //       icon: const CNSymbol('heart.fill', size: 18),
            //       style: CNButtonStyle.bordered,
            //       onPressed: () => _set('Icon Bordered'),
            //     ),
            //     CNButton.icon(
            //       icon: const CNSymbol('heart.fill', size: 18),
            //       style: CNButtonStyle.borderedProminent,
            //       onPressed: () => _set('Icon BorderedProminent'),
            //     ),
            //     CNButton.icon(
            //       icon: const CNSymbol('heart.fill', size: 18),
            //       style: CNButtonStyle.filled,
            //       onPressed: () => _set('Icon Filled'),
            //     ),
            //     CNButton.icon(
            //       icon: const CNSymbol('heart.fill', size: 18),
            //       style: CNButtonStyle.glass,
            //       onPressed: () => _set('Icon Glass'),
            //     ),
            //     CNButton.icon(
            //       icon: const CNSymbol('heart.fill', size: 18),
            //       style: CNButtonStyle.prominentGlass,
            //       onPressed: () => _set('Icon ProminentGlass'),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 48),
            Center(child: Text('Last pressed: $_last')),

            const SizedBox(height: 48),
            const Text('Color well'),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 44.0,
                  height: 24.0,
                  child: CNColorWell(
                    color: _color,
                    style: CNColorWellStyle.regular,
                    onColorChanged: (color) {
                      print('Color changed: $color');
                      setState(() => _color = color);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                CNColorWell(
                  color: _color,
                  style: CNColorWellStyle.expanded,
                  onColorChanged: (color) {
                    print('Color changed: $color');
                    setState(() => _color = color);
                  },
                ),
                const SizedBox(width: 12),
                CNColorWell(
                  color: _color,
                  style: CNColorWellStyle.minimal,
                  supportsAlpha: false,
                  onColorChanged: (color) {
                    print('Color changed: $color');
                    setState(() => _color = color);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
