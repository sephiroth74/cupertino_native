import 'package:flutter/widgets.dart';

/// Helpers for per-state colors expressed as [WidgetStateProperty] objects.
///
/// A color property may deliberately resolve to `null` for some states — e.g.
/// `WidgetStateProperty<Color?>.fromMap({WidgetState.hovered: fill})` styles
/// only the hovered state. Both helpers below read that `null` as "not
/// specified, ask the layer below", which is what keeps the
/// widget → component theme → semantic default chain working *per state*
/// instead of wholesale.
abstract final class CNStateColor {
  /// A constraint satisfied only by the idle state, i.e. when none of
  /// [WidgetState.hovered], [WidgetState.pressed], [WidgetState.selected] or
  /// [WidgetState.disabled] is active.
  ///
  /// Useful as a [WidgetStateProperty.fromMap] key to style the resting
  /// appearance without flattening the interaction feedback the way
  /// [WidgetStatePropertyAll] does.
  static final WidgetStatesConstraint idle =
      ~(WidgetState.hovered |
          WidgetState.pressed |
          WidgetState.selected |
          WidgetState.disabled);

  /// A property that applies [color] to the idle state only, leaving every
  /// other state to the layers below it. Returns null when [color] is null.
  ///
  /// This is the drop-in equivalent of a plain "background color" / "foreground
  /// color" parameter: the hover, press, selection and disabled appearances keep
  /// coming from the theme.
  static WidgetStateProperty<Color?>? idleOnly(Color? color) {
    if (color == null) return null;
    return WidgetStateProperty<Color?>.fromMap({idle: color});
  }

  /// Resolves [states] against [candidates] in order and returns the first
  /// non-null color, or `null` when no candidate resolves one.
  ///
  /// Pass the candidates highest-priority first (widget parameter, then theme
  /// override, then semantic default).
  static Color? resolve(
    Set<WidgetState> states,
    List<WidgetStateProperty<Color?>?> candidates,
  ) {
    for (final WidgetStateProperty<Color?>? candidate in candidates) {
      final Color? color = candidate?.resolve(states);
      if (color != null) return color;
    }
    return null;
  }

  /// Layers [over] on top of [under]: for any state where [over] resolves to a
  /// color that color wins, otherwise [under] applies.
  ///
  /// Returns the other property when one of the two is null, so layering a
  /// theme that styles a single state on top of one that styles a different
  /// state keeps both.
  static WidgetStateProperty<Color?>? layer(
    WidgetStateProperty<Color?>? over,
    WidgetStateProperty<Color?>? under,
  ) {
    if (over == null) return under;
    if (under == null) return over;
    return _CNLayeredStateColor(over, under);
  }
}

/// The [CNStateColor.layer] result: [over] with [under] as its per-state
/// fallback. Equality is structural so theme data objects built this way stay
/// comparable (and thus don't trigger spurious rebuilds).
@immutable
class _CNLayeredStateColor implements WidgetStateProperty<Color?> {
  const _CNLayeredStateColor(this.over, this.under);

  final WidgetStateProperty<Color?> over;
  final WidgetStateProperty<Color?> under;

  @override
  bool operator ==(Object other) =>
      other is _CNLayeredStateColor &&
      other.over == over &&
      other.under == under;

  @override
  int get hashCode => Object.hash(over, under);

  @override
  Color? resolve(Set<WidgetState> states) =>
      over.resolve(states) ?? under.resolve(states);

  @override
  String toString() => 'CNStateColor.layer($over, $under)';
}
