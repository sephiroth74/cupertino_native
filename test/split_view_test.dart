import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CNSplitView', () {
    testWidgets('enforces pane min extents in horizontal layout', (
      tester,
    ) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: SizedBox(
              width: 500,
              height: 200,
              child: CNSplitView(
                axis: CNSplitAxis.horizontal,
                initialFraction: 0.2,
                minFraction: 0.1,
                maxFraction: 0.9,
                first: const CNSplitPane(
                  minExtent: 220,
                  child: SizedBox.expand(key: Key('first-pane')),
                ),
                second: const CNSplitPane(
                  minExtent: 120,
                  child: SizedBox.expand(key: Key('second-pane')),
                ),
              ),
            ),
          ),
        ),
      );

      final firstSize = tester.getSize(find.byKey(const Key('first-pane')));
      final secondSize = tester.getSize(find.byKey(const Key('second-pane')));

      expect(firstSize.width, greaterThanOrEqualTo(220));
      expect(secondSize.width, greaterThanOrEqualTo(120));
    });

    testWidgets('collapse then expand restores previous split position', (
      tester,
    ) async {
      final controller = CNSplitViewController();

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: SizedBox(
              width: 520,
              height: 220,
              child: CNSplitView(
                controller: controller,
                axis: CNSplitAxis.horizontal,
                initialFraction: 0.4,
                first: const CNSplitPane(
                  minExtent: 100,
                  child: SizedBox.expand(key: Key('first-pane')),
                ),
                second: const CNSplitPane(
                  minExtent: 100,
                  child: SizedBox.expand(key: Key('second-pane')),
                ),
              ),
            ),
          ),
        ),
      );

      final firstBefore = tester
          .getSize(find.byKey(const Key('first-pane')))
          .width;

      controller.collapseFirst();
      await tester.pumpAndSettle();

      final firstCollapsed = tester
          .getSize(find.byKey(const Key('first-pane')))
          .width;
      expect(firstCollapsed, 0);

      controller.expandFirst();
      await tester.pumpAndSettle();

      final firstExpanded = tester
          .getSize(find.byKey(const Key('first-pane')))
          .width;
      expect(firstExpanded, closeTo(firstBefore, 0.5));
    });

    testWidgets('snaps near target and can be released with further drag', (
      tester,
    ) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: SizedBox(
              width: 600,
              height: 220,
              child: CNSplitView(
                axis: CNSplitAxis.horizontal,
                initialFraction: 0.2,
                minFraction: 0.1,
                maxFraction: 0.9,
                snapFractions: const <double>[0.5],
                snapThreshold: 0.1,
                snapReleaseThreshold: 0.15,
                first: const CNSplitPane(
                  minExtent: 80,
                  child: SizedBox.expand(key: Key('first-pane')),
                ),
                second: const CNSplitPane(
                  minExtent: 80,
                  child: SizedBox.expand(key: Key('second-pane')),
                ),
              ),
            ),
          ),
        ),
      );

      final firstFinder = find.byKey(const Key('first-pane'));
      final secondFinder = find.byKey(const Key('second-pane'));

      Offset dividerCenter() {
        final firstRect = tester.getRect(firstFinder);
        final secondRect = tester.getRect(secondFinder);
        return Offset(
          (firstRect.right + secondRect.left) / 2,
          firstRect.center.dy,
        );
      }

      final firstStart = tester.getSize(firstFinder).width;
      final secondStart = tester.getSize(secondFinder).width;
      final availableExtent = firstStart + secondStart;
      final targetFirstAtSnap = availableExtent * 0.5;
      final deltaToSnapNeighborhood = targetFirstAtSnap - firstStart - 20;

      await tester.dragFrom(
        dividerCenter(),
        Offset(deltaToSnapNeighborhood, 0),
      );
      await tester.pumpAndSettle();

      final firstSnapped = tester.getSize(firstFinder).width;
      expect(firstSnapped, closeTo(targetFirstAtSnap, 1.5));

      await tester.dragFrom(dividerCenter(), const Offset(110, 0));
      await tester.pumpAndSettle();

      final firstReleased = tester.getSize(firstFinder).width;
      expect(firstReleased, greaterThan(330));
    });

    testWidgets('onChanged receives updated metrics when host size changes', (
      tester,
    ) async {
      double width = 560;
      final metrics = <CNSplitMetrics>[];

      Widget buildHarness() {
        return CupertinoApp(
          home: CupertinoPageScaffold(
            child: SizedBox(
              width: width,
              height: 220,
              child: CNSplitView(
                axis: CNSplitAxis.horizontal,
                initialFraction: 0.4,
                first: const CNSplitPane(
                  minExtent: 80,
                  child: SizedBox.expand(),
                ),
                second: const CNSplitPane(
                  minExtent: 80,
                  child: SizedBox.expand(),
                ),
                onChanged: metrics.add,
              ),
            ),
          ),
        );
      }

      await tester.pumpWidget(buildHarness());
      await tester.pump();

      width = 680;
      await tester.pumpWidget(buildHarness());
      await tester.pump();

      expect(metrics.length, greaterThanOrEqualTo(2));
      expect(metrics.last.totalExtent, greaterThan(metrics.first.totalExtent));
    });
  });
}
