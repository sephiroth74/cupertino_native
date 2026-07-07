import 'dart:convert';

import 'package:cupertino_native/channel/channel_serialization.dart';
import 'package:cupertino_native/channel/layout_constraints_payload.dart';
import 'package:cupertino_native/channel/payload_patch.dart';
import 'package:cupertino_native/components/button.dart';
import 'package:cupertino_native/components/button_child.dart';
import 'package:cupertino_native/components/divider.dart';
import 'package:cupertino_native/components/menu_child.dart';
import 'package:cupertino_native/components/text.dart';
import 'package:cupertino_native/components/view_modifiers.dart';
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
    this.style = CNMenuStyle.automatic,
    this.modifiers,
  });

  /// Menu content children.
  final List<CNMenuChild> children;

  /// Label content children for the tappable menu trigger.
  final List<CNButtonChild> labels;

  /// Shared native view modifiers.
  final CNViewModifiers? modifiers;

  /// Callback fired when the menu trigger primary action is invoked.
  final VoidCallback? onPrimaryAction;

  /// SwiftUI menu style.
  final CNMenuStyle style;

  @override
  State<CNMenu> createState() => _CNMenuState();
}

class _CNMenuState extends State<CNMenu> {
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
  void didUpdateWidget(covariant CNMenu oldWidget) {
    super.didUpdateWidget(oldWidget);

    final shouldResetPayload =
        oldWidget.style != widget.style ||
        oldWidget.modifiers != widget.modifiers ||
        !listEquals(oldWidget.children, widget.children) ||
        !listEquals(oldWidget.labels, widget.labels);

    if (shouldResetPayload) {
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

  bool get _isDark => CNTheme.of(context).brightness == Brightness.dark;

  void _cacheCurrentProps() {
    final payload = _toPayload();
    _lastSerializedPayload = jsonEncode(payload);
    _lastPayload = Map<String, dynamic>.from(payload);
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
        if (widget.modifiers?.enabled != false) {
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

  List<Map<String, dynamic>> _serializeLabelChildren(List<CNButtonChild> labelChildren, BuildContext context) {
    return labelChildren
        .map((child) => {'type': child.buttonChildType, 'payload': child.toChannelMap(context, ignoreTheme: true)})
        .toList();
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;

    final payload = _toPayload();
    final serializedPayload = jsonEncode(payload);

    if (_lastPayload == null) {
      if (_lastSerializedPayload != serializedPayload) {
        await ch.invokeMethod('setData', payload);
      }

      _lastSerializedPayload = serializedPayload;
      _lastPayload = Map<String, dynamic>.from(payload);
      // _requestIntrinsicSize();
      return;
    }

    final patch = computeJsonSafePatch(_lastPayload!, payload);
    if (patch.isEmpty) {
      _lastSerializedPayload = serializedPayload;
      return;
    }

    await ch.invokeMethod('applyPatch', patch);
    _lastSerializedPayload = serializedPayload;
    _lastPayload = Map<String, dynamic>.from(payload);
    // _requestIntrinsicSize();
  }

  Map<String, dynamic> _toPayload() {
    final payload = <String, dynamic>{
      'children': _serializeChildren(widget.children, context),
      'labelChildren': _serializeLabelChildren(widget.labels, context),
      'menuStyle': widget.style.name,
      'isDark': _isDark,
    };

    writeLayoutConstraintsPayload(
      payload,
      layoutConstraintsPayload: _layoutConstraintsSyncState.layoutConstraintsPayload,
      explicitConstraints: widget.modifiers?.constraints,
    );

    widget.modifiers?.writeToPayload(payload, context);

    return payload;
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.macOS) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final explicitConstraints = widget.modifiers?.constraints;
        final effectiveShrinkWrap = widget.modifiers?.shrinkWrap ?? true;
        final hasBoundedParentSize = constraints.hasBoundedWidth || constraints.hasBoundedHeight;
        final hasBoundedExplicitSize =
            (explicitConstraints?.hasBoundedWidth ?? false) || (explicitConstraints?.hasBoundedHeight ?? false);

        assert(
          effectiveShrinkWrap || hasBoundedExplicitSize || hasBoundedParentSize,
          'CNMenu requires at least one bounded axis when shrinkWrap is false. '
          'Provide bounded constraints in CNViewModifiers.constraints or place CNMenu in a parent with bounded size.',
        );

        final resolvedLayoutConstraints = resolveLayoutConstraintsPayload(
          parentConstraints: constraints,
          explicitConstraints: explicitConstraints,
        );
        final resolvedConstraints = resolvedLayoutConstraints.resolvedConstraints;
        _layoutConstraintsSyncState.apply(resolvedLayoutConstraints, sync: _syncPropsToNativeIfNeeded);

        final hasBoundedWidth = constraints.hasBoundedWidth;
        final hasBoundedHeight = constraints.hasBoundedHeight;

        final intrinsicOrDefaultWidth = _intrinsicWidth ?? _kDefaultWidth;
        final intrinsicOrDefaultHeight = _intrinsicHeight ?? _kDefaultHeight;

        final resolvedWidth = effectiveShrinkWrap
            ? (hasBoundedWidth ? intrinsicOrDefaultWidth.clamp(0.0, constraints.maxWidth).toDouble() : intrinsicOrDefaultWidth)
            : (resolvedConstraints.hasBoundedWidth ? resolvedConstraints.maxWidth : intrinsicOrDefaultWidth);
        final resolvedHeight = effectiveShrinkWrap
            ? (hasBoundedHeight ? intrinsicOrDefaultHeight.clamp(0.0, constraints.maxHeight).toDouble() : intrinsicOrDefaultHeight)
            : (resolvedConstraints.hasBoundedHeight ? resolvedConstraints.maxHeight : intrinsicOrDefaultHeight);

        final creationParams = _toPayload();

        Widget nativeView = AppKitView(
          viewType: 'CupertinoNativeMenu',
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onCreated,
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

        return SizedBox(width: resolvedWidth, height: resolvedHeight, child: nativeView);
      },
    );
  }
}
