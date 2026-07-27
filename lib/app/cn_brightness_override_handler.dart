import 'package:flutter/foundation.dart';
import 'package:macos_window_utils/macos_window_utils.dart';

class CNBrightnessOverrideHandler {
  static Brightness? _lastBrightness;

  static void ensureMatchingBrightness(Brightness currentBrightness) {
    if (currentBrightness == _lastBrightness) return;
    WindowManipulator.overrideMacOSBrightness(dark: currentBrightness == Brightness.dark);
    _lastBrightness = currentBrightness;
  }
}
