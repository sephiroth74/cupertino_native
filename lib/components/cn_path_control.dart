// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativePathControl2';

/// A native macOS NSPathControl widget.
///
/// Displays a file path as a clickable breadcrumb. Supports editable paths
/// with an open panel for choosing files/directories.
class CNPathControl extends CNWidget {
  const CNPathControl({
    super.key,
    super.debugLog,
    required this.url,
    this.isDirectory = false,
    this.editable = true,
    this.controlSize = CNControlSize.regular,
    this.controlStyle = CNPathControlStyle.standard,
    this.allowedTypes,
    this.onPressed,
    this.shrink = true,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
    this.help,
  });

  /// Allowed file types (extensions) for the open panel.
  final List<String>? allowedTypes;

  /// The size of the control.
  final CNControlSize controlSize;

  /// The style of the control.
  final CNPathControlStyle controlStyle;

  /// Whether the path is editable (shows open panel on click).
  final bool editable;

  /// Whether the URL is a directory.
  final bool isDirectory;

  /// Called when a path component is clicked. Passes the clicked path string.
  final ValueChanged<String>? onPressed;

  /// The file path to display.
  final Uri url;

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
  State<CNPathControl> createState() => _CNPathControlState();

  @override
  String get nativeViewType => _kNativeViewType;
}

/// Style for CNPathControl2.
enum CNPathControlStyle {
  /// Standard breadcrumb path style.
  standard,

  /// Popup menu style.
  popup,
}

class _CNPathControlState extends CNWidgetState<CNPathControl> {
  @override
  Size computeDefaultSize() => const Size(200, 24);

  @override
  Set<Factory<OneSequenceGestureRecognizer>>? get gestureRecognizers => {
    Factory<OneSequenceGestureRecognizer>(() => TapGestureRecognizer()),
  };

  @override
  Future<void> onNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'pressed':
        final path = call.arguments as String?;
        if (path != null) {
          widget.onPressed?.call(path);
        }
    }
  }

  @override
  Map<String, dynamic> toWidgetPayload(BuildContext context, {required BoxConstraints? constraints}) {
    final payload = <String, dynamic>{
      'path': widget.url.toFilePath(),
      'isDirectory': widget.isDirectory,
      'editable': widget.editable,
      'controlSize': widget.controlSize.name,
      'controlStyle': widget.controlStyle.name,
      'allowedTypes': widget.allowedTypes,
      'enabled': widget.onPressed != null,
    };

    widget.writeSharedFields(context, payload: payload, constraints: constraints);
    return payload;
  }
}
