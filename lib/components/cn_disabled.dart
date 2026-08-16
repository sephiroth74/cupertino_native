import 'package:flutter/widgets.dart';

/// Disables an entire subtree — both Flutter widgets and native AppKit views.
///
/// Flutter's [IgnorePointer] only removes widgets from Flutter's own hit-test
/// tree. A CN widget is a real `NSView` embedded in the AppKit hierarchy, so
/// AppKit delivers mouse events to it directly and [IgnorePointer] has no
/// effect on it. [CNDisabled] closes that gap: it wraps the subtree in
/// [IgnorePointer] and [ExcludeFocus] for the Flutter side, and publishes a
/// scope that every native CN widget below it reads in order to send
/// `enabled: false` / `ignorePointer: true` to its own native view.
///
/// ```dart
/// CNDisabled(
///   disabled: !isEditable,
///   child: Column(
///     children: [
///       CNTextField(...),          // native: disabled appearance, no input
///       CupertinoButton(...),      // flutter: pointer events ignored
///     ],
///   ),
/// )
/// ```
///
/// Like SwiftUI's `.disabled(_:)` the effect only accumulates: a descendant
/// `CNDisabled(disabled: false)` cannot re-enable a subtree that an ancestor
/// has already disabled.
class CNDisabled extends StatelessWidget {
  /// Creates a scope that disables [child] and everything below it.
  const CNDisabled({
    super.key,
    this.disabled = true,
    this.opacity,
    required this.child,
  });

  /// The subtree to disable.
  final Widget child;

  /// Whether the subtree is disabled.
  final bool disabled;

  /// Optional opacity applied to the subtree while it is disabled.
  ///
  /// Native views already render their own disabled appearance, and Flutter
  /// opacity does not apply to platform views, so leaving this null keeps the
  /// two sides consistent. Set it only when the Flutter children in the
  /// subtree need to be dimmed to look disabled.
  final double? opacity;

  /// Whether an enclosing [CNDisabled] disables the given [context].
  ///
  /// Registers [context] as a dependency, so the caller rebuilds when the
  /// scope changes.
  static bool of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_CNDisabledScope>();
    return scope?.disabled ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final effective = disabled || of(context);

    Widget result = child;
    if (effective && opacity != null) {
      result = Opacity(opacity: opacity!, child: result);
    }

    return _CNDisabledScope(
      disabled: effective,
      child: ExcludeFocus(
        excluding: effective,
        child: IgnorePointer(ignoring: effective, child: result),
      ),
    );
  }
}

class _CNDisabledScope extends InheritedWidget {
  const _CNDisabledScope({required this.disabled, required super.child});

  final bool disabled;

  @override
  bool updateShouldNotify(_CNDisabledScope oldWidget) =>
      disabled != oldWidget.disabled;
}
