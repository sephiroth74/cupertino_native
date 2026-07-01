import 'package:cupertino_native/model/control_size.dart';
import 'package:cupertino_native/style/sf_symbol.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import '../channel/params.dart';
import '../style/button_style.dart';
import '../theme/cn_theme.dart';

const double _kDefaultHeight = 64.0;
const double _kDefaultWidth = 80.0;
const double _kDefaultSize = 44.0;

/// Represents the image scale for a [CNButton] with a system image.
enum CNImageScale {
  /// Small image scale.
  small,
  /// Medium image scale.
  medium,
  /// Large image scale.
  large,
}

/// Semantic role for button actions.
enum CNButtonRole {
  /// Default role.
  none,

  /// Cancel role.
  cancel,

  /// Destructive role.
  destructive,

  /// Close role.
  close,
}

/// A Cupertino-native push button.
///
/// Embeds a native SwiftUI Button for authentic visuals and behavior on
/// macOS. Falls back to [CupertinoButton] on other platforms.
class CNButton extends StatefulWidget {
  /// Creates a text button variant of [CNButton].
  const CNButton({
    super.key,
    this.label,
    this.systemImage,
    this.role = CNButtonRole.none,
    this.onPressed,
    this.enabled = true,
    this.tint,
    this.height,
    this.shrinkWrap = false,
    this.style = CNButtonStyle.automatic,
    this.controlSize = CNControlSize.regular,
    this.imageScale = CNImageScale.medium,
    this.symbolRenderingMode,
  }) : width = null;

  /// Creates an icon-only variant of [CNButton].
  const CNButton.systemImage(
    String this.systemImage, {
    super.key,
    this.onPressed,
    this.enabled = true,
    this.tint,
    double size = _kDefaultSize,
    this.style = CNButtonStyle.automatic,
    this.controlSize = CNControlSize.regular,
    this.role = CNButtonRole.none,
    this.imageScale = CNImageScale.medium,
    this.symbolRenderingMode,
  }) : label = null,
       width = size,
       height = size,
       shrinkWrap = false,
       super();

  /// Control size.
  final CNControlSize controlSize;

  /// Whether the control is interactive and tappable.
  final bool enabled;

  /// Control height.
  final double? height;

  /// Optional button systemImage.
  final String? systemImage;

  /// Semantic role for the button action.
  final CNButtonRole role;

  /// Button text (null in icon mode).
  final String? label; // null in icon mode

  /// Callback when pressed.
  final VoidCallback? onPressed;

  /// If true, sizes the control to its intrinsic width.
  final bool shrinkWrap;

  /// Visual style to apply.
  final CNButtonStyle style;

  /// Accent/tint color.
  final Color? tint;

  /// Fixed width used in icon mode.
  final double? width; // fixed when icon mode

  /// Image scale for system image buttons.
  final CNImageScale imageScale;

  /// Optional symbol rendering mode for system image buttons.
  final CNSymbolRenderingMode? symbolRenderingMode;

  @override
  State<CNButton> createState() => _CNButtonState();

  /// Whether this instance has a system image.
  bool get hasSystemImage => systemImage != null;

  /// Whether this instance is configured as system image-only variant.
  bool get isSystemImageOnly => label == null && systemImage != null;
}

class _CNButtonState extends State<CNButton> {
  MethodChannel? _channel;
  Offset? _downPosition;
  double? _intrinsicHeight;
  double? _intrinsicWidth;
  CNControlSize? _lastControlSize;
  String? _lastIconName;
  bool? _lastIsDark;
  CNButtonRole? _lastRole;
  CNButtonStyle? _lastStyle;
  int? _lastTint;
  String? _lastTitle;
  CNImageScale? _lastImageScale;
  CNSymbolRenderingMode? _lastSymbolRenderingMode;
  bool _pressed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CNButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;

  Color? get _effectiveTint => widget.tint;

  String? get _iconName => widget.systemImage;

  String get _role => widget.role.name;

  void _onCreated(int id) {
    final ch = MethodChannel('CupertinoNativeButton_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _lastTint = resolveColorToArgb(_effectiveTint, context);
    _lastIsDark = _isDark;
    _lastTitle = widget.label;
    _lastIconName = _iconName;
    _lastRole = widget.role;
    _lastStyle = widget.style;
    _lastControlSize = widget.controlSize;
    _lastImageScale = widget.imageScale;
    _lastSymbolRenderingMode = widget.symbolRenderingMode;
    _requestIntrinsicSize();
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'pressed':
        if (widget.enabled && widget.onPressed != null) {
          widget.onPressed!();
        }
        break;
    }
    return null;
  }

  Future<void> _requestIntrinsicSize() async {
    final ch = _channel;
    if (ch == null) return;
    try {
      final size = await ch.invokeMethod<Map>('getIntrinsicSize');
      final w = (size?['width'] as num?)?.toDouble();
      final h = (size?['height'] as num?)?.toDouble();

      if (w != null && h != null && mounted) {
        setState(() {
          _intrinsicWidth = w;
          _intrinsicHeight = h;
        });
      }
    } catch (_) {}
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    final tint = resolveColorToArgb(_effectiveTint, context);
    final preIconName = _iconName;
    bool needsIntrinsicSize = false;

    if (_lastTint != tint && tint != null) {
      await ch.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
    if (_lastStyle != widget.style) {
      await ch.invokeMethod('setStyle', {'buttonStyle': widget.style.name});
      _lastStyle = widget.style;
      needsIntrinsicSize = true;
    }
    if (_lastRole != widget.role) {
      await ch.invokeMethod('setStyle', {'buttonRole': _role});
      _lastRole = widget.role;
    }
    if (_lastControlSize != widget.controlSize) {
      await ch.invokeMethod('setControlSize', {'controlSize': widget.controlSize.name});
      _lastControlSize = widget.controlSize;
      needsIntrinsicSize = true;
    }

    if(_lastImageScale != widget.imageScale) {
      await ch.invokeMethod('setImageScale', {'imageScale': widget.imageScale.name});
      _lastImageScale = widget.imageScale;
      needsIntrinsicSize = true;
    }

    // Enabled state
    await ch.invokeMethod('setEnabled', {'enabled': (widget.enabled && widget.onPressed != null)});
    if (_lastTitle != widget.label && widget.label != null) {
      await ch.invokeMethod('setButtonTitle', {'title': widget.label});
      _lastTitle = widget.label;
      needsIntrinsicSize = true;
    }

    if (widget.hasSystemImage) {
      final iconName = preIconName;
      final updates = <String, dynamic>{};
      if (_lastIconName != iconName && iconName != null) {
        updates['buttonIconName'] = iconName;
        _lastIconName = iconName;
        needsIntrinsicSize = true;
      }
      if (_lastImageScale != widget.imageScale) {
        updates['imageScale'] = widget.imageScale.name;
        _lastImageScale = widget.imageScale;
        needsIntrinsicSize = true;
      }

      if (_lastSymbolRenderingMode != widget.symbolRenderingMode) {
        updates['symbolRenderingMode'] = widget.symbolRenderingMode?.name;
        _lastSymbolRenderingMode = widget.symbolRenderingMode;
      }

      if (updates.isNotEmpty) {
        await ch.invokeMethod('setButtonIcon', updates);
      }
    }

    if (needsIntrinsicSize) {
      _requestIntrinsicSize();
    }
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    // Capture context-derived values before any awaits
    final isDark = _isDark;
    final tint = resolveColorToArgb(_effectiveTint, context);
    if (_lastIsDark != isDark) {
      await ch.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }
    // Also propagate theme-driven tint changes (e.g., accent color changes)
    if (_lastTint != tint && tint != null) {
      await ch.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
  }

  Future<void> _setPressed(bool pressed) async {
    final ch = _channel;
    if (ch == null) return;
    if (_pressed == pressed) return;
    _pressed = pressed;
    try {
      await ch.invokeMethod('setPressed', {'pressed': pressed});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!(defaultTargetPlatform == TargetPlatform.macOS)) {
      // Fallback Flutter implementation
      return SizedBox.shrink();
    }

    const viewType = 'CupertinoNativeButton';

    final creationParams = <String, dynamic>{
      if (widget.label != null) 'buttonTitle': widget.label,
      if (_iconName != null) 'buttonIconName': _iconName,
      'buttonRole': _role,
      'buttonStyle': widget.style.name,
      'enabled': (widget.enabled && widget.onPressed != null),
      'isDark': _isDark,
      'style': encodeStyle(context, tint: _effectiveTint),
      'controlSize': widget.controlSize.name,
      'tint': resolveColorToArgb(_effectiveTint, context),
      'imageScale': widget.imageScale.name,
      'symbolRenderingMode': widget.symbolRenderingMode?.name,
    };

    final platformView = AppKitView(
      viewType: viewType,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: _onCreated,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{Factory<TapGestureRecognizer>(() => TapGestureRecognizer())},
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth = constraints.hasBoundedWidth;
        final hasBoundedHeight = constraints.hasBoundedHeight;
        final preferIntrinsicWidth = widget.shrinkWrap || !hasBoundedWidth;
        final preferIntrinsicHeight = widget.shrinkWrap || !hasBoundedHeight;
        double? width;
        if (preferIntrinsicWidth) {
          width = _intrinsicWidth ?? _kDefaultWidth;
        } else {
          width = _intrinsicWidth;
        }
        double? height;
        if (preferIntrinsicHeight) {
          height = _intrinsicHeight ?? _kDefaultHeight;
        } else {
          height = _intrinsicHeight;
        }

        return Listener(
          onPointerDown: (e) {
            _downPosition = e.position;
            _setPressed(true);
          },
          onPointerMove: (e) {
            final start = _downPosition;
            if (start != null && _pressed) {
              final moved = (e.position - start).distance;
              if (moved > kTouchSlop) {
                _setPressed(false);
              }
            }
          },
          onPointerUp: (_) {
            _setPressed(false);
            _downPosition = null;
          },
          onPointerCancel: (_) {
            _setPressed(false);
            _downPosition = null;
          },
          child: SizedBox(width: width, height: height, child: platformView),
        );
      },
    );
  }
}
