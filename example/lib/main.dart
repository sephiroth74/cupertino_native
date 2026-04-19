import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'demos/slider.dart';
import 'demos/switch.dart';
import 'demos/segmented_control.dart';
import 'demos/tab_bar.dart';
import 'demos/icon.dart';
import 'demos/image.dart';
import 'demos/popup_menu_button.dart';
import 'demos/button.dart';
import 'demos/combo_button.dart';
import 'demos/color_well.dart';
import 'demos/path_control.dart';
import 'demos/progress_indicators.dart';
import 'demos/level_indicators.dart';
import 'demos/stepper.dart';
import 'demos/checkboxes.dart';
import 'demos/date_picker.dart';
import 'demos/search_field.dart';
import 'demos/text_field.dart';
import 'demos/secure_text_field.dart';
import 'demos/combo_box.dart';
import 'demos/alert.dart';
import 'demos/popover.dart';
import 'demos/context_menu.dart';
import 'demos/sheet.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  Color _accentColor = CupertinoColors.systemBlue;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _setAccentColor(Color color) {
    setState(() {
      _accentColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: _accentColor,
      ),
      home: HomePage(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
        accentColor: _accentColor,
        onSelectAccentColor: _setAccentColor,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.accentColor,
    required this.onSelectAccentColor,
  });

  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final Color accentColor;
  final ValueChanged<Color> onSelectAccentColor;

  static const _systemColors = <MapEntry<String, Color>>[
    MapEntry('Red', CupertinoColors.systemRed),
    MapEntry('Orange', CupertinoColors.systemOrange),
    MapEntry('Yellow', CupertinoColors.systemYellow),
    MapEntry('Green', CupertinoColors.systemGreen),
    MapEntry('Teal', CupertinoColors.systemTeal),
    MapEntry('Blue', CupertinoColors.systemBlue),
    MapEntry('Indigo', CupertinoColors.systemIndigo),
    MapEntry('Purple', CupertinoColors.systemPurple),
    MapEntry('Pink', CupertinoColors.systemPink),
    MapEntry('Gray', CupertinoColors.systemGrey),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        enableBackgroundFilterBlur: true,
        backgroundColor: CupertinoColors.systemGroupedBackground,
        middle: const Text('Cupertino Native'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CNComboButton(
              controlSize: CNControlSize.regular,
              style: CNComboButtonStyle.split,
              title: 'Accent Color',
              image: CNImage(
                systemSymbolName: 'circle.fill',
                symbolConfiguration: CNSymbolConfiguration.monochrome(
                  accentColor,
                ),
              ),
              menu: CNMenu(
                items: _systemColors.map((entry) {
                  return CNMenuItem(
                    title: entry.key,
                    image: CNImage(
                      systemSymbolName: 'circle.fill',
                      symbolConfiguration: CNSymbolConfiguration.monochrome(
                        entry.value,
                      ),
                    ),
                    state: accentColor == entry.value
                        ? CNMenuItemState.on
                        : CNMenuItemState.off,
                    tag: entry.value.toARGB32(),
                    enabled: true,
                  );
                }).toList(),
              ),
              onPressed: (value) {
                debugPrint('onPressed($value)');
              },
              onMenuItemSelected: (value) {
                final selectedColor = Color(value.tag as int);
                onSelectAccentColor(selectedColor);
              },
            ),
            const SizedBox(width: 8),
            CNButton.icon(
              icon: CNSymbol(isDarkMode ? 'sun.max' : 'moon', size: 18),
              onPressed: onToggleTheme,
            ),
          ],
        ),
      ),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          CupertinoListSection.insetGrouped(
            header: Text('Components'),
            children: [
              CupertinoListTile(
                title: Text('Slider'),
                leading: CNIcon(
                  symbol: CNSymbol('slider.horizontal.3', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const SliderDemoPage()),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Switch'),
                leading: CNIcon(
                  symbol: CNSymbol('switch.2', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const SwitchDemoPage()),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Checkbox'),
                leading: CNIcon(
                  symbol: CNSymbol('checkmark.square', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const CheckboxDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Segmented Control'),
                leading: CNIcon(
                  symbol: CNSymbol('rectangle.split.3x1', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const SegmentedControlDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Icon'),
                leading: CNIcon(symbol: CNSymbol('app', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const IconDemoPage()),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Image'),
                leading: CNIcon(symbol: CNSymbol('photo', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const ImageDemoPage()),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Popup Menu Button'),
                leading: CNIcon(
                  symbol: CNSymbol('ellipsis.circle', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const PopupMenuButtonDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Button'),
                leading: CNIcon(
                  symbol: CNSymbol('hand.tap', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const ButtonDemoPage()),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Combo Button'),
                leading: CNIcon(
                  symbol: CNSymbol('chevron.down.square', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const ComboButtonDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Color Well'),
                leading: CNIcon(
                  symbol: CNSymbol('paintpalette', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const ColorWellDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Path Control'),
                leading: CNIcon(symbol: CNSymbol('folder', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const PathControlDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Progress Indicators'),
                leading: CNIcon(
                  symbol: CNSymbol('hourglass', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const ProgressIndicatorsPageDemo(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Level Indicators'),
                leading: CNIcon(symbol: CNSymbol('gauge', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const LevelIndicatorDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Steppers'),
                leading: CNIcon(
                  symbol: CNSymbol('plusminus', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const StepperDemoPage()),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Date Picker'),
                leading: CNIcon(
                  symbol: CNSymbol('calendar', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const DatePickerDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Search Field'),
                leading: CNIcon(
                  symbol: CNSymbol('magnifyingglass', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const SearchFieldDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Text Field'),
                leading: CNIcon(
                  symbol: CNSymbol(
                    'character.cursor.ibeam',
                    color: accentColor,
                  ),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const TextFieldDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Secure Text Field'),
                leading: CNIcon(
                  symbol: CNSymbol('lock.shield', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const SecureTextFieldDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Combo Box'),
                leading: CNIcon(
                  symbol: CNSymbol('list.bullet.rectangle', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const ComboBoxDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Alert'),
                leading: CNIcon(
                  symbol: CNSymbol(
                    'exclamationmark.bubble',
                    color: accentColor,
                  ),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const AlertDemoPage()),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Popover'),
                leading: CNIcon(
                  symbol: CNSymbol(
                    'rectangle.on.rectangle',
                    color: accentColor,
                  ),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const PopoverDemoPage()),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Context Menu'),
                leading: CNIcon(
                  symbol: CNSymbol('ellipsis.rectangle', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const ContextMenuDemoPage(),
                    ),
                  );
                },
              ),
              CupertinoListTile(
                title: Text('Sheet'),
                leading: CNIcon(
                  symbol: CNSymbol(
                    'square.and.line.vertical.and.square',
                    color: accentColor,
                  ),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const SheetDemoPage()),
                  );
                },
              ),
            ],
          ),
          CupertinoListSection.insetGrouped(
            header: Text('Navigation'),
            children: [
              CupertinoListTile(
                title: Text('Tab Bar'),
                leading: CNIcon(
                  symbol: CNSymbol('square.grid.2x2', color: accentColor),
                ),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(builder: (_) => const TabBarDemoPage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
