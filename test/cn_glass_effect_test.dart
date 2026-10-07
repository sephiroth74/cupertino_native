import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CNGlassEffect.toMap', () {
    testWidgets('defaults to a regular, non-interactive capsule', (
      tester,
    ) async {
      final map = await _serialize(tester, const CNGlassEffect());
      expect(map, {'variant': 'regular', 'interactive': false});
    });

    testWidgets('serializes tint, shape and padding', (tester) async {
      final map = await _serialize(
        tester,
        const CNGlassEffect(
          variant: CNGlassVariant.clear,
          tint: Color(0xFF112233),
          interactive: true,
          shape: CNRoundedRectangle(cornerRadius: 12),
          padding: EdgeInsets.fromLTRB(1, 2, 3, 4),
        ),
      );
      expect(map['variant'], 'clear');
      expect(map['interactive'], true);
      expect(map['tint'], 0xFF112233);
      expect(map['shape'], const CNRoundedRectangle(cornerRadius: 12).toMap());
      expect(map['padding'], {
        'top': 2.0,
        'leading': 1.0,
        'bottom': 4.0,
        'trailing': 3.0,
      });
    });
  });

  group('CNWidget.totalPaddings', () {
    test('adds the glass padding to the widget paddings', () {
      const text = CNText(
        'a',
        paddings: EdgeInsets.all(2),
        glassEffect: CNGlassEffect(padding: EdgeInsets.all(8)),
      );
      expect(text.totalPaddings.horizontal, 20);
      expect(text.totalPaddings.vertical, 20);
    });

    test('is zero without paddings or glass', () {
      expect(const CNText('a').totalPaddings.vertical, 0);
    });
  });

  group('CNSearchField', () {
    testWidgets('forwards its glass effect to the shared payload', (
      tester,
    ) async {
      const effect = CNGlassEffect(
        variant: CNGlassVariant.clear,
        padding: EdgeInsets.all(4),
      );
      const field = CNSearchField(glassEffect: effect);
      late Map<String, dynamic> payload;
      late Map<String, dynamic> expected;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              payload = field.writeSharedFields(
                context,
                payload: <String, dynamic>{},
                constraints: null,
              );
              expected = effect.toMap(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(payload['glassEffect'], expected);
      expect(field.totalPaddings.vertical, 8);
    });

    test('leaves the bezel style unset by default', () {
      expect(const CNSearchField().bezelStyle, isNull);
    });
  });
}

Future<Map<String, dynamic>> _serialize(
  WidgetTester tester,
  CNGlassEffect effect,
) async {
  late Map<String, dynamic> map;
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Builder(
        builder: (context) {
          map = effect.toMap(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return map;
}
