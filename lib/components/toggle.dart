import 'dart:convert';

import 'package:cupertino_native/channel/channel_serialization.dart';
import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/components/button_child.dart';
import 'package:cupertino_native/components/image.dart';
import 'package:cupertino_native/components/text.dart';
import 'package:cupertino_native/model/control_size.dart';
import 'package:cupertino_native/theme/cn_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const double _kDefaultToggleHeight = 30.0;
const double _kDefaultToggleWidth = 200.0;

/// A macOS toggle control that toggles between on and off states.
///
/// The [CNToggle] is a native macOS toggle control that wraps the SwiftUI Toggle view.
/// It displays a toggle with an optional label and icon.
///
/// Example:
/// ```dart
/// CNToggle(
///   value: true,
///   label: 'Dark Mode',
///   onChanged: (bool value) {
///     print('Toggle changed to: $value');
///   },
/// )
/// ```
class CNToggle extends StatefulWidget {
  /// Creates a [CNToggle].
  const CNToggle({
    super.key,
    required this.value,
    this.onChanged,
    this.children = const [],
    this.label,
    this.systemSymbolName,
    this.toggleStyle = CNToggleStyle.switch_,
    this.controlSize = CNControlSize.regular,
    this.tint,
    this.foregroundColor,
    this.width,
    this.height,
    this.shrinkWrap = false,
  }) : enabled = onChanged != null;

  /// Label content children rendered in the native `Toggle` label closure.
  ///
  /// When empty, [label] and [systemSymbolName] are used as a legacy fallback.
  final List<CNButtonChild> children;

  /// The size of the control, which affects its appearance.
  final CNControlSize controlSize;

  /// Whether the toggle is enabled for interaction.
  final bool enabled;

  /// Optional foreground color for the label content.
  final Color? foregroundColor;

  /// Optional fixed height.
  final double? height;

  /// Optional label text for the toggle.
  final String? label;

  /// Called when the user toggles the control.
  final ValueChanged<bool>? onChanged;

  /// If true, allows intrinsic sizing on unconstrained axes.
  final bool shrinkWrap;

  /// Optional system symbol name (SF Symbol) to display with the label.
  final String? systemSymbolName;

  /// Optional tint color for the toggle control.
  final Color? tint;

  /// The style of the toggle control.
  final CNToggleStyle toggleStyle;

  /// Whether the toggle is on or off.
  final bool value;

  /// Optional fixed width.
  final double? width;

  @override
  State<CNToggle> createState() => _CNToggleState();
}

/// Controller for a [CNToggle] that allows imperative updates from Dart
/// to the underlying native toggle instance.
class CNToggleController {
  MethodChannel? _channel;

  /// Enables or disables user interaction on the native toggle.
  Future<void> setEnabled(bool enabled) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setIsEnabled', {'value': enabled});
  }

  /// Sets the toggle [value]. When [animated] is true the change is animated
  /// on the native control.
  Future<void> setValue(bool value, {bool animated = false}) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setValue', {'value': value, 'animated': animated});
  }

  void _attach(MethodChannel channel) {
    _channel = channel;
  }

  void _detach() {
    _channel = null;
  }
}

/// Represents the style of a [CNToggle] control.
enum CNToggleStyle {
  /// Automatic style (default)
  automatic,

  /// Default platform switch style
  switch_,

  /// Button toggle style (appears as a button)
  button,

  /// Checkbox toggle style
  checkbox,
}

class _CNToggleState extends State<CNToggle> {
  MethodChannel? _channel;
  late CNToggleController _controller;
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
  void didUpdateWidget(covariant CNToggle oldWidget) {
    super.didUpdateWidget(oldWidget);

    final shouldResetPayload =
        oldWidget.value != widget.value ||
        oldWidget.enabled != widget.enabled ||
        oldWidget.label != widget.label ||
        oldWidget.systemSymbolName != widget.systemSymbolName ||
        oldWidget.toggleStyle != widget.toggleStyle ||
        oldWidget.controlSize != widget.controlSize ||
        oldWidget.tint != widget.tint ||
        oldWidget.foregroundColor != widget.foregroundColor ||
        oldWidget.width != widget.width ||
        oldWidget.height != widget.height ||
        oldWidget.shrinkWrap != widget.shrinkWrap ||
        !listEquals(oldWidget.children, widget.children);

    if (shouldResetPayload) {
      _lastSerializedPayload = null;
    }

    _syncPropsToNativeIfNeeded();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _controller._detach();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = CNToggleController();
  }

  Color? get _effectiveTint {
    final theme = CNTheme.of(context);
    return widget.tint ?? theme.toggleTheme.tint ?? theme.accentColor;
  }

  bool get _isDark => CNTheme.brightnessOf(context) == Brightness.dark;

  void _cacheCurrentProps() {
    _lastSerializedPayload = _serializeCurrentPayload();
  }

  void _onIntrinsicSizeChanged(double? width, double? height) {
    if (!mounted || width == null || height == null) return;

    if (width == _intrinsicWidth && height == _intrinsicHeight) {
      return; // No change
    }

    setState(() {
      _intrinsicWidth = width > 0 ? width : null;
      _intrinsicHeight = height > 0 ? height : null;
    });
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'onChanged') {
      final args = CNChannelSerialization.asMap(call.arguments);
      final rawValue = args?['value'];
      final bool? newValue;
      if (rawValue is bool) {
        newValue = rawValue;
      } else if (rawValue is num) {
        newValue = rawValue.toInt() == 1;
      } else {
        newValue = null;
      }

      if (newValue != null) {
        widget.onChanged?.call(newValue);
      }
    } else if (call.method == 'intrinsicSizeChanged') {
      final args = CNChannelSerialization.asMap(call.arguments);
      _onIntrinsicSizeChanged((args?['width'] as num?)?.toDouble(), (args?['height'] as num?)?.toDouble());
    }
    return null;
  }

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('CupertinoNativeToggle_$id');
    _channel = channel;
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _requestIntrinsicSize();
    _controller._attach(channel);
  }

  Future<void> _requestIntrinsicSize() async {
    final channel = _channel;
    if (channel == null) return;

    try {
      final result = await channel.invokeMethod<Map>('getIntrinsicSize');
      if (result != null) {
        _onIntrinsicSizeChanged((result['width'] as num?)?.toDouble(), (result['height'] as num?)?.toDouble());
      }
    } catch (_) {}
  }

  List<CNButtonChild> _resolvedLabelChildren() {
    if (widget.children.isNotEmpty) {
      return widget.children;
    }

    final legacyChildren = <CNButtonChild>[];
    if (widget.systemSymbolName != null) {
      legacyChildren.add(CNImage(systemSymbolName: widget.systemSymbolName!));
    }
    if (widget.label != null) {
      legacyChildren.add(CNText(widget.label!));
    }
    return legacyChildren;
  }

  List<Map<String, dynamic>> _serializeChildren(List<CNButtonChild> children) {
    return children
        .map((child) => {'type': child.buttonChildType, 'payload': child.toChannelMap(context, ignoreTheme: true)})
        .toList();
  }

  String _serializeCurrentPayload() => jsonEncode(_toPayload(frameWidth: _layoutWidth, frameHeight: _layoutHeight));

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    final payload = _toPayload(frameWidth: _layoutWidth, frameHeight: _layoutHeight);
    final serializedPayload = jsonEncode(payload);

    if (_lastSerializedPayload != serializedPayload) {
      await channel.invokeMethod('setToggle', payload);
      _cacheCurrentProps();
      _requestIntrinsicSize();
    }
  }

  Map<String, dynamic> _toPayload({double? frameWidth, double? frameHeight}) {
    final payload = {
      'value': widget.value,
      'enabled': widget.enabled,
      'labelChildren': _serializeChildren(_resolvedLabelChildren()),
      'toggleStyle': widget.toggleStyle.toShortString(),
      'isDark': _isDark,
      'controlSize': widget.controlSize.name,
      'tint': resolveColorToArgb(_effectiveTint, context),
      'foregroundColor': resolveColorToArgb(widget.foregroundColor, context),
    };

    if (frameWidth != null) {
      payload['width'] = frameWidth;
    }

    if (frameHeight != null) {
      payload['height'] = frameHeight;
    }

    return payload;
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.macOS) {
      return const SizedBox.shrink();
    }

    const viewType = 'cupertino_native/toggle';

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasFixedWidth = constraints.hasTightWidth;
        final hasFixedHeight = constraints.hasTightHeight;
        final hasExplicitWidth = widget.width != null;
        final hasExplicitHeight = widget.height != null;
        final shouldSendWidth = hasExplicitWidth || hasFixedWidth;
        final shouldSendHeight = hasExplicitHeight || hasFixedHeight;

        final resolvedWidth = widget.width ?? (hasFixedWidth ? constraints.maxWidth : (_intrinsicWidth ?? _kDefaultToggleWidth));
        final resolvedHeight =
            widget.height ?? (hasFixedHeight ? constraints.maxHeight : (_intrinsicHeight ?? _kDefaultToggleHeight));

        final nextLayoutWidth = shouldSendWidth ? resolvedWidth : null;
        final nextLayoutHeight = shouldSendHeight ? resolvedHeight : null;

        if (_layoutWidth != nextLayoutWidth || _layoutHeight != nextLayoutHeight) {
          _layoutWidth = nextLayoutWidth;
          _layoutHeight = nextLayoutHeight;
          _syncPropsToNativeIfNeeded();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _requestIntrinsicSize();
            }
          });
        }

        final creationParams = _toPayload(frameWidth: nextLayoutWidth, frameHeight: nextLayoutHeight);

        return SizedBox(
          height: resolvedHeight,
          width: resolvedWidth,
          child: AppKitView(
            viewType: viewType,
            creationParamsCodec: const StandardMessageCodec(),
            creationParams: creationParams,
            onPlatformViewCreated: _onPlatformViewCreated,
          ),
        );
      },
    );
  }
}

/// Extension to convert enum to string
extension CNToggleStyleExtension on CNToggleStyle {
  // ignore: public_member_api_docs
  String toShortString() {
    switch (this) {
      case CNToggleStyle.automatic:
        return 'automatic';
      case CNToggleStyle.switch_:
        return 'switch';
      case CNToggleStyle.button:
        return 'button';
      case CNToggleStyle.checkbox:
        return 'checkbox';
    }
  }
}
