// Public exports and convenience API for the plugin.

import 'cupertino_native_platform_interface.dart';

export 'app/cn_app.dart';
export 'app/cn_content_area.dart';
export 'app/cn_main_window_listener.dart';
export 'app/cn_page_route.dart';
export 'app/cn_page_scaffold.dart';
export 'app/cn_scrollbar.dart';
export 'app/cn_sidebar.dart';
export 'app/cn_status_bar.dart';
export 'app/cn_window.dart';
export 'components/cn_accent_color_listener.dart';
export 'components/cn_alert.dart';
export 'components/cn_button.dart';
export 'components/cn_child.dart';
export 'components/cn_color_well.dart';
export 'components/cn_combo_box.dart';
export 'components/cn_context_menu.dart';
export 'components/cn_date_picker.dart';
export 'components/cn_gauge.dart';
export 'components/cn_image.dart';
export 'components/cn_label.dart';
export 'components/cn_menu.dart';
export 'components/cn_path_control.dart';
export 'components/cn_picker.dart';
export 'components/cn_popover.dart';
export 'components/cn_progress_view.dart';
export 'components/cn_search_field.dart';
export 'components/cn_secure_field.dart';
export 'components/cn_segmented_control.dart';
export 'components/cn_slider.dart';
export 'components/cn_stepper.dart';
export 'components/cn_tab_view.dart';
export 'components/cn_text_editor.dart';
export 'components/cn_text_field.dart';
export 'components/cn_text.dart';
export 'components/cn_toggle.dart';
export 'components/cn_toolbar.dart';
export 'components/group_box.dart';
export 'cupertino_native_method_channel.dart';
export 'cupertino_native_platform_interface.dart';
export 'extensions/box_constraints.dart';
export 'extensions/cn_dynamic_color.dart';
export 'extensions/color_ext.dart';
export 'model/control_size.dart';
export 'style/button_style.dart';
export 'style/cn_colors.dart';
export 'style/cn_overlay.dart';
export 'style/cn_shape.dart';
export 'style/cn_shape_style.dart';
export 'style/cn_typography.dart';
export 'style/color_well_style.dart';
export 'style/font.dart';
export 'style/macos26_materials.dart';
export 'style/progress_style.dart';
export 'style/sf_symbol.dart';
export 'style/text_field_bezel_style.dart';
export 'style/text.dart';
export 'theme/cn_button_theme_data.dart';
export 'theme/cn_date_picker_theme_data.dart';
export 'theme/cn_gauge_theme_data.dart';
export 'theme/cn_icon_button_theme_data.dart';
export 'theme/cn_picker_theme_data.dart';
export 'theme/cn_progress_theme_data.dart';
export 'theme/cn_scrollbar_theme.dart';
export 'theme/cn_secure_field_theme_data.dart';
export 'theme/cn_segmented_control_theme_data.dart';
export 'theme/cn_slider_theme_data.dart';
export 'theme/cn_stepper_theme_data.dart';
export 'theme/cn_text_field_theme_data.dart';
export 'theme/cn_theme_data.dart';
export 'theme/cn_theme.dart';
export 'theme/cn_toggle_theme_data.dart';
export 'widgets/cn_pixel_perfect_container.dart';
export 'widgets/cn_window_geometry.dart';
export 'components/cn_icon_button.dart';

/// Top-level facade for simple plugin interactions.
class CupertinoNative {
  /// Returns a user-friendly platform version string supplied by the
  /// platform implementation.
  Future<String?> getPlatformVersion() {
    return CupertinoNativePlatform.instance.getPlatformVersion();
  }
}
