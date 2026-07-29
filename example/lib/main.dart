import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, ThemeMode;
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'demos/cn_alert_demo.dart';
import 'demos/cn_button_demo.dart';
import 'demos/cn_color_well_demo.dart';
import 'demos/cn_combo_box_demo.dart';
import 'demos/cn_context_menu_demo.dart';
import 'demos/cn_date_picker_demo.dart';
import 'demos/cn_gauge_demo.dart';
import 'demos/cn_image_demo.dart';
import 'demos/cn_label_demo.dart';
import 'demos/cn_menu_demo.dart';
import 'demos/cn_path_control_demo.dart';
import 'demos/cn_picker_demo.dart';
import 'demos/cn_popover_demo.dart';
import 'demos/cn_progressview_demo.dart';
import 'demos/cn_search_field_demo.dart';
import 'demos/cn_segmented_control_demo.dart';
import 'demos/cn_tab_view_demo.dart';
import 'demos/cn_secure_field_demo.dart';
import 'demos/cn_slider_demo.dart';
import 'demos/cn_stepper_demo.dart';
import 'demos/cn_text_demo.dart';
import 'demos/cn_text_field_demo.dart';
import 'demos/cn_toggle_demo.dart';
import 'demos/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CNAccentColorListener.load();
  await WindowManipulator.initialize(enableWindowDelegate: true);
  // await initializeWindowManager();
  runApp(const MyApp());
}

const _entries = <_DemoEntry>[
  _DemoEntry('CNAlert', 'exclamationmark.bubble', AlertDemoPage()),
  _DemoEntry('CNButton', 'button.horizontal', ButtonDemoPage()),
  _DemoEntry('CNColorWell', 'paintpalette', ColorWellDemoPage()),
  _DemoEntry('CNComboBox', 'list.bullet.rectangle', ComboBoxDemoPage()),
  _DemoEntry('CNContextMenu', 'ellipsis.rectangle', ContextMenuDemoPage()),
  _DemoEntry('CNDatePicker', 'calendar', DatePickerDemoPage()),
  _DemoEntry('CNGauge', 'gauge.chart.lefthalf.righthalf', GaugeDemoPage()),
  _DemoEntry('CNImage', 'testtube.2', CNImage2DemoPage()),
  _DemoEntry('CNLabel', 'textformat', LabelDemoPage()),
  _DemoEntry('CNMenu', 'ellipsis.circle', MenuButtonDemoPage()),
  _DemoEntry('CNPathControl', 'folder', PathControlDemoPage()),
  _DemoEntry('CNPicker', 'rectangle.split.3x1.fill', PickerDemoPage()),
  _DemoEntry('CNPopover', 'rectangle.on.rectangle', PopoverDemoPage()),
  _DemoEntry('CNProgressView', 'progress.indicator', ProgressIndicatorsPageDemo()),
  _DemoEntry('CNSearchField', 'magnifyingglass', SearchFieldDemoPage()),
  _DemoEntry('CNSegmentedControl', 'rectangle.split.3x1', SegmentedControlDemoPage()),
  _DemoEntry('CNTabView', 'rectangle.split.3x1.fill', TabViewDemoPage()),
  _DemoEntry('CNSecureField', 'lock.shield', SecureTextFieldDemoPage()),
  _DemoEntry('CNSlider', 'slider.horizontal.3', SliderDemoPage()),
  _DemoEntry('CNStepper', 'plusminus', StepperDemoPage()),
  _DemoEntry('CNText', 'text.viewfinder', TextDemoPage()),
  _DemoEntry('CNTextField', 'character.cursor.ibeam', TextFieldDemoPage()),
  _DemoEntry('CNToggle', 'switch.2', ToggleDemo()),
  _DemoEntry('Theme Tokens', 'paintbrush.pointed', ThemeDemoPage()),
];

Future<void> initializeWindowManager() async {
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    skipTaskbar: false,
    size: Size(1280, 1024),
    minimumSize: Size(1024, 800),
    maximumSize: Size(1920, 1080),
    fullScreen: false,
    center: true,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setFullScreen(false);
    await windowManager.show();
    await windowManager.focus();
  });
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
  const _DesktopDemoShell({required this.selectedIndex});

  final int selectedIndex;

  @override
  State<_DesktopDemoShell> createState() => _DesktopDemoShellState();
}

class _DesktopDemoShellState extends State<_DesktopDemoShell> {
  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey(widget.selectedIndex),
      child: Container(color: CNTheme.of(context).canvasColor.withAlpha(127), child: _entries[widget.selectedIndex].page),
    );
  }
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late Brightness brightness;
  String? searchQuery;
  int selectedIndex = 0;
  bool sideBarClosed = false;

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppTheme(),
      builder: (context, child) {
        final appTheme = context.watch<AppTheme>();

        brightness = appTheme.mode == ThemeMode.system
            ? WidgetsBinding.instance.platformDispatcher.platformBrightness
            : (appTheme.mode == ThemeMode.dark ? Brightness.dark : Brightness.light);

        debugPrint('Building MyApp with brightness: $brightness, appTheme.mode: ${appTheme.mode}');

        return CNApp(
            themeMode: appTheme.mode,
            color: null,
            debugShowCheckedModeBanner: false,
            home: (context) {
            final accentColor = CNTheme.of(context).accentColor;
            debugPrint('Building home with accentColor: $accentColor, brightness: $brightness, appTheme.mode: ${appTheme.mode}');

            return CNWindow(
              state: NSVisualEffectViewState.followsWindowActiveState,
              backgroundColor: CNTheme.of(context).canvasColor.withAlpha(1),
              sidebar: CNSidebar(
                builder: (context, scrollController) {
                  return _SideBar(
                    selectedIndex: selectedIndex,
                    scrollController: scrollController,
                    searchQuery: searchQuery,
                    onItemSelected: (index) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                  );
                },
                minWidth: 250,
                isResizable: true,
                maxWidth: 400,
                startWidth: 250,
                dragClosed: true,
                material: NSVisualEffectViewMaterial.fullScreenUI,
                backgroundColor: CNColors.transparent,
              ),
              statusBar: CNStatusBar(
                height: 32,
                color: accentColor.withAlpha(127),
                expandedColor: CNTheme.of(context).canvasColor,
                expansionMode: CNStatusBarExpansionMode.overAll,
                presentationStyle: CNStatusBarPresentationStyle.push,
                expandedMinHeight: 120,
                expandedMaxHeight: 400,
                expandedStartHeight: 200,
                dragClosed: true,
                leftItems: (context, isExpanded) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 8),
                      _StatusBarButton(icon: CupertinoIcons.exclamationmark_triangle, label: '0', onPressed: () {}),
                      _StatusBarButton(icon: CupertinoIcons.info_circle, label: '2', onPressed: () {}),
                    ],
                  );
                },
                rightItems: (context, isExpanded) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _StatusBarButton(
                        icon: CupertinoIcons.text_alignleft,
                        label: 'Terminal',
                        isActive: isExpanded,
                        onPressed: () {
                          CNWindowScope.of(context).toggleStatusBar();
                        },
                      ),
                      _StatusBarButton(icon: CupertinoIcons.doc_text, label: 'Dart', onPressed: () {}),
                      _StatusBarButton(icon: CupertinoIcons.checkmark_circle, label: 'UTF-8', onPressed: () {}),
                      const SizedBox(width: 8),
                    ],
                  );
                },
                expandedBuilder: (context, scrollController) {
                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: 50,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Text(
                          '[\$ flutter run] Line $index: Application output...',
                          style: TextStyle(fontSize: 12, fontFamily: 'Menlo', color: CNTheme.of(context).labelColor),
                        ),
                      );
                    },
                  );
                },
              ),
              toolbar: CNToolbarConfig(
                onSearchChanged: (context, value) {
                  debugPrint('Search changed: $value');
                  setState(() {
                    searchQuery = value;
                  });
                },
                onItemPressed: (context, value) {
                  final tags = value.split(':');
                  debugPrint('Toolbar item pressed: $value, tags: $tags, tags.length: ${tags.length}');
                  if (tags.length == 2 && tags[0] == 'theme_picker') {
                    debugPrint('Theme picker selected: ${tags[1]}');
                    final selectedTag = tags[1];
                    if (selectedTag == ThemeMode.system.name) {
                      appTheme.mode = ThemeMode.system;
                    } else if (selectedTag == ThemeMode.light.name) {
                      appTheme.mode = ThemeMode.light;
                    } else {
                      appTheme.mode = ThemeMode.dark;
                    }
                  } else if (tags.length == 1 && tags[0] == 'toggle_navigation') {
                    debugPrint('Toggling sidebar');
                    CNWindowScope.of(context).toggleSidebar();
                  }
                },
                searchable: true,
                searchText: searchQuery,
                titleDisplayMode: CNToolbarTitleDisplayMode.automatic,
                toolbarBackground: accentColor.withAlpha(244),
                toolbarBlurEnabled: true,
                toolbarBlurMaterial: CNToolbarBlurMaterial.titlebar,
                title: CNChildText('Cupertino Native Demo'),
                groups: [
                  CNToolbarItemGroup(
                    placement: CNToolbarPlacement.navigation,
                    children: [
                      CNChildButton(
                        tag: 'toggle_navigation',
                        title: 'Toggle Navigation',
                        systemImage: 'sidebar.left',
                        labelStyle: CNLabelStyle.iconOnly,
                        help: 'Toggle the navigation sidebar',
                      ),
                    ],
                  ),
                  CNToolbarItemGroup(
                    placement: CNToolbarPlacement.automatic,
                    children: [
                      CNChildPicker(
                        pickerStyle: CNPickerStyle.menu.name,
                        labelStyle: CNLabelStyle.titleAndIcon,
                        tag: 'theme_picker',
                        label: [
                          CNChildLabel(
                            appTheme.mode.name,
                            labelStyle: CNLabelStyle.titleAndIcon,
                            tag: appTheme.mode.name,
                            systemImage: appTheme.mode == ThemeMode.system
                                ? 'sun.max'
                                : (appTheme.mode == ThemeMode.light ? 'sun.max' : 'moon.fill'),
                          ),
                        ],
                        children: [
                          CNChildLabel('System Theme', tag: ThemeMode.system.name, systemImage: 'sun.lefthalf.filled'),
                          CNChildLabel('Light Theme', tag: ThemeMode.light.name, systemImage: 'sun.max'),
                          CNChildLabel('Dark Theme', tag: ThemeMode.dark.name, systemImage: 'moon.fill'),
                        ],
                        selection: appTheme.mode.name,
                      ),
                    ],
                  ),
                ],
              ),
              child: _DesktopDemoShell(selectedIndex: selectedIndex),
            );
            },
        );
      },
    );
  }
}

class _SideBar extends StatelessWidget {
  const _SideBar({required this.onItemSelected, required this.selectedIndex, this.scrollController, this.searchQuery});

  final void Function(int index) onItemSelected;
  final ScrollController? scrollController;
  final String? searchQuery;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = CNTheme.of(context).accentColor;
    final isBright = accentColor.computeLuminance() > 0.5;
    final labelColor = theme.labelColor;

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        final isSelected = index == selectedIndex;
        final isValidEntry =
            searchQuery == null || searchQuery!.isEmpty || entry.title.toLowerCase().contains(searchQuery!.toLowerCase());

        if (!isValidEntry) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () => onItemSelected(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            decoration: BoxDecoration(
              color: isSelected ? accentColor.withValues(alpha: 1.0) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                CNImage(
                  constraints: const BoxConstraints(maxWidth: 18, maxHeight: 18),
                  systemSymbolName: entry.symbolName,
                  foregroundColor: isSelected
                      ? isBright
                            ? CNColors.black
                            : CNColors.white
                      : (isDark ? CupertinoColors.label.darkColor : CupertinoColors.label.color),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.title,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? (isBright ? CNColors.label.color : CNColors.label.darkColor) : labelColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusBarButton extends StatelessWidget {
  const _StatusBarButton({required this.icon, required this.label, required this.onPressed, this.isActive = false});

  final IconData icon;
  final bool isActive;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: isActive ? CNColors.fillPrimary.withAlpha(40) : Colors.transparent,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: CNColors.label),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: CNColors.label)),
          ],
        ),
      ),
    );
  }
}
