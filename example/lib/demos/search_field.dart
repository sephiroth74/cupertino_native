import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

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
  final List<CNControlSize> _sizes = CNControlSize.values;
  final List<CNTextFieldBezelStyle> _bezelStyles = CNTextFieldBezelStyle.values;
  static const _demoFont = CNFont.monospacedSystem(
    CNFontSize.points(13),
    weight: CNFontWeight.medium,
  );

  CNControlSize _controlSize = CNControlSize.regular;
  CNTextFieldBezelStyle _bezelStyle = CNTextFieldBezelStyle.round;
  bool _suggestionsEnabled = true;
  String _query = '';
  String _submittedQuery = 'None';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Search Field')),
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
                  size: 44,
                  items: _sizes
                      .map(
                        (size) => CNPopupMenuItem(
                          label: size.name,
                          checked: _controlSize == size,
                        ),
                      )
                      .toList(),
                  onSelected: (value) {
                    setState(() => _controlSize = _sizes[value]);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Bezel Style'),
                const SizedBox(width: 12),
                CNPopupMenuButton.icon(
                  buttonIcon: const CNSymbol('chevron.down', size: 18),
                  buttonStyle: CNButtonStyle.plain,
                  size: 44,
                  items: _bezelStyles
                      .map(
                        (s) => CNPopupMenuItem(
                          label: s.name,
                          checked: _bezelStyle == s,
                        ),
                      )
                      .toList(),
                  onSelected: (value) {
                    setState(() => _bezelStyle = _bezelStyles[value]);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Suggestions'),
                const SizedBox(width: 12),
                CNSwitch(
                  value: _suggestionsEnabled,
                  onChanged: (v) => setState(() => _suggestionsEnabled = v),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Interactive'),
            const SizedBox(height: 12),
            CNSearchField(
              text: _query,
              placeholder: 'Search files, folders, or symbols',
              suggestions: _suggestionsEnabled ? _kDemoSuggestions : null,
              onSuggestionsRequested: (query) {
                if (query.isEmpty) return [];
                if (!_suggestionsEnabled) return const <String>[];
                if (query.isEmpty) return _kDemoSuggestions;
                final lower = query.toLowerCase();
                return _kDemoSuggestions
                    .where((item) => item.toLowerCase().contains(lower))
                    .toList();
              },
              controlSize: _controlSize,
              bezelStyle: _bezelStyle,
              width: 320,
              onChanged: (value) {
                setState(() => _query = value);
              },
              onSubmitted: (value) {
                setState(
                  () => _submittedQuery = value.isEmpty ? 'Empty query' : value,
                );
              },
            ),
            const SizedBox(height: 12),
            Text('Live query: ${_query.isEmpty ? 'Empty' : _query}'),
            Text('Last submitted: $_submittedQuery'),
            const SizedBox(height: 24),
            const Text('Styled'),
            const SizedBox(height: 12),
            CNSearchField(
              text: 'Build artifacts',
              placeholder: 'Search build outputs',
              placeholderColor: CupertinoColors.systemOrange,
              textColor: CupertinoColors.systemCyan,
              backgroundColor: CupertinoColors.activeBlue,
              font: _demoFont,
              bezelStyle: CNTextFieldBezelStyle.round,
              width: 320,
              onChanged: (value) {},
            ),
            const SizedBox(height: 24),
            const Text('Disabled'),
            const SizedBox(height: 12),
            const CNSearchField(
              text: 'Archived projects',
              placeholder: 'Disabled search',
              width: 320,
            ),
          ],
        ),
      ),
    );
  }
}
