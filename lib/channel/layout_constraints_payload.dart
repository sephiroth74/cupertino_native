import 'dart:convert';

import 'package:cupertino_native/extensions/box_constraints.dart';
import 'package:flutter/widgets.dart';

/// Computes the canonical constraints payload used by native-backed widgets.
CNResolvedLayoutConstraints resolveLayoutConstraintsPayload({
  required BoxConstraints parentConstraints,
  required BoxConstraints? explicitConstraints,
}) {
  final resolvedConstraints = explicitConstraints ?? parentConstraints;
  final layoutConstraintsPayload = resolvedConstraints.toMap();

  return CNResolvedLayoutConstraints(
    resolvedConstraints: resolvedConstraints,
    layoutConstraintsPayload: layoutConstraintsPayload,
    serializedLayoutConstraintsPayload: jsonEncode(layoutConstraintsPayload),
  );
}

/// Writes layout-derived constraints only when explicit constraints are absent,
/// because explicit constraints are already serialized by shared view modifiers.
void writeLayoutConstraintsPayload(
  Map<String, dynamic> payload, {
  required Map<String, dynamic>? layoutConstraintsPayload,
  required BoxConstraints? explicitConstraints,
}) {
  if (layoutConstraintsPayload != null && explicitConstraints == null) {
    payload['constraints'] = layoutConstraintsPayload;
  }
}

/// Returns true when constraints changed and schedules a post-frame sync.
bool syncOnLayoutConstraintsChange({
  required String? previousSerializedLayoutConstraintsPayload,
  required CNResolvedLayoutConstraints resolvedLayoutConstraints,
  required Future<void> Function() sync,
}) {
  final changed =
      previousSerializedLayoutConstraintsPayload != resolvedLayoutConstraints.serializedLayoutConstraintsPayload;
  if (!changed) {
    return false;
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    sync();
  });

  return true;
}

/// Resolved constraints data used for channel payload generation and diffing.
class CNResolvedLayoutConstraints {
  /// Creates a resolved constraints snapshot for payload serialization.
  const CNResolvedLayoutConstraints({
    required this.resolvedConstraints,
    required this.layoutConstraintsPayload,
    required this.serializedLayoutConstraintsPayload,
  });

  /// Channel-friendly map to send as `constraints` payload.
  final Map<String, dynamic> layoutConstraintsPayload;

  /// Constraints that should drive widget layout behavior.
  final BoxConstraints resolvedConstraints;

  /// Stable JSON representation used for change detection.
  final String serializedLayoutConstraintsPayload;
}

/// Stateful helper that stores the latest layout constraints payload and
/// schedules native sync when constraints change.
class CNLayoutConstraintsSyncState {
  Map<String, dynamic>? _layoutConstraintsPayload;
  String? _serializedLayoutConstraintsPayload;

  /// Last computed payload map to include in channel data.
  Map<String, dynamic>? get layoutConstraintsPayload => _layoutConstraintsPayload;

  /// Updates internal payload/snapshot and schedules sync when constraints changed.
  void apply(
    CNResolvedLayoutConstraints resolvedLayoutConstraints, {
    required Future<void> Function() sync,
  }) {
    _layoutConstraintsPayload = resolvedLayoutConstraints.layoutConstraintsPayload;

    if (syncOnLayoutConstraintsChange(
      previousSerializedLayoutConstraintsPayload: _serializedLayoutConstraintsPayload,
      resolvedLayoutConstraints: resolvedLayoutConstraints,
      sync: sync,
    )) {
      _serializedLayoutConstraintsPayload = resolvedLayoutConstraints.serializedLayoutConstraintsPayload;
    }
  }
}
