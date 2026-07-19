// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativeDatePicker2';

/// Style for the SwiftUI DatePicker.
enum CNDatePicker2Style {
  /// System-determined style.
  automatic,

  /// Compact inline style.
  compact,

  /// Full graphical calendar/clock.
  graphical,

  /// Text field style.
  field,
}

/// Displayed components for the SwiftUI DatePicker.
enum CNDatePicker2Component {
  /// Date component (year, month, day).
  date,

  /// Hour and minute component.
  hourAndMinute,
}

class CNDatePicker2 extends CNWidget {
  const CNDatePicker2({
    super.key,
    super.debugLog,
    required this.selection,
    this.onChanged,
    this.displayedComponents = const [CNDatePicker2Component.date],
    this.datePickerStyle = CNDatePicker2Style.automatic,
    this.controlSize = CNControlSize.regular,
    this.label,
    this.minDate,
    this.maxDate,
    this.shrink = true,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
  });

  /// Control size.
  final CNControlSize controlSize;

  /// Style of the date picker.
  final CNDatePicker2Style datePickerStyle;

  /// Which components to display.
  final List<CNDatePicker2Component> displayedComponents;

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
  final EdgeInsetsGeometry? paddings;

  @override
  final bool shrink;

  @override
  final Object? tint;

  @override
  State<CNDatePicker2> createState() => _CNDatePicker2State();

  @override
  String get nativeViewType => _kNativeViewType;
}

class _CNDatePicker2State extends CNWidgetState<CNDatePicker2> {
  @override
  Size computeDefaultSize() {
    final showFull =
        (widget.displayedComponents.contains(CNDatePicker2Component.date) &&
            widget.displayedComponents.contains(CNDatePicker2Component.hourAndMinute)) ||
        widget.displayedComponents.isEmpty;

    final showDateOnly = !showFull && widget.displayedComponents.contains(CNDatePicker2Component.date);

    switch (widget.datePickerStyle) {
      case CNDatePicker2Style.field:
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

      case CNDatePicker2Style.graphical:
        if (showFull) {
          return const Size(284, 148);
        } else if (showDateOnly) {
          return const Size(147, 148);
        } else {
          return const Size(127, 119);
        }

      case CNDatePicker2Style.compact:
      case CNDatePicker2Style.automatic:
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
