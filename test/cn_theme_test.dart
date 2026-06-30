import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('of returns provided theme data', (tester) async {
    late CNThemeData resolved;
    final expected = CNThemeData(brightness: Brightness.dark, primaryColor: CupertinoColors.systemOrange.darkColor);

    await tester.pumpWidget(
      CNTheme(
        data: expected,
        child: Builder(
          builder: (context) {
            resolved = CNTheme.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(resolved, expected);
    expect(CNTheme.brightnessOf(tester.element(find.byType(SizedBox))), Brightness.dark);
  });

  testWidgets('of falls back when no CNTheme is provided', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(builder: _captureTheme),
      ),
    );

    final context = tester.element(find.byType(SizedBox));
    final resolved = CNTheme.of(context);
    final maybeResolved = CNTheme.maybeOf(context);

    expect(resolved.brightness, Brightness.light);
    expect(maybeResolved, isNull);
  });
}

Widget _captureTheme(BuildContext context) {
  return const SizedBox.shrink();
}
