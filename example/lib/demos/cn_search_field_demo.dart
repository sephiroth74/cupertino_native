import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/common_widgets.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';

const _kDebugLog = false;

class _DemoFile {
  const _DemoFile(this.name, this.section, this.kind, this.symbol, this.color);

  final Color color;
  final String kind;
  final String name;
  final String section;
  final String symbol;
}

const _kDemoFiles = [
  _DemoFile(
    'AppDelegate.swift',
    'Swift Sources',
    'Application entry point',
    'swift',
    CNColors.orange,
  ),
  _DemoFile(
    'ContentView.swift',
    'Swift Sources',
    'SwiftUI view',
    'swift',
    CNColors.orange,
  ),
  _DemoFile(
    'ViewController.swift',
    'Swift Sources',
    'AppKit controller',
    'swift',
    CNColors.orange,
  ),
  _DemoFile(
    'SceneDelegate.swift',
    'Swift Sources',
    'Scene lifecycle',
    'swift',
    CNColors.orange,
  ),
  _DemoFile(
    'LaunchScreen.storyboard',
    'Interface',
    'Storyboard',
    'rectangle.on.rectangle',
    CNColors.blue,
  ),
  _DemoFile(
    'Main.storyboard',
    'Interface',
    'Storyboard',
    'rectangle.on.rectangle',
    CNColors.blue,
  ),
  _DemoFile(
    'Assets.xcassets',
    'Interface',
    'Asset catalog',
    'photo.on.rectangle.angled',
    CNColors.blue,
  ),
  _DemoFile(
    'Info.plist',
    'Configuration',
    'Property list',
    'list.bullet.rectangle',
    CNColors.systemGray,
  ),
  _DemoFile(
    'Podfile',
    'Configuration',
    'CocoaPods manifest',
    'shippingbox',
    CNColors.systemGray,
  ),
  _DemoFile(
    'Package.swift',
    'Configuration',
    'SwiftPM manifest',
    'shippingbox',
    CNColors.systemGray,
  ),
  _DemoFile(
    'README.md',
    'Configuration',
    'Documentation',
    'doc.text',
    CNColors.systemGray,
  ),
];

const _kSectionOrder = ['Swift Sources', 'Interface', 'Configuration'];

class SearchFieldDemoPage extends StatefulWidget {
  const SearchFieldDemoPage({super.key});

  @override
  State<SearchFieldDemoPage> createState() => _SearchFieldDemoPageState();
}

class _SearchFieldDemoPageState extends State<SearchFieldDemoPage> {
  final TextEditingController controller = TextEditingController();

  CNTextFieldBezelStyle bezelStyle = CNTextFieldBezelStyle.round;
  Color? borderColor;
  double borderWidth = 0.0;
  CNControlSize controlSize = CNControlSize.regular;
  double cornerRadius = 0.0;
  CNFont? font;
  double fontSize = 24.0;
  bool isEnabled = true;
  String? lastPicked;
  Color? placeholderColor;
  bool showImages = true;
  bool showSectionTitles = true;
  bool showSecondaryTitles = true;
  Color? textColor;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  CNPixelPerfectContainer(
                    child: CNSearchField(
                      debugLog: _kDebugLog,
                      controller: controller,
                      font: font,
                      controlSize: controlSize,
                      bezelStyle: bezelStyle,
                      borderColor: borderColor,
                      borderWidth: borderWidth,
                      cornerRadius: cornerRadius,
                      placeholderColor: placeholderColor,
                      textColor: textColor,
                      enabled: isEnabled,
                      placeholder: 'Search for a file...',
                      onChanged: (value) {
                        debugPrint('Search field text changed: $value');
                      },
                      onSubmitted: (value) {
                        debugPrint('Search field text submitted: $value');
                      },
                      onSuggestionSelected: (item) {
                        debugPrint('Suggestion selected: ${item.title}');
                        setState(() => lastPicked = item.title);
                      },
                      onSuggestionsRequested: _suggestionsFor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CNButton(
                        children: const [CNChildText('Clear')],
                        onPressed: () => controller.clear(),
                      ),
                      const SizedBox(width: 12),
                      CNButton(
                        children: const [CNChildText('Set "Package.swift"')],
                        onPressed: () => controller.text = 'Package.swift',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CNText(
                    lastPicked == null
                        ? 'No suggestion picked yet.'
                        : 'Last picked suggestion: $lastPicked',
                  ),
                ],
              ),
            ),
          ),
          RightSideOptionContainer(
            title: 'Options',
            options: {
              'Control Size': ControlSizePicker(
                value: controlSize,
                onChanged: (v) => setState(() => controlSize = v),
              ),
              'Bezel Style': BezelStylePicker(
                value: bezelStyle,
                onChanged: (v) => setState(() => bezelStyle = v),
              ),
              'Border Color': ColorPicker(
                colors: kSystemColors,
                value: borderColor,
                onChanged: (color) => setState(() => borderColor = color),
              ),
              'Border Width': SizeSliderPicker(
                value: borderWidth,
                min: 0.0,
                max: 6.0,
                onChanged: (v) => setState(() => borderWidth = v),
              ),
              'Corner Radius': SizeSliderPicker(
                value: cornerRadius,
                min: 0.0,
                max: 20.0,
                onChanged: (v) => setState(() => cornerRadius = v),
              ),
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
                onChanged: (f) => setState(
                  () => font = f?.copyWith(size: CNFontSize.points(fontSize)),
                ),
              ),
              'Font Size': SizeSliderPicker(
                value: fontSize,
                min: 8.0,
                max: 72.0,
                onChanged: (newSize) => setState(() {
                  fontSize = newSize;
                  if (font != null) {
                    font = font!.copyWith(size: CNFontSize.points(fontSize));
                  }
                }),
              ),
              'Section Titles': CNToggle(
                isOn: showSectionTitles,
                controlSize: CNControlSize.regular,
                onChanged: (v) => setState(() => showSectionTitles = v),
              ),
              'Secondary Titles': CNToggle(
                isOn: showSecondaryTitles,
                controlSize: CNControlSize.regular,
                onChanged: (v) => setState(() => showSecondaryTitles = v),
              ),
              'Suggestion Images': CNToggle(
                isOn: showImages,
                controlSize: CNControlSize.regular,
                onChanged: (v) => setState(() => showImages = v),
              ),
              'Enabled': CNToggle(
                isOn: isEnabled,
                controlSize: CNControlSize.regular,
                onChanged: (v) => setState(() => isEnabled = v),
              ),
            },
          ),
        ],
      ),
    );
  }

  List<CNSuggestionSection> _suggestionsFor(String query) {
    debugPrint('onSuggestionsRequested for query: "$query"');
    if (query.isEmpty) return const [];

    final needle = query.toLowerCase();
    final matches = _kDemoFiles.where(
      (file) => file.name.toLowerCase().contains(needle),
    );

    return _kSectionOrder
        .map((section) {
          final items = matches
              .where((file) => file.section == section)
              .map(
                (file) => CNSuggestionItem(
                  title: file.name,
                  secondaryTitle: showSecondaryTitles ? file.kind : null,
                  systemImage: showImages ? file.symbol : null,
                  imageColor: file.color,
                  help: '${file.section} — ${file.kind}',
                ),
              )
              .toList();
          return CNSuggestionSection(
            title: showSectionTitles ? section : null,
            items: items,
          );
        })
        .where((section) => section.items.isNotEmpty)
        .toList();
  }
}
