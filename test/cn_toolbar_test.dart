import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Width of the pumped bar.
const double _kBarWidth = 800;

/// Horizontal gutter `CNToolbar` puts on each side of every item.
const double _kItemGutter = 4;

/// A pure-Flutter probe item: a fixed-size box behind no platform view, so the
/// toolbar's per-item wrapping can be measured without a native channel.
class _ProbeItem extends CNToolbarItem {
  const _ProbeItem({
    required this.probeKey,
    this.size = const Size(24, 20),
    this.managesOwnHeight = false,
    this.onConstraints,
    super.decoration,
    super.decorationPadding,
  });

  @override
  final bool managesOwnHeight;

  /// Reports the constraints the item is built with.
  final ValueChanged<BoxConstraints>? onConstraints;

  final Key probeKey;
  final Size size;

  @override
  CNChild? toOverflowChild(BuildContext context) => null;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        onConstraints?.call(constraints);
        return SizedBox(key: probeKey, width: size.width, height: size.height);
      },
    );
  }
}

/// Pumps [toolbar] full-width at its preferred height.
Future<void> _pumpToolbar(WidgetTester tester, CNToolbar toolbar) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(size: Size(_kBarWidth, 600)),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: _kBarWidth,
            height: toolbar.preferredSize.height,
            child: toolbar,
          ),
        ),
      ),
    ),
  );
  // Flush the zero-duration timer VisualEffectSubviewContainer posts from its
  // build, or the binding trips its "timer still pending" invariant on teardown.
  await tester.pump(Duration.zero);
}

/// The rect of the box painting [decoration], in global coordinates.
Rect _decorationRect(WidgetTester tester, Decoration decoration) {
  final finder = find.byWidgetPredicate(
    (widget) => widget is DecoratedBox && widget.decoration == decoration,
  );
  expect(finder, findsOneWidget);
  return tester.getRect(finder);
}

void main() {
  const decoration = BoxDecoration(color: CNColors.white);
  const otherDecoration = BoxDecoration(color: CNColors.black);

  testWidgets('decoration hugs its own item, inflated by decorationPadding', (
    tester,
  ) async {
    const probeKey = ValueKey('probe');
    await _pumpToolbar(
      tester,
      const CNToolbar(
        automaticallyImplyLeading: false,
        actions: [
          _ProbeItem(
            probeKey: probeKey,
            size: Size(24, 20),
            decoration: decoration,
            decorationPadding: EdgeInsets.all(6),
          ),
        ],
      ),
    );

    final item = tester.getRect(find.byKey(probeKey));
    expect(item.size, const Size(24, 20));

    final painted = _decorationRect(tester, decoration);
    expect(painted.size, const Size(24 + 12, 20 + 12));
    expect(painted.left, item.left - 6);
    expect(painted.top, item.top - 6);
  });

  testWidgets("a decoration's border does not inflate the box past the item", (
    tester,
  ) async {
    const probeKey = ValueKey('probe');
    const bordered = BoxDecoration(
      color: CNColors.white,
      border: Border.fromBorderSide(BorderSide(color: CNColors.black)),
    );
    await _pumpToolbar(
      tester,
      const CNToolbar(
        automaticallyImplyLeading: false,
        actions: [
          _ProbeItem(
            probeKey: probeKey,
            size: Size(24, 20),
            decoration: bordered,
          ),
        ],
      ),
    );

    // A Container would add the 1pt border to its padding and paint a rim
    // around the item; the box has to stay exactly the item's size.
    final item = tester.getRect(find.byKey(probeKey));
    expect(item.size, const Size(24, 20));
    expect(_decorationRect(tester, bordered), item);
  });

  testWidgets('each item gets its own decoration, split by the gutter', (
    tester,
  ) async {
    await _pumpToolbar(
      tester,
      const CNToolbar(
        automaticallyImplyLeading: false,
        actions: [
          _ProbeItem(probeKey: ValueKey('a'), decoration: decoration),
          _ProbeItem(probeKey: ValueKey('b'), decoration: otherDecoration),
        ],
      ),
    );

    final first = _decorationRect(tester, decoration);
    final second = _decorationRect(tester, otherDecoration);
    // Two separate pills rather than one continuous strip: the decorations sit
    // inside the per-item gutter, so they are 2 × 4pt apart.
    expect(second.left - first.right, _kItemGutter * 2);
  });

  testWidgets('decorationPadding is taken out of the band before the item '
      'measures it', (tester) async {
    const padding = EdgeInsets.all(8);
    // The bar's own 1pt bottom divider also comes out of the content box.
    const band = kCNToolbarHeight - 8 - 8 - 1;
    BoxConstraints? seen;

    await _pumpToolbar(
      tester,
      CNToolbar(
        automaticallyImplyLeading: false,
        padding: padding,
        actions: [
          _ProbeItem(
            probeKey: const ValueKey('probe'),
            managesOwnHeight: true,
            decoration: decoration,
            decorationPadding: const EdgeInsets.symmetric(vertical: 4),
            onConstraints: (constraints) => seen = constraints,
          ),
        ],
      ),
    );

    // Without the decoration the item would read the full band; with it, the
    // decoration owns the band and the control measures what is left inside.
    expect(seen?.maxHeight, band - 8);
  });

  testWidgets('nothing is painted when decoration is null', (tester) async {
    await _pumpToolbar(
      tester,
      const CNToolbar(
        automaticallyImplyLeading: false,
        actions: [
          _ProbeItem(
            probeKey: ValueKey('probe'),
            decorationPadding: EdgeInsets.all(6),
          ),
        ],
      ),
    );

    // decorationPadding alone is inert — no box is inserted around the item.
    expect(
      tester.getRect(find.byKey(const ValueKey('probe'))).size,
      const Size(24, 20),
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is DecoratedBox && widget.decoration == decoration,
      ),
      findsNothing,
    );
  });
}
