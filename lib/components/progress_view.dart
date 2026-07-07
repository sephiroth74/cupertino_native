import 'dart:convert';

import 'package:cupertino_native/channel/channel_serialization.dart';
import 'package:cupertino_native/channel/layout_constraints_payload.dart';
import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/channel/payload_patch.dart';
import 'package:cupertino_native/components/button_child.dart';
import 'package:cupertino_native/components/view_modifiable.dart';
import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/model/control_size.dart';
import 'package:cupertino_native/style/progress_style.dart';
import 'package:cupertino_native/theme/cn_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const _kDefaultCircularSizeExtraLarge = 32.0;
const _kDefaultCircularSizeLarge = 32.0;
const _kDefaultCircularSizeMini = 10.0;
const _kDefaultCircularSizeRegular = 32.0;
const _kDefaultCircularSizeSmall = 16.0;

const _kDefaultLinearSizeExtraLarge = 20.0;
const _kDefaultLinearSizeLarge = 20.0;
const _kDefaultLinearSizeMini = 12.0;
const _kDefaultLinearSizeRegular = 20.0;
const _kDefaultLinearSizeSmall = 20.0;

/// A native macOS SwiftUI-style progress view.
///
/// Backed by SwiftUI `ProgressView` on macOS.
class CNProgressView extends StatefulWidget with CNButtonChild, CNViewModifiable {
  /// Creates a progress view.
  ///
  /// Pass `value` as null for indeterminate mode.
  const CNProgressView({
    super.key,
    this.value,
    this.total = 1.0,
    this.progressViewStyle = CNProgressViewStyle.linear,
    this.modifiers,
  }) : assert(total > 0);

  /// Progress view style.
  final CNProgressViewStyle progressViewStyle;

  /// Total value used for determinate progress.
  final double total;

  /// Determinate progress value. Null means indeterminate.
  final double? value;

  @override
  final CNViewModifiers? modifiers;

  @override
  String get buttonChildType => 'progressView';

  @override
  State<CNProgressView> createState() => _CNProgressViewState();

  @override
  EdgeInsets? get padding => modifiers?.padding;

  @override
  List<Object?> get props => [value, total, progressViewStyle, modifiers];

  @override
  bool get stringify => true;

  @override
  Object? get tag => modifiers?.tag;

  @override
  Map<String, dynamic> toChannelMap(BuildContext context, {bool ignoreTheme = false}) {
    return toMap(context, ignoreTheme: ignoreTheme);
  }

  /// Serializes this progress view to a map for platform channel communication.
  Map<String, dynamic> toMap(BuildContext context, {bool ignoreTheme = false, Map<String, dynamic>? layoutConstraintsPayload}) {
    final isDark = CNTheme.brightnessOf(context) == Brightness.dark;
    final resolvedTint = ignoreTheme ? null : CNTheme.of(context).progressTheme.tintColor ?? CNTheme.of(context).primaryColor;

    final payload = <String, dynamic>{
      'style': progressViewStyle.name,
      'isDark': isDark,
      if (modifiers?.tint == null) 'tint': resolveColorToArgb(resolvedTint, context),
      'value': value,
      'total': total,
    };

    writeLayoutConstraintsPayload(
      payload,
      layoutConstraintsPayload: layoutConstraintsPayload,
      explicitConstraints: modifiers?.constraints,
    );

    writeModifiers(payload, context);
    return payload;
  }
}

class _CNProgressViewState extends State<CNProgressView> {
  MethodChannel? _channel;
  double? _intrinsicHeight;
  double? _intrinsicWidth;
  Map<String, dynamic>? _lastPayload;
  String? _lastSerializedPayload;
  final CNLayoutConstraintsSyncState _layoutConstraintsSyncState = CNLayoutConstraintsSyncState();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CNProgressView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  bool get _isDark => CNTheme.brightnessOf(context) == Brightness.dark;

  Color? get _resolvedTint => widget.modifiers?.tint ?? CNTheme.of(context).progressTheme.tintColor;

  void _cacheCurrentProps() {
    final payload = _toPayload();
    _lastSerializedPayload = jsonEncode(payload);
    _lastPayload = Map<String, dynamic>.from(payload);
  }

  double _defaultHeight() {
    if (widget.progressViewStyle == CNProgressViewStyle.circular) {
      switch (widget.modifiers?.controlSize ?? CNControlSize.regular) {
        case CNControlSize.mini:
          return _kDefaultCircularSizeMini;
        case CNControlSize.small:
          return _kDefaultCircularSizeSmall;
        case CNControlSize.regular:
          return _kDefaultCircularSizeRegular;
        case CNControlSize.large:
          return _kDefaultCircularSizeLarge;
        case CNControlSize.extraLarge:
          return _kDefaultCircularSizeExtraLarge;
      }
    } else {
      switch (widget.modifiers?.controlSize ?? CNControlSize.regular) {
        case CNControlSize.mini:
          return _kDefaultLinearSizeMini;
        case CNControlSize.small:
          return _kDefaultLinearSizeSmall;
        case CNControlSize.regular:
          return _kDefaultLinearSizeRegular;
        case CNControlSize.large:
          return _kDefaultLinearSizeLarge;
        case CNControlSize.extraLarge:
          return _kDefaultLinearSizeExtraLarge;
      }
    }
  }

  double _defaultWidth() {
    if (widget.progressViewStyle == CNProgressViewStyle.circular) {
      return _defaultHeight();
    }
    return 10;
  }

  void _onCreated(int id) {
    final ch = MethodChannel('CupertinoNativeProgressIndicator_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    if (widget.modifiers?.shrinkWrap ?? true) {
      _requestIntrinsicSize();
    }
  }

  void _onIntrinsicSizeChanged(double? width, double? height) {
    debugPrint('[CNProgressView] intrinsicSizeChanged -> width=$width, height=$height');

    if (!mounted || width == null || height == null) return;
    if (width == _intrinsicWidth && height == _intrinsicHeight) return;

    setState(() {
      _intrinsicWidth = width > 0 ? width : null;
      _intrinsicHeight = height > 0 ? height : null;
    });
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'intrinsicSizeChanged':
        final args = CNChannelSerialization.asMap(call.arguments);
        _onIntrinsicSizeChanged((args?['width'] as num?)?.toDouble(), (args?['height'] as num?)?.toDouble());
        break;
      default:
        break;
    }
    return null;
  }

  Future<void> _requestIntrinsicSize() async {
    debugPrint('[CNProgressView] requestIntrinsicSize');
    final ch = _channel;
    if (ch == null) return;

    try {
      final size = await ch.invokeMethod<Map>('getIntrinsicSize');
      _onIntrinsicSizeChanged((size?['width'] as num?)?.toDouble(), (size?['height'] as num?)?.toDouble());
    } catch (_) {
      // Ignored.
    }
  }

  bool _shouldRequestIntrinsicSize(Map<String, dynamic> previous, Map<String, dynamic> next, Map<String, dynamic> patch) {
    final previousValue = previous['value'];
    final nextValue = next['value'];
    final valueNullabilityChanged = (previousValue == null) != (nextValue == null);

    if (valueNullabilityChanged) {
      return true;
    }

    const sizeAffectingKeys = {'style', 'controlSize', 'constraints', 'shrinkWrap'};
    return patch.keys.any(sizeAffectingKeys.contains);
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    debugPrint('[CNProgressView] syncPropsToNativeIfNeeded');
    final ch = _channel;
    if (ch == null) return;

    final payload = _toPayload();
    final serializedPayload = jsonEncode(payload);

    if (_lastPayload == null) {
      if (_lastSerializedPayload != serializedPayload) {
        debugPrint('[CNProgressView] setData -> $payload');
        await ch.invokeMethod('setData', payload);
      }

      _lastSerializedPayload = serializedPayload;
      _lastPayload = Map<String, dynamic>.from(payload);
      if (widget.modifiers?.shrinkWrap ?? true) {
        _requestIntrinsicSize();
      }
      return;
    }

    final patch = computeJsonSafePatch(_lastPayload!, payload);
    if (patch.isEmpty) {
      _lastSerializedPayload = serializedPayload;
      return;
    }

    debugPrint('[CNProgressView] applyPatch -> $patch');
    final previousPayload = _lastPayload!;
    await ch.invokeMethod('applyPatch', patch);
    _lastSerializedPayload = serializedPayload;
    _lastPayload = Map<String, dynamic>.from(payload);

    if ((widget.modifiers?.shrinkWrap ?? true) && _shouldRequestIntrinsicSize(previousPayload, payload, patch)) {
      _requestIntrinsicSize();
    }
  }

  Map<String, dynamic> _toPayload() {
    final payload = <String, dynamic>{
      'style': widget.progressViewStyle.name,
      'controlSize': (widget.modifiers?.controlSize ?? CNControlSize.regular).name,
      'isDark': _isDark,
      if (widget.modifiers?.tint == null) 'tint': resolveColorToArgb(_resolvedTint, context),
      'value': widget.value,
      'total': widget.total,
    };

    writeLayoutConstraintsPayload(
      payload,
      layoutConstraintsPayload: _layoutConstraintsSyncState.layoutConstraintsPayload,
      explicitConstraints: widget.modifiers?.constraints,
    );

    widget.writeModifiers(payload, context);
    return payload;
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.macOS) {
      return SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final shrinkWrap = widget.modifiers?.shrinkWrap ?? true;
        final resolvedLayoutConstraints = resolveLayoutConstraintsPayload(
          parentConstraints: constraints,
          explicitConstraints: widget.modifiers?.constraints,
        );
        final resolvedConstraints = resolvedLayoutConstraints.resolvedConstraints;
        _layoutConstraintsSyncState.apply(resolvedLayoutConstraints, sync: _syncPropsToNativeIfNeeded);

        final hasBoundedWidth = constraints.hasBoundedWidth;
        final hasBoundedHeight = constraints.hasBoundedHeight;

        final resolvedWidth = hasBoundedWidth ? constraints.maxWidth : _intrinsicWidth ?? _defaultWidth();
        final resolvedHeight = hasBoundedHeight ? constraints.maxHeight : _intrinsicHeight ?? _defaultHeight();

        final creationParams = _toPayload();

        Widget nativeView = AppKitView(
          viewType: 'CupertinoNativeProgressIndicator',
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onCreated,
        );

        if (!shrinkWrap) {
          nativeView = ConstrainedBox(constraints: resolvedConstraints, child: nativeView);
          return nativeView;
        }

        return SizedBox(width: resolvedWidth, height: resolvedHeight, child: nativeView);
      },
    );
  }
}
