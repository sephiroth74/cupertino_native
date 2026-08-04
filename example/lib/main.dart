import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/cn_resizable_panel_demo.dart';
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
import 'demos/cn_icon_button_demo.dart';
import 'demos/cn_image_demo.dart';
import 'demos/cn_label_demo.dart';
import 'demos/cn_menu_demo.dart';
import 'demos/cn_navigation_demo.dart';
import 'demos/cn_overlay_demo.dart';
import 'demos/cn_path_control_demo.dart';
import 'demos/cn_picker_demo.dart';
import 'demos/cn_popover_demo.dart';
import 'demos/cn_progressview_demo.dart';
import 'demos/cn_search_field_demo.dart';
import 'demos/cn_secure_field_demo.dart';
import 'demos/cn_segmented_control_demo.dart';
import 'demos/cn_slider_demo.dart';
import 'demos/cn_stepper_demo.dart';
import 'demos/cn_tab_view_demo.dart';
import 'demos/cn_text_demo.dart';
import 'demos/cn_text_editor_demo.dart';
import 'demos/cn_text_field_demo.dart';
import 'demos/cn_toggle_demo.dart';
import 'demos/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeWindowManager();
  await WindowManipulator.initialize(enableWindowDelegate: true);
  // Reshape the window chrome once so the Flutter toolbar can draw over a
  // transparent, full-size-content-view titlebar (no native NSToolbar).
  await WindowManipulator.makeTitlebarTransparent();
  await WindowManipulator.enableFullSizeContentView();
  await WindowManipulator.hideTitle();
  await CNAccentColorListener.load();
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
  _DemoEntry('CNIconButton', 'square.grid.2x2', IconButtonDemoPage()),
  _DemoEntry('CNImage', 'testtube.2', CNImage2DemoPage()),
  _DemoEntry('CNLabel', 'textformat', LabelDemoPage()),
  _DemoEntry('CNMenu', 'ellipsis.circle', MenuButtonDemoPage()),
  _DemoEntry('Navigation', 'arrow.forward.square', NavigationDemoPage()),
  _DemoEntry('Overlay', 'square.on.circle', OverlayDemoPage()),
  _DemoEntry('CNPathControl', 'folder', PathControlDemoPage()),
  _DemoEntry('CNPicker', 'rectangle.split.3x1.fill', PickerDemoPage()),
  _DemoEntry('CNPopover', 'rectangle.on.rectangle', PopoverDemoPage()),
  _DemoEntry(
    'CNProgressView',
    'progress.indicator',
    ProgressIndicatorsPageDemo(),
  ),
  _DemoEntry('CNSearchField', 'magnifyingglass', SearchFieldDemoPage()),
  _DemoEntry(
    'CNSegmentedControl',
    'rectangle.split.3x1',
    SegmentedControlDemoPage(),
  ),
  _DemoEntry('CNTabView', 'rectangle.split.3x1.fill', TabViewDemoPage()),
  _DemoEntry('CNSecureField', 'lock.shield', SecureTextFieldDemoPage()),
  _DemoEntry('CNSlider', 'slider.horizontal.3', SliderDemoPage()),
  _DemoEntry('CNStepper', 'plusminus', StepperDemoPage()),
  _DemoEntry('CNText', 'text.viewfinder', TextDemoPage()),
  _DemoEntry('CNTextField', 'character.cursor.ibeam', TextFieldDemoPage()),
  _DemoEntry('CNTextEditor', 'text.alignleft', TextEditorDemoPage()),
  _DemoEntry('CNToggle', 'switch.2', ToggleDemo()),
  _DemoEntry('Resizable Panel', 'square.split.2x2', ResizablePanelDemoPage()),
  _DemoEntry('Theme Tokens', 'paintbrush.pointed', ThemeDemoPage()),
];

Future<void> initializeWindowManager() async {
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    skipTaskbar: false,
    size: Size(1280, 1024),
    minimumSize: Size(1024, 300),
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
  const _DesktopDemoShell({
    required this.selectedIndex,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  final ValueChanged<String> onSearchChanged;
  final String? searchQuery;
  final int selectedIndex;

  @override
  State<_DesktopDemoShell> createState() => _DesktopDemoShellState();
}

class _DesktopDemoShellState extends State<_DesktopDemoShell> {
  @override
  Widget build(BuildContext context) {
    // This context sits below CNWindowScope (the shell is CNWindow.child), so
    // the toolbar's sidebar-toggle can reach the scope here.
    context.watch<AppTheme>();
    final theme = CNTheme.of(context);
    final accentColor = theme.accentColor;
    final entry = _entries[widget.selectedIndex];
    final isDark = theme.brightness == Brightness.dark;

    return CNPageScaffold(
      toolBar: CNToolbar(
        automaticallyImplyLeading: true,
        leading: [
          CNToolbarIconButton(
            'sidebar.left',
            tooltip: 'Toggle the navigation sidebar',
            onPressed: () => CNWindowScope.of(context).toggleSidebar(),
          ),
        ],
        title: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.title),
            const SizedBox(height: 2.0),
            Text(
              'Cupertino Native Demo',
              style: TextStyle(fontSize: theme.typography.caption1.fontSize),
            ),
          ],
        ),
        backgroundColor: isDark
            ? accentColor?.withLuminance(0.3)
            : accentColor?.withLuminance(0.9),
        enableBlur: true,
        actions: [
          createToolbarThemePicker(context),
          const CNToolbarSpacer(spacerUnits: 0.25),
          const CNToolbarDivider(),
          const CNToolbarSpacer(spacerUnits: 0.25),
        ],
        search: CNSearchField(
          text: widget.searchQuery ?? '',
          placeholder: 'Search',
          onChanged: widget.onSearchChanged,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey(widget.selectedIndex),
        child: entry.page,
      ),
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
            : (appTheme.mode == ThemeMode.dark
                  ? Brightness.dark
                  : Brightness.light);

        debugPrint(
          'Building MyApp with brightness: $brightness, appTheme.mode: ${appTheme.mode}',
        );

        return CNApp(
          themeMode: appTheme.mode,
          debugShowCheckedModeBanner: false,
          home: (context) {
            final accentColor = CNTheme.of(context).accentColor;
            final accentColorHex = accentColor != null
                ? '#${accentColor.value.toRadixString(16).padLeft(8, '0')}'
                : 'null';
            debugPrint(
              'Building home with accentColorHex: $accentColorHex, brightness: $brightness, appTheme.mode: ${appTheme.mode}',
            );

            return CNWindow(
              state: NSVisualEffectViewState.followsWindowActiveState,
              backgroundColor: CNTheme.of(context).canvasColor.withAlpha(1),
              toolbarSpansFullWidth: true,
              sidebar: CNSidebar(
                builder: (context) {
                  return _SideBar(
                    selectedIndex: selectedIndex,
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
                // In full-width toolbar mode the window already drops the sidebar
                // below the toolbar strip, so no extra top padding is needed here.
                material: NSVisualEffectViewMaterial.fullScreenUI,
                backgroundColor: CNColors.canvasColor.withAlpha(127),
              ),
              statusBar: CNStatusBar(
                height: 32,
                color: accentColor?.withAlpha(127),
                dividerColor: CNTheme.of(context).separatorColor.withAlpha(51),
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
                      _StatusBarButton(
                        icon: CupertinoIcons.exclamationmark_triangle,
                        label: '0',
                        onPressed: () {},
                      ),
                      _StatusBarButton(
                        icon: CupertinoIcons.info_circle,
                        label: '2',
                        onPressed: () {},
                      ),
                    ],
                  );
                },
                rightItems: (context, isExpanded) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CNPixelPerfectContainer(
                        adjustPosition: true,
                        child: CNToggle(
                          controlSize: CNControlSize.regular,
                          toggleStyle: CNToggleStyle.button,
                          isOn: isExpanded,
                          content: CNChildLabel(
                            'Terminal',
                            labelStyle: CNLabelStyle.titleAndIcon,
                            systemImage: 'apple.terminal',
                          ),
                          onChanged: (value) {
                            CNWindowScope.of(context).toggleStatusBar();
                          },
                        ),
                      ),
                      _StatusBarButton(
                        icon: CupertinoIcons.doc_text,
                        label: 'Dart',
                        onPressed: () {},
                      ),
                      _StatusBarButton(
                        icon: CupertinoIcons.checkmark_circle,
                        label: 'UTF-8',
                        onPressed: () {},
                      ),
                      const SizedBox(width: 8),
                    ],
                  );
                },
                expandedBuilder: (context) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: 50,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1),
                        child: Text(
                          '[\$ flutter run] Line $index: Application output...',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Menlo',
                            color: CNTheme.of(context).labelColor,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              child: _DesktopDemoShell(
                selectedIndex: selectedIndex,
                searchQuery: searchQuery,
                onSearchChanged: (value) {
                  debugPrint('Search changed: $value');
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _SideBar extends StatelessWidget {
  const _SideBar({
    required this.onItemSelected,
    required this.selectedIndex,
    this.searchQuery,
  });

  final void Function(int index) onItemSelected;
  final String? searchQuery;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = CNTheme.of(context).accentColor;
    final isBright = (accentColor?.computeLuminance() ?? 0) > 0.5;
    final labelColor = theme.labelColor;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        final isSelected = index == selectedIndex;
        final isValidEntry =
            searchQuery == null ||
            searchQuery!.isEmpty ||
            entry.title.toLowerCase().contains(searchQuery!.toLowerCase());

        if (!isValidEntry) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () => onItemSelected(index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor?.withValues(alpha: 1.0)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                CNImage(
                  constraints: const BoxConstraints(
                    maxWidth: 18,
                    maxHeight: 18,
                  ),
                  systemSymbolName: entry.symbolName,
                  foregroundColor: isSelected
                      ? isBright
                            ? CNColors.black
                            : CNColors.white
                      : (isDark
                            ? CupertinoColors.label.darkColor
                            : CupertinoColors.label.color),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.title,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? (isBright
                                ? CNColors.label.color
                                : CNColors.label.darkColor)
                          : labelColor,
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
  const _StatusBarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : isActive = false;

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
          color: isActive
              ? CNColors.fillPrimary.withAlpha(40)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: CNColors.label),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: CNColors.label),
            ),
          ],
        ),
      ),
    );
  }
}

CNToolbarItem createToolbarThemePicker(BuildContext context) {
  final appTheme = context.watch<AppTheme>();

  return CNToolbarPicker(
    pickerStyle: CNPickerStyle.menu,
    selection: appTheme.mode.name,
    children: [
      CNChildLabel(
        'System Theme',
        tag: ThemeMode.system.name,
        systemImage: 'sun.lefthalf.filled',
      ),
      CNChildLabel(
        'Light Theme',
        tag: ThemeMode.light.name,
        systemImage: 'sun.max',
      ),
      CNChildLabel(
        'Dark Theme',
        tag: ThemeMode.dark.name,
        systemImage: 'moon.fill',
      ),
    ],
    onChanged: (tag) => appTheme.mode = ThemeMode.values.byName(tag),
  );
}
