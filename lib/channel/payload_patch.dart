import 'dart:convert';

/// Computes a JSON-safe patch map where changed keys are included and removed
/// keys are represented as `null`.
Map<String, dynamic> computeJsonSafePatch(Map<String, dynamic> previous, Map<String, dynamic> next) {
  final patch = <String, dynamic>{};
  final keys = <String>{...previous.keys, ...next.keys};

  for (final key in keys) {
    final hadPrevious = previous.containsKey(key);
    final hasNext = next.containsKey(key);
    final oldValue = hadPrevious ? previous[key] : null;
    final newValue = hasNext ? next[key] : null;

    final changed = jsonEncode(oldValue) != jsonEncode(newValue);
    if (!changed) {
      continue;
    }

    patch[key] = hasNext ? newValue : null;
  }

  return patch;
}
