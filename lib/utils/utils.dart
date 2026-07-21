import 'package:flutter/material.dart';
import 'package:cupertino_native/cupertino_native.dart';

// ignore: public_member_api_docs
bool debugCheckHasCNTheme(BuildContext context, [bool check = true]) {
  assert(() {
    if (CNTheme.maybeOf(context) == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('A CNTheme widget is necessary to draw this layout.'),
        ErrorHint(
          'To introduce a CNTheme widget, you can either directly '
          'include one, or use a widget that contains CNTheme itself, '
          'such as CNApp',
        ),
        ...context.describeMissingAncestor(expectedAncestorType: CNThemeData),
      ]);
    }
    return true;
  }());
  return true;
}
