import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

const _kDebugLog = true;

const _kDemoSuggestions = [
  'AppDelegate.swift',
  'ContentView.swift',
  'ViewController.swift',
  'SceneDelegate.swift',
  'Info.plist',
  'Assets.xcassets',
  'LaunchScreen.storyboard',
  'Main.storyboard',
  'Podfile',
  'Package.swift',
  'README.md',
];

class SearchFieldDemoPage extends StatefulWidget {
  const SearchFieldDemoPage({super.key});

  @override
  State<SearchFieldDemoPage> createState() => _SearchFieldDemoPageState();
}

class _SearchFieldDemoPageState extends State<SearchFieldDemoPage> {
  CNTextFieldBezelStyle bezelStyle = CNTextFieldBezelStyle.round;
  CNControlSize controlSize = CNControlSize.regular;
  CNFont? font;
  double fontSize = 24.0;
  bool isEnabled = true;
  Color? placeholderColor;
  String? text;
  Color? textColor;

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Search Field')),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CNSearchField2(
                      debugLog: _kDebugLog,
                      text: text,
                      font: font,
                      controlSize: controlSize,
                      bezelStyle: bezelStyle,
                      placeholderColor: placeholderColor,
                      textColor: textColor,
                      onChanged: isEnabled
                          ? (value) {
                              debugPrint('Search field text changed: $value');
                              setState(() {
                                text = value;
                              });
                            }
                          : null,
                      onSubmitted: isEnabled
                          ? (value) {
                              debugPrint('Search field text submitted: $value');
                            }
                          : null,
                      placeholder: 'Search for a file...',
                      onSuggestionsRequested: (query) {
                        debugPrint('onSuggestionsRequested for query: "$query"');
                        if (query.isEmpty) {
                          debugPrint('Returning all suggestions');
                          return Future.value(_kDemoSuggestions);
                        } else {
                          debugPrint('Filtering suggestions for query: "$query"');
                          return Future.value(
                            _kDemoSuggestions.where((s) => s.toLowerCase().contains(query.toLowerCase())).toList(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            RightSideOptionContainer(
              title: 'Options',
              options: {
                'Control Size': ControlSizePicker(value: controlSize, onChanged: (v) => setState(() => controlSize = v)),
                'Bezel Style': BezelStylePicker(value: bezelStyle, onChanged: (v) => setState(() => bezelStyle = v)),
                'Text Color': ColorPicker(
                  colors: kSystemColors,
                  value: textColor,
                  onChanged: (color) => setState(() => textColor = color),
                ),
                'Placeholder Color': ColorPicker(
                  colors: kSystemColors,
                  value: placeholderColor,
                  onChanged: (color) => setState(() => placeholderColor = color),
                ),
                'Font': FontPicker(
                  fonts: kAvailableFonts,
                  value: font,
                  onChanged: (f) => setState(() => font = f?.copyWith(size: CNFontSize.points(fontSize))),
                ),
                'Font Size': Row(
                  children: [
                    Expanded(child: Text('${fontSize.toStringAsFixed(0)} pt', style: const TextStyle(fontSize: 16))),
                    CNStepper2(
                      value: fontSize,
                      min: 8.0,
                      max: 72.0,
                      step: 1.0,
                      onChanged: font != null
                          ? (v) => setState(() {
                              fontSize = v;
                              if (font != null) {
                                font = font!.copyWith(size: CNFontSize.points(fontSize));
                              }
                            })
                          : null,
                    ),
                  ],
                ),
                'Enabled': CNToggle2(
                  isOn: isEnabled,
                  toggleStyle: CNToggle2Style.switchStyle,
                  controlSize: CNControlSize.regular,
                  onChanged: (v) => setState(() => isEnabled = v),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
