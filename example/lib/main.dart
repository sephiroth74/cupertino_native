import 'dart:io';

import 'package:cupertino_native/app/cn_app.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:cupertino_native_example/demos/consts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, ThemeMode;
import 'package:flutter/scheduler.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:provider/provider.dart';
import 'package:system_theme/system_theme.dart';

import 'demos/cn_alert_demo.dart';
import 'demos/cn_button_demo.dart';
import 'demos/cn_color_well_demo.dart';
import 'demos/cn_context_menu.dart';
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
import 'demos/cn_secure_field_demo.dart';
import 'demos/cn_slider_demo.dart';
import 'demos/cn_stepper_demo.dart';
import 'demos/cn_text_demo.dart';
import 'demos/cn_text_field_demo.dart';
import 'demos/cn_toggle_demo.dart';
import 'demos/theme.dart';

const _entries = <_DemoEntry>[
  _DemoEntry('CNAlert', 'exclamationmark.bubble', AlertDemoPage()),
  _DemoEntry('CNButton', 'button.horizontal', ButtonDemoPage()),
  _DemoEntry('CNColorWell', 'paintpalette', ColorWellDemoPage()),
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
  _DemoEntry('CNSecureField', 'lock.shield', SecureTextFieldDemoPage()),
  _DemoEntry('CNSlider', 'slider.horizontal.3', SliderDemoPage()),
  _DemoEntry('CNStepper', 'plusminus', StepperDemoPage()),
  _DemoEntry('CNText', 'text.viewfinder', TextDemoPage()),
  _DemoEntry('CNTextField', 'character.cursor.ibeam', TextFieldDemoPage()),
  _DemoEntry('CNToggle', 'switch.2', ToggleDemo()),
  _DemoEntry('Theme Tokens', 'paintbrush.pointed', ThemeDemoPage()),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CNAccentColorListener.load();
  WindowManipulator.initialize(enableWindowDelegate: true);
  // await Window.initialize();
  // await Window.setEffect(effect: WindowEffect.sidebar);
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

class _SideBar extends StatelessWidget {
  const _SideBar({required this.onItemSelected, required this.accentColor, required this.selectedIndex});

  final Color? accentColor;
  final void Function(int index) onItemSelected;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = CNTheme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final entry = _entries[index];
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onItemSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? CupertinoColors.activeBlue.withValues(alpha: 0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  CNImage2(
                    constraints: const BoxConstraints(maxWidth: 18, maxHeight: 18),
                    systemSymbolName: entry.symbolName,
                    foregroundColor: isSelected
                        ? CupertinoColors.activeBlue
                        : (isDark ? CupertinoColors.label.darkColor : CupertinoColors.label.color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.title,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? CupertinoColors.label.darkColor : CupertinoColors.label.color,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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

class _DesktopDemoShell extends StatefulWidget {
  const _DesktopDemoShell({required this.appTheme, required this.brightness, required this.accentColor});

  final Color? accentColor;
  final AppTheme appTheme;
  final Brightness brightness;

  @override
  State<_DesktopDemoShell> createState() => _DesktopDemoShellState();
}

class _DesktopDemoShellState extends State<_DesktopDemoShell> {
  int _selectedIndex = 0;

  @override
  void didUpdateWidget(covariant _DesktopDemoShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (mounted) {
      setBrightness(widget.brightness);
    }
  }

  @override
  void initState() {
    super.initState();
    setWindowEffect();
  }

  void setWindowEffect() {
    // Window.setEffect(effect: value!, color: color, dark: widget.brightness == Brightness.dark);
    WindowManipulator.setMaterial(NSVisualEffectViewMaterial.sidebar);

    if (Platform.isMacOS) {
      if (widget.brightness != Brightness.light && widget.brightness != Brightness.dark) {
        WindowManipulator.overrideMacOSBrightness(dark: widget.brightness == Brightness.dark);
      }
    }
    // setState(() => effect = value);
  }

  void setBrightness(Brightness brightness) {
    // this.brightness = brightness;
    setWindowEffect();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 250,
          child: _SideBar(
            selectedIndex: _selectedIndex,
            accentColor: widget.accentColor,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
        Expanded(
          child: KeyedSubtree(key: ValueKey(_selectedIndex), child: _entries[_selectedIndex].page),
        ),
      ],
    );
  }
}

class _MyAppState extends State<MyApp> {
  late Brightness brightness;

  @override
  void initState() {
    super.initState();
    var dispatcher = SchedulerBinding.instance.platformDispatcher;
    dispatcher.onPlatformBrightnessChanged = () {
      setState(() {});
    };
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
          home: Builder(
            builder: (context) {
              final theme = CNTheme.of(context);
              final accentColor = theme.accentColor;

              return CNToolbar(
                config: CNToolbarConfig(
                  onSearchChanged: (value) {
                    debugPrint('Search changed: $value');
                  },
                  onItemPressed: (value) {
                    debugPrint('Toolbar item pressed: $value');
                    final tags = value.split(':');
                    if (tags.length == 2 && tags[0] == 'theme_picker') {
                      final selectedTag = tags[1];
                      if (selectedTag == ThemeMode.system.name) {
                        appTheme.mode = ThemeMode.system;
                      } else if (selectedTag == ThemeMode.light.name) {
                        appTheme.mode = ThemeMode.light;
                      } else {
                        appTheme.mode = ThemeMode.dark;
                      }
                    } else if (tags.length == 2 && tags[0] == 'accent_color') {
                      final selectedTag = tags[1];
                      if (selectedTag == 'system') {
                        context.read<CNTheme>().data.copyWith(primaryColor: SystemTheme.accentColor.accent);
                      } else {
                        final selectedColor = kSystemColors[selectedTag];
                        if (selectedColor != null) {
                          context.read<CNTheme>().data.copyWith(primaryColor: selectedColor);
                        }
                      }
                      setState(() {});
                    }
                  },
                  searchable: true,
                  titleDisplayMode: CNToolbarTitleDisplayMode.automatic,
                  toolbarBackground: accentColor.withAlpha(234),
                  toolbarBlurEnabled: true,
                  toolbarBlurMaterial: CNToolbarBlurMaterial.titlebar,
                  title: CNChildText('Cupertino Native Demo'),
                  groups: [
                    CNToolbarItemGroup(
                      placement: CNToolbarPlacement.primaryAction,
                      children: [
                        CNChildButton(
                          tag: 'toggle_navigation',
                          title: 'Toggle Navigation',
                          systemImage: 'sidebar.left',
                          labelStyle: CNLabel2Style.iconOnly,
                          badge: 2,
                        ),
                      ],
                    ),
                    CNToolbarItemGroup(
                      placement: CNToolbarPlacement.automatic,
                      children: [
                        CNChildPicker(
                          pickerStyle: CNPickerStyle2.menu.name,
                          labelStyle: CNLabel2Style.titleAndIcon,
                          tag: 'theme_picker',
                          label: [
                            CNChildLabel(
                              appTheme.mode.name,
                              labelStyle: CNLabel2Style.titleAndIcon,
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
                child: _DesktopDemoShell(appTheme: appTheme, brightness: brightness, accentColor: accentColor),
              );
            },
          ),
        );
      },
    );
  }
}
