// Public exports and convenience API for the plugin.

import 'cupertino_native_platform_interface.dart';

export 'components/button.dart';
export 'components/button_child.dart';
export 'components/cn_alert2.dart';
export 'components/cn_button.dart';
export 'components/cn_child.dart';
export 'components/cn_color_well.dart';
export 'components/cn_context_menu.dart';
export 'components/cn_date_picker.dart';
export 'components/cn_gauge.dart';
export 'components/cn_image.dart';
export 'components/cn_label.dart';
export 'components/cn_menu2.dart';
export 'components/cn_path_control.dart';
export 'components/cn_picker.dart';
export 'components/cn_progress_view.dart';
export 'components/cn_search_field.dart';
export 'components/cn_secure_field.dart';
export 'components/cn_slider.dart';
export 'components/cn_stepper.dart';
export 'components/cn_text.dart';
export 'components/cn_text_field.dart';
export 'components/cn_toggle.dart';
export 'components/group_box.dart';
export 'components/image.dart';
export 'components/label.dart';
export 'components/list.dart';
export 'components/menu.dart';
export 'components/menu_child.dart';
export 'components/menu_model.dart';
export 'components/navigation_bar.dart';
export 'components/page_route.dart';
export 'components/page_scaffold.dart';
export 'components/picker.dart';
export 'components/popover.dart';
export 'components/cn_popover2.dart';
export 'components/popup_menu_button.dart';
export 'components/segmented_control.dart';
export 'components/split_view.dart';
export 'components/tab_bar.dart';
export 'components/tab_view.dart';
export 'components/text.dart';
export 'components/text_view.dart';
export 'components/toggle.dart';
export 'components/toolbar/toolbar.dart';
export 'components/window/window.dart';
export 'cupertino_native_method_channel.dart';
export 'cupertino_native_platform_interface.dart';
export 'extensions/box_constraints.dart';
export 'model/checkbox_state.dart';
export 'model/control_size.dart';
export 'model/picker_style.dart';
export 'style/button_style.dart';
export 'style/cn_colors.dart';
export 'style/cn_shape_style.dart';
export 'style/cn_typography.dart';
export 'style/color_well_style.dart';
export 'style/combo_box_behavior.dart';
export 'style/font.dart';
export 'style/level_indicator_style.dart';
export 'style/macos26_materials.dart';
export 'style/menu_style.dart';
export 'style/path_control_style.dart';
export 'style/progress_style.dart';
export 'style/sf_symbol.dart';
export 'style/text.dart';
// combo button removed
export 'style/text_field_bezel_style.dart';
export 'theme/cn_theme.dart';
export 'theme/cn_theme_data.dart';

/// Top-level facade for simple plugin interactions.
class CupertinoNative {
  /// Returns a user-friendly platform version string supplied by the
  /// platform implementation.
  Future<String?> getPlatformVersion() {
    return CupertinoNativePlatform.instance.getPlatformVersion();
  }
}
