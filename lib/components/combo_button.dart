import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

const double _kDefaultComboButtonWidth = 100.0;
const double _kDefaultComboButtonHeight = 24.0;

/// A native macOS combo button that can show a menu attached to a button.
class CNComboButton extends StatefulWidget {
  /// The explicit menu model used by the combo button.
  final CNMenu? menu;

  /// Convenience list of string items used to build a menu internally.
  final List<String>? items;

  /// The control size used by the native AppKit control.
  final CNControlSize controlSize;

  /// The button title displayed in the native control.
  final String title;

  /// An optional image to display in the combo button.
  final CNImage? image;

  /// The visual combo button style.
  final CNComboButtonStyle style;

  /// Callback invoked when the main button area is pressed.
  final ValueChanged<CNComboButton>? onPressed;

  /// Callback invoked when a menu item is selected.
  final ValueChanged<CNMenuItem>? onMenuItemSelected;

  /// Creates a combo button backed by either [menu] or [items].
  const CNComboButton({
    super.key,
    this.menu,
    this.items,
    this.controlSize = CNControlSize.regular,
    required this.title,
    this.style = CNComboButtonStyle.split,
    this.image,
    this.onPressed,
    this.onMenuItemSelected,
  }) : assert(
         menu == null || items == null,
         'Cannot provide both menu and items.',
       ),
       assert(
         menu != null || items != null,
         'Must provide either menu or items.',
       );

  @override
  State<CNComboButton> createState() => _CNComboButtonState();

  /// Whether the button is interactive.
  bool get enabled => onPressed != null || onMenuItemSelected != null;
}

class _CNComboButtonState extends State<CNComboButton> {
  MethodChannel? _channel;
  CNMenu? _internalMenu;
  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;
  double? _intrinsicWidth;
  double? _intrinsicHeight;
  bool _lastIsDark = false;
  CNMenu? _lastMenu;

  CNMenu get menu {
    if (widget.menu != null) return widget.menu!;
    return _internalMenu ??= CNMenu(
      items: widget.items!.map((item) => CNMenuItem(title: item)).toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    menu.addListener(_onMenuChanged);
  }

  @override
  void didUpdateWidget(covariant CNComboButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded(oldWidget);
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    menu.removeListener(_onMenuChanged);
    _internalMenu?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    if (!(defaultTargetPlatform == TargetPlatform.macOS)) {
      return Placeholder();
    }

    const viewType = 'CupertinoNativeComboButton';

    final creationParams = <String, dynamic>{
      'enabled': widget.enabled,
      'isDark': _isDark,
      'controlSize': widget.controlSize.name,
      'title': widget.title,
      'image': widget.image?.toMap(context),
      'style': widget.style.name,
      'menu': menu.toJson(context),
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        bool hasBoundedWidth = constraints.hasBoundedWidth;
        bool hasBoundedHeight = constraints.hasBoundedHeight;

        double? width;
        double? height;

        if (hasBoundedWidth) {
          width = constraints.minWidth > 0
              ? constraints.minWidth
              : constraints.maxWidth;
        } else if (_intrinsicWidth != null && _intrinsicWidth! > 0) {
          width = _intrinsicWidth;
        } else {
          width = _kDefaultComboButtonWidth;
        }

        if (_intrinsicHeight != null && _intrinsicHeight! > 0) {
          height = _intrinsicHeight;
        } else if (hasBoundedHeight) {
          height = constraints.maxHeight;
        } else {
          height = _kDefaultComboButtonHeight;
        }

        return SizedBox(
          width: width,
          height: height,
          child: AppKitView(
            viewType: viewType,
            creationParamsCodec: const StandardMessageCodec(),
            creationParams: creationParams,
            onPlatformViewCreated: _onPlatformViewCreated,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
            },
          ),
        );
      },
    );
  }

  void _onPlatformViewCreated(int id) {
    final channel = MethodChannel('CupertinoNativeComboButton_$id');
    _channel = channel;
    channel.setMethodCallHandler(_onMethodCall);
    _cacheCurrentProps();
    _syncBrightnessIfNeeded();
    _requestIntrinsicSize();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    debugPrint(
      '[checkbox] Method call from native: ${call.method} with args: ${call.arguments}',
    );

    if (call.method == 'menuItemSelected') {
      final args = call.arguments as Map<dynamic, dynamic>;
      final title = args['title'] as String;
      final tag = args['tag'] as int?;
      final index = args['index'] as int?;
      final identifier = args['identifier'] as String?;
      debugPrint('Menu item selected: title=$title, tag=$tag, index=$index');

      final selectedItem = menu.findItemByIdentifier(identifier ?? '');
      if (selectedItem != null && selectedItem.enabled) {
        widget.onMenuItemSelected?.call(selectedItem);
      } else {
        debugPrint('No menu item found with identifier: $identifier');
      }
    } else if (call.method == 'comboButtonPressed') {
      widget.onPressed?.call(widget);
    }
  }

  void _cacheCurrentProps() {
    // Cache any properties that might be needed for later updates.
    _lastIsDark = _isDark;
    _lastMenu = menu;
  }

  Future<void> _syncPropsToNativeIfNeeded(CNComboButton oldWidget) async {
    final channel = _channel;
    if (channel == null) return;
    if (!mounted) return;

    bool requireIntrinsicSizeUpdate = false;

    if (_lastMenu != menu) {
      debugPrint(
        'Menu instance changed. Updating listener and syncing to native.',
      );
      _lastMenu?.removeListener(_onMenuChanged);
      menu.addListener(_onMenuChanged);
      await channel.invokeMethod('setMenu', {'value': menu.toJson(context)});
      _lastMenu = menu;
      requireIntrinsicSizeUpdate = true;
    } else {
      debugPrint(
        'Menu instance did not change. No need to update listener or sync menu to native.',
      );
    }

    if (_lastIsDark != _isDark) {
      await channel.invokeMethod('setIsDark', {'value': _isDark});
      _lastIsDark = _isDark;
    }

    if (oldWidget.enabled != widget.enabled) {
      await channel.invokeMethod('setIsEnabled', {'value': widget.enabled});
    }

    if (oldWidget.controlSize != widget.controlSize) {
      await channel.invokeMethod('setControlSize', {
        'value': widget.controlSize.name,
      });
      requireIntrinsicSizeUpdate = true;
    }

    if (oldWidget.title != widget.title) {
      await channel.invokeMethod('setTitle', {'value': widget.title});
      requireIntrinsicSizeUpdate = true;
    }

    if (oldWidget.image != widget.image) {
      await channel.invokeMethod('setImage', {
        'value': widget.image?.toMap(context),
      });
      requireIntrinsicSizeUpdate = true;
    }

    if (oldWidget.style != widget.style) {
      await channel.invokeMethod('setStyle', {'value': widget.style.name});
      requireIntrinsicSizeUpdate = true;
    }

    if (requireIntrinsicSizeUpdate) {
      _requestIntrinsicSize();
    }
  }

  void _onMenuChanged() {
    if (!mounted) return;
    _syncPropsToNativeIfNeeded(widget);
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final channel = _channel;
    if (channel == null) return;
  }

  Future<void> _requestIntrinsicSize() async {
    final ch = _channel;
    if (ch == null) return;
    try {
      SchedulerBinding.instance.scheduleFrame();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final ch = _channel;
        if (ch == null) return;
        final size = await ch.invokeMethod<Map>('getIntrinsicSize');
        final w = (size?['width'] as num?)?.toDouble();
        final h = (size?['height'] as num?)?.toDouble();
        _onIntrinsicSizeChanged(w, h);
      });
    } catch (_) {}
  }

  void _onIntrinsicSizeChanged(double? width, double? height) {
    if (width != null && height != null && mounted) {
      setState(() {
        debugPrint('Intrinsic size updated: $width x $height');

        _intrinsicWidth = width > -1 ? width : null;
        _intrinsicHeight = height > -1 ? height : null;
      });
    }
  }
}
