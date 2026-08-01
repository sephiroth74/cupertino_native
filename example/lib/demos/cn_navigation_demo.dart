import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

/// Bridges the content-area [Navigator] of [NavigationDemoPage] with the
/// window-level native toolbar `navigation.back` button defined in `main.dart`.
///
/// Provided app-wide (above `CNApp`) so both the toolbar callbacks and the
/// nested navigator can reach the same instance.
class NavigationController extends ChangeNotifier {
  /// Key of the content-area [Navigator], used to pop from the toolbar.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool _canGoBack = false;

  /// Whether the content-area navigator currently has a page to pop.
  ///
  /// The toolbar back button binds its `enabled` state to this value.
  bool get canGoBack => _canGoBack;

  /// Updates [canGoBack] and notifies listeners only on a real change.
  void setCanGoBack(bool value) {
    if (_canGoBack == value) return;
    _canGoBack = value;
    notifyListeners();
  }

  /// Pops the content-area navigator (invoked by the toolbar back button).
  void goBack() => navigatorKey.currentState?.maybePop();
}

/// Observes push/pop on the nested navigator and reports whether it can pop.
class _BackObserver extends NavigatorObserver {
  _BackObserver(this.onChanged);

  final ValueChanged<bool> onChanged;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _sync();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _sync();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => _sync();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => _sync();

  void _sync() => onChanged(navigator?.canPop() ?? false);
}

/// Demonstrates route-based navigation with [CNPageRoute].
///
/// Two distinct patterns are shown side by side:
///
///  1. **Content-area navigation** — a nested [Navigator] scopes pushes to the
///     content area, so the sidebar, the native toolbar and the status bar stay
///     fixed while master → detail pages slide in. This is the idiomatic macOS
///     pattern. The window toolbar's `navigation.back` button reflects and
///     drives this navigator via [NavigationController].
///
///  2. **Window-level navigation** — pushing on the root navigator
///     (`rootNavigator: true`) presents a page that covers the whole Flutter
///     content view. Note: the native `NSToolbar` lives in the window titlebar
///     (outside the Flutter view), so it remains visible.
class NavigationDemoPage extends StatefulWidget {
  const NavigationDemoPage({super.key});

  @override
  State<NavigationDemoPage> createState() => _NavigationDemoPageState();
}

class _NavigationDemoPageState extends State<NavigationDemoPage> {
  NavigationController? _controller;
  late final _BackObserver _observer = _BackObserver(_onStackChanged);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = context.read<NavigationController>();
  }

  @override
  void dispose() {
    // Reset the shared state so the toolbar back button disables once this demo
    // is no longer visible. Deferred because dispose runs during a build.
    final controller = _controller;
    WidgetsBinding.instance.addPostFrameCallback((_) => controller?.setCanGoBack(false));
    super.dispose();
  }

  void _onStackChanged(bool canPop) {
    // Observer callbacks can fire during a build (the initial route push), so
    // defer the notify to avoid setState-during-build in the toolbar owner.
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller?.setCanGoBack(canPop));
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<NavigationController>();
    // A nested Navigator keeps every push inside the content area. Its initial
    // ('/') route is the master list; detail pages are pushed onto it via
    // Navigator.of(context) (which resolves to this nearest navigator).
    return Navigator(
      key: controller.navigatorKey,
      observers: [_observer],
      onGenerateRoute: (settings) => CNPageRoute(
        builder: (_) => const _MasterPage(),
        settings: settings,
      ),
    );
  }
}

/// Sample data shown in the master list.
class _Item {
  const _Item(this.title, this.symbol, this.detail);

  final String detail;
  final String symbol;
  final String title;
}

const _items = <_Item>[
  _Item('Overview', 'square.grid.2x2', 'A summary page pushed onto the content-area navigator.'),
  _Item('Documents', 'doc.text', 'Push detail pages while the sidebar and toolbar stay put.'),
  _Item('Downloads', 'arrow.down.circle', 'The native back button calls Navigator.of(context).maybePop().'),
  _Item('Settings', 'gearshape', 'Every level uses CNPageScaffold + CNNavigationBar.'),
];

// ============================================================================
// Pattern 1 — content-area (nested navigator)
// ============================================================================

class _MasterPage extends StatelessWidget {
  const _MasterPage();

  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);

    return CNPageScaffold(
      navigationBar: const CNNavigationBar(middle: Text('Navigation')),
      child: CNContentArea(
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              Text('Content-area navigation', style: theme.typography.title2),
              const SizedBox(height: 4),
              Text(
                'Tapping a row pushes a detail page onto a nested Navigator, '
                'so the sidebar, native toolbar and status bar remain fixed.',
                style: theme.typography.subheadline.copyWith(color: theme.secondaryLabelColor),
              ),
              const SizedBox(height: 16),
              for (final item in _items)
                _NavRow(
                  item: item,
                  onTap: () => Navigator.of(context).push(
                    CNPageRoute(builder: (_) => _DetailPage(item: item, depth: 1)),
                  ),
                ),
              const SizedBox(height: 32),
              Text('Window-level navigation', style: theme.typography.title2),
              const SizedBox(height: 4),
              Text(
                'Pushing on the root navigator presents a page over the whole '
                'Flutter content view (the native toolbar stays in the titlebar).',
                style: theme.typography.subheadline.copyWith(color: theme.secondaryLabelColor),
              ),
              const SizedBox(height: 16),
              CNButton(
                onPressed: () => Navigator.of(context, rootNavigator: true).push(
                  CNPageRoute(builder: (_) => const _WindowLevelPage()),
                ),
                buttonStyle: CNButtonStyle.borderedProminent,
                children: const [CNChildText('Present a window-level page')],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailPage extends StatelessWidget {
  const _DetailPage({required this.item, required this.depth});

  final int depth;
  final _Item item;

  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);

    return CNPageScaffold(
      backgroundColor: theme.canvasColor,
      navigationBar: CNNavigationBar(
        leading: const CNNavigationBarBackButton(),
        middle: Text(item.title),
      ),
      child: CNContentArea(
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                children: [
                  CNImage(
                    constraints: const BoxConstraints(maxWidth: 28, maxHeight: 28),
                    systemSymbolName: item.symbol,
                    foregroundColor: theme.accentColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('${item.title} — level $depth', style: theme.typography.title1),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(item.detail, style: theme.typography.body),
              const SizedBox(height: 24),
              CNButton(
                onPressed: () => Navigator.of(context).push(
                  CNPageRoute(builder: (_) => _DetailPage(item: item, depth: depth + 1)),
                ),
                children: const [CNChildText('Push another level')],
              ),
              const SizedBox(height: 12),
              CNButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                buttonStyle: CNButtonStyle.borderless,
                children: const [CNChildText('Back to root')],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// Pattern 2 — window-level (root navigator)
// ============================================================================

class _WindowLevelPage extends StatelessWidget {
  const _WindowLevelPage();

  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);

    return CNPageScaffold(
      backgroundColor: theme.canvasColor,
      // This page is pushed on the root navigator, so `context` resolves to it
      // and the back button pops the whole page off the window.
      navigationBar: const CNNavigationBar(
        leading: CNNavigationBarBackButton(label: 'Close'),
        middle: Text('Window-level page'),
      ),
      child: CNContentArea(
        builder: (context, scrollController) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CNImage(
                  constraints: const BoxConstraints(maxWidth: 48, maxHeight: 48),
                  systemSymbolName: 'macwindow',
                  foregroundColor: theme.accentColor,
                ),
                const SizedBox(height: 16),
                Text('This page covers the whole content view', style: theme.typography.title2),
                const SizedBox(height: 8),
                Text(
                  'The sidebar and status bar are hidden behind it, while the\n'
                  'native toolbar remains in the window titlebar.',
                  textAlign: TextAlign.center,
                  style: theme.typography.body.copyWith(color: theme.secondaryLabelColor),
                ),
                const SizedBox(height: 24),
                CNButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  buttonStyle: CNButtonStyle.borderedProminent,
                  children: const [CNChildText('Close')],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// Shared
// ============================================================================

class _NavRow extends StatelessWidget {
  const _NavRow({required this.item, required this.onTap});

  final _Item item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: theme.fillPrimaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CNImage(
              constraints: const BoxConstraints(maxWidth: 18, maxHeight: 18),
              systemSymbolName: item.symbol,
              foregroundColor: theme.accentColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(item.title, style: theme.typography.body.copyWith(fontWeight: FontWeight.w600)),
            ),
            Text('›', style: TextStyle(color: theme.secondaryLabelColor, fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
