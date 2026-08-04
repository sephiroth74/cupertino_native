import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

/// Demonstrates route-based navigation with [CNPageRoute].
///
/// Both patterns push on the **root navigator** (`rootNavigator: true`): a
/// pushed page's [CNPageScaffold] owns the whole toolbar strip and replaces the
/// shared app toolbar (see [CNPageScaffold], which reserves and draws the bar
/// flush at the window top — it does not stack beneath a parent bar).
///
///  1. **Master → detail** — the master list is a bare [CNContentArea] under the
///     app toolbar; tapping a row pushes a detail page whose own [CNToolbar]
///     (with a synthesized back button) replaces the app toolbar.
///
///  2. **Window-level page** — a page presented the same way, supplying its own
///     toolbar with an explicit close button.
class NavigationDemoPage extends StatelessWidget {
  const NavigationDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MasterPage();
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

    return CNContentArea(
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Text('Content-area navigation', style: theme.typography.title2),
            const SizedBox(height: 4),
            Text(
              'Tapping a row pushes a detail page on the root navigator. Its '
              "CNPageScaffold owns the whole toolbar strip, so the detail page's "
              'toolbar (with a synthesized back button) replaces the app toolbar.',
              style: theme.typography.subheadline.copyWith(color: theme.secondaryLabelColor),
            ),
            const SizedBox(height: 16),
            for (final item in _items)
              _NavRow(
                item: item,
                onTap: () {
                  debugPrint('Pushing detail page for ${item.title}');
                  Navigator.of(context, rootNavigator: true).push(CNPageRoute(builder: (_) => _DetailPage(item: item, depth: 1)));
                },
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
      // The route can pop, so CNToolbar synthesizes a leading back button.
      toolBar: CNToolbar(
        title: Text(item.title),
        automaticallyImplyLeading: true,
        actions: [
          CNToolbarButton('gearshape', onPressed: () => debugPrint('Settings tapped')),
        ],
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
        leading: [CNToolbarIconButton('xmark', tooltip: 'Close', onPressed: () => Navigator.of(context).maybePop())],
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
