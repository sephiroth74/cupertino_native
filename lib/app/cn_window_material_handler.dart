import 'package:flutter/foundation.dart';
import 'package:macos_window_utils/macos_window_utils.dart';

/// Synchronizes the window-wide visual effect with the one declared by
/// `CNWindow`.
///
/// The window's root view is itself an `NSVisualEffectView` (see
/// `macos_window_utils`), so a *global* material is set on that view rather than
/// on a subview: every surface that leaves its own Flutter paint transparent —
/// the content area, the sidebars, the status bar — blurs against it. Per-part
/// materials (`CNSidebar.material`, `CNStatusBar.material`,
/// `CNToolbar.material`, `CNWindow.childMaterial`) are separate
/// `NSVisualEffectView` subviews layered over this one.
class CNWindowMaterialHandler {
  static NSVisualEffectViewMaterial? _lastMaterial;
  static NSVisualEffectViewState? _lastState;

  /// Applies [material] and [state] to the window's root visual effect view,
  /// skipping the platform round-trip when neither has changed since the last
  /// call.
  ///
  /// A null [material] leaves the window's current material untouched — the
  /// native default is `NSVisualEffectViewMaterial.windowBackground`.
  static void ensureVisualEffect({
    required NSVisualEffectViewState state,
    NSVisualEffectViewMaterial? material,
  }) {
    if (defaultTargetPlatform != TargetPlatform.macOS) return;
    if (material != null && material != _lastMaterial) {
      _lastMaterial = material;
      WindowManipulator.setMaterial(material);
    }
    if (state != _lastState) {
      _lastState = state;
      WindowManipulator.setNSVisualEffectViewState(state);
    }
  }
}
