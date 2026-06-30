import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

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

/// Controller for a [CNToggle] that allows imperative updates from Dart
/// to the underlying native toggle instance.
class CNToggleController {
  MethodChannel? _channel;

  /// Sets the toggle [value]. When [animated] is true the change is animated
  /// on the native control.
  Future<void> setValue(bool value, {bool animated = false}) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setValue', {'value': value, 'animated': animated});
  }

  /// Enables or disables user interaction on the native toggle.
  Future<void> setEnabled(bool enabled) async {
    final channel = _channel;
    if (channel == null) return;
    await channel.invokeMethod('setIsEnabled', {'value': enabled});
  }

  void _attach(MethodChannel channel) {
    _channel = channel;
  }

  void _detach() {
    _channel = null;
  }
}

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
    this.label,
    this.systemSymbolName,
    this.toggleStyle = CNToggleStyle.switch_,
    this.controlSize = CNControlSize.regular,
    this.tint,
  }) : enabled = onChanged != null;

  /// The size of the control, which affects its appearance.
  final CNControlSize controlSize;

  /// Whether the toggle is enabled for interaction.
  final bool enabled;

  /// Optional label text for the toggle.
  final String? label;

  /// Called when the user toggles the control.
  final ValueChanged<bool>? onChanged;

  /// Optional system symbol name (SF Symbol) to display with the label.
  final String? systemSymbolName;

  /// Optional tint color for the toggle control.
  final Color? tint;

  /// The style of the toggle control.
  final CNToggleStyle toggleStyle;

  /// Whether the toggle is on or off.
  final bool value;

  @override
  State<CNToggle> createState() => _CNToggleState();
}

class _CNToggleState extends State<CNToggle> {
  MethodChannel? _channel;
  late CNToggleController _controller;
  double? _intrinsicHeight;
  double? _intrinsicWidth;
  CNControlSize? _lastControlSize;
  bool? _lastEnabled;
  bool? _lastIsDark;
  Color? _lastTint;
  CNToggleStyle? _lastToggleStyle;
  bool? _lastValue;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CNToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
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

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('CupertinoNativeToggle_$id');
    _channel = channel;
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _syncBrightnessIfNeeded();
    _controller._attach(channel);
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'onChanged') {
      final args = call.arguments as Map?;
      final newValue = (args?['value'] as bool?);
      if (newValue != null) {
        _lastValue = newValue;
        widget.onChanged?.call(newValue);
      }
    } else if (call.method == 'intrinsicSizeChanged') {
      final args = call.arguments as Map?;
      _onIntrinsicSizeChanged((args?['width'] as num?)?.toDouble(), (args?['height'] as num?)?.toDouble());
    }
    return null;
  }

  Future<void> _queryIntrinsicSize() async {
    try {
      final result = await _channel?.invokeMethod<Map>('getIntrinsicSize');
      if (result != null) {
        debugPrint('Picker intrinsic size: $result');
        _onIntrinsicSizeChanged((result['width'] as num?)?.toDouble(), (result['height'] as num?)?.toDouble());
      }
    } catch (e) {
      // Fallback to default height
      _intrinsicWidth = null;
      _intrinsicHeight = null;
    }
  }

  void _onIntrinsicSizeChanged(double? width, double? height) {
    if (!mounted || width == null || height == null) return;
    debugPrint('_onIntrinsicSizeChanged: width=$width, height=$height');

    if (width == _intrinsicWidth && height == _intrinsicHeight) {
      return; // No change
    }

    setState(() {
      _intrinsicWidth = width > -1 ? width : null;
      _intrinsicHeight = height > -1 ? height : null;
    });
  }

  void _cacheCurrentProps() {
    _lastValue = widget.value;
    _lastEnabled = widget.enabled;
    _lastIsDark = _isDark;
    _lastToggleStyle = widget.toggleStyle;
    _lastControlSize = widget.controlSize;
    _lastTint = widget.tint;
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    if (_lastValue != widget.value) {
      await channel.invokeMethod('setValue', {'value': widget.value});
      _lastValue = widget.value;
    }
    if (_lastEnabled != widget.enabled) {
      await channel.invokeMethod('setIsEnabled', {'value': widget.enabled});
      _lastEnabled = widget.enabled;
    }
    if (_lastToggleStyle != widget.toggleStyle) {
      await channel.invokeMethod('setToggleStyle', {'toggleStyle': widget.toggleStyle.toShortString()});
      _lastToggleStyle = widget.toggleStyle;
      _queryIntrinsicSize();
    }
    if (_lastControlSize != widget.controlSize) {
      await channel.invokeMethod('setControlSize', {'controlSize': widget.controlSize.name});
      _lastControlSize = widget.controlSize;
      _queryIntrinsicSize();
    }
    if (_lastTint != widget.tint && mounted) {
      final tintValue = resolveColorToArgb(widget.tint, context);
      await channel.invokeMethod('setTint', {'tint': tintValue});
      _lastTint = widget.tint;
    }
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;
    final isDark = _isDark;
    if (_lastIsDark != isDark) {
      await channel.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.macOS) {
      return SizedBox.shrink();
    }

    const viewType = 'cupertino_native/toggle';
    final creationParams = <String, dynamic>{
      'value': widget.value,
      'enabled': widget.enabled,
      'label': widget.label,
      'systemSymbolName': widget.systemSymbolName,
      'toggleStyle': widget.toggleStyle.toShortString(),
      'isDark': _isDark,
      'controlSize': widget.controlSize.name,
      'tint': resolveColorToArgb(widget.tint, context),
    };

    final child = AppKitView(
      viewType: viewType,
      creationParamsCodec: const StandardMessageCodec(),
      creationParams: creationParams,
      onPlatformViewCreated: _onPlatformViewCreated,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        double? width;
        double? height;

        if (_intrinsicWidth != null) {
          width = _intrinsicWidth;
        } else if (constraints.hasBoundedWidth) {
          width = constraints.maxWidth;
        } else {
          width = 200.0; // Default width
        }

        if (_intrinsicHeight != null) {
          height = _intrinsicHeight;
        } else if (constraints.hasBoundedHeight) {
          height = constraints.maxHeight;
        } else {
          height = 30.0; // Default height
        }

        return SizedBox(height: height, width: width, child: child);
      },
    );
  }
}
