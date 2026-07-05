import 'dart:convert';

import 'package:cupertino_native/channel/channel_serialization.dart';
import 'package:cupertino_native/components/button_child.dart';
import 'package:cupertino_native/components/menu_badge_support.dart';
import 'package:cupertino_native/components/menu_child.dart';
import 'package:cupertino_native/model/control_size.dart';
import 'package:cupertino_native/theme/cn_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../channel/params.dart';
import '../style/button_style.dart';

const double _kDefaultHeight = 64.0;
const double _kDefaultWidth = 80.0;

/// Semantic role for button actions.
enum CNButtonRole {
  /// Default role.
  none,

  /// Cancel role.
  cancel,

  /// Destructive role.
  destructive,

  /// Close role.
  close,
}

/// A Cupertino-native push button.
///
/// Embeds a native SwiftUI Button for authentic visuals and behavior on
/// macOS. Falls back to [CupertinoButton] on other platforms.
class CNButton extends StatefulWidget with CNMenuChild {
  /// Creates a native SwiftUI button.
  ///
  /// Supported child types are [CNImage], [CNLabel], and [CNText].
  const CNButton({
    super.key,
    this.children = const [],
    this.badge,
    this.role = CNButtonRole.none,
    this.onPressed,
    this.enabled = true,
    this.tint,
    this.width,
    this.height,
    this.shrinkWrap = false,
    this.style = CNButtonStyle.automatic,
    this.controlSize = CNControlSize.regular,
  }) : assert(badge == null || badge is String || badge is int, 'Badge must be a String or int.');

  /// Optional badge shown next to the menu item when used inside [CNMenu].
  final Object? badge;

  /// Content views shown inside the native SwiftUI button label closure.
  final List<CNButtonChild> children;

  /// Control size.
  final CNControlSize controlSize;

  /// Whether the control is interactive and tappable.
  final bool enabled;

  /// Control height.
  final double? height;

  /// Callback when pressed.
  final VoidCallback? onPressed;

  /// Semantic role for the button action.
  final CNButtonRole role;

  /// If true, sizes the control to its intrinsic width.
  final bool shrinkWrap;

  /// Visual style to apply.
  final CNButtonStyle style;

  /// Accent/tint color.
  final Color? tint;

  /// Fixed width used in icon mode.
  final double? width;

  @override
  State<CNButton> createState() => _CNButtonState();

  @override
  String get menuChildType => 'button';

  @override
  List<Object?> get props => [children, badge, controlSize, enabled, height, onPressed, role, shrinkWrap, style, tint, width];

  @override
  bool get stringify => true;

  @override
  Map<String, dynamic> toChannelMap(BuildContext context, {bool ignoreTheme = false}) => _toPayloadForMenu(context);

  Map<String, dynamic> _toPayloadForMenu(BuildContext context) {
    return {
      'buttonChildren': children
          .map((child) => {'type': child.buttonChildType, 'payload': child.toChannelMap(context, ignoreTheme: true)})
          .toList(),
      if (badge != null) 'badge': serializeMenuBadge(badge),
      'buttonRole': role.name,
      'buttonStyle': style.name,
      'enabled': enabled && onPressed != null,
      'isDark': CNTheme.of(context).brightness == Brightness.dark,
      'controlSize': controlSize.name,
      'tint': resolveColorToArgb(tint, context),
      'width': width,
      'height': height,
    };
  }
}

class _CNButtonState extends State<CNButton> {
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
  void didUpdateWidget(covariant CNButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    final controlSizeChanged = oldWidget.controlSize != widget.controlSize;
    final childrenChanged = !listEquals(oldWidget.children, widget.children);

    if (controlSizeChanged || childrenChanged) {
      _layoutWidth = null;
      _layoutHeight = null;
      _intrinsicWidth = null;
      _intrinsicHeight = null;
      _lastSerializedPayload = null;
    }

    _syncPropsToNativeIfNeeded();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  bool get _isDark => CNTheme.of(context).brightness == Brightness.dark;

  Color? get _effectiveTint => widget.tint;

  String get _role => widget.role.name;

  List<Map<String, dynamic>> _serializeChildren() {
    return widget.children
        .map((child) => {'type': child.buttonChildType, 'payload': child.toChannelMap(context, ignoreTheme: true)})
        .toList();
  }

  Map<String, dynamic> _toPayload({double? frameWidth, double? frameHeight}) {
    return {
      'buttonChildren': _serializeChildren(),
      'buttonRole': _role,
      'buttonStyle': widget.style.name,
      'enabled': widget.enabled && widget.onPressed != null,
      'isDark': _isDark,
      'controlSize': widget.controlSize.name,
      'tint': resolveColorToArgb(_effectiveTint, context),
      'width': frameWidth,
      'height': frameHeight,
    };
  }

  String _serializeCurrentPayload() => jsonEncode(_toPayload(frameWidth: _layoutWidth, frameHeight: _layoutHeight));

  void _cacheCurrentProps() {
    _lastSerializedPayload = _serializeCurrentPayload();
  }

  void _onCreated(int id) {
    final ch = MethodChannel('CupertinoNativeButton_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _requestIntrinsicSize();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'pressed':
        if (widget.enabled && widget.onPressed != null) {
          widget.onPressed!();
        }
        break;
      case 'intrinsicSizeChanged':
        final args = CNChannelSerialization.asMap(call.arguments);
        final w = (args?['width'] as num?)?.toDouble();
        final h = (args?['height'] as num?)?.toDouble();
        if (w != null && h != null && mounted) {
          if (w == _intrinsicWidth && h == _intrinsicHeight) {
            break;
          }
          setState(() {
            _intrinsicWidth = w > 0 ? w : null;
            _intrinsicHeight = h > 0 ? h : null;
          });
        }
        break;
    }
    return null;
  }

  Future<void> _requestIntrinsicSize() async {
    final ch = _channel;
    if (ch == null) return;
    try {
      final size = await ch.invokeMethod<Map>('getIntrinsicSize');
      final w = (size?['width'] as num?)?.toDouble();
      final h = (size?['height'] as num?)?.toDouble();

      if (w != null && h != null && mounted) {
        setState(() {
          _intrinsicWidth = w;
          _intrinsicHeight = h;
        });
      }
    } catch (_) {}
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;

    final payload = _toPayload(frameWidth: _layoutWidth, frameHeight: _layoutHeight);
    final serializedPayload = jsonEncode(payload);

    if (_lastSerializedPayload != serializedPayload) {
      await ch.invokeMethod('setButton', payload);
      _cacheCurrentProps();
      _requestIntrinsicSize();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!(defaultTargetPlatform == TargetPlatform.macOS)) {
      // Fallback Flutter implementation
      return SizedBox.shrink();
    }

    const viewType = 'CupertinoNativeButton';

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasFixedWidth = constraints.hasTightWidth;
        final hasFixedHeight = constraints.hasTightHeight;
        final useIntrinsicWidth = widget.shrinkWrap || !hasFixedWidth;
        final useIntrinsicHeight = widget.shrinkWrap || !hasFixedHeight;
        final resolvedWidth = widget.width ?? (useIntrinsicWidth ? (_intrinsicWidth ?? _kDefaultWidth) : constraints.maxWidth);

        final resolvedHeight =
            widget.height ?? (useIntrinsicHeight ? (_intrinsicHeight ?? _kDefaultHeight) : constraints.maxHeight);

        if (_layoutWidth != resolvedWidth || _layoutHeight != resolvedHeight) {
          _layoutWidth = useIntrinsicWidth ? _layoutWidth : resolvedWidth;
          _layoutHeight = useIntrinsicHeight ? _layoutHeight : resolvedHeight;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _syncPropsToNativeIfNeeded();
          });
        }

        final creationParams = _toPayload(
          frameWidth: useIntrinsicWidth ? null : resolvedWidth,
          frameHeight: useIntrinsicHeight ? null : resolvedHeight,
        );

        return SizedBox(
          width: resolvedWidth,
          height: resolvedHeight,
          child: AppKitView(
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
          ),
        );
      },
    );
  }
}
