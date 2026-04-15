/// Controls the interaction mode of a [CNComboBox].
enum CNComboBoxBehavior {
  /// Display-only: the combo box is not editable and not enabled.
  ///
  /// Maps to `NSComboBox.isEditable = false` and `NSComboBox.isEnabled = false`.
  none,

  /// Dropdown-only: the user can open the dropdown and select an item but
  /// cannot type in the text field.
  ///
  /// Maps to `NSComboBox.isEditable = false` and `NSComboBox.isEnabled = true`.
  selectable,

  /// Fully interactive: the user can both type and select from the dropdown.
  ///
  /// Maps to `NSComboBox.isEditable = true` and `NSComboBox.isEnabled = true`.
  editable,
}
