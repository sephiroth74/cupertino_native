// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativeGauge2';

/// A native SwiftUI Gauge widget.
///
/// Displays a value within a range, with optional labels and gradient tint.
class CNGauge extends CNWidget {
  const CNGauge({
    super.key,
    super.debugLog,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.label,
    this.currentValueLabel,
    this.minimumValueLabel,
    this.maximumValueLabel,
    this.gaugeStyle = CNGaugeStyle.automatic,
    this.controlSize = CNControlSize.regular,
    this.shrink = true,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
    this.help,
    this.overlay,
    this.background,
  }) : assert(min < max),
       assert(value >= min && value <= max);

  /// Control size.
  final CNControlSize controlSize;

  /// Text displayed for the current value.
  final List<CNChild>? currentValueLabel;

  /// The gauge visual style.
  final CNGaugeStyle gaugeStyle;

  /// The label displayed in the gauge (e.g. an icon or text).
  final List<CNChild>? label;

  /// Maximum value.
  final double max;

  /// Text displayed at the maximum end.
  final List<CNChild>? maximumValueLabel;

  /// Minimum value.
  final double min;

  /// Text displayed at the minimum end.
  final List<CNChild>? minimumValueLabel;

  /// Current value of the gauge.
  final double value;

  @override
  final CNBackground? background;

  @override
  final BoxConstraints? constraints;

  @override
  final Color? foregroundColor;

  @override
  final String? help;

  @override
  final CNOverlay? overlay;

  @override
  final EdgeInsetsGeometry? paddings;

  @override
  final bool shrink;

  @override
  final Object? tint;

  @override
  State<CNGauge> createState() => _CNGaugeState();

  @override
  String get nativeViewType => _kNativeViewType;
}

/// Gauge style matching SwiftUI GaugeStyle.
enum CNGaugeStyle {
  /// Automatic style (system default).
  automatic,

  /// Accessory circular style.
  accessoryCircular,

  /// Accessory circular capacity style.
  accessoryCircularCapacity,

  /// Accessory linear style.
  accessoryLinear,

  /// Accessory linear capacity style.
  accessoryLinearCapacity,

  /// Linear capacity style.
  linearCapacity,
}

class _CNGaugeState extends CNWidgetState<CNGauge> {
  @override
  Size computeDefaultSize() => _defaultSize();

  @override
  Map<String, dynamic> toWidgetPayload(
    BuildContext context, {
    required BoxConstraints? constraints,
  }) {
    final payload = <String, dynamic>{
      'value': widget.value,
      'min': widget.min,
      'max': widget.max,
      'gaugeStyle': widget.gaugeStyle.name,
      'controlSize': widget.controlSize.name,
      'label': widget.label?.map((c) => c.toChildPayload(context)).toList(),
      'currentValueLabel': widget.currentValueLabel
          ?.map((c) => c.toChildPayload(context))
          .toList(),
      'minimumValueLabel': widget.minimumValueLabel
          ?.map((c) => c.toChildPayload(context))
          .toList(),
      'maximumValueLabel': widget.maximumValueLabel
          ?.map((c) => c.toChildPayload(context))
          .toList(),
    };

    widget.writeSharedFields(
      context,
      payload: payload,
      constraints: constraints,
      tintFallback: CNGaugeTheme.of(context).tintColor,
    );
    return payload;
  }

  Size _defaultSize() {
    switch (widget.gaugeStyle) {
      case CNGaugeStyle.accessoryCircular:
      case CNGaugeStyle.accessoryCircularCapacity:
        return const Size(50, 50);
      case CNGaugeStyle.accessoryLinear:
      case CNGaugeStyle.accessoryLinearCapacity:
        return const Size(150, 20);
      case CNGaugeStyle.linearCapacity:
        return const Size(200, 20);
      case CNGaugeStyle.automatic:
        return const Size(150, 20);
    }
  }
}
