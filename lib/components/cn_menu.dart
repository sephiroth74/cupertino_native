// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativeMenu2';

/// A native SwiftUI Menu widget.
///
/// The menu shows [items] (buttons, dividers, sub-menus) and is activated
/// via a trigger [label].
class CNMenu extends CNWidget {
  const CNMenu({
    super.key,
    super.debugLog,
    required this.items,
    required this.label,
    this.primaryActionTag,
    this.onItemPressed,
    this.menuStyle = CNMenuStyle.automatic,
    this.controlSize,
    this.font,
    this.shrink = true,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
    this.help,
  });

  /// Control size.
  final CNControlSize? controlSize;

  /// Font applied to the menu.
  final CNFont? font;

  /// The menu items (buttons, dividers, sub-menus).
  final List<CNChild> items;

  /// Label content displayed as the menu trigger.
  final List<CNChild> label;

  /// Visual style for the menu.
  final CNMenuStyle menuStyle;

  /// Called when any button item (or primaryAction) is pressed.
  final ValueChanged<String>? onItemPressed;

  /// Optional id for the primary action on the top-level menu.
  final String? primaryActionTag;

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
  State<CNMenu> createState() => _CNMenuState();

  @override
  String get nativeViewType => _kNativeViewType;

  bool get enabled => onItemPressed != null;
}

/// Visual style for [CNMenu].
enum CNMenuStyle {
  /// Default menu style.
  automatic,

  /// Button-style menu.
  button,

  /// Bordered button menu style.
  borderedButton,

  /// Borderless button menu style.
  borderlessButton,
}

class _CNMenuState extends CNWidgetState<CNMenu> {
  @override
  Size computeDefaultSize() => const Size(80.0, 32.0);

  // Il menu è interattivo: senza questi recognizer i tap non raggiungono la
  // view AppKit quando il widget è dentro uno scrollable (la drag dello scroll
  // vince l'arena dei gesti).
  @override
  Set<Factory<OneSequenceGestureRecognizer>>? get gestureRecognizers => {
    Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
  };

  @override
  Future<dynamic> onNativeMethodCall(MethodCall call) async {
    if (call.method == 'itemPressed') {
      final id = call.arguments as String?;
      if (id != null) {
        widget.onItemPressed?.call(id);
      }
    }
    return null;
  }

  @override
  Map<String, dynamic> toWidgetPayload(BuildContext context, {required BoxConstraints? constraints}) {
    final payload = <String, dynamic>{
      'items': widget.items.map((c) => c.toChildPayload(context)).toList(),
      'label': widget.label.map((c) => c.toChildPayload(context)).toList(),
      'primaryActionTag': widget.primaryActionTag,
      'menuStyle': widget.menuStyle.name,
      'controlSize': widget.controlSize?.name,
      'font': widget.font?.toMap(),
      'enabled': widget.enabled,
    };

    widget.writeSharedFields(context, payload: payload, constraints: constraints);
    return payload;
  }
}
