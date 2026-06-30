import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'demos/slider.dart';
import 'demos/toggle_demo.dart';
import 'demos/segmented_control.dart';
import 'demos/picker.dart';
import 'demos/tab_bar.dart';
import 'demos/icon.dart';
import 'demos/image.dart';
import 'demos/popup_menu_button.dart';
import 'demos/menu_button.dart';
import 'demos/button.dart';
import 'demos/color_well.dart';
import 'demos/path_control.dart';
import 'demos/progress_indicators.dart';
import 'demos/level_indicators.dart';
import 'demos/stepper.dart';
import 'demos/date_picker.dart';
import 'demos/search_field.dart';
import 'demos/text_field.dart';
import 'demos/secure_text_field.dart';
import 'demos/text_view.dart';
import 'demos/combo_box.dart';
import 'demos/alert.dart';
import 'demos/popover.dart';
import 'demos/context_menu.dart';
import 'demos/label.dart';
import 'demos/sheet.dart';
import 'demos/split_view.dart';
import 'demos/group_box.dart';
import 'demos/tab_view.dart';
import 'demos/swiftui_toolbar_demo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color _accentColor = CupertinoColors.systemBlue;
  bool _isDarkMode = false;

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
      theme: CupertinoThemeData(brightness: _isDarkMode ? Brightness.dark : Brightness.light, primaryColor: _accentColor),
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

  final Color accentColor;
  final bool isDarkMode;
  final ValueChanged<Color> onSelectAccentColor;
  final VoidCallback onToggleTheme;

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
            CNMenuButton(
              buttonLabel: 'Accent Color',
              buttonIcon: CNSymbol('circle.fill', mode: CNSymbolRenderingMode.monochrome),
              controlSize: CNControlSize.regular,
              menu: CNMenu(
                items: _systemColors.map((entry) {
                  return CNMenuItem(
                    title: entry.key,
                    image: CNImage(
                      systemSymbolName: 'circle.fill',
                      symbolConfiguration: CNSymbolConfiguration.monochrome(entry.value),
                    ),
                    state: accentColor == entry.value ? CNMenuItemState.on : CNMenuItemState.off,
                    tag: entry.value.toARGB32(),
                    enabled: true,
                  );
                }).toList(),
              ),
              onSelected: (value) {
                final selectedColor = Color(value.tag as int);
                onSelectAccentColor(selectedColor);
              },
            ),
            const SizedBox(width: 8),
            CNButton.icon(icon: CNSymbol(isDarkMode ? 'sun.max' : 'moon', size: 18), onPressed: onToggleTheme),
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
                leading: CNIcon(symbol: CNSymbol('slider.horizontal.3', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const SliderDemoPage()));
                },
              ),

              CupertinoListTile(
                title: Text('Toggle'),
                leading: CNIcon(symbol: CNSymbol('switch.2', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const ToggleDemo()));
                },
              ),

              CupertinoListTile(
                title: Text('Segmented Control (deprecated)'),
                leading: CNIcon(symbol: CNSymbol('rectangle.split.3x1', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const SegmentedControlDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('Picker'),
                leading: CNIcon(symbol: CNSymbol('rectangle.split.3x1.fill', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const PickerDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('TabView'),
                leading: CNIcon(symbol: CNSymbol('rectangle.split.3x1', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const TabViewDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('Icon'),
                leading: CNIcon(symbol: CNSymbol('app', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const IconDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('Image'),
                leading: CNIcon(symbol: CNSymbol('photo', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const ImageDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('Popup Menu Button'),
                leading: CNIcon(symbol: CNSymbol('ellipsis.circle', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const PopupMenuButtonDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('Menu Button'),
                leading: CNIcon(symbol: CNSymbol('ellipsis.circle', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const MenuButtonDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('Label'),
                leading: CNIcon(symbol: CNSymbol('textformat', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const LabelDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('Button'),
                leading: CNIcon(symbol: CNSymbol('hand.tap', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const ButtonDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('Color Well'),
                leading: CNIcon(symbol: CNSymbol('paintpalette', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const ColorWellDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('Path Control'),
                leading: CNIcon(symbol: CNSymbol('folder', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const PathControlDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('Progress Indicators'),
                leading: CNIcon(symbol: CNSymbol('hourglass', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const ProgressIndicatorsPageDemo()));
                },
              ),
              CupertinoListTile(
                title: Text('Level Indicators'),
                leading: CNIcon(symbol: CNSymbol('gauge', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const LevelIndicatorDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('Steppers'),
                leading: CNIcon(symbol: CNSymbol('plusminus', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const StepperDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('Date Picker'),
                leading: CNIcon(symbol: CNSymbol('calendar', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const DatePickerDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('Search Field'),
                leading: CNIcon(symbol: CNSymbol('magnifyingglass', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const SearchFieldDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('Text Field'),
                leading: CNIcon(symbol: CNSymbol('character.cursor.ibeam', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const TextFieldDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('Secure Text Field'),
                leading: CNIcon(symbol: CNSymbol('lock.shield', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const SecureTextFieldDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('Text View / Text Area'),
                leading: CNIcon(symbol: CNSymbol('text.justify.left', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const TextViewDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('Combo Box'),
                leading: CNIcon(symbol: CNSymbol('list.bullet.rectangle', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const ComboBoxDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('Alert'),
                leading: CNIcon(symbol: CNSymbol('exclamationmark.bubble', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const AlertDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('Popover'),
                leading: CNIcon(symbol: CNSymbol('rectangle.on.rectangle', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const PopoverDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('Context Menu'),
                leading: CNIcon(symbol: CNSymbol('ellipsis.rectangle', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const ContextMenuDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('GroupBox'),
                leading: CNIcon(symbol: CNSymbol('textformat', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const GroupBoxDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('Sheet'),
                leading: CNIcon(symbol: CNSymbol('square.and.line.vertical.and.square', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const SheetDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('Split View'),
                leading: CNIcon(symbol: CNSymbol('rectangle.split.2x1', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const SplitViewDemoPage()));
                },
              ),
              CupertinoListTile(
                title: Text('SwiftUI Toolbar'),
                leading: CNIcon(symbol: CNSymbol('macwindow', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const SwiftUIToolbarDemo()));
                },
              ),
            ],
          ),
          CupertinoListSection.insetGrouped(
            header: Text('Navigation'),
            children: [
              CupertinoListTile(
                title: Text('Tab Bar'),
                leading: CNIcon(symbol: CNSymbol('square.grid.2x2', color: accentColor)),
                trailing: CupertinoListTileChevron(),
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) => const TabBarDemoPage()));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
