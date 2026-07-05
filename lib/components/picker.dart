import 'package:cupertino_native/components/button_child.dart';
import 'package:cupertino_native/components/image.dart';
import 'package:cupertino_native/components/label.dart';
import 'package:cupertino_native/components/text.dart';
import 'package:cupertino_native/components/view_modifiable.dart';
import 'package:cupertino_native/components/view_modifiers.dart';
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
    required this.onValueChanged,
    this.labelChildren = const [],
    this.pickerStyle = CNPickerStyle.segmented,
    this.shrinkWrap = false,
    this.asList = false,
    required this.items,
    this.modifiers,
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
  final ValueChanged<int> onValueChanged;

  /// Picker style for the picker.
  final CNPickerStyle pickerStyle;

  /// The index of the selected option.
  final int selectedIndex;

  /// Whether the picker should shrink-wrap its content.
  final bool shrinkWrap;

  @override
  final CNViewModifiers? modifiers;

  @override
  State<CNPicker> createState() => _CNPickerState();

  @override
  EdgeInsets? get padding => modifiers?.padding;

  @override
  Object? get tag => modifiers?.tag;
}

class _CNPickerState extends State<CNPicker> {
  MethodChannel? _channel;
  double? _intrinsicHeight;
  double? _intrinsicWidth;
  String? _lastSerializedPayload;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CNPicker oldWidget) {
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
    _lastSerializedPayload = _serializeCurrentPayload();
  }

  void _onIntrinsicSizeChanged(double? width, double? height) {
    if (!mounted || width == null || height == null) return;
    setState(() {
      _intrinsicWidth = width > -1 ? width : null;
      _intrinsicHeight = height > -1 ? height : null;
    });
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'valueChanged') {
      final args = call.arguments as Map?;
      final idx = (args?['index'] as num?)?.toInt();
      if (idx != null) {
        widget.onValueChanged(idx);
      }
    } else if (call.method == 'intrinsicSizeChanged') {
      final args = call.arguments as Map?;
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

  String _serializeCurrentPayload() => _toPayload().toString();

  Future<void> _syncPropsToNativeIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;

    final payload = _toPayload();
    final serializedPayload = payload.toString();

    if (_lastSerializedPayload != serializedPayload) {
      await channel.invokeMethod('setPicker', payload);
      _cacheCurrentProps();
      _queryIntrinsicSize();
    }
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

    widget.writeModifiers(payload, context);
    return payload;
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.macOS) {
      return SizedBox.shrink();
    }

    const viewType = 'CupertinoNativePicker';
    final creationParams = _toPayload();

    final child = AppKitView(
      viewType: viewType,
      creationParamsCodec: const StandardMessageCodec(),
      creationParams: creationParams,
      onPlatformViewCreated: _onPlatformViewCreated,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool hasBoundedWidth = constraints.hasBoundedWidth;
        final bool hasBoundedHeight = constraints.hasBoundedHeight;

        double? width;
        double? height;

        if (widget.shrinkWrap) {
          if (hasBoundedWidth) {
            final targetWidth = _intrinsicWidth ?? _kDefaultPickerWidth;
            width = targetWidth.clamp(0.0, constraints.maxWidth);
          } else {
            width = _intrinsicWidth ?? _kDefaultPickerWidth;
          }

          if (hasBoundedHeight) {
            final targetHeight = _intrinsicHeight ?? _kDefaultPickerHeight;
            height = targetHeight.clamp(0.0, constraints.maxHeight);
          } else {
            height = _intrinsicHeight ?? _kDefaultPickerHeight;
          }
        } else if (hasBoundedWidth) {
          width = constraints.maxWidth;
          if (_intrinsicHeight != null) {
            height = _intrinsicHeight;
          } else if (hasBoundedHeight) {
            height = constraints.maxHeight;
          } else {
            height = _kDefaultPickerHeight;
          }
        } else {
          width = _intrinsicWidth ?? _kDefaultPickerWidth;
          height = _intrinsicHeight ?? (hasBoundedHeight ? constraints.maxHeight : _kDefaultPickerHeight);
        }

        if (width == double.infinity) {
          width = _intrinsicWidth ?? _kDefaultPickerWidth;
        }
        if (height == double.infinity) {
          height = _intrinsicHeight ?? _kDefaultPickerHeight;
        }

        return SizedBox(height: height, width: width, child: child);
      },
    );
  }
}
