import 'package:cupertino_native/components/menu.dart';
import 'package:cupertino_native/components/menu_child.dart';
import 'package:cupertino_native/components/view_modifiers.dart';
import 'package:flutter/widgets.dart';

/// A visual divider entry used inside [CNMenu.children].
class CNDivider with CNMenuChild {
  /// Creates a divider menu entry.
  const CNDivider();

  final CNViewModifiers _modifiers = const CNViewModifiers();

  @override
  bool get enabled => _modifiers.enabled ?? true;

  @override
  String get menuChildType => 'divider';

  @override
  CNViewModifiers get modifiers => _modifiers;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  EdgeInsets? get padding => _modifiers.padding;

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => false;

  @override
  Object? get tag => _modifiers.tag;

  @override
  Map<String, dynamic> toChannelMap(BuildContext context, {bool ignoreTheme = false}) {
    return {};
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CNDivider()';
  }

  @override
  void writeModifiers(Map<String, dynamic> payload, BuildContext context) {}
}
