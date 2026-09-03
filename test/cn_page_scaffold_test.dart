import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _kPageSize = Size(800, 600);

/// Body for the content area in split-mode tests.
Widget _emptyContent(BuildContext context, ScrollController controller) =>
    const SizedBox.expand();

/// Pumps [scaffold] at a fixed page size.
Future<void> _pumpScaffold(WidgetTester tester, CNPageScaffold scaffold) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(size: _kPageSize),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox.fromSize(size: _kPageSize, child: scaffold),
        ),
      ),
    ),
  );
  // Flush the zero-duration timer CNToolbar's visual-effect container posts.
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
  const gradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [CNColors.white, CNColors.black],
    ),
  );

  testWidgets('decoration paints the whole page, toolbar strip included', (
    tester,
  ) async {
    await _pumpScaffold(
      tester,
      const CNPageScaffold(
        decoration: gradient,
        toolBar: CNToolbar(
          automaticallyImplyLeading: false,
          backgroundColor: CNColors.transparent,
        ),
        child: SizedBox.expand(),
      ),
    );

    // Spanning the full height (not just below the bar) is what lets a vertical
    // gradient start at the window top.
    expect(_decorationRect(tester, gradient), Offset.zero & _kPageSize);
  });

  testWidgets('decoration paints the whole page in split mode', (tester) async {
    await _pumpScaffold(
      tester,
      CNPageScaffold(
        decoration: gradient,
        children: const [
          SizedBox(width: 120),
          CNContentArea(builder: _emptyContent),
        ],
      ),
    );

    expect(_decorationRect(tester, gradient), Offset.zero & _kPageSize);
  });

  testWidgets('backgroundColor still paints a flat page', (tester) async {
    await _pumpScaffold(
      tester,
      const CNPageScaffold(
        backgroundColor: CNColors.white,
        child: SizedBox.expand(),
      ),
    );

    expect(
      _decorationRect(tester, const BoxDecoration(color: CNColors.white)),
      Offset.zero & _kPageSize,
    );
  });

  test('backgroundColor and decoration are mutually exclusive', () {
    expect(
      () => CNPageScaffold(
        backgroundColor: CNColors.white,
        decoration: gradient,
        child: const SizedBox.expand(),
      ),
      throwsAssertionError,
    );
  });
}
