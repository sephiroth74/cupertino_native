# Cupertino Native

Real native macOS controls — SwiftUI and AppKit — embedded inside Flutter, with a Flutter-idiomatic API.

Widgets in this package are not repainted look-alikes: each one hosts an actual `NSView` / SwiftUI view through Flutter platform views and drives it over method channels. You get exact system rendering (including Liquid Glass materials, SF Symbols, focus rings and accent-color behaviour) while writing ordinary Dart.

---

## This is a fork

This package is a fork of [**serverpod/cupertino_native**](https://github.com/serverpod/cupertino_native) (also on [pub.dev](https://pub.dev/packages/cupertino_native)), created by [Serverpod](https://serverpod.dev) as a proof of concept for bringing Liquid Glass to Flutter. All credit for the original idea and the first implementation goes to them — see their write-up, [_Is it time for Flutter to leave the uncanny valley?_](https://medium.com/serverpod/is-it-time-for-flutter-to-leave-the-uncanny-valley-b7f2cdb834ae).

The fork keeps the original BSD 3-Clause license and the `CN*` naming, but the internals and the widget set have diverged substantially. It is developed independently and is **not** an official Serverpod release.

Fork home: <https://github.com/sephiroth74/cupertino_native>

## How this fork differs from upstream

**Scope and requirements**

- **macOS only.** iOS support has been dropped; every widget targets AppKit/SwiftUI on the desktop.
- **macOS 26.0+ is required** (upstream targets macOS 11+). The native target is built against the macOS 26 SDK and uses its APIs directly, so there is no back-deployment path.

**Rewritten architecture**

- All widgets share a single base — `CNWidget` / `CNWidgetState` on the Dart side, `CNWidgetNSView<P>` + `CNViewModel<P>` on the Swift side. Adding a widget means writing a payload, a SwiftUI body and a factory; layout, sizing, channel lifecycle and diffing come for free.
- **Patch-based syncing:** each rebuild sends a minimal, type-aware diff of the widget payload instead of the full state.
- **Intrinsic sizing model:** every widget supports `shrink` — either the native view reports its intrinsic size back to Dart (`shrink: true`), or Dart resolves constraints and hands them to SwiftUI's `.frame(min/ideal/max)` (`shrink: false`).
- Most controls are now **SwiftUI-hosted** rather than raw AppKit wrappers, which is what makes styles like `CNButtonStyle.glass` and `CNSymbolRenderingMode` available.

**Much larger widget set**

Upstream ships around eight widgets. This fork ships the full list in [Widgets](#widgets) below, including text input (`CNTextField`, `CNSecureField`, `CNTextEditor`, `CNSearchField`, `CNComboBox`), pickers (`CNPicker`, `CNDatePicker`, `CNColorWell`, `CNPathControl`), indicators (`CNGauge`, `CNProgressView`) and menus (`CNMenu`, `CNContextMenuRegion`, `CNPopover`).

**Application shell**

A whole layer that does not exist upstream: `CNApp`, `CNWindow` (with sidebars, end sidebar and an expandable status bar), `CNPageScaffold`, `CNToolbar` with native toolbar items, `CNSidebar`, `CNStatusBar`, `CNScrollbar`, `CNResizablePane` and multi-window support.

**Extended theming**

`CNThemeData` grew from a handful of semantic colors into a full token set: five fill levels, glass materials, HIG typography, per-widget theme data (`CNButtonThemeData`, `CNSliderThemeData`, `CNToggleThemeData`, …), `CNStateColor` for per-state colors, and live tracking of the user's system accent color via `CNAccentColorListener`.

### Coming from upstream

Several upstream APIs were renamed or replaced:

| Upstream | This fork |
| --- | --- |
| `CNIcon(symbol: CNSymbol('star'))` | `CNImage(systemSymbolName: 'star')` |
| `CNButton(label: 'Press')` | `CNButton(children: [CNChildText('Press')])` |
| `CNButton.icon(icon: …)` | `CNIconButton(systemSymbolName: …)` or `CNButton` with a `CNChildImage` |
| `CNSwitch` | `CNToggle` |
| `CNPopupMenuButton` / `CNPopupMenuItem` | `CNMenu(items: [CNChildButton(…)], label: …)` |
| `CNMenu` / `CNMenuItem` (context menus) | `CNContextMenuRegion(items: [CNChildButton(…)])` |
| `CNTabBar` / `CNTabBarItem` | `CNTabView` + `CNTabController` (or `CNSegmentedControl`) |
| `CNSplitView` / `CNSplitViewController` | `CNPageScaffold(children: …)` with `CNResizablePane`, or `CNWindow(sidebar: …)` |
| `CNAlertAction`, `CNPopoverAction` | `CNChildButton` |
| `CNThemeData.primaryColor` | `CNThemeData.accentColor` (`userAccentColor` ?? `systemAccentColor`) |

## Requirements

- macOS **26.0** or later (both the build machine and the target)
- Xcode **26** or later
- Flutter **>= 3.44.0**, Dart **>= 3.8.0**

## Installation

This fork is not published on pub.dev (the `cupertino_native` name there belongs to upstream), so depend on it via Git:

```yaml
dependencies:
  cupertino_native:
    git:
      url: https://github.com/sephiroth74/cupertino_native.git
      ref: main
```

Then set your app's macOS deployment target to 26.0:

```ruby
# macos/Podfile
platform :osx, '26.0'
```

and in `macos/Runner.xcodeproj` set `MACOSX_DEPLOYMENT_TARGET = 26.0` for every configuration.

If you drive the window yourself (transparent titlebar, full-size content view, …) also add [`macos_window_utils`](https://pub.dev/packages/macos_window_utils) to your app — this package depends on it internally, but you need a direct dependency to import `WindowManipulator`.

## Widgets

### Controls

| Widget | Native backing |
| --- | --- |
| `CNButton` | SwiftUI `Button`; label composed from `CNChild` elements, `CNButtonStyle` includes `glass` / `prominentGlass` |
| `CNIconButton` | Borderless SF Symbol button with idle / hovered / pressed / selected / disabled state colors |
| `CNSegmentedControl` | `NSSegmentedControl`; single, multiple and momentary selection |
| `CNSlider` | SwiftUI `Slider` with optional steps, tick marks and edge labels |
| `CNStepper` | SwiftUI `Stepper` |
| `CNToggle` | SwiftUI `Toggle` (switch, checkbox and button styles) |
| `CNPicker` | SwiftUI `Picker` (menu, segmented, inline, …) |
| `CNDatePicker` | SwiftUI `DatePicker`, per-component configuration |
| `CNColorWell` | Native color well / color panel |
| `CNPathControl` | `NSPathControl` breadcrumb, optionally editable with an open panel |
| `CNComboBox` | Editable `CNTextField` plus a window-level `NSMenu` drop-down |

### Text and images

| Widget | Native backing |
| --- | --- |
| `CNText` | SwiftUI `Text` with `CNFont`, line limits, truncation and text scale |
| `CNLabel` | SwiftUI `Label` (title + SF Symbol) |
| `CNImage` | SF Symbols with hierarchical, palette and multicolor rendering modes |
| `CNTextField` | SwiftUI `TextField`, driven by a `TextEditingController` |
| `CNSecureField` | SwiftUI `SecureField` |
| `CNTextEditor` | Multi-line native editor that fills its constraints |
| `CNSearchField` | Native search field with a `TextEditingController` and asynchronous, sectioned completion suggestions (title, subtitle, SF Symbol) |

### Indicators

| Widget | Native backing |
| --- | --- |
| `CNGauge` | SwiftUI `Gauge` with labels and gradient tint |
| `CNProgressView` | SwiftUI `ProgressView`, linear or circular, determinate (`value`) or indeterminate |

### Menus, alerts and overlays

| Widget | Native backing |
| --- | --- |
| `CNMenu` | SwiftUI `Menu` / pull-down button, supports sub-menus and a primary action |
| `CNContextMenuRegion` | `NSMenu` on secondary click over any Flutter subtree |
| `CNAlert` | `NSAlert` as a modal dialog (`show`) or window sheet (`showSheet`), with suppression checkbox |
| `CNPopover` | `NSPopover` anchored to any widget's `BuildContext` |

### Application shell and layout

| Widget | Purpose |
| --- | --- |
| `CNApp` | App root: builds `CNTheme` for light/dark, tracks the main window and window geometry |
| `CNWindow` / `CNWindowScope` | Window chrome: visual-effect background, leading and trailing sidebars, status bar |
| `CNPageScaffold` / `CNContentArea` | Page body with a toolbar; single `child` or a split layout of resizable panes |
| `CNToolbar` | Toolbar with native items: `CNToolbarButton`, `CNToolbarIconButton`, `CNToolbarPullDownButton`, `CNToolbarPicker`, `CNToolbarComboBox`, plus `CNToolbarDivider`, `CNToolbarSpacer` and `CNToolbarCustomItem` |
| `CNSidebar` | Resizable, collapsible sidebar configuration for `CNWindow` |
| `CNStatusBar` | Bottom status bar with an expandable panel (push or overlay presentation) |
| `CNTabView` / `CNTabController` | Tabbed container driven by a native segmented control |
| `CNResizablePane` | Standalone resizable pane |
| `CNGroupBox` | SwiftUI-style `GroupBox` grouping with optional title |
| `CNScrollbar` | macOS-styled scrollbar |
| `CNPageRoute` | Page route matching macOS navigation transitions |

### Building blocks and utilities

- **`CNChild` family** — declarative content passed into native views: `CNChildText`, `CNChildImage`, `CNChildLabel`, `CNChildButton`, `CNChildDivider`, `CNChildGroup`, `CNChildHStack`, `CNChildVStack`, `CNChildMenu`, `CNChildPicker`, `CNChildProgressView`, `CNChildTextField`, `CNChildToggle`.
- **Theming** — `CNTheme`, `CNThemeData`, `CNTypography`, `CNColors`, `CNStateColor`, `CNGlassMaterial`, per-widget `*ThemeData` classes.
- **Styling** — `CNBackground`, `CNOverlay`, `CNShape`, `CNShapeStyle`, `CNFont`, `CNControlSize`.
- **Helpers** — `CNAccentColorListener` / `CNAccentColorBuilder` (live system accent color), `MainWindowStreamBuilder`, `CNPixelPerfectContainer` and `CNWindowGeometryScope` for pixel-exact alignment between Flutter and native layers.

## Quick start

```dart
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/widgets.dart';
import 'package:macos_window_utils/macos_window_utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowManipulator.initialize(enableWindowDelegate: true);
  // Fetches the current system accent color and keeps CNTheme in sync with it.
  await CNAccentColorListener.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CNApp(
      title: 'Cupertino Native',
      home: (context) => CNWindow(
        backgroundColor: CNTheme.of(context).canvasColor,
        child: const PlaybackPage(),
      ),
    );
  }
}

class PlaybackPage extends StatefulWidget {
  const PlaybackPage({super.key});

  @override
  State<PlaybackPage> createState() => _PlaybackPageState();
}

class _PlaybackPageState extends State<PlaybackPage> {
  bool _muted = false;
  double _volume = 0.4;

  @override
  Widget build(BuildContext context) {
    return CNPageScaffold(
      toolBar: const CNToolbar(title: Text('Playback')),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            CNSlider(
              value: _volume,
              onChanged: (value) => setState(() => _volume = value),
            ),
            CNToggle(
              isOn: _muted,
              content: const CNChildLabel('Mute', systemImage: 'speaker.slash'),
              onChanged: (value) => setState(() => _muted = value),
            ),
            CNButton(
              buttonStyle: CNButtonStyle.glass,
              children: const [CNChildLabel('Play', systemImage: 'play.fill')],
              onPressed: () => CNAlert.show(
                context,
                title: 'Now playing',
                message: 'Volume is at ${(_volume * 100).round()}%.',
                actions: const [CNChildButton(tag: 'ok', title: 'OK')],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Theming

`CNApp` installs a `CNTheme` for you and switches it with `themeMode`. Read tokens from anywhere below it:

```dart
final theme = CNTheme.of(context);

Text('Hello', style: theme.typography.body);
Container(color: theme.canvasColor);
CNButton(
  tint: theme.accentColor, // user accent color, falling back to the system one
  children: const [CNChildText('Continue')],
  onPressed: () {},
);
```

Resolution order for every styled property:

1. Explicit widget parameter (`tint`, `foregroundColor`, `font`, …)
2. Component-level override (`CNThemeData.buttonTheme`, `.sliderTheme`, …)
3. `CNThemeData` semantic default

Pass `lightTheme` / `darkTheme` to `CNApp` to replace the defaults wholesale.

## Example app

The repository contains a full demo application with one page per widget — including a *Theme Tokens* page, a sidebar, a native toolbar and an expandable status bar. It is the most complete reference for the API.

👉 [`example/`](example/) — see [`example/lib/main.dart`](example/lib/main.dart) for the app shell and [`example/lib/demos/`](example/lib/demos/) for the per-widget pages.

```bash
cd example
flutter run -d macos
```

## Screenshots

<!--
TODO: add screenshots of the demo app.
Suggested set: app shell (sidebar + toolbar + status bar), buttons and toggles,
text input, pickers and date picker, gauges and progress, menus and popovers,
light and dark side by side.

![App shell](misc/screenshots/app-shell.png)
-->

_Screenshots coming soon._

## Status and limitations

- macOS 26 only — there is no iOS, Windows, Linux or web implementation, and no fallback rendering on older macOS versions.
- Non-macOS platforms build, but the widgets render as empty boxes.
- Native platform views do not compose freely with Flutter scrolling and clipping; scroll views containing native controls still need care.
- The API is not stable yet. Expect renames between versions.

## Contributing

Issues and pull requests are welcome at <https://github.com/sephiroth74/cupertino_native/issues>.

Before opening a PR:

```bash
flutter analyze
flutter test
```

New widgets should follow the `CNWidget` / `CNWidgetState` + `CNWidgetNSView` architecture; public APIs need doc comments (`public_member_api_docs` is enforced).

## License

BSD 3-Clause — see [LICENSE](LICENSE). Copyright (c) 2025 Serverpod AB for the original work, retained in this fork.
