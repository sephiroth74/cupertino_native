// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativeSegmentedControl2';

/// A native SwiftUI segmented control.
///
/// Supports two display modes:
/// - Text labels via [labels] (list of strings).
/// - SF Symbol icons via [symbols] (list of SF Symbol names).
///
/// Exactly one of [labels] or [symbols] must be provided.
class CNSegmentedControl2 extends CNWidget {
  const CNSegmentedControl2({
    super.key,
    super.debugLog,
    this.labels,
    this.symbols,
    required this.selectedIndex,
    required this.onValueChanged,
    this.enabled = true,
    this.shrink = true,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
  }) : assert(
         (labels != null && symbols == null) || (labels == null && symbols != null),
         'Exactly one of labels or symbols must be provided.',
       );

  /// Whether the control is interactive.
  final bool enabled;

  /// Text labels for each segment.
  /// Mutually exclusive with [symbols].
  final List<String>? labels;

  /// Called when the selected segment changes.
  final ValueChanged<int> onValueChanged;

  /// The index of the currently selected segment.
  final int selectedIndex;

  /// SF Symbol names for each segment (rendered as icons).
  /// Mutually exclusive with [labels].
  final List<String>? symbols;

  @override
  final BoxConstraints? constraints;

  @override
  final Color? foregroundColor;

  @override
  final EdgeInsetsGeometry? paddings;

  @override
  final bool shrink;

  @override
  final Object? tint;

  @override
  State<CNSegmentedControl2> createState() => _CNSegmentedControl2State();

  @override
  String get nativeViewType => _kNativeViewType;
}

class _CNSegmentedControl2State extends CNWidgetState<CNSegmentedControl2> {
  @override
  (double, double) computeExpandSize({required BoxConstraints constraints}) {
    var (width, height) = super.computeExpandSize(constraints: constraints);
    return (width, height.isFinite ? height : 32);
  }

  @override
  Size computeDefaultSize() => const Size(200, 32);

  @override
  Future<void> onNativeMethodCall(MethodCall call) async {
    if (call.method == 'valueChanged') {
      final args = call.arguments as Map?;
      final idx = (args?['index'] as num?)?.toInt();
      if (idx != null) {
        widget.onValueChanged(idx);
      }
    }
  }

  @override
  Map<String, dynamic> toWidgetPayload(BuildContext context, {required BoxConstraints? constraints}) {
    final payload = <String, dynamic>{
      'labels': widget.labels,
      'symbols': widget.symbols,
      'selectedIndex': widget.selectedIndex,
      'enabled': widget.enabled,
    };

    widget.writeSharedFields(context, payload: payload, constraints: constraints);
    return payload;
  }
}
