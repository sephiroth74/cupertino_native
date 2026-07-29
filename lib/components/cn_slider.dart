// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const double _kDefaultSliderWidth = 100.0;
const _kNativeViewType = 'CupertinoNativeSlider2';

class CNSlider extends CNWidget {
  const CNSlider({
    super.key,
    super.debugLog,
    required this.value,
    this.onChanged,
    this.onEditingChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.step,
    this.ticks,
    this.minimumValueLabel,
    this.maximumValueLabel,
    this.controlSize = CNControlSize.regular,
    this.shrink = true,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
    this.help,
  }) : assert(min < max),
       assert(value >= min && value <= max),
       assert(step == null || step > 0),
       assert(step == null || ticks == null, 'step and ticks cannot be used together');

  /// Control size for the slider.
  final CNControlSize controlSize;

  /// Maximum value.
  final double max;

  /// Label displayed at the maximum end of the slider.
  final String? maximumValueLabel;

  /// Minimum value.
  final double min;

  /// Label displayed at the minimum end of the slider.
  final String? minimumValueLabel;

  /// Called when slider value changes.
  final ValueChanged<double>? onChanged;

  /// Called when editing starts/ends.
  final ValueChanged<bool>? onEditingChanged;

  /// Optional step increment. Mutually exclusive with [ticks].
  final double? step;

  /// Optional tick marks. Mutually exclusive with [step].
  final List<CNSliderTick>? ticks;

  /// Current value.
  final double value;

  @override
  final BoxConstraints? constraints;

  @override
  final Color? foregroundColor;

  @override
  final String? help;

  @override
  final EdgeInsetsGeometry? paddings;

  @override
  final bool shrink;

  @override
  final Object? tint;

  @override
  State<CNSlider> createState() => _CNSliderState();

  @override
  String get nativeViewType => _kNativeViewType;
}

/// A tick mark for [CNSlider].
class CNSliderTick {
  /// Creates a tick at the given [value] with an optional [label].
  const CNSliderTick(this.value, {this.label});

  /// Optional label displayed at this tick.
  final String? label;

  /// The value where this tick should appear.
  final double value;
}

class _CNSliderState extends CNWidgetState<CNSlider> {
  @override
  Size computeDefaultSize() => Size(_kDefaultSliderWidth, _defaultHeight());

  @override
  double computeShrinkWidth({required BoxConstraints constraints, required double defaultWidth, double? intrinsicWidth}) {
    double resolvedWidth;
    if (intrinsicWidth != null) {
      resolvedWidth = intrinsicWidth;
      logDebug('shrink mode: using intrinsicWidth');
    } else if (constraints.hasBoundedWidth) {
      resolvedWidth = constraints.maxWidth;
      logDebug('shrink mode: using parent maxWidth');
    } else {
      resolvedWidth = defaultWidth;
      logDebug('shrink mode: using defaultSize.width');
    }
    resolvedWidth = constraints.constrainWidth(resolvedWidth);
    return resolvedWidth;
  }

  @override
  Future<void> onNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'valueChanged':
        final args = call.arguments as Map?;
        final value = (args?['value'] as num?)?.toDouble();
        if (value != null) {
          widget.onChanged?.call(value);
        }
      case 'editingChanged':
        final args = call.arguments as Map?;
        final editing = (args?['editing'] as bool?) ?? (args?['editing'] as num?)?.toInt() == 1;
        widget.onEditingChanged?.call(editing);
    }
  }

  @override
  Map<String, dynamic> toWidgetPayload(BuildContext context, {required BoxConstraints? constraints}) {
    final payload = <String, dynamic>{
      'value': widget.value,
      'min': widget.min,
      'max': widget.max,
      'step': widget.step,
      'controlSize': widget.controlSize.name,
      'minimumValueLabel': widget.minimumValueLabel,
      'maximumValueLabel': widget.maximumValueLabel,
      'enabled': widget.onChanged != null,
      'ticks': widget.ticks?.map((t) => {'value': t.value, 'label': t.label}).toList(),
    };

    widget.writeSharedFields(
      context,
      payload: payload,
      constraints: constraints,
      tintFallback: CNSliderTheme.of(context).tintColor,
    );
    return payload;
  }

  double _defaultHeight() {
    final verticalPaddings = widget.paddings?.vertical ?? 0;
    final hasTickLabels = widget.ticks?.any((e) => e.label != null) ?? false;
    double defaultHeight;

    switch (widget.controlSize) {
      case CNControlSize.mini:
        defaultHeight = 12.0;
      case CNControlSize.small:
        defaultHeight = 14.0;
      case CNControlSize.regular:
        defaultHeight = 16.0;
      case CNControlSize.large:
        defaultHeight = 20.0;
      case CNControlSize.extraLarge:
        defaultHeight = 20.0;
    }
    return defaultHeight + verticalPaddings + (hasTickLabels ? 15 : 0);
  }
}
