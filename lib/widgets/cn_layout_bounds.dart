import 'package:cupertino_native/widgets/cn_measure_child.dart';
import 'package:flutter/widgets.dart';

/// A widget that measures its child's layout bounds and reports it via callbacks.
class CNLayoutBounds extends StatefulWidget {
  /// Creates a [CNLayoutBounds] widget.
  const CNLayoutBounds({
    super.key,
    required this.child,
    this.enabled = true,
    this.color = const Color(0xFF009900),
  });

  /// The child widget to measure and layout.
  final Widget child;

  /// The color of the layout bounds rectangle. This is used for debugging purposes.
  final Color color;

  /// Whether the layout bounds measurement is enabled. If false, the child will be displayed without measuring its layout bounds.
  final bool enabled;

  @override
  State<CNLayoutBounds> createState() => _CNLayoutBoundsState();
}

class _CNLayoutBoundsState extends State<CNLayoutBounds> {
  Size? childSize;

  void onSizeChanged(Size value) {
    debugPrint('onSizeChanged: $value');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          childSize = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return CNMeasureChild(
      onSizeChanged: onSizeChanged,

      /// draw a simple text on top-right corner of the rectangle with the size of the child widget
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: widget.color, width: 1.0),
        ),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            widget.child,
            Positioned(
              top: 1,
              right: 0,
              child: Text(
                childSize != null
                    ? '${childSize!.width.toInt()}x${childSize!.height.toInt()}'
                    : '',
                style: TextStyle(
                  color: widget.color,
                  fontSize: 6,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
