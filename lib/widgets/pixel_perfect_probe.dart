import 'package:flutter/widgets.dart';

/// Flutter-only geometry snapshot used for pixel-perfect diagnostics.
class FlutterPixelGeometry {
  /// Creates an immutable Flutter geometry snapshot.
  const FlutterPixelGeometry({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.physicalX,
    required this.physicalY,
    required this.physicalWidth,
    required this.physicalHeight,
    required this.devicePixelRatio,
    required this.pixelAlignedX,
    required this.pixelAlignedY,
    required this.pixelAlignedWidth,
    required this.pixelAlignedHeight,
  });

  /// Device pixel ratio used for the conversion.
  final double devicePixelRatio;

  /// Logical height.
  final double height;

  /// Physical height in pixels.
  final double physicalHeight;

  /// Physical width in pixels.
  final double physicalWidth;

  /// Physical x in pixels.
  final double physicalX;

  /// Physical y in pixels.
  final double physicalY;

  /// Whether the height is aligned to physical pixels.
  final bool pixelAlignedHeight;

  /// Whether the width is aligned to physical pixels.
  final bool pixelAlignedWidth;

  /// Whether the x position is aligned to physical pixels.
  final bool pixelAlignedX;

  /// Whether the y position is aligned to physical pixels.
  final bool pixelAlignedY;

  /// Logical width.
  final double width;

  /// Logical x in the global Flutter coordinate space.
  final double x;

  /// Logical y in the global Flutter coordinate space.
  final double y;

  @override
  String toString() {
    return 'FlutterPixelGeometry('
        'x: $x, y: $y, width: $width, height: $height, '
        'physicalX: $physicalX, physicalY: $physicalY, '
        'physicalWidth: $physicalWidth, physicalHeight: $physicalHeight, '
        'devicePixelRatio: $devicePixelRatio, '
        'pixelAlignedX: $pixelAlignedX, pixelAlignedY: $pixelAlignedY, '
        'pixelAlignedWidth: $pixelAlignedWidth, pixelAlignedHeight: $pixelAlignedHeight'
        ')';
  }
}

/// Wrap any widget to measure its global geometry using only Flutter APIs.
class PixelPerfectProbe extends StatefulWidget {
  /// Creates a pixel-geometry probe around [child].
  const PixelPerfectProbe({super.key, required this.child, this.onGeometryChanged, this.adjustPosition = false});

  /// If true, applies a local translation to keep x/y aligned to physical pixels.
  final bool adjustPosition;

  /// Child being measured.
  final Widget child;

  /// Called whenever geometry changes.
  final ValueChanged<FlutterPixelGeometry>? onGeometryChanged;

  @override
  State<PixelPerfectProbe> createState() => _PixelPerfectProbeState();

  /// Whether the probe is enabled. If false, no geometry will be reported.
  bool get enabled => adjustPosition;
}

class _PixelPerfectProbeState extends State<PixelPerfectProbe> with WidgetsBindingObserver {
  String? _lastSignature;
  final GlobalKey _probeKey = GlobalKey();
  bool _probeQueued = false;
  double _snapDx = 0;
  double _snapDy = 0;

  @override
  void didChangeMetrics() {
    _queueProbe();
  }

  @override
  void didUpdateWidget(covariant PixelPerfectProbe oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      _queueProbe();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  bool _isAligned(double physicalValue) {
    return (physicalValue - physicalValue.round()).abs() < 0.001;
  }

  void _probeNow() {
    if (!mounted || !widget.enabled) {
      // debugPrint('[PixelPerfectProbe]: skipping probe because not mounted or disabled');
      return;
    }

    final ctx = _probeKey.currentContext;
    if (ctx == null) {
      // debugPrint('[PixelPerfectProbe]: skipping probe because context is null');
      return;
    }

    final renderObject = ctx.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      // debugPrint('[PixelPerfectProbe]: skipping probe because renderObject is not a RenderBox or has no size');
      return;
    }

    final origin = renderObject.localToGlobal(Offset.zero);
    final size = renderObject.size;
    final dpr = View.maybeOf(ctx)?.devicePixelRatio ?? MediaQuery.maybeDevicePixelRatioOf(ctx) ?? 1.0;

    final rawPhysicalX = origin.dx * dpr;
    final rawPhysicalY = origin.dy * dpr;

    debugPrint('origin: $origin, size: $size, dpr: $dpr, rawPhysicalX: $rawPhysicalX, rawPhysicalY: $rawPhysicalY');

    if (widget.adjustPosition) {
      final desiredDx = _snapDx + _snapDelta(rawPhysicalX, dpr);
      final desiredDy = _snapDy + _snapDelta(rawPhysicalY, dpr);

      // Avoid setState churn for tiny floating point noise.
      if ((desiredDx - _snapDx).abs() > 0.0001 || (desiredDy - _snapDy).abs() > 0.0001) {
        // debugPrint('[PixelPerfectProbe]: updating snap delta');
        setState(() {
          _snapDx = desiredDx;
          _snapDy = desiredDy;
        });
        _queueProbe();
        return;
      }
    } else if (_snapDx != 0 || _snapDy != 0) {
      // debugPrint('[PixelPerfectProbe]: resetting snap delta');
      setState(() {
        _snapDx = 0;
        _snapDy = 0;
      });
      _queueProbe();
      return;
    }

    final snappedX = origin.dx;
    final snappedY = origin.dy;
    final physicalX = snappedX * dpr;
    final physicalY = snappedY * dpr;
    final physicalWidth = size.width * dpr;
    final physicalHeight = size.height * dpr;

    final geometry = FlutterPixelGeometry(
      x: snappedX,
      y: snappedY,
      width: size.width,
      height: size.height,
      physicalX: physicalX,
      physicalY: physicalY,
      physicalWidth: physicalWidth,
      physicalHeight: physicalHeight,
      devicePixelRatio: dpr,
      pixelAlignedX: _isAligned(physicalX),
      pixelAlignedY: _isAligned(physicalY),
      pixelAlignedWidth: _isAligned(physicalWidth),
      pixelAlignedHeight: _isAligned(physicalHeight),
    );

    final signature = [geometry.x, geometry.y, geometry.width, geometry.height, geometry.devicePixelRatio].join('|');

    if (signature == _lastSignature) {
      // debugPrint('[PixelPerfectProbe]: skipping probe because geometry has not changed');
      return;
    }

    _lastSignature = signature;
    widget.onGeometryChanged?.call(geometry);
  }

  void _queueProbe() {
    // debugPrint('[PixelPerfectProbe]: queueing probe');
    if (!mounted || !widget.enabled || _probeQueued) {
      // debugPrint('[PixelPerfectProbe]: skipping probe because conditions not met');
      return;
    }
    _probeQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _probeQueued = false;
      _probeNow();
    });
  }

  double _snapDelta(double physicalValue, double dpr) {
    if (dpr <= 0) return 0;
    return (physicalValue.roundToDouble() - physicalValue) / dpr;
  }

  @override
  Widget build(BuildContext context) {
    _queueProbe();
    return Transform.translate(
      offset: Offset(_snapDx, _snapDy),
      child: KeyedSubtree(key: _probeKey, child: widget.child),
    );
  }
}
