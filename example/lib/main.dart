import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show ThemeMode;
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
import 'demos/theme.dart';
import 'package:provider/provider.dart';
import 'package:provider/src/change_notifier_provider.dart';
import 'package:system_theme/system_theme.dart';

const _systemColors = <MapEntry<String, Color>>[
  MapEntry('Red', MacOS26Colors.red),
  MapEntry('Orange', MacOS26Colors.orange),
  MapEntry('Yellow', MacOS26Colors.yellow),
  MapEntry('Green', MacOS26Colors.green),
  MapEntry('Teal', MacOS26Colors.teal),
  MapEntry('Blue', MacOS26Colors.blue),
  MapEntry('Indigo', MacOS26Colors.indigo),
  MapEntry('Purple', MacOS26Colors.purple),
  MapEntry('Pink', MacOS26Colors.pink),
  MapEntry('Gray', MacOS26Colors.gray),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemTheme.accentColor.load();
  runApp(const MyApp());
}

class AppTheme extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  set mode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color? _accentColor = null;

  void _setAccentColor(Color color) {
    setState(() {
      _accentColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SystemThemeBuilder(
      builder: (context, color) {
        if (_accentColor == null) {
          _accentColor = color.accent;
        }
        return ChangeNotifierProvider(
          create: (_) => AppTheme(),
          builder: (context, child) {
            final appTheme = context.watch<AppTheme>();
            final brightness = appTheme.mode == ThemeMode.system
                ? WidgetsBinding.instance.platformDispatcher.platformBrightness
                : (appTheme.mode == ThemeMode.dark ? Brightness.dark : Brightness.light);
            return CNDesktopApp(
              debugShowCheckedModeBanner: false,
              themeMode: appTheme.mode,
              theme: CNThemeData(brightness: brightness, primaryColor: _accentColor ?? color.accent),
              home: _DesktopDemoShell(
                isDarkMode: brightness == Brightness.dark,
                accentColor: _accentColor ?? color.accent,
                onSelectAccentColor: _setAccentColor,
              ),
            );
          },
        );
      },
    );
  }
}

class _DesktopDemoShell extends StatefulWidget {
  const _DesktopDemoShell({required this.isDarkMode, required this.accentColor, required this.onSelectAccentColor});

  final Color accentColor;
  final bool isDarkMode;
  final ValueChanged<Color> onSelectAccentColor;

  @override
  State<_DesktopDemoShell> createState() => _DesktopDemoShellState();
}

class _DesktopDemoShellState extends State<_DesktopDemoShell> {
  String _searchQuery = '';
  final CNMainWindowController _windowController = CNMainWindowController();

  @override
  void dispose() {
    _windowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.accentColor;
    final theme = CNTheme.of(context);

    return CNMainWindow(
      controller: _windowController,
      toolbarTitle: 'Cupertino Native',
      toolbarShowSearch: true,
      toolbarGroups: [
        CNToolbarGroup(
          id: 'left-window',
          placement: CNToolbarItemPlacement.navigation,
          items: [
            CNToolbarButtonItem(
              id: 'toggle-left-sidebar',
              systemSymbolName: 'sidebar.left',
              onPressed: _windowController.toggleSidebar,
            ),
          ],
        ),
        CNToolbarGroup(
          id: 'status-window',
          placement: CNToolbarItemPlacement.status,
          items: [
            CNToolbarButtonItem(
              id: 'toggle-right-sidebar',
              systemSymbolName: 'sidebar.right',
              onPressed: _windowController.toggleTrailingSidebar,
            ),
          ],
        ),
        CNToolbarGroup(
          id: 'appearance',
          placement: CNToolbarItemPlacement.principal,
          items: [
            CNToolbarPickerItem(
              id: 'accent-colors',
              pickerStyle: CNPickerStyle.menu,
              controlSize: CNControlSize.regular,
              items: _systemColors.map((e) => e.key).toList(),
              selectedValue: _systemColors.firstWhere((e) => e.value == accentColor, orElse: () => _systemColors.first).key,
              onChanged: (value) {
                final selected = _systemColors.firstWhere((e) => e.key == value, orElse: () => _systemColors.first);
                widget.onSelectAccentColor(selected.value);
              },
            ),
            CNToolbarToggleItem(
              id: 'dark-mode-toggle',
              systemSymbolName: 'moon.fill',
              isOn: widget.isDarkMode,
              toggleStyle: CNToggleStyle.automatic,
              controlSize: CNControlSize.small,
              onChanged: (_) {
                setState(() {
                  final theme = context.read<AppTheme>();
                  theme.mode = theme.mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
                });
              },
            ),
          ],
        ),
      ],
      onToolbarSearchChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      sidebar: CNSidebar(
        shownByDefault: true,
        startWidth: 250,
        child: SafeArea(
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              CNListSection.insetGrouped(
                backgroundColor: theme.canvasColor,
                header: Text('Components'),
                children: [
                  CNListTile(
                    title: Text('Theme Tokens'),
                    leading: CNIcon(symbol: CNSymbol('paintbrush.pointed', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const ThemeDemoPage()));
                    },
                  ),

                  CNListTile(
                    title: Text('Slider'),
                    leading: CNIcon(symbol: CNSymbol('slider.horizontal.3', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const SliderDemoPage()));
                    },
                  ),

                  CNListTile(
                    title: Text('Toggle'),
                    leading: CNIcon(symbol: CNSymbol('switch.2', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const ToggleDemo()));
                    },
                  ),

                  CNListTile(
                    title: Text('Segmented Control (x)'),
                    leading: CNIcon(symbol: CNSymbol('rectangle.split.3x1', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const SegmentedControlDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('Picker'),
                    leading: CNIcon(symbol: CNSymbol('rectangle.split.3x1.fill', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const PickerDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('TabView'),
                    leading: CNIcon(symbol: CNSymbol('rectangle.split.3x1', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const TabViewDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('Icon'),
                    leading: CNIcon(symbol: CNSymbol('app', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const IconDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('Image'),
                    leading: CNIcon(symbol: CNSymbol('photo', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const ImageDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('Popup Menu Button'),
                    leading: CNIcon(symbol: CNSymbol('ellipsis.circle', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const PopupMenuButtonDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('Menu Button'),
                    leading: CNIcon(symbol: CNSymbol('ellipsis.circle', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const MenuButtonDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('Label'),
                    leading: CNIcon(symbol: CNSymbol('textformat', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const LabelDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('Button'),
                    leading: CNIcon(symbol: CNSymbol('hand.tap', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const ButtonDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('Color Well'),
                    leading: CNIcon(symbol: CNSymbol('paintpalette', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const ColorWellDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('Path Control'),
                    leading: CNIcon(symbol: CNSymbol('folder', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const PathControlDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('Progress Indicators'),
                    leading: CNIcon(symbol: CNSymbol('hourglass', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const ProgressIndicatorsPageDemo()));
                    },
                  ),
                  CNListTile(
                    title: Text('Level Indicators'),
                    leading: CNIcon(symbol: CNSymbol('gauge', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const LevelIndicatorDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('Steppers'),
                    leading: CNIcon(symbol: CNSymbol('plusminus', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const StepperDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('Date Picker'),
                    leading: CNIcon(symbol: CNSymbol('calendar', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const DatePickerDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('Search Field'),
                    leading: CNIcon(symbol: CNSymbol('magnifyingglass', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const SearchFieldDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('Text Field'),
                    leading: CNIcon(symbol: CNSymbol('character.cursor.ibeam', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const TextFieldDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('Secure Text Field'),
                    leading: CNIcon(symbol: CNSymbol('lock.shield', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const SecureTextFieldDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('Text View / Text Area'),
                    leading: CNIcon(symbol: CNSymbol('text.justify.left', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const TextViewDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('Combo Box'),
                    leading: CNIcon(symbol: CNSymbol('list.bullet.rectangle', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const ComboBoxDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('Alert'),
                    leading: CNIcon(symbol: CNSymbol('exclamationmark.bubble', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const AlertDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('Popover'),
                    leading: CNIcon(symbol: CNSymbol('rectangle.on.rectangle', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const PopoverDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('Context Menu'),
                    leading: CNIcon(symbol: CNSymbol('ellipsis.rectangle', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const ContextMenuDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('GroupBox'),
                    leading: CNIcon(symbol: CNSymbol('textformat', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const GroupBoxDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('Sheet'),
                    leading: CNIcon(symbol: CNSymbol('square.and.line.vertical.and.square', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const SheetDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('Split View'),
                    leading: CNIcon(symbol: CNSymbol('rectangle.split.2x1', color: accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const SplitViewDemoPage()));
                    },
                  ),
                  CNListTile(
                    title: Text('SwiftUI Toolbar'),
                    leading: CNIcon(symbol: CNSymbol('macwindow', color: widget.accentColor)),
                    trailing: const CNListTileChevron(),
                    onTap: () {
                      Navigator.of(context).push(CNPageRoute(builder: (_) => const SwiftUIToolbarDemo()));
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      endSidebar: CNSidebar(
        shownByDefault: false,
        startWidth: 280,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Text('Inspector', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Sidebar sinistra: ${_windowController.isSidebarVisible ? 'aperta' : 'chiusa'}'),
              const SizedBox(height: 4),
              Text('Sidebar destra: ${_windowController.isTrailingSidebarVisible ? 'aperta' : 'chiusa'}'),
              const SizedBox(height: 4),
              Text('Search: ${_searchQuery.isEmpty ? '-' : _searchQuery}'),
            ],
          ),
        ),
      ),
      child: HomePage(
        isDarkMode: widget.isDarkMode,
        accentColor: widget.accentColor,
        onSelectAccentColor: widget.onSelectAccentColor,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.isDarkMode, required this.accentColor, required this.onSelectAccentColor});

  final Color accentColor;
  final bool isDarkMode;
  final ValueChanged<Color> onSelectAccentColor;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);

    debugPrint('HomePage build: isDarkMode=${widget.isDarkMode}, accentColor=${widget.accentColor}');

    return Center(
      child: CNMenuButton(
        label: 'Select Accent Color',
        systemImage: 'circle.fill',
        tint: widget.accentColor,
        symbolRenderingMode: CNSymbolRenderingMode.monochrome,
        menu: CNMenu(
          items: _systemColors
              .map(
                (e) => CNMenuItem(
                  title: e.key,
                  image: CNImage(
                    systemSymbolName: 'circle.fill',
                    symbolConfiguration: CNSymbolConfiguration.monochrome(e.value),
                  ),
                ),
              )
              .toList(),
        ),
        onSelected: (item) {
          final selectedColor = _systemColors.firstWhere((e) => e.key == item.title, orElse: () => _systemColors.first).value;
          widget.onSelectAccentColor(selectedColor);
        },
        menuStyle: CNMenuStyle.automatic,
        controlSize: CNControlSize.large,
      ),
    );
  }
}
