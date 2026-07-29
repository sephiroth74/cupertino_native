import 'package:flutter/widgets.dart';

/// The current window frame in screen coordinates.
///
/// Exposed via [CNWindowGeometryScope.of] to descendant widgets that need
/// the absolute window position (e.g. for pixel-alignment calculations).
class WindowFrame {
  /// Creates an immutable window frame snapshot.
  const WindowFrame({required this.x, required this.y, required this.width, required this.height});

  /// Zero frame used before the first measurement.
  static const zero = WindowFrame(x: 0, y: 0, width: 0, height: 0);

  /// Window height in screen points.
  final double height;

  /// Window width in screen points.
  final double width;

  /// Window origin x in screen points.
  final double x;

  /// Window origin y in screen points.
  final double y;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WindowFrame && x == other.x && y == other.y && width == other.width && height == other.height;

  @override
  int get hashCode => Object.hash(x, y, width, height);

  @override
  String toString() => 'WindowFrame(x: $x, y: $y, width: $width, height: $height)';
}

/// An [InheritedWidget] that provides the current [WindowFrame] to descendants.
///
/// Managed by [CNApp], which listens to window move/resize events and updates
/// the scope automatically.
class CNWindowGeometryScope extends InheritedWidget {
  /// Creates a window geometry scope with the given [frame].
  const CNWindowGeometryScope({super.key, required this.frame, required super.child});

  /// The current window frame in screen coordinates.
  final WindowFrame frame;

  @override
  bool updateShouldNotify(CNWindowGeometryScope oldWidget) => frame != oldWidget.frame;

  /// Returns the current [WindowFrame] from the nearest ancestor, or
  /// [WindowFrame.zero] if none is found.
  static WindowFrame of(BuildContext context) {
    final data = context.dependOnInheritedWidgetOfExactType<CNWindowGeometryScope>();
    return data?.frame ?? WindowFrame.zero;
  }

  /// Like [of], but does not register a dependency — the caller will not
  /// rebuild when the frame changes.
  static WindowFrame maybeOf(BuildContext context) {
    final data = context.getInheritedWidgetOfExactType<CNWindowGeometryScope>();
    return data?.frame ?? WindowFrame.zero;
  }
}
