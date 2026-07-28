// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativeDatePicker2';

class CNDatePicker extends CNWidget {
  const CNDatePicker({
    super.key,
    super.debugLog,
    required this.selection,
    this.onChanged,
    this.displayedComponents = const [CNDatePickerComponent.date],
    this.datePickerStyle = CNDatePickerStyle.automatic,
    this.controlSize = CNControlSize.regular,
    this.label,
    this.minDate,
    this.maxDate,
    this.shrink = true,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
    this.help,
  });

  /// Control size.
  final CNControlSize controlSize;

  /// Style of the date picker.
  final CNDatePickerStyle datePickerStyle;

  /// Which components to display.
  final List<CNDatePickerComponent> displayedComponents;

  /// Optional label displayed next to the picker.
  final String? label;

  /// Maximum selectable date.
  final DateTime? maxDate;

  /// Minimum selectable date.
  final DateTime? minDate;

  /// Called when the date changes. Null disables the picker.
  final ValueChanged<DateTime>? onChanged;

  /// The currently selected date.
  final DateTime selection;

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
  State<CNDatePicker> createState() => _CNDatePicker2State();

  @override
  String get nativeViewType => _kNativeViewType;
}

/// Displayed components for the SwiftUI DatePicker.
enum CNDatePickerComponent {
  /// Date component (year, month, day).
  date,

  /// Hour and minute component.
  hourAndMinute,
}

/// Style for the SwiftUI DatePicker.
enum CNDatePickerStyle {
  /// System-determined style.
  automatic,

  /// Compact inline style.
  compact,

  /// Full graphical calendar/clock.
  graphical,

  /// Text field style.
  field,
}

class _CNDatePicker2State extends CNWidgetState<CNDatePicker> {
  @override
  Size computeDefaultSize() {
    final showFull =
        (widget.displayedComponents.contains(CNDatePickerComponent.date) &&
            widget.displayedComponents.contains(CNDatePickerComponent.hourAndMinute)) ||
        widget.displayedComponents.isEmpty;

    final showDateOnly = !showFull && widget.displayedComponents.contains(CNDatePickerComponent.date);

    switch (widget.datePickerStyle) {
      case CNDatePickerStyle.field:
        switch (widget.controlSize) {
          case CNControlSize.extraLarge:
            if (showFull) {
              return const Size(130, 21);
            } else if (showDateOnly) {
              return const Size(86, 21);
            } else {
              return const Size(50, 21);
            }
          case CNControlSize.large:
            if (showFull) {
              return const Size(130, 21);
            } else if (showDateOnly) {
              return const Size(86, 21);
            } else {
              return const Size(50, 21);
            }
          case CNControlSize.regular:
            if (showFull) {
              return const Size(130, 21);
            } else if (showDateOnly) {
              return const Size(86, 21);
            } else {
              return const Size(50, 21);
            }
          case CNControlSize.small:
            if (showFull) {
              return const Size(114, 19);
            } else if (showDateOnly) {
              return const Size(76, 19);
            } else {
              return const Size(45, 19);
            }
          case CNControlSize.mini:
            if (showFull) {
              return const Size(98, 16);
            } else if (showDateOnly) {
              return const Size(66, 16);
            } else {
              return const Size(40, 16);
            }
        }

      case CNDatePickerStyle.graphical:
        if (showFull) {
          return const Size(284, 148);
        } else if (showDateOnly) {
          return const Size(147, 148);
        } else {
          return const Size(127, 119);
        }

      case CNDatePickerStyle.compact:
      case CNDatePickerStyle.automatic:
        switch (widget.controlSize) {
          case CNControlSize.extraLarge:
            if (showFull) {
              return const Size(157, 34);
            } else if (showDateOnly) {
              return const Size(113, 34);
            } else {
              return const Size(77, 34);
            }
          case CNControlSize.large:
            if (showFull) {
              return const Size(150, 26);
            } else if (showDateOnly) {
              return const Size(106, 26);
            } else {
              return const Size(70, 26);
            }
          case CNControlSize.regular:
            if (showFull) {
              return const Size(147, 22);
            } else if (showDateOnly) {
              return const Size(103, 22);
            } else {
              return const Size(67, 22);
            }
          case CNControlSize.small:
            if (showFull) {
              return const Size(129, 20);
            } else if (showDateOnly) {
              return const Size(91, 20);
            } else {
              return const Size(60, 20);
            }
          case CNControlSize.mini:
            if (showFull) {
              return const Size(109, 20);
            } else if (showDateOnly) {
              return const Size(77, 20);
            } else {
              return const Size(51, 20);
            }
        }
    }
  }

  @override
  Set<Factory<OneSequenceGestureRecognizer>> get gestureRecognizers => {
    Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
  };

  @override
  Future<void> onNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'dateChanged':
        final args = call.arguments as Map?;
        final timestamp = (args?['timestamp'] as num?)?.toInt();
        if (timestamp != null) {
          widget.onChanged?.call(DateTime.fromMillisecondsSinceEpoch(timestamp));
        }
    }
  }

  @override
  Map<String, dynamic> toWidgetPayload(BuildContext context, {required BoxConstraints? constraints}) {
    final payload = <String, dynamic>{
      'selection': widget.selection.millisecondsSinceEpoch,
      'displayedComponents': widget.displayedComponents.map((c) => c.name).toList(),
      'datePickerStyle': widget.datePickerStyle.name,
      'controlSize': widget.controlSize.name,
      'label': widget.label,
      'minDate': widget.minDate?.millisecondsSinceEpoch,
      'maxDate': widget.maxDate?.millisecondsSinceEpoch,
      'enabled': widget.onChanged != null,
    };

    widget.writeSharedFields(context, payload: payload, constraints: constraints);
    return payload;
  }
}
