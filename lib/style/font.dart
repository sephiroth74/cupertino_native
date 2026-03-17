/// NSFont-compatible weights.
enum CNFontWeight {
  /// Ultra-light system weight.
  ultraLight,

  /// Thin system weight.
  thin,

  /// Light system weight.
  light,

  /// Regular system weight.
  regular,

  /// Medium system weight.
  medium,

  /// Semibold system weight.
  semibold,

  /// Bold system weight.
  bold,

  /// Heavy system weight.
  heavy,

  /// Black system weight.
  black,
}

/// Named NSFont static sizes.
enum CNFontSizePreset {
  /// Maps to `NSFont.systemFontSize`.
  system,

  /// Maps to `NSFont.smallSystemFontSize`.
  smallSystem,

  /// Maps to `NSFont.labelFontSize`.
  label,
}

/// Describes a font size either as a named NSFont preset or raw points.
class CNFontSize {
  /// Uses one of NSFont's static size presets.
  const CNFontSize.preset(this.preset) : points = null;

  /// Uses a raw point size.
  const CNFontSize.points(this.points) : preset = null;

  /// Named NSFont size preset.
  final CNFontSizePreset? preset;

  /// Raw point size.
  final double? points;

  /// Serializes this value for platform channel transport.
  Map<String, dynamic> toMap() {
    if (preset != null) {
      return {'preset': preset!.name};
    }
    return {'points': points};
  }
}

/// NSFont-compatible constructors.
enum CNFontKind {
  /// `NSFont.systemFont(ofSize:weight:)`.
  system,

  /// `NSFont.boldSystemFont(ofSize:)`.
  boldSystem,

  /// `NSFont.monospacedSystemFont(ofSize:weight:)`.
  monospacedSystem,

  /// `NSFont.monospacedDigitSystemFont(ofSize:weight:)`.
  monospacedDigitSystem,

  /// `NSFont.userFont(ofSize:)`.
  user,

  /// `NSFont.userFixedPitchFont(ofSize:)`.
  userFixedPitch,

  /// `NSFont.menuFont(ofSize:)`.
  menu,

  /// `NSFont.menuBarFont(ofSize:)`.
  menuBar,

  /// `NSFont.messageFont(ofSize:)`.
  message,

  /// `NSFont.paletteFont(ofSize:)`.
  palette,

  /// `NSFont.titleBarFont(ofSize:)`.
  titleBar,

  /// `NSFont.toolTipsFont(ofSize:)`.
  toolTips,

  /// `NSFont.controlContentFont(ofSize:)`.
  controlContent,

  /// `NSFont.labelFont(ofSize:)`.
  label,

  /// `NSFont(name:size:)`.
  named,
}

/// Declarative font descriptor serialized to native NSFont constructors.
class CNFont {
  /// Constructor kind mapped on the native side.
  final CNFontKind kind;

  /// Requested size.
  final CNFontSize size;

  /// Optional weight for weighted constructors.
  final CNFontWeight? weight;

  /// Font PostScript/family name for `named` kind.
  final String? name;

  /// Creates `NSFont.systemFont(ofSize:weight:)`.
  const CNFont.system(this.size, {this.weight = CNFontWeight.regular})
    : kind = CNFontKind.system,
      name = null;

  /// Creates `NSFont.boldSystemFont(ofSize:)`.
  const CNFont.boldSystem(this.size)
    : kind = CNFontKind.boldSystem,
      weight = null,
      name = null;

  /// Creates `NSFont.monospacedSystemFont(ofSize:weight:)`.
  const CNFont.monospacedSystem(this.size, {this.weight = CNFontWeight.regular})
    : kind = CNFontKind.monospacedSystem,
      name = null;

  /// Creates `NSFont.monospacedDigitSystemFont(ofSize:weight:)`.
  const CNFont.monospacedDigitSystem(
    this.size, {
    this.weight = CNFontWeight.regular,
  }) : kind = CNFontKind.monospacedDigitSystem,
       name = null;

  /// Creates `NSFont.userFont(ofSize:)`.
  const CNFont.user(this.size)
    : kind = CNFontKind.user,
      weight = null,
      name = null;

  /// Creates `NSFont.userFixedPitchFont(ofSize:)`.
  const CNFont.userFixedPitch(this.size)
    : kind = CNFontKind.userFixedPitch,
      weight = null,
      name = null;

  /// Creates `NSFont.menuFont(ofSize:)`.
  const CNFont.menu(this.size)
    : kind = CNFontKind.menu,
      weight = null,
      name = null;

  /// Creates `NSFont.menuBarFont(ofSize:)`.
  const CNFont.menuBar(this.size)
    : kind = CNFontKind.menuBar,
      weight = null,
      name = null;

  /// Creates `NSFont.messageFont(ofSize:)`.
  const CNFont.message(this.size)
    : kind = CNFontKind.message,
      weight = null,
      name = null;

  /// Creates `NSFont.paletteFont(ofSize:)`.
  const CNFont.palette(this.size)
    : kind = CNFontKind.palette,
      weight = null,
      name = null;

  /// Creates `NSFont.titleBarFont(ofSize:)`.
  const CNFont.titleBar(this.size)
    : kind = CNFontKind.titleBar,
      weight = null,
      name = null;

  /// Creates `NSFont.toolTipsFont(ofSize:)`.
  const CNFont.toolTips(this.size)
    : kind = CNFontKind.toolTips,
      weight = null,
      name = null;

  /// Creates `NSFont.controlContentFont(ofSize:)`.
  const CNFont.controlContent(this.size)
    : kind = CNFontKind.controlContent,
      weight = null,
      name = null;

  /// Creates `NSFont.labelFont(ofSize:)`.
  const CNFont.label(this.size)
    : kind = CNFontKind.label,
      weight = null,
      name = null;

  /// Creates `NSFont(name:size:)`.
  const CNFont.named(this.name, this.size)
    : kind = CNFontKind.named,
      weight = null;

  /// Serializes this value for platform channel transport.
  Map<String, dynamic> toMap() {
    return {
      'kind': kind.name,
      'size': size.toMap(),
      if (weight != null) 'weight': weight!.name,
      if (name != null) 'name': name,
    };
  }
}
