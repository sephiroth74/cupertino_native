/// The border/bezel style of a native text input control.
///
/// Maps to the combination of `NSTextField.isBezeled`, `NSTextField.isBordered`
/// and `NSTextField.bezelStyle` on macOS.
enum CNTextFieldBezelStyle {
  /// No border is drawn.
  none,

  /// A single-pixel line border.
  line,

  /// A square bezel (recessed, square corners).
  bezel,

  /// A rounded bezel — the default style used by NSSearchField.
  round,
}
