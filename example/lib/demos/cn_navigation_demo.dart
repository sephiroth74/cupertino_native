import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

/// Demonstrates route-based navigation with [CNPageRoute].
///
/// Two distinct patterns are shown side by side:
///
///  1. **Content-area navigation** — a nested [Navigator] scopes pushes to the
///     content area, so the sidebar, the shared app toolbar and the status bar
///     stay fixed while master → detail pages slide in. Each pushed page carries
///     its own [CNToolbar] (with a back button), stacked just below the shared
///     app toolbar. This is the idiomatic macOS pattern.
///
///  2. **Window-level navigation** — pushing on the root navigator
///     (`rootNavigator: true`) presents a page that covers the whole Flutter
///     content view. Because the toolbar now lives inside the Flutter view (not a
///     native `NSToolbar` in the titlebar), the pushed page covers the shared app
///     toolbar too and supplies its own.
class NavigationDemoPage extends StatelessWidget {
  const NavigationDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // A nested Navigator keeps every push inside the content area. Its initial
    // ('/') route is the master list; detail pages are pushed onto it via
    // Navigator.of(context) (which resolves to this nearest navigator).
    return Navigator(
      onGenerateRoute: (settings) => CNPageRoute(builder: (_) => const _MasterPage(), settings: settings),
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
  _Item('Documents', 'doc.text', 'Push detail pages while the sidebar and app toolbar stay put.'),
  _Item('Downloads', 'arrow.down.circle', 'The synthesized back button calls Navigator.of(context).maybePop().'),
  _Item('Settings', 'gearshape', 'Every level uses CNPageScaffold + CNToolbar.'),
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
      toolBar: const CNToolbar(title: Text('Navigation')),
      child: CNContentArea(
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              Text('Content-area navigation', style: theme.typography.title2),
              const SizedBox(height: 4),
              Text(
                'Tapping a row pushes a detail page onto a nested Navigator, so the '
                'sidebar, shared app toolbar and status bar remain fixed. The detail '
                "page's own toolbar stacks just below the app toolbar.",
                style: theme.typography.subheadline.copyWith(color: theme.secondaryLabelColor),
              ),
              const SizedBox(height: 16),
              for (final item in _items)
                _NavRow(
                  item: item,
                  onTap: () => Navigator.of(context).push(CNPageRoute(builder: (_) => _DetailPage(item: item, depth: 1))),
                ),
              const SizedBox(height: 32),
              Text('Window-level navigation', style: theme.typography.title2),
              const SizedBox(height: 4),
              Text(
                'Pushing on the root navigator presents a page over the whole Flutter '
                'content view, covering the shared app toolbar; the page supplies its own.',
                style: theme.typography.subheadline.copyWith(color: theme.secondaryLabelColor),
              ),
              const SizedBox(height: 16),
              CNButton(
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).push(CNPageRoute(builder: (_) => const _WindowLevelPage())),
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
      // The nested route can pop, so CNToolbar synthesizes a leading back button.
      toolBar: CNToolbar(title: Text(item.title)),
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
                  Expanded(child: Text('${item.title} — level $depth', style: theme.typography.title1)),
                ],
              ),
              const SizedBox(height: 12),
              Text(item.detail, style: theme.typography.body),
              const SizedBox(height: 24),
              CNButton(
                onPressed: () => Navigator.of(context).push(
                  CNPageRoute(
                    builder: (_) => _DetailPage(item: item, depth: depth + 1),
                  ),
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
      // and the close button pops the whole page off the window.
      toolBar: CNToolbar(
        automaticallyImplyLeading: false,
        leading: CNToolbarIconButton('xmark', tooltip: 'Close', onPressed: () => Navigator.of(context).maybePop()),
        title: const Text('Window-level page'),
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
                  'The sidebar, status bar and shared app toolbar are all hidden\n'
                  'behind it, so the page supplies its own toolbar.',
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
        decoration: BoxDecoration(color: theme.fillPrimaryColor, borderRadius: BorderRadius.circular(8)),
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
