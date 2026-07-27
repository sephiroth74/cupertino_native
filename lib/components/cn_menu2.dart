// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativeMenu2';

/// Visual style for [CNMenu2].
enum CNMenuStyle2 {
  /// Default menu style.
  automatic,

  /// Button-style menu.
  button,

  /// Bordered button menu style.
  borderedButton,

  /// Borderless button menu style.
  borderlessButton,
}

/// A native SwiftUI Menu widget.
///
/// The menu shows [items] (buttons, dividers, sub-menus) and is activated
/// via a trigger [label].
class CNMenu2 extends CNWidget {
  const CNMenu2({
    super.key,
    super.debugLog,
    required this.items,
    required this.label,
    this.primaryActionTag,
    this.onItemPressed,
    this.menuStyle = CNMenuStyle2.automatic,
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
  final CNMenuStyle2 menuStyle;

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
  State<CNMenu2> createState() => _CNMenu2State();

  @override
  String get nativeViewType => _kNativeViewType;

  bool get enabled => onItemPressed != null;
}

class _CNMenu2State extends CNWidgetState<CNMenu2> {
  @override
  Size computeDefaultSize() => const Size(80.0, 32.0);

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
