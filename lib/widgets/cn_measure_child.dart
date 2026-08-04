import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A widget that measures its child's size and layout position and reports it via callbacks.
class CNMeasureChild extends SingleChildRenderObjectWidget {
  /// Creates a [CNMeasureChild] widget.
  const CNMeasureChild({
    super.key,
    super.child,
    this.onSizeChanged,
    this.onLayout,
  });

  /// Callback that is called when the child's layout position changes.
  final ValueChanged<Rect>? onLayout;

  /// Callback that is called when the child's size changes.
  final ValueChanged<Size>? onSizeChanged;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderItem(onLayout, onSizeChanged);
  }

  @override
  // ignore: library_private_types_in_public_api
  void updateRenderObject(BuildContext context, _RenderItem renderObject) {
    renderObject.onSizeChanged = onSizeChanged;
    renderObject.onLayout = onLayout;
  }
}

class _RenderItem extends RenderProxyBox {
  _RenderItem(this.onLayout, this.onSizeChanged, [RenderBox? child])
    : super(child);

  ValueChanged<Rect>? onLayout;
  ValueChanged<Size>? onSizeChanged;

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);

    onLayout?.call(offset & size);
  }

  @override
  void performLayout() {
    super.performLayout();
    onSizeChanged?.call(size);
  }
}
