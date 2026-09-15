import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:macos_window_utils/widgets/visual_effect_subview_container/visual_effect_subview_container.dart';

const Size _kWindowSize = Size(1200, 800);

/// Marks the content of each part whose background/material is measured.
const Key _kSidebarKey = Key('sidebar-content');
const Key _kEndSidebarKey = Key('end-sidebar-content');
const Key _kStatusBarKey = Key('status-bar-item');
const Key _kPanelKey = Key('status-bar-panel');
const Key _kToolbarTitleKey = Key('toolbar-title');

const Color _kExplicitColor = Color(0xFF112233);

/// The theme the window resolved its defaults against.
CNThemeData? _theme;

/// Pumps a [CNWindow] with both sidebars, a status bar with its panel expanded
/// and — when [toolBar] is set — a toolbar, so every part's background and
/// visual effect view can be inspected at once.
Future<void> _pumpWindow(
  WidgetTester tester, {
  NSVisualEffectViewMaterial? windowMaterial,
  NSVisualEffectViewState windowState = NSVisualEffectViewState.active,
  NSVisualEffectViewMaterial? sidebarMaterial,
  NSVisualEffectViewState? sidebarState,
  Color? sidebarColor,
  NSVisualEffectViewMaterial? statusBarMaterial,
  NSVisualEffectViewMaterial? statusBarExpandedMaterial,
  NSVisualEffectViewState? statusBarState,
  CNToolbar? toolBar,
}) async {
  tester.view.physicalSize = _kWindowSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    CNApp(
      home: (context) {
        _theme = CNTheme.of(context);
        return CNWindow(
          material: windowMaterial,
          state: windowState,
          sidebar: CNSidebar(
            minWidth: 250,
            startWidth: 250,
            material: sidebarMaterial,
            state: sidebarState,
            backgroundColor: sidebarColor,
            builder: (context) => const SizedBox.expand(key: _kSidebarKey),
          ),
          endSidebar: CNSidebar(
            minWidth: 200,
            startWidth: 200,
            shownByDefault: true,
            builder: (context) => const SizedBox.expand(key: _kEndSidebarKey),
          ),
          statusBar: CNStatusBar(
            material: statusBarMaterial,
            expandedMaterial: statusBarExpandedMaterial,
            state: statusBarState,
            shownByDefault: true,
            leftItems: (context, isExpanded) =>
                const SizedBox.shrink(key: _kStatusBarKey),
            expandedBuilder: (context) =>
                const SizedBox.expand(key: _kPanelKey),
          ),
          child: CNPageScaffold(toolBar: toolBar, child: const SizedBox.expand()),
        );
      },
    ),
  );
  // Flush the zero-duration timers the visual-effect containers post on build.
  await tester.pump(Duration.zero);
}

/// The color painted by the closest background box around the part marked [key].
Color? _backgroundOf(WidgetTester tester, Key key) {
  final box = find
      .ancestor(
        of: find.byKey(key),
        matching: find.byWidgetPredicate(
          (widget) => widget is ColoredBox || widget is DecoratedBox,
        ),
      )
      .evaluate()
      .first
      .widget;
  if (box is ColoredBox) return box.color;
  final decoration = (box as DecoratedBox).decoration;
  return decoration is BoxDecoration ? decoration.color : null;
}

/// The visual effect view wrapping the part marked [key], or null when that part
/// has none of its own.
VisualEffectSubviewContainer? _effectOf(WidgetTester tester, Key key) {
  final finder = find.ancestor(
    of: find.byKey(key),
    matching: find.byType(VisualEffectSubviewContainer),
  );
  final candidates = finder.evaluate();
  return candidates.isEmpty
      ? null
      : candidates.first.widget as VisualEffectSubviewContainer;
}

void main() {
  testWidgets('with no material anywhere, every part paints the canvas color '
      'and adds no visual effect view', (tester) async {
    await _pumpWindow(tester);

    expect(_backgroundOf(tester, _kSidebarKey), _theme!.canvasColor);
    expect(_backgroundOf(tester, _kEndSidebarKey), _theme!.canvasColor);
    expect(_backgroundOf(tester, _kStatusBarKey), _theme!.canvasColor);
    expect(_backgroundOf(tester, _kPanelKey), _theme!.canvasColor);

    expect(_effectOf(tester, _kSidebarKey), isNull);
    expect(_effectOf(tester, _kStatusBarKey), isNull);
    expect(_effectOf(tester, _kPanelKey), isNull);
  });

  testWidgets('a window material makes every part transparent so the '
      'window-wide blur shows through, without per-part views', (tester) async {
    await _pumpWindow(
      tester,
      windowMaterial: NSVisualEffectViewMaterial.underWindowBackground,
    );

    expect(_backgroundOf(tester, _kSidebarKey), CNColors.transparent);
    expect(_backgroundOf(tester, _kEndSidebarKey), CNColors.transparent);
    expect(_backgroundOf(tester, _kStatusBarKey), CNColors.transparent);
    expect(_backgroundOf(tester, _kPanelKey), CNColors.transparent);

    expect(_effectOf(tester, _kSidebarKey), isNull);
    expect(_effectOf(tester, _kStatusBarKey), isNull);
    expect(_effectOf(tester, _kPanelKey), isNull);
  });

  testWidgets('an explicit part color still wins over the transparent default', (
    tester,
  ) async {
    await _pumpWindow(
      tester,
      windowMaterial: NSVisualEffectViewMaterial.underWindowBackground,
      sidebarColor: _kExplicitColor,
    );

    expect(_backgroundOf(tester, _kSidebarKey), _kExplicitColor);
    expect(_backgroundOf(tester, _kEndSidebarKey), CNColors.transparent);
  });

  testWidgets('a part material adds a visual effect view of its own, following '
      'the window state, and only for that part', (tester) async {
    await _pumpWindow(
      tester,
      sidebarMaterial: NSVisualEffectViewMaterial.sidebar,
      statusBarMaterial: NSVisualEffectViewMaterial.headerView,
    );

    final sidebarEffect = _effectOf(tester, _kSidebarKey);
    expect(sidebarEffect?.material, NSVisualEffectViewMaterial.sidebar);
    expect(sidebarEffect?.state, NSVisualEffectViewState.active);
    // Its own material makes the sidebar transparent even with no window-wide
    // one, and clears whatever the window painted behind it.
    expect(_backgroundOf(tester, _kSidebarKey), CNColors.transparent);

    expect(
      _effectOf(tester, _kStatusBarKey)?.material,
      NSVisualEffectViewMaterial.headerView,
    );
    // The expanded panel falls back to the bar's material…
    expect(
      _effectOf(tester, _kPanelKey)?.material,
      NSVisualEffectViewMaterial.headerView,
    );
    // …while a part left alone keeps the canvas color and no view.
    expect(_backgroundOf(tester, _kEndSidebarKey), _theme!.canvasColor);
    expect(_effectOf(tester, _kEndSidebarKey), isNull);
  });

  testWidgets('a part state overrides the window state', (tester) async {
    await _pumpWindow(
      tester,
      sidebarMaterial: NSVisualEffectViewMaterial.sidebar,
      sidebarState: NSVisualEffectViewState.inactive,
      statusBarMaterial: NSVisualEffectViewMaterial.headerView,
      statusBarState: NSVisualEffectViewState.followsWindowActiveState,
    );

    expect(
      _effectOf(tester, _kSidebarKey)?.state,
      NSVisualEffectViewState.inactive,
    );
    expect(
      _effectOf(tester, _kStatusBarKey)?.state,
      NSVisualEffectViewState.followsWindowActiveState,
    );
  });

  testWidgets('the expanded panel can blur differently from the bar', (
    tester,
  ) async {
    await _pumpWindow(
      tester,
      statusBarMaterial: NSVisualEffectViewMaterial.headerView,
      statusBarExpandedMaterial: NSVisualEffectViewMaterial.contentBackground,
    );

    expect(
      _effectOf(tester, _kStatusBarKey)?.material,
      NSVisualEffectViewMaterial.headerView,
    );
    expect(
      _effectOf(tester, _kPanelKey)?.material,
      NSVisualEffectViewMaterial.contentBackground,
    );
  });

  testWidgets('a toolbar material adds a visual effect view under the bar, '
      'following the window state', (tester) async {
    await _pumpWindow(
      tester,
      toolBar: const CNToolbar(
        automaticallyImplyLeading: false,
        material: NSVisualEffectViewMaterial.headerView,
        title: Text('Title', key: _kToolbarTitleKey),
      ),
    );

    final effect = _effectOf(tester, _kToolbarTitleKey);
    expect(effect?.material, NSVisualEffectViewMaterial.headerView);
    expect(effect?.state, NSVisualEffectViewState.active);
  });

  testWidgets('a toolbar with no material of its own adds no visual effect '
      'view, so the window-wide material runs behind the bar', (tester) async {
    await _pumpWindow(
      tester,
      windowMaterial: NSVisualEffectViewMaterial.underWindowBackground,
      toolBar: const CNToolbar(
        automaticallyImplyLeading: false,
        title: Text('Title', key: _kToolbarTitleKey),
      ),
    );

    expect(_effectOf(tester, _kToolbarTitleKey), isNull);
  });

  testWidgets('a toolbar state overrides the window state', (tester) async {
    await _pumpWindow(
      tester,
      toolBar: const CNToolbar(
        automaticallyImplyLeading: false,
        material: NSVisualEffectViewMaterial.headerView,
        state: NSVisualEffectViewState.inactive,
        title: Text('Title', key: _kToolbarTitleKey),
      ),
    );

    expect(
      _effectOf(tester, _kToolbarTitleKey)?.state,
      NSVisualEffectViewState.inactive,
    );
  });
}
