/// Represents the state of a checkbox, which can be on, off, or mixed (indeterminate).
enum CNCheckboxState {
  /// The checkbox is on.
  on(1),

  /// The checkbox is off.
  off(0),

  /// The checkbox is in an indeterminate state.
  mixed(-1);

  /// The integer value associated with this state, used for platform communication.
  final int value;

  const CNCheckboxState(this.value);
}
