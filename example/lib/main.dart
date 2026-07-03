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
  static const _entries = <_DemoEntry>[
    _DemoEntry('Theme Tokens', 'paintbrush.pointed', ThemeDemoPage()),
    _DemoEntry('Slider', 'slider.horizontal.3', SliderDemoPage()),
    _DemoEntry('Toggle', 'switch.2', ToggleDemo()),
    _DemoEntry('Segmented Control', 'rectangle.split.3x1', SegmentedControlDemoPage()),
    _DemoEntry('Picker', 'rectangle.split.3x1.fill', PickerDemoPage()),
    _DemoEntry('TabView', 'rectangle.split.3x1', TabViewDemoPage()),
    _DemoEntry('Icon', 'app', IconDemoPage()),
    _DemoEntry('Image', 'photo', ImageDemoPage()),
    _DemoEntry('Popup Menu Button', 'ellipsis.circle', PopupMenuButtonDemoPage()),
    _DemoEntry('Menu Button', 'ellipsis.circle', MenuButtonDemoPage()),
    _DemoEntry('Label', 'textformat', LabelDemoPage()),
    _DemoEntry('Button', 'hand.tap', ButtonDemoPage()),
    _DemoEntry('Color Well', 'paintpalette', ColorWellDemoPage()),
    _DemoEntry('Path Control', 'folder', PathControlDemoPage()),
    _DemoEntry('Progress Indicators', 'hourglass', ProgressIndicatorsPageDemo()),
    _DemoEntry('Level Indicators', 'gauge', LevelIndicatorDemoPage()),
    _DemoEntry('Steppers', 'plusminus', StepperDemoPage()),
    _DemoEntry('Date Picker', 'calendar', DatePickerDemoPage()),
    _DemoEntry('Search Field', 'magnifyingglass', SearchFieldDemoPage()),
    _DemoEntry('Text Field', 'character.cursor.ibeam', TextFieldDemoPage()),
    _DemoEntry('Secure Text Field', 'lock.shield', SecureTextFieldDemoPage()),
    _DemoEntry('Text View / Text Area', 'text.justify.left', TextViewDemoPage()),
    _DemoEntry('Combo Box', 'list.bullet.rectangle', ComboBoxDemoPage()),
    _DemoEntry('Alert', 'exclamationmark.bubble', AlertDemoPage()),
    _DemoEntry('Popover', 'rectangle.on.rectangle', PopoverDemoPage()),
    _DemoEntry('Context Menu', 'ellipsis.rectangle', ContextMenuDemoPage()),
    _DemoEntry('GroupBox', 'textformat', GroupBoxDemoPage()),
    _DemoEntry('Sheet', 'square.and.line.vertical.and.square', SheetDemoPage()),
    _DemoEntry('Split View', 'rectangle.split.2x1', SplitViewDemoPage()),
  ];

  String _searchQuery = '';
  int _selectedIndex = 0;
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
    final search = _searchQuery.trim().toLowerCase();
    final visibleEntries = search.isEmpty
        ? _entries
        : _entries.where((entry) => entry.title.toLowerCase().contains(search)).toList();
    final selectedEntry = _entries[_selectedIndex];

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
            CNToolbarMenuButtonItem(
              id: 'menu-button',
              label: 'Accent Color',
              image: const CNImage(systemSymbolName: 'circle.fill'),
              menuStyle: CNMenuStyle.borderedButton,
              onSelected: (value) {},
              menu: CNMenu(
                items: _systemColors.map((e) {
                  return CNMenuItem(
                    title: e.key,
                    state: e.value == accentColor ? CNMenuItemState.on : CNMenuItemState.off,
                    image: CNImage(
                      systemSymbolName: 'circle.fill',
                      symbolRenderingMode: CNSymbolRenderingMode.monochrome,
                      foregroundStyleColors: [e.value],
                    ),
                  );
                }).toList(),
              ),
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
                  for (final entry in visibleEntries)
                    CNListTile(
                      title: Text(entry.title),
                      leading: CNIcon(symbol: CNSymbol(entry.symbolName, color: accentColor)),
                      trailing: _selectedIndex == _entries.indexOf(entry)
                          ? const Text('✓', style: TextStyle(fontSize: 16))
                          : const CNListTileChevron(),
                      onTap: () {
                        setState(() {
                          _selectedIndex = _entries.indexOf(entry);
                        });
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
              Text('Selezione: ${selectedEntry.title}'),
              const SizedBox(height: 4),
              Text('Search: ${_searchQuery.isEmpty ? '-' : _searchQuery}'),
            ],
          ),
        ),
      ),
      child: IndexedStack(
        index: _selectedIndex,
        children: const [
          ThemeDemoPage(),
          SliderDemoPage(),
          ToggleDemo(),
          SegmentedControlDemoPage(),
          PickerDemoPage(),
          TabViewDemoPage(),
          IconDemoPage(),
          ImageDemoPage(),
          PopupMenuButtonDemoPage(),
          MenuButtonDemoPage(),
          LabelDemoPage(),
          ButtonDemoPage(),
          ColorWellDemoPage(),
          PathControlDemoPage(),
          ProgressIndicatorsPageDemo(),
          LevelIndicatorDemoPage(),
          StepperDemoPage(),
          DatePickerDemoPage(),
          SearchFieldDemoPage(),
          TextFieldDemoPage(),
          SecureTextFieldDemoPage(),
          TextViewDemoPage(),
          ComboBoxDemoPage(),
          AlertDemoPage(),
          PopoverDemoPage(),
          ContextMenuDemoPage(),
          GroupBoxDemoPage(),
          SheetDemoPage(),
          SplitViewDemoPage(),
        ],
      ),
    );
  }
}

class _DemoEntry {
  const _DemoEntry(this.title, this.symbolName, this.page);

  final Widget page;
  final String symbolName;
  final String title;
}
