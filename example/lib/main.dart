import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/cn_image_demo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';

import 'demos/alert.dart';
import 'demos/cn_button_demo.dart';
import 'demos/cn_color_well_demo.dart';
import 'demos/combo_box.dart';
import 'demos/cn_context_menu.dart';
import 'demos/cn_date_picker_demo.dart';
import 'demos/group_box.dart';
import 'demos/icon.dart';
import 'demos/cn_label_demo.dart';
import 'demos/level_indicators.dart';
import 'demos/cn_menu_demo.dart';
import 'demos/path_control.dart';
import 'demos/cn_picker_demo.dart';
import 'demos/popover.dart';
import 'demos/popup_menu_button.dart';
import 'demos/cn_progressview_demo.dart';
import 'demos/cn_search_field_demo.dart';
import 'demos/secure_text_field.dart';
import 'demos/segmented_control.dart';
import 'demos/sheet.dart';
import 'demos/cn_slider_demo.dart';
import 'demos/split_view.dart';
import 'demos/cn_stepper_demo.dart';
import 'demos/tab_view.dart';
import 'demos/cn_text_demo.dart';
import 'demos/cn_text_field_demo.dart';
import 'demos/text_view.dart';
import 'demos/theme.dart';
import 'demos/cn_toggle_demo.dart';

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

class _DemoEntry {
  const _DemoEntry(this.title, this.symbolName, this.page);

  final Widget page;
  final String symbolName;
  final String title;
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
    _DemoEntry('CNImage', 'testtube.2', CNImage2DemoPage()),
    _DemoEntry('CNText', 'text.viewfinder', TextDemoPage()),
    _DemoEntry('CNProgressView', 'progress.indicator', ProgressIndicatorsPageDemo()),
    _DemoEntry('CNSlider', 'slider.horizontal.3', SliderDemoPage()),
    _DemoEntry('CNColorWell', 'paintpalette', ColorWellDemoPage()),
    _DemoEntry('CNDatePicker', 'calendar', DatePickerDemoPage()),
    _DemoEntry('CNStepper', 'plusminus', StepperDemoPage()),
    _DemoEntry('CNTextField', 'character.cursor.ibeam', TextFieldDemoPage()),
    _DemoEntry('CNToggle', 'switch.2', ToggleDemo()),
    _DemoEntry('CNSearchField', 'magnifyingglass', SearchFieldDemoPage()),
    _DemoEntry('CNLabel', 'textformat', LabelDemoPage()),
    _DemoEntry('CNButton', 'button.horizontal', ButtonDemoPage()),
    _DemoEntry('CNMenu', 'ellipsis.circle', MenuButtonDemoPage()),
    _DemoEntry('CNPicker', 'rectangle.split.3x1.fill', PickerDemoPage()),
    _DemoEntry('CNContextMenu', 'ellipsis.rectangle', ContextMenuDemoPage()),


    _DemoEntry('Theme Tokens', 'paintbrush.pointed', ThemeDemoPage()),
    _DemoEntry('Segmented Control', 'rectangle.split.3x1', SegmentedControlDemoPage()),
    _DemoEntry('TabView', 'rectangle.split.3x1', TabViewDemoPage()),
    _DemoEntry('Icon', 'app', IconDemoPage()),
    _DemoEntry('Popup Menu Button', 'ellipsis.circle', PopupMenuButtonDemoPage()),
    _DemoEntry('Path Control', 'folder', PathControlDemoPage()),
    _DemoEntry('Level Indicators', 'gauge', LevelIndicatorDemoPage()),
    _DemoEntry('Secure Text Field', 'lock.shield', SecureTextFieldDemoPage()),
    _DemoEntry('Text View / Text Area', 'text.justify.left', TextViewDemoPage()),
    _DemoEntry('Combo Box', 'list.bullet.rectangle', ComboBoxDemoPage()),
    _DemoEntry('Alert', 'exclamationmark.bubble', AlertDemoPage()),
    _DemoEntry('Popover', 'rectangle.on.rectangle', PopoverDemoPage()),
    _DemoEntry('GroupBox', 'textformat', GroupBoxDemoPage()),
    _DemoEntry('Sheet', 'square.and.line.vertical.and.square', SheetDemoPage()),
    _DemoEntry('Split View', 'rectangle.split.2x1', SplitViewDemoPage()),
  ];

  final String _searchQuery = '';
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
    final isDark = theme.brightness == Brightness.dark;

    return CNMainWindow(
      controller: _windowController,
      toolbarTitle: 'Cupertino Native',
      toolbarShowSearch: false,
      // toolbarColor: widget.accentColor,
      // toolbarGroups: [
      //   CNToolbarGroup(
      //     id: 'left-window',
      //     placement: CNToolbarItemPlacement.navigation,
      //     items: [
      //       CNToolbarButtonItem(
      //         id: 'toggle-left-sidebar',
      //         systemSymbolName: 'sidebar.left',
      //         onPressed: _windowController.toggleSidebar,
      //       ),
      //     ],
      //   ),
      //   CNToolbarGroup(
      //     id: 'status-window',
      //     placement: CNToolbarItemPlacement.status,
      //     items: [
      //       CNToolbarButtonItem(
      //         id: 'toggle-right-sidebar',
      //         systemSymbolName: 'sidebar.right',
      //         onPressed: _windowController.toggleTrailingSidebar,
      //       ),
      //     ],
      //   ),
      //   CNToolbarGroup(
      //     id: 'appearance',
      //     placement: CNToolbarItemPlacement.principal,
      //     items: [
      //       CNToolbarPickerItem(
      //         id: 'accent-colors',
      //         pickerStyle: CNPickerStyle.menu,
      //         controlSize: CNControlSize.regular,
      //         items: _systemColors.map((e) => e.key).toList(),
      //         selectedValue: _systemColors.firstWhere((e) => e.value == accentColor, orElse: () => _systemColors.first).key,
      //         onChanged: (value) {
      //           final selected = _systemColors.firstWhere((e) => e.key == value, orElse: () => _systemColors.first);
      //           widget.onSelectAccentColor(selected.value);
      //         },
      //       ),
      //       CNToolbarMenuButtonItem(
      //         id: 'menu-button',
      //         label: 'Accent Color',
      //         image: const CNImage(systemSymbolName: 'circle.fill'),
      //         menuStyle: CNMenuStyle.borderedButton,
      //         onSelected: (value) {},
      //         menu: CNMenuModel(
      //           items: _systemColors.map((e) {
      //             return CNMenuModelItem(
      //               title: e.key,
      //               state: e.value == accentColor ? CNMenuModelItemState.on : CNMenuModelItemState.off,
      //               image: CNImage(
      //                 systemSymbolName: 'circle.fill',
      //                 symbolRenderingMode: CNSymbolRenderingMode.monochrome,
      //                 foregroundStyleColors: [e.value],
      //               ),
      //             );
      //           }).toList(),
      //         ),
      //       ),

      //       CNToolbarToggleItem(
      //         id: 'dark-mode-toggle',
      //         systemSymbolName: 'moon.fill',
      //         isOn: widget.isDarkMode,
      //         toggleStyle: CNToggleStyle.automatic,
      //         controlSize: CNControlSize.small,
      //         onChanged: (_) {
      //           setState(() {
      //             final theme = context.read<AppTheme>();
      //             theme.mode = theme.mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      //           });
      //         },
      //       ),
      //     ],
      //   ),
      // ],
      // onToolbarSearchChanged: (value) {
      //   setState(() {
      //     _searchQuery = value;
      //   });
      // },
      sidebar: CNSidebar(
        shownByDefault: true,
        startWidth: 250,
        child: SafeArea(
          child: Container(
            color: theme.groupedBackgroundColor,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                CNListSection.insetGrouped(
                  backgroundColor: theme.groupedBackgroundColor,
                  children: [
                    for (final entry in visibleEntries)
                      CNListTile(
                        title: Text(entry.title),
                        leading: CNIcon(
                          symbol: CNSymbol(
                            entry.symbolName,
                            color: _selectedIndex == _entries.indexOf(entry)
                                ? CupertinoColors.label.darkColor
                                : isDark
                                ? CupertinoColors.label.darkColor
                                : CupertinoColors.label.color,
                          ),
                        ),
                        selected: _selectedIndex == _entries.indexOf(entry),
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
      ),
      child: KeyedSubtree(key: ValueKey(_selectedIndex), child: _entries[_selectedIndex].page),
    );
  }
}

class _MyAppState extends State<MyApp> {
  Color? _accentColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    var dispatcher = SchedulerBinding.instance.platformDispatcher;

    // This callback is called every time the brightness changes.
    dispatcher.onPlatformBrightnessChanged = () {
      var brightness = dispatcher.platformBrightness;
      debugPrint('Platform brightness changed: $brightness');
      setState(() {});
    };
  }

  void _setAccentColor(Color color) {
    setState(() {
      _accentColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SystemThemeBuilder(
      builder: (context, color) {
        debugPrint('System accent color: ${color.accent}');
        _accentColor ??= color.accent;
        return ChangeNotifierProvider(
          create: (_) => AppTheme(),
          builder: (context, child) {
            final appTheme = context.watch<AppTheme>();
            final brightness = appTheme.mode == ThemeMode.system
                ? WidgetsBinding.instance.platformDispatcher.platformBrightness
                : (appTheme.mode == ThemeMode.dark ? Brightness.dark : Brightness.light);

            debugPrint('App brightness: $brightness, accent color: $_accentColor');

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
