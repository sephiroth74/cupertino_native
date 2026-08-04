// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativeStepper2';

class CNStepper extends CNWidget {
  const CNStepper({
    super.key,
    super.debugLog,
    required this.value,
    this.onChanged,
    this.onEditingChanged,
    this.min = 0.0,
    this.max = 100.0,
    this.step = 1.0,
    this.controlSize = CNControlSize.regular,
    this.shrink = true,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
    this.help,
    this.overlay,
  }) : assert(min < max),
       assert(value >= min && value <= max),
       assert(step > 0);

  /// Control size for the stepper.
  final CNControlSize controlSize;

  /// Maximum value.
  final double max;

  /// Minimum value.
  final double min;

  /// Called when stepper value changes.
  final ValueChanged<double>? onChanged;

  /// Called when editing starts/ends.
  final ValueChanged<bool>? onEditingChanged;

  /// Step increment.
  final double step;

  /// Current value.
  final double value;

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
  State<CNStepper> createState() => _CNStepperState();

  @override
  String get nativeViewType => _kNativeViewType;
}

class _CNStepperState extends CNWidgetState<CNStepper> {
  @override
  Size computeDefaultSize() => Size(_defaultWidth(), _defaultHeight());

  @override
  double computeShrinkHeight({
    required BoxConstraints constraints,
    required double defaultHeight,
    double? intrinsicHeight,
  }) {
    double resolvedHeight;
    if (intrinsicHeight != null) {
      resolvedHeight = intrinsicHeight;
      logDebug('shrink mode: using intrinsicHeight');
    } else if (constraints.tightHeight != null) {
      resolvedHeight = constraints.tightHeight!;
      logDebug('shrink mode: using tightHeight from constraints');
    } else {
      resolvedHeight = defaultHeight;
      logDebug('shrink mode: using defaultSize.height');
    }
    // resolvedHeight = parentConstraints.constrainHeight(resolvedHeight);
    return resolvedHeight;
  }

  // Lo stepper è interattivo: senza questi recognizer i tap non raggiungono la
  // view AppKit quando il widget è dentro uno scrollable (la drag dello scroll
  // vince l'arena dei gesti).
  @override
  Set<Factory<OneSequenceGestureRecognizer>>? get gestureRecognizers => {
    Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
  };

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
        final editing =
            (args?['editing'] as bool?) ??
            (args?['editing'] as num?)?.toInt() == 1;
        widget.onEditingChanged?.call(editing);
    }
  }

  @override
  Map<String, dynamic> toWidgetPayload(
    BuildContext context, {
    required BoxConstraints? constraints,
  }) {
    final payload = <String, dynamic>{
      'value': widget.value,
      'min': widget.min,
      'max': widget.max,
      'step': widget.step,
      'controlSize': widget.controlSize.name,
      'enabled': widget.onChanged != null,
    };

    widget.writeSharedFields(
      context,
      payload: payload,
      constraints: constraints,
      tintFallback: CNStepperTheme.of(context).tintColor,
    );
    return payload;
  }

  double _defaultHeight() {
    switch (widget.controlSize) {
      case CNControlSize.mini:
        return 20.0;
      case CNControlSize.small:
        return 22.0;
      case CNControlSize.regular:
        return 26.0;
      case CNControlSize.large:
        return 30.0;
      case CNControlSize.extraLarge:
        return 38.0;
    }
  }

  double _defaultWidth() {
    switch (widget.controlSize) {
      case CNControlSize.mini:
        return 13.0;
      case CNControlSize.small:
        return 17.0;
      case CNControlSize.regular:
        return 20.0;
      case CNControlSize.large:
        return 23.0;
      case CNControlSize.extraLarge:
        return 30.0;
    }
  }
}
