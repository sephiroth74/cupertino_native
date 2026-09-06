import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const Size _kWindowSize = Size(1200, 800);
const double _kSidebarWidth = 250.0;
const double _kSeparatorWidth = 2.0;
const Color _kSeparatorColor = Color(0xFF112233);
const Color _kHighlightColor = Color(0xFFAABBCC);

/// Marks the body of the content area, to measure where it starts.
const Key _kBodyKey = Key('body');

/// Pumps a [CNWindow] with a single resizable sidebar.
Future<void> _pumpWindow(
  WidgetTester tester, {
  double separatorWidth = _kSeparatorWidth,
  bool toolbarSpansFullWidth = false,
  bool isResizable = true,
}) async {
  tester.view.physicalSize = _kWindowSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    CNApp(
      home: (context) => CNWindow(
        toolbarSpansFullWidth: toolbarSpansFullWidth,
        sidebar: CNSidebar(
          minWidth: _kSidebarWidth,
          startWidth: _kSidebarWidth,
          maxWidth: 400,
          isResizable: isResizable,
          separatorColor: _kSeparatorColor,
          separatorHighlightColor: _kHighlightColor,
          separatorWidth: separatorWidth,
          builder: (context) => const SizedBox.expand(),
        ),
        child: const CNPageScaffold(child: SizedBox.expand(key: _kBodyKey)),
      ),
    ),
  );
  // Flush the zero-duration timers the visual-effect containers post on build.
  await tester.pump(Duration.zero);
}

/// The box painting the separator bar, in whichever of its two colors.
Finder _separatorFinder() => find.byWidgetPredicate((widget) {
  if (widget is! DecoratedBox) return false;
  final decoration = widget.decoration;
  return decoration is BoxDecoration &&
      (decoration.color == _kSeparatorColor ||
          decoration.color == _kHighlightColor);
});

BoxDecoration _separatorDecoration(WidgetTester tester) {
  final finder = _separatorFinder();
  expect(finder, findsOneWidget);
  return (tester.widget<DecoratedBox>(finder)).decoration as BoxDecoration;
}

bool _isHighlighted(WidgetTester tester) =>
    _separatorDecoration(tester).color == _kHighlightColor;

/// Center of the separator bar.
Offset _separatorCenter(WidgetTester tester) =>
    tester.getCenter(_separatorFinder());

void main() {
  testWidgets('the separator is exactly separatorWidth wide, flush against the '
      'sidebar edge', (tester) async {
    await _pumpWindow(tester);

    final rect = tester.getRect(_separatorFinder());
    expect(rect.width, _kSeparatorWidth);
    expect(rect.left, _kSidebarWidth);
    expect(rect.height, _kWindowSize.height);

    // The pointer-grab area matches the bar: no wider tolerance band.
    final band = find.ancestor(
      of: _separatorFinder(),
      matching: find.byType(GestureDetector),
    );
    expect(tester.getRect(band.first), rect);
  });

  testWidgets('the separator takes layout space: the content starts after it', (
    tester,
  ) async {
    await _pumpWindow(tester, separatorWidth: 20.0);

    final separator = tester.getRect(_separatorFinder());
    expect(separator.left, _kSidebarWidth);
    expect(separator.width, 20.0);

    // Split mode: the content area itself is pushed past the separator.
    final body = tester.getRect(find.byKey(_kBodyKey));
    expect(body.left, _kSidebarWidth + 20.0);
    expect(body.right, _kWindowSize.width);
  });

  testWidgets('the content clears the separator in full-width toolbar mode', (
    tester,
  ) async {
    await _pumpWindow(
      tester,
      separatorWidth: 20.0,
      toolbarSpansFullWidth: true,
    );

    // The content area spans the whole window, so the body is inset instead.
    expect(tester.getRect(_separatorFinder()).left, _kSidebarWidth);
    expect(tester.getRect(find.byKey(_kBodyKey)).left, _kSidebarWidth + 20.0);
  });

  testWidgets('a non-resizable sidebar has no separator and no gutter', (
    tester,
  ) async {
    await _pumpWindow(tester, separatorWidth: 20.0, isResizable: false);

    expect(_separatorFinder(), findsNothing);
    expect(tester.getRect(find.byKey(_kBodyKey)).left, _kSidebarWidth);
  });

  testWidgets('hovering highlights the separator only after a second', (
    tester,
  ) async {
    await _pumpWindow(tester);
    expect(_isHighlighted(tester), isFalse);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(_separatorCenter(tester));
    await tester.pump();
    expect(_isHighlighted(tester), isFalse);

    await tester.pump(const Duration(milliseconds: 900));
    expect(_isHighlighted(tester), isFalse);

    await tester.pump(const Duration(milliseconds: 200));
    expect(_isHighlighted(tester), isTrue);
    expect(
      _separatorDecoration(tester).borderRadius,
      BorderRadius.circular(_kSeparatorWidth / 2),
    );

    // Moving off the bar without a button held clears it again.
    await gesture.moveTo(const Offset(600, 400));
    await tester.pump();
    expect(_isHighlighted(tester), isFalse);
  });

  testWidgets('leaving the bar before the delay never highlights it', (
    tester,
  ) async {
    await _pumpWindow(tester);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await gesture.moveTo(_separatorCenter(tester));
    await tester.pump(const Duration(milliseconds: 500));
    await gesture.moveTo(const Offset(600, 400));
    await tester.pump(const Duration(seconds: 2));

    expect(_isHighlighted(tester), isFalse);
  });

  testWidgets('pressing highlights immediately and holds for the whole drag', (
    tester,
  ) async {
    await _pumpWindow(tester);

    final gesture = await tester.startGesture(_separatorCenter(tester));
    await tester.pump();
    expect(_isHighlighted(tester), isTrue);

    // Dragging the separator right widens the sidebar; the highlight stays on
    // even though the window overlays a cursor-pinning MouseRegion on top.
    await gesture.moveBy(const Offset(60, 0));
    await tester.pump();
    expect(_isHighlighted(tester), isTrue);
    expect(tester.getRect(_separatorFinder()).left, _kSidebarWidth + 60);

    // Released on the bar (it followed the pointer), so it stays highlighted.
    await gesture.up();
    await tester.pump();
    expect(_isHighlighted(tester), isTrue);
    await tester.pump(Duration.zero);
  });

  testWidgets('releasing away from the bar clears the highlight', (
    tester,
  ) async {
    await _pumpWindow(tester);

    final gesture = await tester.startGesture(_separatorCenter(tester));
    await tester.pump();
    expect(_isHighlighted(tester), isTrue);

    // Past maxWidth the sidebar stops growing, so the pointer leaves the bar.
    await gesture.moveBy(const Offset(400, 0));
    await tester.pump();
    expect(_isHighlighted(tester), isTrue);

    await gesture.up();
    await tester.pump();
    expect(_isHighlighted(tester), isFalse);
    await tester.pump(Duration.zero);
  });
}
