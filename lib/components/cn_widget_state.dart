// ignore_for_file: public_member_api_docs

import 'package:collection/collection.dart';
import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_debug_id_mixin.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Base state for all CN widgets that render a native SwiftUI view via platform channels.
///
/// Subclasses must implement [toWidgetPayload] and [computeDefaultSize].
/// The [build] method, layout resolution, patch diffing, and channel lifecycle
/// are handled entirely by this base class.
abstract class CNWidgetState<T extends CNWidget> extends State<T> with CNWidgetDebugIdMixin<T> {
  MethodChannel? _channel;
  double? _intrinsicHeight;
  double? _intrinsicWidth;
  BoxConstraints? _lastConstraints;
  Map<String, dynamic>? _lastSentPayload;

  @override
  void didChangeDependencies() {
    logDebug('didChangeDependencies');
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    logDebug('didUpdateWidget');
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

  /// Produces the widget-specific payload map for the native side.
  /// Called on every build and for patch computation.
  Map<String, dynamic> toWidgetPayload(BuildContext context, {required BoxConstraints? constraints});

  /// Override to handle additional method calls from native besides `intrinsicSizeChanged`.
  @protected
  Future<void> onNativeMethodCall(MethodCall call) async {}

  void logDebug(String message) {
    if (!widget.debugLog) return;
    debugPrint('$debugLogPrefix $message');
  }

  // --- Private implementation ---

  BoxConstraints _resolveConstraints(BoxConstraints parentConstraints) {
    final explicit = widget.constraints;
    if (!widget.shrink && explicit != null) {
      return BoxConstraints(
        minWidth: parentConstraints.minWidth > explicit.minWidth ? parentConstraints.minWidth : explicit.minWidth,
        maxWidth: parentConstraints.maxWidth < explicit.maxWidth ? parentConstraints.maxWidth : explicit.maxWidth,
        minHeight: parentConstraints.minHeight > explicit.minHeight ? parentConstraints.minHeight : explicit.minHeight,
        maxHeight: parentConstraints.maxHeight < explicit.maxHeight ? parentConstraints.maxHeight : explicit.maxHeight,
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
    logDebug('onPlatformViewCreated id=$id');
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
      _onIntrinsicSizeChanged((size?['width'] as num?)?.toDouble(), (size?['height'] as num?)?.toDouble());
    } catch (_) {}
  }

  void _scheduleIntrinsicSizeRequest() {
    if (!widget.shrink) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestIntrinsicSize();
    });
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    logDebug('onMethodCall ${call.method} args=${call.arguments}');
    if (call.method == 'intrinsicSizeChanged') {
      final args = call.arguments as Map?;
      final width = (args?['width'] as num?)?.toDouble();
      final height = (args?['height'] as num?)?.toDouble();
      _onIntrinsicSizeChanged(width, height);
    } else {
      await onNativeMethodCall(call);
    }
    return null;
  }

  void _onIntrinsicSizeChanged(double? width, double? height) {
    logDebug('received intrinsic size change: width=$width, height=$height');
    if (!mounted || width == null || height == null) return;

    final normalizedWidth = width > 0 ? width : null;
    final normalizedHeight = height > 0 ? height : null;
    if (normalizedWidth == _intrinsicWidth && normalizedHeight == _intrinsicHeight) {
      return;
    }

    setState(() {
      _intrinsicWidth = normalizedWidth;
      _intrinsicHeight = normalizedHeight;
    });
  }

  Future<void> _syncPropsToNativeIfNeeded({required T oldWidget}) async {
    logDebug('syncPropsToNativeIfNeeded');

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
    await _channel?.invokeMethod('applyPatch', diff);
    _lastSentPayload = newPayload;
    _scheduleIntrinsicSizeRequest();
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

        logDebug('build: payload=$payload');

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
          creationParams: payload,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
        );

        logDebug(
          'build: constraints=$parentConstraints, widget.constraints=${widget.constraints}, '
          'shrink=${widget.shrink}, intrinsicWidth=$_intrinsicWidth, intrinsicHeight=$_intrinsicHeight',
        );

        if (widget.shrink) {
          final defaultSize = computeDefaultSize();
          double resolvedWidth;
          double resolvedHeight;

          if (intrinsicWidth != null) {
            resolvedWidth = intrinsicWidth!;
            logDebug('shrink mode: using intrinsicWidth');
          } else if (_lastConstraints?.tightWidth != null) {
            resolvedWidth = _lastConstraints!.tightWidth!;
            logDebug('shrink mode: using tightWidth from constraints');
          } else {
            resolvedWidth = defaultSize.width;
            logDebug('shrink mode: using defaultSize.width');
          }

          if (intrinsicHeight != null) {
            resolvedHeight = intrinsicHeight!;
            logDebug('shrink mode: using intrinsicHeight');
          } else if (_lastConstraints?.tightHeight != null) {
            resolvedHeight = _lastConstraints!.tightHeight!;
            logDebug('shrink mode: using tightHeight from constraints');
          } else {
            resolvedHeight = defaultSize.height;
            logDebug('shrink mode: using defaultSize.height');
          }

          resolvedWidth = parentConstraints.constrainWidth(resolvedWidth);
          resolvedHeight = parentConstraints.constrainHeight(resolvedHeight);

          logDebug('shrink mode: resolvedWidth=$resolvedWidth, resolvedHeight=$resolvedHeight');

          if (widget.debugLog) {
            platformView = Container(
              color: CNColors.red.withOpacity(0.1),
              child: platformView,
            );
          }
          return SizedBox(width: resolvedWidth, height: resolvedHeight, child: platformView);
        } else {
          final resolvedWidth = _lastConstraints!.tightWidth ?? _lastConstraints!.maxWidth;
          final resolvedHeight = _lastConstraints!.tightHeight ?? _lastConstraints!.maxHeight;

          logDebug('expand mode: resolvedWidth=$resolvedWidth, resolvedHeight=$resolvedHeight');

          assert(
            resolvedWidth.isFinite && resolvedHeight.isFinite,
            '${widget.runtimeType} requires finite dimensions when shrink is false. '
            'Provide explicit constraints or place the widget in a bounded parent.',
          );

          if (widget.debugLog) {
            platformView = Container(
              color: CNColors.red.withOpacity(0.1),
              child: platformView,
            );
          }

          return ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: resolvedWidth, height: resolvedHeight),
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
Map<String, dynamic> computePayloadPatch(Map<String, dynamic> oldPayload, Map<String, dynamic> newPayload) {
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
