/// Defines the style of a level indicator.
enum CNLevelIndicatorStyle {
  /// A level indicator that fills continuously.
  continuousCapacity,

  /// A level indicator that fills in discrete steps.
  discreteCapacity,

  /// A level indicator that fills in star-like shapes.
  rating,

  /// A level indicator that fills in continuous steps, with a different visual style than [continuousCapacity].
  relevancy,
}
