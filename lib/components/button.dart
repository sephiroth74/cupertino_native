import 'dart:convert';

import 'package:cupertino_native/channel/channel_serialization.dart';
import 'package:cupertino_native/components/button_child.dart';
import 'package:cupertino_native/components/menu_badge_support.dart';
import 'package:cupertino_native/components/menu_child.dart';
import 'package:cupertino_native/components/view_modifiable.dart';
import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/theme/cn_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../style/button_style.dart';

const double _kDefaultHeight = 64.0;
const double _kDefaultWidth = 80.0;

/// A Cupertino-native push button.
///
/// Embeds a native SwiftUI Button for authentic visuals and behavior on
/// macOS. Falls back to [CupertinoButton] on other platforms.
class CNButton extends StatefulWidget with CNViewModifiable, CNMenuChild {
  /// Creates a native SwiftUI button.
  ///
  /// Supported child types are [CNImage], [CNLabel], and [CNText].
  const CNButton({
    super.key,
    this.children = const [],
    this.badge,
    this.role = CNButtonRole.none,
    this.onPressed,
    this.shrinkWrap = false,
    this.style = CNButtonStyle.automatic,
    this.modifiers,
  }) : assert(badge == null || badge is String || badge is int, 'Badge must be a String or int.');

  /// Optional badge shown next to the menu item when used inside [CNMenu].
  final Object? badge;

  /// Content views shown inside the native SwiftUI button label closure.
  final List<CNButtonChild> children;

  /// Callback when pressed.
  final VoidCallback? onPressed;

  /// Semantic role for the button action.
  final CNButtonRole role;

  /// Visual style to apply.
  final CNButtonStyle style;

  @override
  final CNViewModifiers? modifiers;

  /// If true, sizes the control to its intrinsic width.
  @override
  final bool shrinkWrap;

  @override
  State<CNButton> createState() => _CNButtonState();

  @override
  String get menuChildType => 'button';

  @override
  List<Object?> get props => [children, badge, onPressed, role, shrinkWrap, style, modifiers];

  @override
  bool get stringify => true;

  @override
  Map<String, dynamic> toChannelMap(BuildContext context, {bool ignoreTheme = false}) => _toPayloadForMenu(context);

  Map<String, dynamic> _toPayloadForMenu(BuildContext context) {
    final payload = <String, dynamic>{
      'buttonChildren': children
          .map((child) => {'type': child.buttonChildType, 'payload': child.toChannelMap(context, ignoreTheme: true)})
          .toList(),
      if (badge != null) 'badge': serializeMenuBadge(badge),
      'buttonRole': role.name,
      'buttonStyle': style.name,
      'isDark': CNTheme.of(context).brightness == Brightness.dark,
    };

    writeModifiers(payload, context);
    return payload;
  }
}

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

class _CNButtonState extends State<CNButton> {
  MethodChannel? _channel;
  double? _intrinsicHeight;
  double? _intrinsicWidth;
  Map<String, dynamic>? _lastPayload;
  String? _lastSerializedPayload;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CNButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    final childrenStructureChanged = _isChildrenStructureChanged(oldWidget.children, widget.children);

    if (childrenStructureChanged) {
      _intrinsicWidth = null;
      _intrinsicHeight = null;
      _lastPayload = null;
      _lastSerializedPayload = null;
    }

    _syncPropsToNativeIfNeeded();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  // double? _layoutHeight;
  // double? _layoutWidth;

  bool get _isDark => CNTheme.of(context).brightness == Brightness.dark;

  String get _role => widget.role.name;

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

  bool _isChildrenStructureChanged(List<CNButtonChild> previous, List<CNButtonChild> next) {
    if (previous.length != next.length) {
      return true;
    }

    for (var i = 0; i < previous.length; i++) {
      if (previous[i].buttonChildType != next[i].buttonChildType) {
        return true;
      }
    }

    return false;
  }

  void _onCreated(int id) {
    final ch = MethodChannel('CupertinoNativeButton_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    debugPrint('[CNButton][Dart] _onMethodCall -> ${call.method}(${call.arguments})');

    switch (call.method) {
      case 'pressed':
        debugPrint('[CNButton][Dart] pressed event');
        if (widget.modifiers?.enabled == true && widget.onPressed != null) {
          widget.onPressed!();
        }
        break;
      case 'intrinsicSizeChanged':
        final args = CNChannelSerialization.asMap(call.arguments);
        final w = (args?['width'] as num?)?.toDouble();
        final h = (args?['height'] as num?)?.toDouble();
        debugPrint('[CNButton][Dart] intrinsicSizeChanged -> width=$w, height=$h');
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

  List<Map<String, dynamic>> _serializeChildren() {
    return widget.children
        .map((child) => {'type': child.buttonChildType, 'payload': child.toChannelMap(context, ignoreTheme: true)})
        .toList();
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    debugPrint('[CNButton][Dart] syncPropsToNativeIfNeeded');
    final ch = _channel;
    if (ch == null) return;

    final payload = _toPayload();
    final serializedPayload = jsonEncode(payload);

    if (_lastPayload == null) {
      if (_lastSerializedPayload != serializedPayload) {
        debugPrint('[CNButton][Dart] setData -> $payload');
        await ch.invokeMethod('setData', payload);
      }

      _lastSerializedPayload = serializedPayload;
      _lastPayload = Map<String, dynamic>.from(payload);
      return;
    }

    final patch = _computePayloadPatch(_lastPayload!, payload);
    if (patch.isEmpty) {
      _lastSerializedPayload = serializedPayload;
      return;
    }

    debugPrint('[CNButton][Dart] applyPatch -> $patch');
    await ch.invokeMethod('applyPatch', patch);
    _lastSerializedPayload = serializedPayload;
    _lastPayload = Map<String, dynamic>.from(payload);
  }

  Map<String, dynamic> _toPayload() {
    final payload = <String, dynamic>{
      'buttonChildren': _serializeChildren(),
      'buttonRole': _role,
      'buttonStyle': widget.style.name,
      'isDark': _isDark,
    };

    widget.writeModifiers(payload, context);
    return payload;
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

        // When to use intrinsic size:
        // 1. If shrinkWrap is true, use intrinsic size.
        // 2. If the parent constraints are unbounded, use intrinsic size.

        // How to resolve the final width and height:
        // 1. If the user has specified a width/height via modifiers, use that.
        // 2. constraints are tight, use the constraint value.
        // 3. Otherwise, use the intrinsic size (if available), or fallback to default

        final useIntrinsicWidth = widget.shrinkWrap || !hasFixedWidth;
        final useIntrinsicHeight = widget.shrinkWrap || !hasFixedHeight;

        final resolvedWidth =
            widget.modifiers?.width ?? (hasFixedWidth ? constraints.maxWidth : (_intrinsicWidth ?? _kDefaultWidth));
        final resolvedHeight =
            widget.modifiers?.height ?? (hasFixedHeight ? constraints.maxHeight : (_intrinsicHeight ?? _kDefaultHeight));

        debugPrint(
          '[CNButton][Dart] build -> constrains: $constraints, hasFixedWidth=$hasFixedWidth, hasFixedHeight=$hasFixedHeight',
        );
        debugPrint(
          '[CNButton][Dart] build -> resolvedWidth=$resolvedWidth, resolvedHeight=$resolvedHeight, useIntrinsicWidth=$useIntrinsicWidth, useIntrinsicHeight=$useIntrinsicHeight',
        );

        final creationParams = _toPayload(
          // frameWidth: useIntrinsicWidth ? null : resolvedWidth,
          // frameHeight: useIntrinsicHeight ? null : resolvedHeight,
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
