import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, ThemeMode;
import 'package:flutter/scheduler.dart';
import 'package:flutter_acrylic/window.dart';
import 'package:flutter_acrylic/window_effect.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemTheme.accentColor.load();
  await Window.initialize();
  await Window.setEffect(effect: WindowEffect.sidebar);
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
  const _DesktopDemoShell();

  @override
  State<_DesktopDemoShell> createState() => _DesktopDemoShellState();
}

class _DesktopDemoShellState extends State<_DesktopDemoShell> {
  static const _entries = <_DemoEntry>[
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

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        SizedBox(
          width: 250,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0x00F0F0F0),
              borderRadius: BorderRadius.circular(8)
            ),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                final isSelected = index == _selectedIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? CupertinoColors.activeBlue.withValues(alpha: 0.2)
                          : Colors.transparent,
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
          ),
        ),
        Expanded(
          child: KeyedSubtree(
            key: ValueKey(_selectedIndex),
            child: _entries[_selectedIndex].page,
          ),
        ),
      ],
    );
  }
}

class _MyAppState extends State<MyApp> {
  Color? _accentColor;

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
    return SystemThemeBuilder(
      builder: (context, color) {
        _accentColor ??= color.accent;
        return ChangeNotifierProvider(
          create: (_) => AppTheme(),
          builder: (context, child) {
            final appTheme = context.watch<AppTheme>();
            final brightness = appTheme.mode == ThemeMode.system
                ? WidgetsBinding.instance.platformDispatcher.platformBrightness
                : (appTheme.mode == ThemeMode.dark ? Brightness.dark : Brightness.light);

            return CNTheme(
              data: CNThemeData(brightness: brightness, primaryColor: _accentColor ?? color.accent),
              child: CupertinoApp(
                debugShowCheckedModeBanner: false,
                home: const _DesktopDemoShell(),
              ),
            );
          },
        );
      },
    );
  }
}
