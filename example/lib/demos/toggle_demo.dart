import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ToggleDemo extends StatefulWidget {
  const ToggleDemo({super.key});

  @override
  State<ToggleDemo> createState() => _ToggleDemoState();
}

class _ToggleDemoState extends State<ToggleDemo> {
  bool _darkMode = false;
  CNToggleStyle _toggleStyle = CNToggleStyle.switch_;
  Color? _tintColor;
  CNControlSize _controlSize = CNControlSize.regular;

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
                      child: CNToggle(
                        value: _darkMode,
                        toggleStyle: _toggleStyle,
                        controlSize: _controlSize,
                        tint: _tintColor,
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
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                constraints: BoxConstraints.expand(width: 350),
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
                          items: CNControlSize.values.map((size) => CNPickerItem(size.name)).toList(),
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
                          items: CNToggleStyle.values.map((style) => CNPickerItem(style.name)).toList(),
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
                                (colorName) =>
                                    CNPickerItem(colorName, icon: CNSymbol("circle.fill", color: kSystemColors[colorName])),
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
