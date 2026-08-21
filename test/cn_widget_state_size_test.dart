import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('computeExpandSize', () {
    test('uses the incoming bounds when both axes are bounded', () {
      final (width, height) = _FakeState().computeExpandSize(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 80),
      );
      expect(width, 500);
      expect(height, 80);
    });

    test('prefers tight bounds over max bounds', () {
      final (width, height) = _FakeState().computeExpandSize(
        constraints: BoxConstraints.tight(const Size(320, 40)),
      );
      expect(width, 320);
      expect(height, 40);
    });

    test('falls back to the default size on an unbounded axis', () {
      // A widget in a Column: width tight, height unbounded.
      final (width, height) = _FakeState().computeExpandSize(
        constraints: const BoxConstraints(
          minWidth: 400,
          maxWidth: 400,
          minHeight: 0,
        ),
      );
      expect(width, 400, reason: 'the bounded axis keeps what the parent gave');
      expect(height, _kDefaultSize.height);
    });

    test('clamps the default size back into the constraints', () {
      final (_, height) = _FakeState().computeExpandSize(
        constraints: const BoxConstraints(maxWidth: 400, minHeight: 60),
      );
      expect(height, 60);
    });

    test('leaves an axis infinite when its default is also infinite', () {
      final (width, _) = _InfiniteWidthState().computeExpandSize(
        constraints: const BoxConstraints(),
      );
      expect(width, double.infinity);
    });
  });
}

const _kDefaultSize = Size(200, 24);

/// Minimal [CNWidget] pair: [computeExpandSize] only reads [computeDefaultSize],
/// so the state can be exercised without mounting it.
class _FakeWidget extends CNWidget {
  const _FakeWidget();

  @override
  BoxConstraints? get constraints => null;

  @override
  Color? get foregroundColor => null;

  @override
  String? get help => null;

  @override
  String get nativeViewType => 'FakeNativeView';

  @override
  EdgeInsetsGeometry? get paddings => null;

  @override
  bool get shrink => false;

  @override
  Object? get tint => null;

  @override
  State<_FakeWidget> createState() => _FakeState();
}

class _FakeState extends CNWidgetState<_FakeWidget> {
  @override
  Size computeDefaultSize() => _kDefaultSize;

  @override
  Map<String, dynamic> toWidgetPayload(
    BuildContext context, {
    required BoxConstraints? constraints,
  }) => const {};
}

class _InfiniteWidthState extends _FakeState {
  @override
  Size computeDefaultSize() => const Size(double.infinity, 24);
}
