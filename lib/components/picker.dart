import 'dart:convert';

import 'package:cupertino_native/channel/channel_serialization.dart';
import 'package:cupertino_native/channel/layout_constraints_payload.dart';
import 'package:cupertino_native/channel/payload_patch.dart';
import 'package:cupertino_native/components/button_child.dart';
import 'package:cupertino_native/components/image.dart';
import 'package:cupertino_native/components/label.dart';
import 'package:cupertino_native/components/text.dart';
import 'package:cupertino_native/components/view_modifiable.dart';
import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:cupertino_native/components/cn_widget_debug_id_mixin.dart';
import 'package:cupertino_native/model/picker_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../theme/cn_theme.dart';

const double _kDefaultPickerHeight = 38.0;
const double _kDefaultPickerWidth = 300.0;

/// A Cupertino-native picker with segmented control style.
class CNPicker extends StatefulWidget with CNViewModifiable {
  /// Creates a Cupertino-native picker.
  CNPicker({
    super.key,
    required this.selectedIndex,
    this.onValueChanged,
    this.labelChildren = const [],
    this.pickerStyle = CNPickerStyle.segmented,
    this.asList = false,
    required this.items,
    this.modifiers = const CNViewModifiers(),
  }) : assert(items.isNotEmpty, 'Items list cannot be empty.'),
       assert(
         items.every((item) => item is CNText || item is CNLabel || item is CNImage),
         'CNPicker items must be CNText, CNLabel, or CNImage.',
       );

  /// Whether the picker should be displayed as a list (true) or segmented control (false).
  final bool asList;

  /// Picker items to display, in order.
  ///
  /// Only Swift-backed content widgets are supported: [CNText], [CNLabel], [CNImage].
  final List<CNButtonChild> items;

  /// Optional rich picker label content.
  ///
  /// When provided, this takes precedence over [label]/[sublabel].
  final List<CNButtonChild> labelChildren;

  /// Called when the user selects an option.
  final ValueChanged<int>? onValueChanged;

  /// Picker style for the picker.
  final CNPickerStyle pickerStyle;

  /// The index of the selected option.
  final int selectedIndex;

  @override
  final CNViewModifiers modifiers;

  @override
  State<CNPicker> createState() => _CNPickerState();
}

class _CNPickerState extends State<CNPicker> with CNWidgetDebugIdMixin<CNPicker> {
  MethodChannel? _channel;
  double? _intrinsicHeight;
  double? _intrinsicWidth;
  Map<String, dynamic>? _lastPayload;
  String? _lastSerializedPayload;
  final CNLayoutConstraintsSyncState _layoutConstraintsSyncState = CNLayoutConstraintsSyncState();

  @override
  void didChangeDependencies() {
    // debugPrint('$debugLogPrefix didChangeDependencies');
    super.didChangeDependencies();
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CNPicker oldWidget) {
    // debugPrint('$debugLogPrefix didUpdateWidget');
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  bool get _isDark => CNTheme.brightnessOf(context) == Brightness.dark;

  void _cacheCurrentProps() {
    final payload = _toPayload();
    _lastSerializedPayload = jsonEncode(payload);
    _lastPayload = Map<String, dynamic>.from(payload);
  }

  void _onIntrinsicSizeChanged(double? width, double? height) {
    // debugPrint('$debugLogPrefix intrinsic size changed: width=$width, height=$height');
    if (!mounted || width == null || height == null) return;

    final hasExplicitTightWidth = widget.modifiers.constraints?.hasTightWidth ?? false;
    if (!hasExplicitTightWidth && width > 0 && width <= 12.0) {
      // debugPrint('$debugLogPrefix ignoring transient intrinsic width=$width before stable layout');
      return;
    }

    final normalizedWidth = width > 0 ? width : null;
    final normalizedHeight = height > 0 ? height : null;

    if (normalizedWidth == _intrinsicWidth && normalizedHeight == _intrinsicHeight) {
      return;
    }

    setState(() {
      _intrinsicWidth = normalizedWidth;
      _intrinsicHeight = normalizedHeight;
    });
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'valueChanged') {
      final args = CNChannelSerialization.asMap(call.arguments);
      final idx = (args?['index'] as num?)?.toInt();
      if (idx != null) {
        widget.onValueChanged?.call(idx);
      }
    } else if (call.method == 'intrinsicSizeChanged') {
      final args = CNChannelSerialization.asMap(call.arguments);
      _onIntrinsicSizeChanged((args?['width'] as num?)?.toDouble(), (args?['height'] as num?)?.toDouble());
    }
    return null;
  }

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('CupertinoNativePicker_$id');
    _channel = channel;
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _queryIntrinsicSize();
  }

  Future<void> _queryIntrinsicSize() async {
    try {
      final result = await _channel?.invokeMethod<Map>('getIntrinsicSize');
      if (result != null) {
        _onIntrinsicSizeChanged((result['width'] as num?)?.toDouble(), (result['height'] as num?)?.toDouble());
      }
    } catch (e) {
      // debugPrint('$debugLogPrefix failed to get intrinsic size: $e');
      // Fallback to default height
      _intrinsicWidth = null;
      _intrinsicHeight = null;
    }
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
        await channel.invokeMethod('setData', payload);
      }

      _lastSerializedPayload = serializedPayload;
      _lastPayload = Map<String, dynamic>.from(payload);
      // _queryIntrinsicSize();
      return;
    }

    final patch = computeJsonSafePatch(_lastPayload!, payload);
    if (patch.isEmpty) {
      _lastSerializedPayload = serializedPayload;
      return;
    }

    final shouldForceSetData =
        patch.keys.contains('pickerStyle') ||
        patch.keys.contains('labelChildren') ||
        _lastPayload!.containsKey('labelChildren') != payload.containsKey('labelChildren');

    if (shouldForceSetData) {
      await channel.invokeMethod('setData', payload);
      _lastSerializedPayload = serializedPayload;
      _lastPayload = Map<String, dynamic>.from(payload);
      return;
    }

    await channel.invokeMethod('applyPatch', patch);
    _lastSerializedPayload = serializedPayload;
    _lastPayload = Map<String, dynamic>.from(payload);
    // _queryIntrinsicSize();
  }

  Map<String, dynamic> _toPayload() {
    final itemsPayload = widget.items.map((item) {
      final childPayload = item.toChannelMap(context, ignoreTheme: true);
      final tag = childPayload['tag'];
      return <String, dynamic>{
        if (tag != null) 'tag': tag,
        'children': [
          {'type': item.buttonChildType, 'payload': childPayload},
        ],
      };
    }).toList();

    final payload = <String, dynamic>{
      'items': itemsPayload,
      'selectedIndex': widget.selectedIndex,
      'isDark': _isDark,
      'pickerStyle': widget.pickerStyle.name,
      'asList': widget.asList,
      if (widget.labelChildren.isNotEmpty) 'labelChildren': _serializeChildren(widget.labelChildren),
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
      return SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveShrinkWrap = widget.modifiers.shrinkWrap;
        final explicitConstraints = widget.modifiers.constraints;
        final hasBoundedParentSize = constraints.hasBoundedWidth || constraints.hasBoundedHeight;
        final hasBoundedModifierSize =
            (explicitConstraints?.hasBoundedWidth ?? false) || (explicitConstraints?.hasBoundedHeight ?? false);

        assert(
          effectiveShrinkWrap || hasBoundedModifierSize || hasBoundedParentSize,
          'CNPicker requires at least one bounded axis when shrinkWrap is false. '
          'Provide bounded constraints in CNViewModifiers.constraints or place CNPicker in a parent with bounded size.',
        );

        final resolvedLayoutConstraints = resolveLayoutConstraintsPayload(
          parentConstraints: constraints,
          explicitConstraints: explicitConstraints,
        );
        final resolvedConstraints = resolvedLayoutConstraints.resolvedConstraints;
        _layoutConstraintsSyncState.apply(resolvedLayoutConstraints, sync: _syncPropsToNativeIfNeeded);

        final hasBoundedWidth = constraints.hasBoundedWidth;
        final hasBoundedHeight = constraints.hasBoundedHeight;
        final intrinsicOrDefaultWidth = _intrinsicWidth ?? _kDefaultPickerWidth;
        final intrinsicOrDefaultHeight = _intrinsicHeight ?? _kDefaultPickerHeight;

        final resolvedWidth = effectiveShrinkWrap
            ? (hasBoundedWidth ? intrinsicOrDefaultWidth.clamp(0.0, constraints.maxWidth).toDouble() : intrinsicOrDefaultWidth)
            : (resolvedConstraints.hasBoundedWidth ? resolvedConstraints.maxWidth : intrinsicOrDefaultWidth);
        final resolvedHeight = effectiveShrinkWrap
            ? (hasBoundedHeight ? intrinsicOrDefaultHeight.clamp(0.0, constraints.maxHeight).toDouble() : intrinsicOrDefaultHeight)
            : (resolvedConstraints.hasBoundedHeight ? resolvedConstraints.maxHeight : intrinsicOrDefaultHeight);

        final nativeView = AppKitView(
          viewType: 'CupertinoNativePicker',
          creationParamsCodec: const StandardMessageCodec(),
          creationParams: _toPayload(),
          onPlatformViewCreated: _onPlatformViewCreated,
        );

        if (!effectiveShrinkWrap) {
          return ConstrainedBox(
            constraints: resolvedConstraints,
            child: SizedBox(
              width: resolvedConstraints.hasBoundedWidth ? null : resolvedWidth,
              height: resolvedConstraints.hasBoundedHeight ? null : resolvedHeight,
              child: nativeView,
            ),
          );
        }

        return SizedBox(height: resolvedHeight, width: resolvedWidth, child: nativeView);
      },
    );
  }
}
