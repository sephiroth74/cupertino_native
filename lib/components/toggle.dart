import 'dart:convert';

import 'package:cupertino_native/channel/channel_serialization.dart';
import 'package:cupertino_native/components/button_child.dart';
import 'package:cupertino_native/components/image.dart';
import 'package:cupertino_native/components/text.dart';
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
    this.label,
    this.systemSymbolName,
    this.toggleStyle = CNToggleStyle.switch_,
    this.shrinkWrap = false,
    this.modifiers,
  });

  /// Label content children rendered in the native `Toggle` label closure.
  ///
  /// When empty, [label] and [systemSymbolName] are used as a legacy fallback.
  final List<CNButtonChild> children;

  /// Optional external controller for imperative native operations.
  final CNToggleController? controller;

  /// Optional label text for the toggle.
  final String? label;

  /// Called when the user toggles the control.
  final ValueChanged<bool>? onChanged;

  /// Optional system symbol name (SF Symbol) to display with the label.
  final String? systemSymbolName;

  /// The style of the toggle control.
  final CNToggleStyle toggleStyle;

  /// Whether the toggle is on or off.
  final bool value;

  @override
  final CNViewModifiers? modifiers;

  /// If true, allows intrinsic sizing on unconstrained axes.
  @override
  final bool shrinkWrap;

  @override
  State<CNToggle> createState() => _CNToggleState();

  @override
  EdgeInsets? get padding => modifiers?.padding;

  @override
  Object? get tag => modifiers?.tag;
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
  Map<String, dynamic>? _lastPayload;
  String? _lastSerializedPayload;
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
        oldWidget.label != widget.label ||
        oldWidget.systemSymbolName != widget.systemSymbolName ||
        oldWidget.toggleStyle != widget.toggleStyle ||
        oldWidget.shrinkWrap != widget.shrinkWrap ||
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
        // Native toggle already updated itself; avoid setToggle/rebuild ping-pong.
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

  Map<String, dynamic> _computePayloadPatch(Map<String, dynamic> previous, Map<String, dynamic> next) {
    final patch = <String, dynamic>{};
    final keys = <String>{...previous.keys, ...next.keys};

    for (final key in keys) {
      final hadPrevious = previous.containsKey(key);
      final hasNext = next.containsKey(key);
      final oldValue = hadPrevious ? previous[key] : null;
      final newValue = hasNext ? next[key] : null;

      final changed = jsonEncode(oldValue) != jsonEncode(newValue);
      if (!changed) continue;

      patch[key] = hasNext ? newValue : null;
    }

    return patch;
  }

  void _onIntrinsicSizeChanged(double? width, double? height) {
    if (!mounted || width == null || height == null) return;

    debugPrint('CNToggle intrinsic size changed: width=$width, height=$height');

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

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    final payload = _toPayload();
    final serializedPayload = jsonEncode(payload);

    if (_lastPayload == null) {
      if (_lastSerializedPayload != serializedPayload) {
        debugPrint('[CNToggle][Dart] Sending full update via setToggle: $serializedPayload');
        await channel.invokeMethod('setToggle', payload);
      }

      _lastSerializedPayload = serializedPayload;
      _lastPayload = Map<String, dynamic>.from(payload);
      return;
    }

    final patch = _computePayloadPatch(_lastPayload!, payload);
    if (patch.isEmpty) {
      debugPrint('[CNToggle][Dart] No patch to send (payload unchanged)');
      _lastSerializedPayload = serializedPayload;
      return;
    }

    final serializedPatch = jsonEncode(patch);
    debugPrint('[CNToggle][Dart] Sending patch via setTogglePatch: $serializedPatch');
    await channel.invokeMethod('setTogglePatch', patch);
    _lastSerializedPayload = serializedPayload;
    _lastPayload = Map<String, dynamic>.from(payload);
  }

  Map<String, dynamic> _toPayload() {
    final payload = <String, dynamic>{
      'value': widget.value,
      'labelChildren': _serializeChildren(_resolvedLabelChildren()),
      'toggleStyle': widget.toggleStyle.toShortString(),
      'isDark': _isDark,
    };
    widget.writeModifiers(payload, context);
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
        final resolvedWidth =
            widget.modifiers?.width ?? (hasFixedWidth ? constraints.maxWidth : (_intrinsicWidth ?? _kDefaultToggleWidth));
        final resolvedHeight =
            widget.modifiers?.height ?? (hasFixedHeight ? constraints.maxHeight : (_intrinsicHeight ?? _kDefaultToggleHeight));

        final creationParams = _toPayload();

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
