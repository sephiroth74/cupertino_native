import 'dart:convert';

import 'package:cupertino_native/channel/channel_serialization.dart';
import 'package:cupertino_native/channel/layout_constraints_payload.dart';
import 'package:cupertino_native/channel/payload_patch.dart';
import 'package:cupertino_native/components/button_child.dart';
import 'package:cupertino_native/components/cn_widget_debug_id_mixin.dart';
import 'package:cupertino_native/components/view_modifiable.dart';
import 'package:cupertino_native/components/view_modifiers.dart';
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
class CNToggle extends StatefulWidget with CNViewModifiable {
  /// Creates a [CNToggle].
  const CNToggle({
    super.key,
    required this.value,
    this.onChanged,
    this.controller,
    this.children = const [],
    this.toggleStyle = CNToggleStyle.switch_,
    this.modifiers = const CNViewModifiers(),
  });

  /// Label content children rendered in the native `Toggle` label closure.
  final List<CNButtonChild> children;

  /// Optional external controller for imperative native operations.
  final CNToggleController? controller;

  /// Called when the user toggles the control.
  final ValueChanged<bool>? onChanged;

  /// The style of the toggle control.
  final CNToggleStyle toggleStyle;

  /// Whether the toggle is on or off.
  final bool value;

  @override
  final CNViewModifiers modifiers;

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
    await channel.invokeMethod('setEnabled', {'value': enabled});
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

class _CNToggleState extends State<CNToggle> with CNWidgetDebugIdMixin<CNToggle> {
  MethodChannel? _channel;
  late CNToggleController _controller;
  double? _intrinsicHeight;
  double? _intrinsicWidth;
  Map<String, dynamic>? _lastPayload;
  String? _lastSerializedPayload;
  final CNLayoutConstraintsSyncState _layoutConstraintsSyncState = CNLayoutConstraintsSyncState();
  bool? _pendingNativeValue;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CNToggle oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      _controller._detach();
      _controller = widget.controller ?? CNToggleController();
      final channel = _channel;
      if (channel != null) {
        _controller._attach(channel);
      }
    }

    final valueChanged = oldWidget.value != widget.value;
    final shouldResetPayload =
        oldWidget.toggleStyle != widget.toggleStyle ||
        oldWidget.modifiers != widget.modifiers ||
        !listEquals(oldWidget.children, widget.children);

    if (shouldResetPayload) {
      _lastSerializedPayload = null;
      _lastPayload = null;
    }

    if (valueChanged) {
      final isEchoFromNative = _pendingNativeValue != null && widget.value == _pendingNativeValue;
      _pendingNativeValue = null;

      if (isEchoFromNative) {
        // Native toggle already updated itself; avoid redundant full-sync ping-pong.
        _cacheCurrentProps();
      } else {
        _lastSerializedPayload = null;
        _lastPayload = null;
      }
    } else {
      _pendingNativeValue = null;
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
    _controller = widget.controller ?? CNToggleController();
  }

  bool get _isDark => CNTheme.brightnessOf(context) == Brightness.dark;

  void _cacheCurrentProps() {
    final payload = _toPayload();
    _lastSerializedPayload = jsonEncode(payload);
    _lastPayload = Map<String, dynamic>.from(payload);
  }

  void _onIntrinsicSizeChanged(double? width, double? height) {
    if (!mounted || width == null || height == null) return;

    // debugPrint('CNToggle intrinsic size changed: width=$width, height=$height');

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
        _pendingNativeValue = newValue;
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

  List<Map<String, dynamic>> _serializeChildren(List<CNButtonChild> children) {
    return children
        .map((child) => {'type': child.buttonChildType, 'payload': child.toChannelMap(context, ignoreTheme: true)})
        .toList();
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    final payload = _toPayload();
    final serializedPayload = jsonEncode(payload);

    if (_lastPayload == null) {
      if (_lastSerializedPayload != serializedPayload) {
        // debugPrint('$debugLogPrefix sending full update via setData: $serializedPayload');
        await channel.invokeMethod('setData', payload);
      }

      _lastSerializedPayload = serializedPayload;
      _lastPayload = Map<String, dynamic>.from(payload);
      return;
    }

    final patch = computeJsonSafePatch(_lastPayload!, payload);
    if (patch.isEmpty) {
      // debugPrint('$debugLogPrefix no patch to send (payload unchanged)');
      _lastSerializedPayload = serializedPayload;
      return;
    }

    final serializedPatch = jsonEncode(patch);
    // debugPrint('$debugLogPrefix sending patch via applyPatch: $serializedPatch');
    await channel.invokeMethod('applyPatch', patch);
    _lastSerializedPayload = serializedPayload;
    _lastPayload = Map<String, dynamic>.from(payload);
  }

  Map<String, dynamic> _toPayload() {
    final payload = <String, dynamic>{
      'value': widget.value,
      'labelChildren': _serializeChildren(widget.children),
      'toggleStyle': widget.toggleStyle.toShortString(),
      'isDark': _isDark,
    };

    writeLayoutConstraintsPayload(
      payload,
      layoutConstraintsPayload: _layoutConstraintsSyncState.layoutConstraintsPayload,
      explicitConstraints: widget.modifiers.constraints,
    );

    widget.writeModifiers(payload, context);
    writeDebugWidgetId(payload);
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
        final effectiveShrinkWrap = widget.modifiers.shrinkWrap;
        final explicitConstraints = widget.modifiers.constraints;
        final hasBoundedParentSize = constraints.hasBoundedWidth || constraints.hasBoundedHeight;
        final hasBoundedModifierSize =
            (explicitConstraints?.hasBoundedWidth ?? false) || (explicitConstraints?.hasBoundedHeight ?? false);

        assert(
          effectiveShrinkWrap || hasBoundedModifierSize || hasBoundedParentSize,
          'CNToggle requires at least one bounded axis when shrinkWrap is false. '
          'Provide bounded constraints in CNViewModifiers.constraints or place CNToggle in a parent with bounded size.',
        );

        final resolvedLayoutConstraints = resolveLayoutConstraintsPayload(
          parentConstraints: constraints,
          explicitConstraints: explicitConstraints,
        );
        final resolvedConstraints = resolvedLayoutConstraints.resolvedConstraints;
        _layoutConstraintsSyncState.apply(resolvedLayoutConstraints, sync: _syncPropsToNativeIfNeeded);

        final hasBoundedWidth = constraints.hasBoundedWidth;
        final hasBoundedHeight = constraints.hasBoundedHeight;

        final intrinsicOrDefaultWidth = _intrinsicWidth ?? _kDefaultToggleWidth;
        final intrinsicOrDefaultHeight = _intrinsicHeight ?? _kDefaultToggleHeight;

        final resolvedWidth = effectiveShrinkWrap
            ? (hasBoundedWidth ? intrinsicOrDefaultWidth.clamp(0.0, constraints.maxWidth).toDouble() : intrinsicOrDefaultWidth)
            : (resolvedConstraints.hasBoundedWidth ? resolvedConstraints.maxWidth : intrinsicOrDefaultWidth);
        final resolvedHeight = effectiveShrinkWrap
            ? (hasBoundedHeight ? intrinsicOrDefaultHeight.clamp(0.0, constraints.maxHeight).toDouble() : intrinsicOrDefaultHeight)
            : (resolvedConstraints.hasBoundedHeight ? resolvedConstraints.maxHeight : intrinsicOrDefaultHeight);

        final creationParams = _toPayload();

        Widget nativeView = AppKitView(
          viewType: viewType,
          creationParamsCodec: const StandardMessageCodec(),
          creationParams: creationParams,
          onPlatformViewCreated: _onPlatformViewCreated,
        );

        if (!effectiveShrinkWrap) {
          nativeView = SizedBox(
            width: resolvedConstraints.hasBoundedWidth ? null : resolvedWidth,
            height: resolvedConstraints.hasBoundedHeight ? null : resolvedHeight,
            child: nativeView,
          );
          nativeView = ConstrainedBox(constraints: resolvedConstraints, child: nativeView);
          return nativeView;
        }

        return SizedBox(height: resolvedHeight, width: resolvedWidth, child: nativeView);
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
