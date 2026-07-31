import 'package:flutter/services.dart';

/// Applies a chain of [TextInputFormatter]s to text reported by a native
/// input widget.
///
/// The native side is the source of the raw edit; this reconciles it with
/// Flutter's formatter ecosystem (e.g. [FilteringTextInputFormatter],
/// [LengthLimitingTextInputFormatter]). Because native reports text and
/// selection separately, the incoming selection is approximated as collapsed
/// at the end of [newText] — adequate for append-style typing, which is what
/// the common formatters assume.
///
/// Returns the formatted [TextEditingValue]. When [formatters] is null or
/// empty the value is returned unchanged (selection collapsed at end).
TextEditingValue applyCNInputFormatters({
  required String newText,
  required TextEditingValue oldValue,
  List<TextInputFormatter>? formatters,
}) {
  var value = TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(offset: newText.length),
  );
  if (formatters == null || formatters.isEmpty) return value;
  for (final formatter in formatters) {
    value = formatter.formatEditUpdate(oldValue, value);
  }
  return value;
}
