import 'package:flutter/foundation.dart';
import 'package:macos_window_utils/macos_window_utils.dart';

/// Synchronizes the macOS window brightness with the Flutter theme brightness.
class CNBrightnessOverrideHandler {
  static Brightness? _lastBrightness;

  /// Overrides the macOS window brightness if it differs from [currentBrightness].
  static void ensureMatchingBrightness(Brightness currentBrightness) {
    if (currentBrightness == _lastBrightness) return;
    WindowManipulator.overrideMacOSBrightness(
      dark: currentBrightness == Brightness.dark,
    );
    _lastBrightness = currentBrightness;
  }
}
