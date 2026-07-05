import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:cupertino_native_example/demos/pixel_perfect_probe.dart';
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                        enforcePixelPerfectPosition: true,
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                constraints: const BoxConstraints.expand(width: 350),
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
                    Row(
                      children: [
                        Expanded(child: const Text('Control Size')),
                        CNPicker(
                          selectedIndex: CNControlSize.values.indexOf(_controlSize),
                          onValueChanged: (index) => setState(() => _controlSize = CNControlSize.values[index]),
                          items: CNControlSize.values.map((size) => CNText(size.name)).toList(),
                          pickerStyle: CNPickerStyle.automatic,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(child: const Text('Button Style')),
                        CNPicker(
                          selectedIndex: CNToggleStyle.values.indexOf(_toggleStyle),
                          onValueChanged: (index) => setState(() => _toggleStyle = CNToggleStyle.values[index]),
                          items: CNToggleStyle.values.map((style) => CNText(style.name)).toList(),
                          pickerStyle: CNPickerStyle.automatic,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(child: const Text('Tint Color')),
                        CNPicker(
                          selectedIndex: kSystemColors.keys.toList().indexOf(
                            _tintColor == null
                                ? 'none'
                                : kSystemColors.entries.firstWhere((entry) => entry.value == _tintColor).key,
                          ),
                          onValueChanged: (index) => setState(() => _tintColor = kSystemColors.values.elementAt(index)),
                          items: kSystemColors.keys
                              .map(
                                (colorName) => CNLabel(
                                  CNText(colorName),
                                  icon: CNImage(
                                    systemSymbolName: 'circle.fill',
                                    modifiers: CNViewModifiers(tint: kSystemColors[colorName]),
                                  ),
                                ),
                              )
                              .toList(),
                          pickerStyle: CNPickerStyle.menu,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
