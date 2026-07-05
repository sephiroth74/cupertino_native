import 'dart:convert';

import 'package:cupertino_native/channel/channel_serialization.dart';
import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/components/button.dart';
import 'package:cupertino_native/components/button_child.dart';
import 'package:cupertino_native/components/menu_child.dart';
import 'package:cupertino_native/components/text.dart';
import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/model/control_size.dart';
import 'package:cupertino_native/style/menu_style.dart';
import 'package:cupertino_native/theme/cn_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const double _kDefaultHeight = 44.0;
const double _kDefaultWidth = 120.0;

/// Backward-compatible alias for [CNDivider].
@Deprecated('Use CNDivider instead.')
typedef CNMenuDivider = CNDivider;

/// A visual divider entry used inside [CNMenu.children].
class CNDivider with CNMenuChild {
  /// Creates a divider menu entry.
  const CNDivider();

  final CNViewModifiers _modifiers = const CNViewModifiers();

  @override
  CNViewModifiers get modifiers => _modifiers;

  @override
  bool get enabled => _modifiers.enabled ?? true;

  @override
  EdgeInsets? get padding => _modifiers.padding;

  @override
  Object? get tag => _modifiers.tag;

  @override
  String get menuChildType => 'divider';

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => false;

  @override
  Map<String, dynamic> toChannelMap(BuildContext context, {bool ignoreTheme = false}) {
    return {};
  }

  @override
  void writeModifiers(Map<String, dynamic> payload, BuildContext context) {}

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CNDivider()';
  }
  
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A native SwiftUI Menu wrapper.
///
/// Supported menu children are [CNButton], [CNText], [CNImage],
/// [CNLabel], and [CNDivider] (all objects implementing [CNMenuChild]).
class CNMenu extends StatefulWidget {
  /// Creates a native menu view.
  const CNMenu({
    super.key,
    this.children = const [],
    this.labels = const [],
    this.onPrimaryAction,
    this.enabled = true,
    this.tint,
    this.foregroundColor,
    this.width,
    this.height,
    this.shrinkWrap = false,
    this.style = CNMenuStyle.automatic,
    this.controlSize = CNControlSize.regular,
  });

  /// Menu content children.
  final List<CNMenuChild> children;

  /// Control size.
  final CNControlSize controlSize;

  /// Whether the control is interactive.
  final bool enabled;

  /// Foreground color.
  final Color? foregroundColor;

  /// Optional fixed height.
  final double? height;

  /// Label content children for the tappable menu trigger.
  final List<CNButtonChild> labels;

  /// Callback fired when the menu trigger primary action is invoked.
  final VoidCallback? onPrimaryAction;

  /// If true, sizes to intrinsic width/height.
  final bool shrinkWrap;

  /// SwiftUI menu style.
  final CNMenuStyle style;

  /// Tint color.
  final Color? tint;

  /// Optional fixed width.
  final double? width;

  @override
  State<CNMenu> createState() => _CNMenuState();
}

class _CNMenuState extends State<CNMenu> {
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
  void didUpdateWidget(covariant CNMenu oldWidget) {
    super.didUpdateWidget(oldWidget);

    final shouldResetPayload =
        oldWidget.enabled != widget.enabled ||
        oldWidget.style != widget.style ||
        oldWidget.tint != widget.tint ||
        oldWidget.foregroundColor != widget.foregroundColor ||
        oldWidget.width != widget.width ||
        oldWidget.height != widget.height ||
        oldWidget.shrinkWrap != widget.shrinkWrap ||
        !listEquals(oldWidget.children, widget.children) ||
        !listEquals(oldWidget.labels, widget.labels);

    if (shouldResetPayload) {
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

  void _cacheCurrentProps() {
    _lastSerializedPayload = _serializeCurrentPayload();
  }

  void _onCreated(int id) {
    final ch = MethodChannel('CupertinoNativeMenu_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _requestIntrinsicSize();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'primaryActionPressed':
        if (widget.enabled) {
          widget.onPrimaryAction?.call();
        }
        break;
      case 'menuButtonPressed':
        final args = CNChannelSerialization.asMap(call.arguments);
        final childIndex = (args?['childIndex'] as num?)?.toInt();
        if (childIndex != null && childIndex >= 0 && childIndex < widget.children.length) {
          final CNMenuChild child = widget.children[childIndex];
          if (child is CNButton && child.enabled && child.onPressed != null) {
            child.onPressed!.call();
          }
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

  List<Map<String, dynamic>> _serializeChildren(List<CNMenuChild> children, BuildContext context) {
    final serialized = <Map<String, dynamic>>[];

    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final payload = Map<String, dynamic>.from(child.toChannelMap(context, ignoreTheme: true));
      if (child.menuChildType == 'button') {
        payload['menuChildIndex'] = i;
      }

      serialized.add({'type': child.menuChildType, 'payload': payload});
    }

    return serialized;
  }

  String _serializeCurrentPayload() => jsonEncode(_toPayload(frameWidth: _layoutWidth, frameHeight: _layoutHeight));

  List<Map<String, dynamic>> _serializeLabelChildren(List<CNButtonChild> labelChildren, BuildContext context) {
    return labelChildren
        .map((child) => {'type': child.buttonChildType, 'payload': child.toChannelMap(context, ignoreTheme: true)})
        .toList();
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;

    final payload = _toPayload(frameWidth: _layoutWidth, frameHeight: _layoutHeight);
    final serializedPayload = jsonEncode(payload);

    if (_lastSerializedPayload != serializedPayload) {
      await ch.invokeMethod('setMenu', payload);
      _cacheCurrentProps();
      _requestIntrinsicSize();
    }
  }

  Map<String, dynamic> _toPayload({double? frameWidth, double? frameHeight}) {
    final payload = {
      'children': _serializeChildren(widget.children, context),
      'labelChildren': _serializeLabelChildren(widget.labels, context),
      'menuStyle': widget.style.name,
      'enabled': widget.enabled,
      'isDark': _isDark,
      'controlSize': widget.controlSize.name,
      'tint': resolveColorToArgb(widget.tint, context),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasFixedWidth = constraints.hasTightWidth;
        final hasFixedHeight = constraints.hasTightHeight;
        final hasExplicitWidth = widget.width != null;
        final hasExplicitHeight = widget.height != null;
        final shouldSendWidth = hasExplicitWidth || hasFixedWidth;
        final shouldSendHeight = hasExplicitHeight || hasFixedHeight;

        final resolvedWidth = widget.width ?? (hasFixedWidth ? constraints.maxWidth : (_intrinsicWidth ?? _kDefaultWidth));
        final resolvedHeight = widget.height ?? (hasFixedHeight ? constraints.maxHeight : (_intrinsicHeight ?? _kDefaultHeight));

        final nextLayoutWidth = shouldSendWidth ? resolvedWidth : null;
        final nextLayoutHeight = shouldSendHeight ? resolvedHeight : null;

        if (_layoutWidth != nextLayoutWidth || _layoutHeight != nextLayoutHeight) {
          _layoutWidth = nextLayoutWidth;
          _layoutHeight = nextLayoutHeight;
          _syncPropsToNativeIfNeeded();
        }

        final creationParams = _toPayload(frameWidth: nextLayoutWidth, frameHeight: nextLayoutHeight);

        return SizedBox(
          width: resolvedWidth,
          height: resolvedHeight,
          child: AppKitView(
            viewType: 'CupertinoNativeMenu',
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
          ),
        );
      },
    );
  }
}
