import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:cupertino_native/widgets/pixel_perfect_probe.dart';
import 'package:flutter/material.dart';

class ToggleDemo extends StatefulWidget {
  const ToggleDemo({super.key});

  @override
  State<ToggleDemo> createState() => _ToggleDemoState();
}

class _ToggleDemoState extends State<ToggleDemo> {
  CNControlSize _controlSize = CNControlSize.regular;
  bool _darkMode = false;
  FlutterPixelGeometry? _flutterGeometry;
  Color? _tintColor;
  CNToggleStyle _toggleStyle = CNToggleStyle.switch_;

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(milliseconds: 800)));
  }

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Toggle Demo')),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Switch Style Toggle', style: CNTheme.of(context).typography.title2),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: PixelPerfectProbe(
                        adjustPosition: true,
                        onGeometryChanged: (geometry) {
                          setState(() {
                            _flutterGeometry = geometry;
                          });
                        },
                        child: CNToggle(
                          value: _darkMode,
                          toggleStyle: _toggleStyle,
                          modifiers: CNViewModifiers(controlSize: _controlSize, tint: _tintColor),
                          onChanged: (value) {
                            setState(() {
                              _darkMode = value;
                            });
                            _showNotification('Dark Mode ${value ? "enabled" : "disabled"}');
                          },
                          children: const [
                            CNText('Dark Mode'),
                            CNText('Enable dark mode for the app'),
                            CNImage(systemSymbolName: 'moon.fill'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_flutterGeometry != null)
                      SelectableText(
                        'Flutter geometry (snapped): '
                        'x=${_flutterGeometry!.x.toStringAsFixed(2)}, '
                        'y=${_flutterGeometry!.y.toStringAsFixed(2)}, '
                        'w=${_flutterGeometry!.width.toStringAsFixed(2)}, '
                        'h=${_flutterGeometry!.height.toStringAsFixed(2)}\n'
                        'physical=(${_flutterGeometry!.physicalX.toStringAsFixed(2)}, ${_flutterGeometry!.physicalY.toStringAsFixed(2)}, '
                        '${_flutterGeometry!.physicalWidth.toStringAsFixed(2)}, ${_flutterGeometry!.physicalHeight.toStringAsFixed(2)}), '
                        'dpr=${_flutterGeometry!.devicePixelRatio.toStringAsFixed(2)}\n'
                        'pixelAligned: '
                        'x=${_flutterGeometry!.pixelAlignedX}, '
                        'y=${_flutterGeometry!.pixelAlignedY}, '
                        'w=${_flutterGeometry!.pixelAlignedWidth}, '
                        'h=${_flutterGeometry!.pixelAlignedHeight}',
                        style: CNTheme.of(context).typography.body.copyWith(color: CNTheme.of(context).secondaryLabelColor),
                      ),
                  ],
                ),
              ),
            ),
            RightSideOptionContainer(
              options: {
                'Control Size': CNPicker(
                  pickerStyle: CNPickerStyle.menu,
                  selectedIndex: CNControlSize.values.indexOf(_controlSize),
                  onValueChanged: (index) => setState(() => _controlSize = CNControlSize.values[index]),
                  items: CNControlSize.values.map((size) => CNText(size.name)).toList(),
                ),
                'Toggle Style': CNPicker(
                  pickerStyle: CNPickerStyle.menu,
                  selectedIndex: CNToggleStyle.values.indexOf(_toggleStyle),
                  onValueChanged: (index) => setState(() => _toggleStyle = CNToggleStyle.values[index]),
                  items: CNToggleStyle.values.map((style) => CNText(style.name)).toList(),
                ),
                'Tint Color': ColorPicker(
                  colors: kSystemColors,
                  currentValue: _tintColor,
                  onValueChanged: (index) => setState(() => _tintColor = kSystemColors.values.elementAt(index)),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
