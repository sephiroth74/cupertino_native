import 'dart:convert';

import 'package:cupertino_native/channel/channel_serialization.dart';
import 'package:cupertino_native/channel/params.dart';
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
    this.controlSize = CNControlSize.regular,
    this.tint,
    this.width,
    this.height,
    this.modifiers,
  }) : assert(total > 0);

  /// Native control size.
  final CNControlSize controlSize;

  /// Progress view style.
  final CNProgressViewStyle progressViewStyle;

  /// Optional tint color.
  final Color? tint;

  /// Total value used for determinate progress.
  final double total;

  /// Determinate progress value. Null means indeterminate.
  final double? value;

  /// Optional fixed height.
  @override
  final double? height;

  @override
  final CNViewModifiers? modifiers;

  /// Optional fixed width.
  @override
  final double? width;

  @override
  String get buttonChildType => 'progressView';

  @override
  State<CNProgressView> createState() => _CNProgressViewState();

  @override
  EdgeInsets? get padding => modifiers?.padding;

  @override
  List<Object?> get props => [value, total, progressViewStyle, controlSize, tint, width, height];

  @override
  bool get stringify => true;

  @override
  Object? get tag => modifiers?.tag;

  @override
  Map<String, dynamic> toChannelMap(BuildContext context, {bool ignoreTheme = false}) {
    final isDark = CNTheme.brightnessOf(context) == Brightness.dark;
    final resolvedTint =
        tint ?? (ignoreTheme ? null : CNTheme.of(context).progressTheme.tintColor ?? CNTheme.of(context).primaryColor);

    final payload = <String, dynamic>{
      'style': progressViewStyle.name,
      'controlSize': controlSize.name,
      'isDark': isDark,
      'tint': resolveColorToArgb(resolvedTint, context),
      'value': value,
      'total': total,
      'width': width,
      'height': height,
    };

    writeModifiers(payload, context);
    return payload;
  }
}

class _CNProgressViewState extends State<CNProgressView> {
  MethodChannel? _channel;
  double? _intrinsicHeight;
  double? _intrinsicWidth;
  String? _lastSerializedPayload;
  double? _layoutHeight;
  double? _layoutWidth;

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

  bool get _isCircular => widget.progressViewStyle == CNProgressViewStyle.circular;

  bool get _isDark => CNTheme.brightnessOf(context) == Brightness.dark;

  Color? get _resolvedTint => widget.tint ?? CNTheme.of(context).progressTheme.tintColor ?? CNTheme.of(context).primaryColor;

  void _cacheCurrentProps() {
    _lastSerializedPayload = _serializeCurrentPayload();
  }

  double _defaultHeight() {
    if (widget.progressViewStyle == CNProgressViewStyle.circular) {
      switch (widget.controlSize) {
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
      switch (widget.controlSize) {
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
    _requestIntrinsicSize();
  }

  void _onIntrinsicSizeChanged(double? width, double? height) {
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
    final ch = _channel;
    if (ch == null) return;

    try {
      final size = await ch.invokeMethod<Map>('getIntrinsicSize');
      _onIntrinsicSizeChanged((size?['width'] as num?)?.toDouble(), (size?['height'] as num?)?.toDouble());
    } catch (_) {
      // Ignored.
    }
  }

  String _serializeCurrentPayload() =>
      jsonEncode(_toPayload(frameWidth: _isCircular ? null : _layoutWidth, frameHeight: _isCircular ? null : _layoutHeight));

  Future<void> _syncPropsToNativeIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;

    final payload = _toPayload(frameWidth: _layoutWidth, frameHeight: _layoutHeight);
    final serializedPayload = jsonEncode(payload);

    if (_lastSerializedPayload != serializedPayload) {
      await ch.invokeMethod('setProgressView', payload);
      _cacheCurrentProps();
      _requestIntrinsicSize();
    }
  }

  Map<String, dynamic> _toPayload({double? frameWidth, double? frameHeight}) {
    final payload = <String, dynamic>{
      'style': widget.progressViewStyle.name,
      'controlSize': widget.controlSize.name,
      'isDark': _isDark,
      'tint': resolveColorToArgb(_resolvedTint, context),
      'value': widget.value,
      'total': widget.total,
      'width': frameWidth,
      'height': frameHeight,
    };

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
        final hasBoundedWidth = constraints.hasBoundedWidth;
        final hasBoundedHeight = constraints.hasBoundedHeight;

        final resolvedWidth =
            widget.width ?? _intrinsicWidth ?? (hasBoundedWidth ? constraints.maxWidth : _intrinsicWidth ?? _defaultWidth());
        final resolvedHeight =
            widget.height ?? _intrinsicHeight ?? (hasBoundedHeight ? constraints.maxHeight : _intrinsicHeight ?? _defaultHeight());

        if (_layoutWidth != resolvedWidth || _layoutHeight != resolvedHeight) {
          _layoutWidth = resolvedWidth;
          _layoutHeight = resolvedHeight;
          _syncPropsToNativeIfNeeded();
        }

        final creationParams = _toPayload(
          frameWidth: _isCircular ? null : widget.width ?? (hasBoundedWidth ? constraints.maxWidth : null),
          frameHeight: _isCircular ? null : widget.height ?? (hasBoundedHeight ? constraints.maxHeight : null),
        );

        return SizedBox(
          width: resolvedWidth,
          height: resolvedHeight,
          child: AppKitView(
            viewType: 'CupertinoNativeProgressIndicator',
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
          ),
        );
      },
    );
  }
}
