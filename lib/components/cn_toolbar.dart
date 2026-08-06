import 'package:cupertino_native/components/cn_widget_debug_id_mixin.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:macos_window_utils/macos/ns_visual_effect_view_material.dart';
import 'package:macos_window_utils/widgets/visual_effect_subview_container/visual_effect_subview_container.dart';
import 'package:window_manager/window_manager.dart' show DragToMoveArea;

/// Default overall toolbar height (mirrors AppKit's 52pt titlebar+toolbar strip).
const double kCNToolbarHeight = 52.0;

/// Default width allotted to the [CNToolbar.title] slot.
const double _kTitleWidth = 150.0;

/// Width of a single [CNToolbarSpacer] unit.
const double _kToolbarItemWidth = 32.0;

/// Left inset that clears the window traffic-light buttons when the sidebar is
/// hidden (the sidebar itself sits under the lights when shown).
const double _kTrafficLightInset = 70.0;

const double _kToolbarItemDefaultHeight = 28.0;

/// A preferred-size widget that can tell whether it fully obstructs content.
///
/// Implemented by [CNToolbar] and consumed by `CNPageScaffold` to decide how to
/// reserve top padding for the bar.
abstract class CNObstructingPreferredSizeWidget implements PreferredSizeWidget {
  /// Whether this widget fully obstructs content behind it.
  bool shouldFullyObstruct(BuildContext context);
}

/// A pure-Flutter toolbar rendered over a transparent, full-size-content-view
/// titlebar — the macOS-idiomatic replacement for a native `NSToolbar`.
///
/// Place it in the `toolBar` slot of `CNPageScaffold`; the scaffold reserves
/// [height] of top padding for the page content and overlays the bar on top.
///
/// The host application must reshape the window chrome once at startup so the
/// titlebar is transparent and the content view spans the full window:
///
/// ```dart
/// await WindowManipulator.makeTitlebarTransparent();
/// await WindowManipulator.enableFullSizeContentView();
/// await WindowManipulator.hideTitle();
/// ```
///
/// Items ([actions] / [leading]) may be native platform-view controls
/// ([CNToolbarIconButton], [CNToolbarPullDownButton], [CNToolbarPicker]) or pure
/// Flutter widgets ([CNToolbarDivider], [CNToolbarSpacer], [CNToolbarCustomItem]).
class CNToolbar extends StatefulWidget
    implements CNObstructingPreferredSizeWidget {
  /// Creates a Flutter toolbar.
  const CNToolbar({
    super.key,
    this.height = kCNToolbarHeight,
    this.leading = const [],
    this.automaticallyImplyLeading = true,
    this.title,
    this.titleWidth = _kTitleWidth,
    this.centerTitle = false,
    this.actions = const [],
    this.search,
    this.padding = const EdgeInsets.all(8),
    this.backgroundColor,
    this.dividerColor,
    this.enableBlur = false,
    this.material = NSVisualEffectViewMaterial.headerView,
  });

  /// Trailing action items (native controls or pure-Flutter items).
  final List<CNToolbarItem> actions;

  /// Whether to synthesize a back button when [leading] is null and the
  /// enclosing route can be popped.
  final bool automaticallyImplyLeading;

  /// Solid background color when [enableBlur] is false, or the tint over the
  /// blur when [enableBlur] is true. Defaults to the theme canvas color.
  final Color? backgroundColor;

  /// Whether to center the [title] within the available space.
  final bool centerTitle;

  /// Color of the 1px bottom divider. Defaults to the theme separator color.
  final Color? dividerColor;

  /// Whether to render a native vibrancy (blur) background.
  final bool enableBlur;

  /// Overall bar height (reserved by the scaffold as top padding).
  final double height;

  /// Leading items (usually a [CNToolbarIconButton]). When non-empty, overrides
  /// the synthesized back button.
  final List<CNToolbarItem> leading;

  /// The visual-effect material used when [enableBlur] is true.
  final NSVisualEffectViewMaterial material;

  /// Inner padding around the bar content.
  final EdgeInsets padding;

  /// Optional native search field placed before the [actions].
  final CNSearchField? search;

  /// Title slot — a plain Flutter widget (typically `Text`); no platform view.
  final Widget? title;

  /// Width allotted to the [title] slot.
  final double titleWidth;

  @override
  State<CNToolbar> createState() => _CNToolbarState();

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  bool shouldFullyObstruct(BuildContext context) => false;
}

/// A borderless toolbar button backed by the pure-Flutter [CNIconButton].
///
/// Unlike [CNToolbarIconButton] (a native `CNButton`), this item renders an SF
/// Symbol through [CNIconButton], so it supports the full [CNIconButtonThemeData]
/// styling surface — per-state foreground/background colors, border, shape,
/// corner radius, icon ratio and a `selected` state.
///
/// Styling is layered, lowest priority first:
/// 1. [CNIconButtonThemeData.toolbarDefaults] — the toolbar look (borderless,
///    transparent idle, subtle hover/pressed fill, accent-tinted selection);
/// 2. any ambient [CNIconButtonTheme] in scope (app-wide overrides);
/// 3. the per-item [theme] override passed here.
class CNToolbarButton extends CNToolbarItem {
  /// Creates a toolbar button from an SF Symbol [systemImage].
  const CNToolbarButton(
    this.systemImage, {
    this.selectedSystemImage,
    this.onPressed,
    this.onLongPress,
    this.label,
    this.isSelected = false,
    this.theme,
    this.help,
  });

  /// Whether the button renders its selected appearance (and swaps to
  /// [selectedSystemImage] when provided).
  final bool isSelected;

  /// Optional text label, used as the overflow-menu title.
  final String? label;

  /// Called when long-pressed.
  final VoidCallback? onLongPress;

  /// Called when tapped. When both this and [onLongPress] are null the button
  /// is disabled.
  final VoidCallback? onPressed;

  /// SF Symbol shown while [isSelected] is true. Falls back to [systemImage].
  final String? selectedSystemImage;

  /// SF Symbol name for the icon.
  final String systemImage;

  /// Optional per-item overrides layered on top of the toolbar defaults and any
  /// ambient [CNIconButtonTheme].
  final CNIconButtonThemeData? theme;

  /// Optional help text shown on hover (SwiftUI `.help()`).
  final String? help;

  @override
  bool get managesOwnHeight => true;

  @override
  CNChild? toOverflowChild(BuildContext context) {
    return CNChildButton(
      tag: label ?? systemImage,
      title: label ?? '',
      systemImage: systemImage,
      enabled: onPressed != null,
      help: help,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Layer the toolbar defaults under any ambient icon-button theme and the
    // per-item override, then expose the result to the inner CNIconButton via a
    // scoped CNIconButtonTheme (the button resolves its look from the nearest one).
    final resolved = CNIconButtonThemeData.toolbarDefaults(
      CNTheme.of(context),
    ).merge(CNIconButtonTheme.of(context)).merge(theme);

    // Pin the button to a square sized off the toolbar's content band, read live
    // from the layout — same approach as the native [CNToolbarIconButton].
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : _kToolbarItemDefaultHeight;
        final widget = CNIconButtonTheme(
          data: resolved,
          child: CNIconButton(
            size: side,
            systemSymbolName: systemImage,
            selectedSystemSymbolName: selectedSystemImage,
            isSelected: isSelected,
            onTap: onPressed,
            onLongPress: onLongPress,
          ),
        );

        if (help != null) {
          return Tooltip(
            message: help,
            waitDuration: Durations.extralong4,
            child: widget,
          );
        }
        return widget;
      },
    );
  }
}

/// A native macOS combo box ([CNComboBox]) placed as a toolbar item.
///
/// Rendered inline and vertically centered in the bar (it does not manage its
/// own height). Because a combo box is a compound data-entry control it has no
/// meaningful overflow-menu representation, so it does not appear in the
/// overflow menu.
class CNToolbarComboBox extends CNToolbarItem {
  /// Creates a toolbar combo box.
  const CNToolbarComboBox({
    required this.items,
    this.text = '',
    this.placeholder,
    this.style = CNComboBoxStyle.bordered,
    this.completes = false,
    this.onChanged,
    this.onSelectionChanged,
    this.width = 160.0,
    this.tint,
  });

  /// Whether the field auto-completes against [items] as the user types.
  final bool completes;

  /// The items in the pop-up list.
  final List<String> items;

  /// Called whenever the text changes.
  final ValueChanged<String>? onChanged;

  /// Called with the index of the item chosen from the pop-up list.
  final ValueChanged<int>? onSelectionChanged;

  /// Placeholder shown when the field is empty.
  final String? placeholder;

  /// The disclosure-caret style.
  final CNComboBoxStyle style;

  /// The current text value.
  final String text;

  /// Optional tint applied to the field.
  final Color? tint;

  /// Fixed field width within the toolbar.
  final double width;

  @override
  CNChild? toOverflowChild(BuildContext context) => null;

  @override
  Widget build(BuildContext context) {
    return CNComboBox(
      text: text,
      items: items,
      placeholder: placeholder,
      style: style,
      completes: completes,
      onChanged: onChanged,
      onSelectionChanged: onSelectionChanged,
      tint: tint,
      shrink: true,
      constraints: BoxConstraints.tightFor(width: width),
    );
  }
}

/// An escape hatch that renders an arbitrary Flutter widget as a toolbar item.
class CNToolbarCustomItem extends CNToolbarItem {
  /// Creates a custom item from a [builder].
  const CNToolbarCustomItem({required this.builder, this.overflowLabel});

  /// Builds the item's widget.
  final WidgetBuilder builder;

  /// Optional label used in the overflow menu (no overflow entry if null).
  final String? overflowLabel;

  @override
  CNChild? toOverflowChild(BuildContext context) {
    if (overflowLabel == null) return null;
    return CNChildButton(tag: overflowLabel!, title: overflowLabel!);
  }

  @override
  Widget build(BuildContext context) => builder(context);
}

/// A thin vertical divider between toolbar items (pure Flutter).
class CNToolbarDivider extends CNToolbarItem {
  /// Creates a toolbar divider.
  const CNToolbarDivider({
    this.padding = const EdgeInsets.all(6.0),
    this.color,
  });

  /// Optional divider color.
  final Color? color;

  /// Padding around the 1px rule.
  final EdgeInsets padding;

  @override
  CNChild? toOverflowChild(BuildContext context) => const CNChildDivider();

  @override
  Widget build(BuildContext context) {
    final dividerColor = color ?? CNTheme.of(context).separatorColor;
    return SizedBox(
      width: padding.horizontal + 1,
      height: _kToolbarItemDefaultHeight,
      child: Padding(
        padding: padding,
        child: ColoredBox(color: dividerColor),
      ),
    );
  }
}

/// A borderless icon button backed by a native `CNButton`.
class CNToolbarIconButton extends CNToolbarItem {
  /// Creates a toolbar icon button from an SF Symbol [systemImage].
  const CNToolbarIconButton(
    this.systemImage, {
    this.onPressed,
    this.label,
    this.showLabel = false,
    this.tooltip,
    this.tint,
  });

  /// Optional text label (shown beneath the icon when [showLabel] is true, and
  /// used as the overflow-menu title).
  final String? label;

  /// Called when tapped. When null, the button is disabled.
  final VoidCallback? onPressed;

  /// Whether to render [label] beneath the icon.
  final bool showLabel;

  /// SF Symbol name for the icon.
  final String systemImage;

  /// Optional tint color.
  final Color? tint;

  /// Tooltip shown on hover (SwiftUI `.help()`).
  final String? tooltip;

  @override
  bool get managesOwnHeight => true;

  @override
  CNChild? toOverflowChild(BuildContext context) {
    return CNChildButton(
      tag: label ?? systemImage,
      title: label ?? '',
      systemImage: systemImage,
      enabled: onPressed != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pin the button to a square sized off the toolbar's content band, read
    // live from the layout (no magic constant). With shrink:false the native
    // side receives a tight `.frame(width:height:)`, SwiftUI centers the symbol
    // inside that fixed frame, and — because intrinsic sizing only runs in
    // shrink mode — there is no measurement feedback loop to run away. This is
    // the same approach as `CnIconButton` (a fixed frame + centered CNImage).
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : _kToolbarItemDefaultHeight;
        // Size the symbol to fit within the square frame (≈45% of the side) so
        // SwiftUI can center it inside the fixed frame instead of drawing it at
        // its default size and overflowing — mirrors `CnIconButton`'s font sizing.
        final iconFont = CNFont.system(CNFontSize.points(side * 0.45));
        return CNButton(
          onPressed: onPressed,
          buttonStyle: CNButtonStyle.accessoryBarAction,
          shrink: false,
          debugLog: false,
          constraints: BoxConstraints.tightFor(width: side, height: side),
          tint: tint,
          help: tooltip,
          children: [
            if (showLabel && label != null)
              CNChildLabel(label!, systemImage: systemImage, font: iconFont)
            else
              CNChildImage(systemImage, font: iconFont),
          ],
        );
      },
    );
  }
}

/// Base class for items placed in a [CNToolbar]'s `leading`/`actions` slots.
abstract class CNToolbarItem {
  /// Const base constructor.
  const CNToolbarItem();

  /// Whether this item sizes itself to the toolbar's content band (e.g. a native
  /// control pinned to a fixed frame) and therefore must NOT be wrapped in the
  /// toolbar's vertical-centering helper — which would strip the height bound the
  /// item needs to read. Pure-Flutter items (dividers, spacers, custom widgets)
  /// leave this false and get centered by the toolbar.
  bool get managesOwnHeight => false;

  /// Builds the item's Flutter representation for the toolbar row.
  Widget build(BuildContext context);

  /// Serializes the item for the overflow menu, or null if it can't overflow
  /// (e.g. spacers).
  CNChild? toOverflowChild(BuildContext context);
}

/// A picker backed by a native `CNPicker`.
class CNToolbarPicker extends CNToolbarItem {
  /// Creates a toolbar picker.
  const CNToolbarPicker({
    required this.children,
    required this.selection,
    this.label,
    this.onChanged,
    this.pickerStyle = CNPickerStyle.menu,
    this.tint,
  });

  /// Picker items (each with a tag).
  final List<CNChild> children;

  /// Optional label content shown alongside the picker.
  final List<CNChild>? label;

  /// Called with the newly selected tag.
  final ValueChanged<String>? onChanged;

  /// Visual style for the picker.
  final CNPickerStyle pickerStyle;

  /// Currently selected tag.
  final String selection;

  /// Optional tint color.
  final Color? tint;

  @override
  CNChild? toOverflowChild(BuildContext context) {
    return CNChildPicker(
      tag: 'picker',
      children: children,
      selection: selection,
      label: label,
      pickerStyle: pickerStyle.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CNPicker(
      children: children,
      selection: selection,
      label: label,
      onChanged: onChanged,
      pickerStyle: pickerStyle,
      tint: tint,
      shrink: true,
    );
  }
}

/// A pull-down menu button backed by a native `CNMenu`.
class CNToolbarPullDownButton extends CNToolbarItem {
  /// Creates a pull-down button.
  const CNToolbarPullDownButton({
    required this.items,
    required this.label,
    this.onItemPressed,
    this.tint,
  });

  /// The menu items.
  final List<CNChild> items;

  /// The trigger label content (e.g. an icon).
  final List<CNChild> label;

  /// Called with the pressed item's tag.
  final ValueChanged<String>? onItemPressed;

  /// Optional tint color.
  final Color? tint;

  @override
  CNChild? toOverflowChild(BuildContext context) {
    return CNChildMenu(label: label, items: items);
  }

  @override
  Widget build(BuildContext context) {
    return CNMenu(
      label: label,
      items: items,
      onItemPressed: onItemPressed,
      tint: tint,
      shrink: true,
    );
  }
}

/// A fixed-width spacer between toolbar items (pure Flutter).
class CNToolbarSpacer extends CNToolbarItem {
  /// Creates a spacer of [spacerUnits] × [_kToolbarItemWidth] width.
  const CNToolbarSpacer({this.spacerUnits = 1.0});

  /// Number of spacer units.
  final double spacerUnits;

  @override
  CNChild? toOverflowChild(BuildContext context) => null;

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: spacerUnits * _kToolbarItemWidth);
}

class _CNToolbarState extends State<CNToolbar>
    with CNWidgetDebugIdMixin<CNToolbar> {
  void logDebug(String message) {
    debugPrint('$debugLogPrefix $message');
  }

  /// Centers a toolbar [child] vertically without imposing a height on it.
  ///
  /// A native control must NOT be given a bounded height. In shrink mode a height
  /// constraint becomes a SwiftUI `.frame(maxHeight:)`, which (a) stretches the
  /// control's bezel to fill that height and (b) destabilises its `fittingSize`
  /// measurement — the reported intrinsic height then oscillates (e.g. 21→45→38→45)
  /// and never settles, so no Flutter-side sizing can converge. Left unbounded, the
  /// control reports its stable natural height instead.
  ///
  /// `UnconstrainedBox` with `constrainedAxis: horizontal` removes only the
  /// vertical bound (so no `maxHeight` reaches the native side) while keeping the
  /// width bound. In the leading slot — which `NavigationToolbar` hands a *tight*
  /// full-band height — the box is forced to the band height and centers the
  /// shorter natural child within it; in the trailing `Row` it shrink-wraps to the
  /// child, which the row then centers. The bar [padding] gives the 8pt inset that
  /// keeps the natural-height controls off the bar edges.
  Widget _centerItem(Widget child) {
    return UnconstrainedBox(
      constrainedAxis: Axis.horizontal,
      alignment: Alignment.center,
      child: CNPixelPerfectContainer(adjustPosition: true, child: child),
    );
  }

  /// Places a toolbar [item] in the row.
  ///
  /// Items that manage their own height (native controls that pin themselves to
  /// a fixed frame sized off the band — see [CNToolbarItem.managesOwnHeight])
  /// are handed through untouched: they need the incoming height bound to read
  /// the band via a `LayoutBuilder`, which [_centerItem]'s `UnconstrainedBox`
  /// would strip. Everything else (dividers, spacers, custom widgets) is
  /// vertically centered by [_centerItem].
  Widget _wrapItem(CNToolbarItem item, BuildContext context) {
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: item.build(context),
    );
    return item.managesOwnHeight
        ? CNPixelPerfectContainer(child: child)
        : _centerItem(child);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CNTheme.of(context);
    final scope = CNWindowScope.maybeOf(context);
    final dividerColor = widget.dividerColor ?? theme.separatorColor;

    // Leading: explicit items, or a synthesized back button when the route can
    // pop and no explicit leading items were provided.
    List<CNToolbarItem> leadingItems = widget.leading;
    if (widget.automaticallyImplyLeading) {
      final canPop = ModalRoute.of(context)?.canPop ?? false;
      if (canPop) {
        leadingItems = [
          CNToolbarIconButton(
            'chevron.backward',
            onPressed: () => Navigator.maybePop(context),
          ),
          ...leadingItems,
        ];
      }
    }
    final Widget? leading = leadingItems.isEmpty
        ? null
        : Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (final item in leadingItems) _wrapItem(item, context),
            ],
          );

    // Title, sized and styled like AppKit's toolbar title.
    Widget? title = widget.title;
    if (title != null) {
      title = SizedBox(
        width: widget.titleWidth,
        child: DefaultTextStyle(
          style: theme.typography.title3.copyWith(
            color: theme.labelColor,
            fontWeight: FontWeight.w600,
          ),
          child: title,
        ),
      );
    }

    // Trailing: actions, then the optional search field. Items that manage
    // their own height keep the band's height bound; the rest are centered.
    final trailingChildren = <Widget>[
      for (final action in widget.actions) _wrapItem(action, context),
      if (widget.search != null)
        _centerItem(SizedBox(width: 180, child: widget.search)),
    ];
    final trailing = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: trailingChildren,
    );

    Widget bar = Container(
      alignment: Alignment.center,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.enableBlur
            ? null
            : (widget.backgroundColor ?? theme.canvasColor),
        border: Border(bottom: BorderSide(color: dividerColor)),
      ),
      child: NavigationToolbar(
        // Clear the traffic lights when the bar starts at the window's left
        // edge: always in full-width mode (the sidebar now sits below the bar),
        // and in split mode only when the sidebar is hidden (otherwise the
        // sidebar itself sits under the lights and the bar starts past them).
        leading: SafeArea(
          top: false,
          right: false,
          bottom: false,
          left:
              (scope?.toolbarSpansFullWidth ?? false) ||
              !(scope?.isSidebarShown ?? false),
          child: leading ?? const SizedBox.shrink(),
        ),
        middle: title,
        centerMiddle: widget.centerTitle,
        trailing: trailing,
        middleSpacing: 8,
      ),
    );

    if (widget.enableBlur) {
      bar = VisualEffectSubviewContainer(
        material: widget.material,
        child: DecoratedBox(
          decoration: BoxDecoration(color: widget.backgroundColor),
          child: bar,
        ),
      );
    }

    // Reserve the traffic-light inset via MediaQuery so the leading SafeArea can
    // consume it only when the sidebar is hidden. Empty regions drag the window.
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(padding: const EdgeInsets.only(left: _kTrafficLightInset)),
      child: DragToMoveArea(child: bar),
    );
  }
}
