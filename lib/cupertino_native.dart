// Public exports and convenience API for the plugin.

export 'cupertino_native_platform_interface.dart';
export 'cupertino_native_method_channel.dart';
export 'components/slider.dart';
export 'components/switch.dart';
export 'components/segmented_control.dart';
export 'components/icon.dart';
export 'components/tab_bar.dart';
export 'components/popup_menu_button.dart';
export 'components/button.dart';
export 'components/color_well.dart';
export 'components/path_control.dart';
export 'components/progress_indicator.dart';
export 'components/level_indicator.dart';
export 'components/stepper.dart';
export 'components/checkbox.dart';
export 'components/combo_button.dart';
export 'components/image.dart';
export 'components/menu.dart';
export 'components/date_picker.dart';
export 'components/alert.dart';
export 'components/popover.dart';

export 'model/control_size.dart';
export 'model/slider_tickmark_position.dart';
export 'model/checkbox_state.dart';

export 'style/sf_symbol.dart';
export 'style/button_style.dart';
export 'style/color_well_style.dart';
export 'style/path_control_style.dart';
export 'style/progress_style.dart';
export 'style/slider_type.dart';
export 'style/level_indicator_style.dart';
export 'style/combo_button_style.dart';
export 'style/font.dart';

import 'cupertino_native_platform_interface.dart';

/// Top-level facade for simple plugin interactions.
class CupertinoNative {
  /// Returns a user-friendly platform version string supplied by the
  /// platform implementation.
  Future<String?> getPlatformVersion() {
    return CupertinoNativePlatform.instance.getPlatformVersion();
  }
}
