// ignore_for_file: public_member_api_docs

import 'package:collection/collection.dart';
import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_debug_id_mixin.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Base state for all CN widgets that render a native SwiftUI view via platform channels.
///
/// Subclasses must implement [toWidgetPayload] and [computeDefaultSize].
/// The [build] method, layout resolution, patch diffing, and channel lifecycle
/// are handled entirely by this base class.
abstract class CNWidgetState<T extends CNWidget> extends State<T>
    with CNWidgetDebugIdMixin<T> {
  (double, double) computeFinalSize({
    required bool shrink,
    required BoxConstraints constraints,
    double? intrinsicWidth,
    double? intrinsicHeight,
  }) {
    if (shrink) {
      return computeShrinkSize(
        constraints: constraints,
        intrinsicWidth: intrinsicWidth,
        intrinsicHeight: intrinsicHeight,
      );
    } else {
      return computeExpandSize(constraints: constraints);
    }
  }

  (double, double) computeShrinkSize({
    required BoxConstraints constraints,
    double? intrinsicWidth,
    double? intrinsicHeight,
  }) {
    final defaultSize = computeDefaultSize();
    double? resolvedWidth = computeShrinkWidth(
      constraints: constraints,
      defaultWidth: defaultSize.width,
      intrinsicWidth: intrinsicWidth,
    );

    double? resolvedHeight = computeShrinkHeight(
      constraints: constraints,
      defaultHeight: defaultSize.height,
      intrinsicHeight: intrinsicHeight,
    );

    logDebug(
      'shrink mode: resolvedWidth=$resolvedWidth, resolvedHeight=$resolvedHeight',
    );

    return (resolvedWidth, resolvedHeight);
  }

  (double, double) computeExpandSize({required BoxConstraints constraints}) {
    final resolvedWidth = constraints.tightWidth ?? constraints.maxWidth;
    final resolvedHeight = constraints.tightHeight ?? constraints.maxHeight;
    return (resolvedWidth, resolvedHeight);
  }

  MethodChannel? _channel;
  double? _intrinsicHeight;
  double? _intrinsicWidth;
  BoxConstraints? _lastConstraints;
  Map<String, dynamic>? _lastSentPayload;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded(oldWidget: oldWidget);
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _channel = null;
    super.dispose();
  }

  /// The current intrinsic height reported by the native view.
  double? get intrinsicHeight => _intrinsicHeight;

  /// The current intrinsic width reported by the native view.
  double? get intrinsicWidth => _intrinsicWidth;

  /// Returns the default size to use before the native view reports its intrinsic size.
  /// Typically computed from font size or other widget properties.
  Size computeDefaultSize();

  /// Optional gesture recognizers to forward to the platform view.
  Set<Factory<OneSequenceGestureRecognizer>>? get gestureRecognizers => null;

  /// Produces the widget-specific payload map for the native side.
  /// Called on every build and for patch computation.
  Map<String, dynamic> toWidgetPayload(
    BuildContext context, {
    required BoxConstraints? constraints,
  });

  /// Override to handle additional method calls from native besides `intrinsicSizeChanged`.
  @protected
  Future<void> onNativeMethodCall(MethodCall call) async {}

  void logDebug(String message) {
    if (!widget.debugLog) return;
    debugPrint('$debugLogPrefix $message');
  }

  double computeShrinkWidth({
    required BoxConstraints constraints,
    required double defaultWidth,
    double? intrinsicWidth,
  }) {
    double resolvedWidth;
    if (intrinsicWidth != null) {
      // check also for tightWidth in constraints, since the widget may have been given a tight width by its parent (e.g. a SizedBox).
      // check also minWidth and maxWidth in constraints, since the widget may have been given a bounded width by its parent (e.g. a Row or Column).
      resolvedWidth = intrinsicWidth;
    } else if (constraints.tightWidth != null) {
      resolvedWidth = constraints.tightWidth!;
    } else {
      resolvedWidth = defaultWidth;
    }
    // resolvedWidth = constraints.constrainWidth(resolvedWidth);

    if (resolvedWidth > constraints.maxWidth) {
      resolvedWidth = constraints.maxWidth;
    } else if (resolvedWidth < constraints.minWidth) {
      resolvedWidth = constraints.minWidth;
    }
    return resolvedWidth;
  }

  double computeShrinkHeight({
    required BoxConstraints constraints,
    required double defaultHeight,
    double? intrinsicHeight,
  }) {
    double resolvedHeight;
    if (intrinsicHeight != null) {
      resolvedHeight = intrinsicHeight;
    } else if (constraints.tightHeight != null) {
      resolvedHeight = constraints.tightHeight!;
    } else if (constraints.hasBoundedHeight) {
      resolvedHeight = constraints.maxHeight;
    } else {
      resolvedHeight = defaultHeight;
    }

    if (resolvedHeight > constraints.maxHeight) {
      resolvedHeight = constraints.maxHeight;
    } else if (resolvedHeight < constraints.minHeight) {
      resolvedHeight = constraints.minHeight;
    }

    // resolvedHeight = parentConstraints.constrainHeight(resolvedHeight);
    return resolvedHeight;
  }

  // --- Private implementation ---

  BoxConstraints _resolveConstraints(BoxConstraints parentConstraints) {
    final explicit = widget.constraints;
    if ( /*!widget.shrink && */ explicit != null) {
      // We should return the smallest constraints that satisfy both the explicit constraints and the parent constraints.
      final minWidth = explicit.minWidth.isFinite
          ? explicit.minWidth
          : parentConstraints.minWidth;
      final maxWidth = explicit.maxWidth.isFinite
          ? explicit.maxWidth
          : parentConstraints.maxWidth;
      final minHeight = explicit.minHeight.isFinite
          ? explicit.minHeight
          : parentConstraints.minHeight;
      final maxHeight = explicit.maxHeight.isFinite
          ? explicit.maxHeight
          : parentConstraints.maxHeight;
      return BoxConstraints(
        minWidth: minWidth,
        maxWidth: maxWidth,
        minHeight: minHeight,
        maxHeight: maxHeight,
      );
    }
    return parentConstraints;
  }

  Map<String, dynamic> _buildPayload({required BoxConstraints? constraints}) {
    final payload = toWidgetPayload(context, constraints: constraints);
    writeDebugWidgetId(payload);
    return payload;
  }

  Future<void> _onPlatformViewCreated(int id) async {
    _channel = MethodChannel('${widget.nativeViewType}_$id');
    _channel?.setMethodCallHandler(_handleMethodCall);

    if (widget.shrink) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestIntrinsicSize();
      });
    }
  }

  Future<void> _requestIntrinsicSize() async {
    final channel = _channel;
    if (channel == null || !mounted) return;

    try {
      final size = await channel.invokeMethod<Map>('getIntrinsicSize');
      _onIntrinsicSizeChanged(
        (size?['width'] as num?)?.toDouble(),
        (size?['height'] as num?)?.toDouble(),
      );
    } catch (_) {}
  }

  void _scheduleIntrinsicSizeRequest() {
    if (!widget.shrink) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestIntrinsicSize();
    });
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'intrinsicSizeChanged') {
      final args = call.arguments as Map?;
      final width = (args?['width'] as num?)?.toDouble();
      final height = (args?['height'] as num?)?.toDouble();
      _onIntrinsicSizeChanged(width, height);
      return null;
    }
    return onNativeMethodCall(call);
  }

  void _onIntrinsicSizeChanged(double? width, double? height) {
    logDebug('_onIntrinsicSizeChanged: width=$width, height=$height');
    if (!mounted || width == null || height == null) return;

    final normalizedWidth = width > 0 ? width : null;
    final normalizedHeight = height > 0 ? height : null;
    if (normalizedWidth == _intrinsicWidth &&
        normalizedHeight == _intrinsicHeight) {
      logDebug('intrinsic size unchanged, skipping setState');
      return;
    }

    setState(() {
      logDebug(
        'updating intrinsic size: width=$normalizedWidth, height=$normalizedHeight',
      );
      _intrinsicWidth = normalizedWidth;
      _intrinsicHeight = normalizedHeight;
    });
  }

  Future<void> _syncPropsToNativeIfNeeded({required T oldWidget}) async {
    if (_channel == null) return;
    if (_lastSentPayload == null) return;

    if (oldWidget.shrink != widget.shrink) {
      logDebug('shrink changed, sending full setData');
      _lastSentPayload = _buildPayload(constraints: _lastConstraints);
      await _channel?.invokeMethod('setData', _lastSentPayload);
      _scheduleIntrinsicSizeRequest();
      return;
    }

    final newPayload = _buildPayload(constraints: _lastConstraints);
    final diff = computePayloadPatch(_lastSentPayload!, newPayload);
    if (diff.isEmpty) {
      logDebug('no changes detected, skipping update');
      return;
    }

    logDebug('sending patch: $diff');
    _lastSentPayload = newPayload;
    await _channel?.invokeMethod('applyPatch', diff);
    if (widget.shrink) {
      await _requestIntrinsicSize();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.macOS) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, parentConstraints) {
        _lastConstraints = _resolveConstraints(parentConstraints);

        final payload = _buildPayload(constraints: _lastConstraints);

        // Detect constraint changes from LayoutBuilder (e.g. window resize).
        // didUpdateWidget won't fire for these since the widget instance hasn't changed.
        if (_lastSentPayload != null && _channel != null) {
          final diff = computePayloadPatch(_lastSentPayload!, payload);
          if (diff.isNotEmpty) {
            logDebug('build: constraints changed, sending patch: $diff');
            _lastSentPayload = payload;
            _channel?.invokeMethod('applyPatch', diff);
            _scheduleIntrinsicSizeRequest();
          }
        } else {
          _lastSentPayload = payload;
        }

        Widget platformView = AppKitView(
          viewType: widget.nativeViewType,
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          creationParams: payload,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
          gestureRecognizers: gestureRecognizers,
        );

        logDebug('*** build ***');
        logDebug(
          'parentConstraints=$parentConstraints, widget.constraints=${widget.constraints}, _lastConstraints=$_lastConstraints',
        );
        logDebug(
          'shrink=${widget.shrink}, intrinsicWidth=$_intrinsicWidth, intrinsicHeight=$_intrinsicHeight',
        );

        final (width, height) = computeFinalSize(
          shrink: widget.shrink,
          constraints: _lastConstraints!,
          intrinsicWidth: intrinsicWidth,
          intrinsicHeight: intrinsicHeight,
        );

        if (widget.shrink) {
          final resolvedWidth = width;
          final resolvedHeight = height;

          logDebug(
            'shrink mode: resolvedWidth=$resolvedWidth, resolvedHeight=$resolvedHeight',
          );

          if (widget.debugLog) {
            platformView = Stack(
              fit: StackFit.passthrough,
              children: [
                SizedBox(
                  // decoration: BoxDecoration(border: Border.all(color: CNColors.red.withValues(alpha: 0.5), width: 1.0)),
                  width: resolvedWidth,
                  height: resolvedHeight,
                ),
                platformView,
              ],
            );
          }
          return SizedBox(
            width: resolvedWidth,
            height: resolvedHeight,
            child: platformView,
          );
        } else {
          final resolvedWidth = width;
          final resolvedHeight = height;

          logDebug(
            'expand mode: resolvedWidth=$resolvedWidth, resolvedHeight=$resolvedHeight',
          );

          assert(
            resolvedWidth.isFinite && resolvedHeight.isFinite,
            '${widget.runtimeType} requires finite dimensions when shrink is false. '
            'Provide explicit constraints or place the widget in a bounded parent.',
          );

          if (widget.debugLog) {
            platformView = Stack(
              fit: StackFit.passthrough,
              children: [
                SizedBox(
                  // decoration: BoxDecoration(border: Border.all(color: CNColors.red.withValues(alpha: 0.5), width: 1.0)),
                  width: resolvedWidth,
                  height: resolvedHeight,
                ),
                platformView,
              ],
            );
          }

          return ConstrainedBox(
            constraints: BoxConstraints.tightFor(
              width: resolvedWidth,
              height: resolvedHeight,
            ),
            child: platformView,
          );
        }
      },
    );
  }
}

/// Computes a minimal patch between [oldPayload] and [newPayload].
///
/// Rules:
/// - Key present in both with same value → omitted
/// - Key present in both with different value → included with new value
/// - Key absent in new → included with null (signals clear)
/// - Key absent in old → included with new value
///
/// Maps are compared recursively, lists use deep equality.
Map<String, dynamic> computePayloadPatch(
  Map<String, dynamic> oldPayload,
  Map<String, dynamic> newPayload,
) {
  final patch = <String, dynamic>{};
  final allKeys = <String>{...oldPayload.keys, ...newPayload.keys};

  for (final key in allKeys) {
    final oldValue = oldPayload[key];
    final newValue = newPayload[key];

    if (!newPayload.containsKey(key)) {
      patch[key] = null;
      continue;
    }

    if (!oldPayload.containsKey(key)) {
      patch[key] = newValue;
      continue;
    }

    if (!_valuesEqual(oldValue, newValue)) {
      patch[key] = newValue;
    }
  }

  return patch;
}

bool _valuesEqual(dynamic a, dynamic b) {
  if (a == b) return true;
  if (a == null || b == null) return false;

  if (a is Map<String, dynamic> && b is Map<String, dynamic>) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || !_valuesEqual(a[key], b[key])) return false;
    }
    return true;
  }

  if (a is List && b is List) {
    return const DeepCollectionEquality().equals(a, b);
  }

  return false;
}
