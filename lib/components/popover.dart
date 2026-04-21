import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

import '../channel/params.dart';
import '../style/button_style.dart';
import '../style/sf_symbol.dart';

/// A selectable action shown in a [CNPopoverButton].
class CNPopoverAction {
  /// Creates a popover action.
  const CNPopoverAction({
    required this.label,
    this.enabled = true,
    this.isDefault = false,
    this.isDestructive = false,
  });

  /// Visible label.
  final String label;

  /// Whether the action can be pressed.
  final bool enabled;

  /// Whether the action is the default one.
  final bool isDefault;

  /// Whether the action is destructive.
  final bool isDestructive;
}

/// Native popover behavior on macOS.
enum CNPopoverBehavior {
  /// Closes when the user interacts outside the popover.
  transient,

  /// Stays open for some interactions outside the popover.
  semitransient,

  /// Leaves closing behavior entirely to the app.
  applicationDefined,
}

/// Preferred edge for the popover anchor.
enum CNPopoverEdge {
  /// Show above the anchor.
  top,

  /// Show below the anchor.
  bottom,

  /// Show on the leading side of the anchor.
  left,

  /// Show on the trailing side of the anchor.
  right,
}

/// A native macOS popover attached to a button or custom trigger view.
class CNPopoverButton extends StatefulWidget {
  /// Creates a popover button with a custom child trigger.
  const CNPopoverButton({
    super.key,
    required this.child,
    required this.message,
    required this.actions,
    required this.onSelected,
    this.title,
    this.tint,
    this.behavior = CNPopoverBehavior.transient,
    this.preferredEdge = CNPopoverEdge.bottom,
    this.popoverWidth = 280,
  }) : buttonLabel = null,
       buttonIcon = null,
       width = null,
       round = false,
       height = null,
       shrinkWrap = false,
       buttonStyle = CNButtonStyle.plain;

  /// Creates a text-labeled popover button.
  const CNPopoverButton.label({
    super.key,
    required this.buttonLabel,
    required this.message,
    required this.actions,
    required this.onSelected,
    this.title,
    this.tint,
    this.height = 32,
    this.shrinkWrap = false,
    this.buttonStyle = CNButtonStyle.plain,
    this.behavior = CNPopoverBehavior.transient,
    this.preferredEdge = CNPopoverEdge.bottom,
    this.popoverWidth = 280,
  }) : child = null,
       buttonIcon = null,
       width = null,
       round = false;

  /// Creates a round icon-only popover button.
  const CNPopoverButton.icon({
    super.key,
    required this.buttonIcon,
    required this.message,
    required this.actions,
    required this.onSelected,
    this.title,
    this.tint,
    this.behavior = CNPopoverBehavior.transient,
    this.preferredEdge = CNPopoverEdge.bottom,
    this.popoverWidth = 280,
    double size = 44,
    this.buttonStyle = CNButtonStyle.glass,
  }) : child = null,
       buttonLabel = null,
       round = true,
       width = size,
       height = size,
       shrinkWrap = false,
       super();

  /// Optional custom trigger child.
  final Widget? child;

  /// Optional button label for text mode.
  final String? buttonLabel;

  /// Optional button icon for icon mode.
  final CNSymbol? buttonIcon;

  /// Optional popover title.
  final String? title;

  /// Required popover message.
  final String message;

  /// Available actions in the popover.
  final List<CNPopoverAction> actions;

  /// Callback invoked with the selected action index.
  final ValueChanged<int> onSelected;

  /// Optional tint color for the trigger.
  final Color? tint;

  /// Popover behavior.
  final CNPopoverBehavior behavior;

  /// Preferred edge of the trigger.
  final CNPopoverEdge preferredEdge;

  /// Desired popover content width.
  final double popoverWidth;

  /// Fixed width in icon mode.
  final double? width;

  /// Whether the icon variant is round.
  final bool round;

  /// Trigger height.
  final double? height;

  /// If true, uses intrinsic width for text mode.
  final bool shrinkWrap;

  /// Visual style to apply to the trigger.
  final CNButtonStyle buttonStyle;

  /// Whether this instance is configured as an icon button variant.
  bool get isIconButton => buttonIcon != null;

  /// Whether this instance uses a custom child widget.
  bool get hasChild => child != null;

  @override
  State<CNPopoverButton> createState() => _CNPopoverButtonState();
}

class _CNPopoverButtonState extends State<CNPopoverButton> {
  MethodChannel? _channel;
  bool? _lastIsDark;
  int? _lastTint;
  String? _lastButtonTitle;
  String? _lastTitle;
  String? _lastMessage;
  String? _lastActionsSignature;
  double? _lastPopoverWidth;
  String? _lastIconName;
  double? _lastIconSize;
  int? _lastIconColor;
  CNButtonStyle? _lastStyle;
  CNPopoverBehavior? _lastBehavior;
  CNPopoverEdge? _lastPreferredEdge;
  double? _intrinsicWidth;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;
  Color? get _effectiveTint =>
      widget.tint ?? CupertinoTheme.of(context).primaryColor;

  @override
  void didUpdateWidget(covariant CNPopoverButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPropsToNativeIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.macOS) {
      return _buildFallback(context);
    }

    const viewType = 'CupertinoNativePopover';
    final creationParams = <String, dynamic>{
      if (widget.hasChild) 'transparentOverlay': true,
      if (widget.buttonLabel != null) 'buttonTitle': widget.buttonLabel,
      if (widget.buttonIcon != null) 'buttonIconName': widget.buttonIcon!.name,
      if (widget.buttonIcon?.size != null)
        'buttonIconSize': widget.buttonIcon!.size,
      if (widget.buttonIcon?.color != null)
        'buttonIconColor': resolveColorToArgb(
          widget.buttonIcon!.color,
          context,
        ),
      if (widget.buttonIcon?.mode != null)
        'buttonIconRenderingMode': widget.buttonIcon!.mode!.name,
      if (widget.buttonIcon?.paletteColors != null)
        'buttonIconPaletteColors': widget.buttonIcon!.paletteColors!
            .map((c) => resolveColorToArgb(c, context))
            .toList(),
      if (widget.buttonIcon?.gradient != null)
        'buttonIconGradientEnabled': widget.buttonIcon!.gradient,
      if (widget.isIconButton) 'round': true,
      'buttonStyle': widget.buttonStyle.name,
      'isDark': _isDark,
      'behavior': widget.behavior.name,
      'preferredEdge': widget.preferredEdge.name,
      'popoverWidth': widget.popoverWidth,
      'popoverTitle': widget.title,
      'popoverMessage': widget.message,
      'actions': [
        for (final action in widget.actions)
          {
            'label': action.label,
            'enabled': action.enabled,
            'isDefault': action.isDefault,
            'isDestructive': action.isDestructive,
          },
      ],
      'style': encodeStyle(context, tint: _effectiveTint),
    };

    final platformView = AppKitView(
      viewType: viewType,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: _onCreated,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
      },
    );

    if (widget.hasChild) {
      return Stack(
        children: [
          widget.child!,
          Positioned.fill(child: platformView),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final preferIntrinsic =
            widget.shrinkWrap || !constraints.hasBoundedWidth;
        double? width;
        if (widget.isIconButton) {
          width = widget.width ?? widget.height;
        } else if (preferIntrinsic) {
          width = _intrinsicWidth ?? 100;
        }

        return SizedBox(
          height: widget.height,
          width: width,
          child: platformView,
        );
      },
    );
  }

  Widget _buildFallback(BuildContext context) {
    Future<void> showFallback() async {
      final selected = await showCupertinoModalPopup<int>(
        context: context,
        builder: (ctx) {
          return CupertinoActionSheet(
            title: widget.title == null ? null : Text(widget.title!),
            message: Text(widget.message),
            actions: [
              for (var index = 0; index < widget.actions.length; index++)
                CupertinoActionSheetAction(
                  onPressed: () {
                    if (!widget.actions[index].enabled) return;
                    Navigator.of(ctx).pop(index);
                  },
                  isDefaultAction: widget.actions[index].isDefault,
                  isDestructiveAction: widget.actions[index].isDestructive,
                  child: Text(widget.actions[index].label),
                ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
          );
        },
      );
      if (selected != null) {
        widget.onSelected(selected);
      }
    }

    if (widget.hasChild) {
      return GestureDetector(onTap: showFallback, child: widget.child);
    }

    return SizedBox(
      height: widget.height,
      width: widget.isIconButton && widget.round
          ? (widget.width ?? widget.height)
          : null,
      child: CupertinoButton(
        padding: widget.isIconButton
            ? const EdgeInsets.all(4)
            : const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        onPressed: showFallback,
        child: widget.isIconButton
            ? Icon(CupertinoIcons.info, size: widget.buttonIcon?.size)
            : Text(widget.buttonLabel ?? ''),
      ),
    );
  }

  void _onCreated(int id) {
    final ch = MethodChannel('CupertinoNativePopover_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _lastTint = resolveColorToArgb(_effectiveTint, context);
    _lastIsDark = _isDark;
    _lastButtonTitle = widget.buttonLabel;
    _lastTitle = widget.title;
    _lastMessage = widget.message;
    _lastActionsSignature = _actionsSignature;
    _lastPopoverWidth = widget.popoverWidth;
    _lastIconName = widget.buttonIcon?.name;
    _lastIconSize = widget.buttonIcon?.size;
    _lastIconColor = resolveColorToArgb(widget.buttonIcon?.color, context);
    _lastStyle = widget.buttonStyle;
    _lastBehavior = widget.behavior;
    _lastPreferredEdge = widget.preferredEdge;
    if (!widget.isIconButton && !widget.hasChild) {
      _requestIntrinsicSize();
    }
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'actionSelected') {
      final args = call.arguments as Map?;
      final index = (args?['index'] as num?)?.toInt();
      if (index != null) {
        widget.onSelected(index);
      }
    }
    return null;
  }

  Future<void> _syncPropsToNativeIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;

    final tint = resolveColorToArgb(_effectiveTint, context);
    if (_lastTint != tint && tint != null) {
      await ch.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
    if (_lastStyle != widget.buttonStyle) {
      await ch.invokeMethod('setStyle', {
        'buttonStyle': widget.buttonStyle.name,
      });
      _lastStyle = widget.buttonStyle;
    }
    if (_lastTitle != widget.title ||
        _lastMessage != widget.message ||
        _lastActionsSignature != _actionsSignature ||
        _lastPopoverWidth != widget.popoverWidth) {
      await ch.invokeMethod('setPopoverContent', {
        'title': widget.title,
        'message': widget.message,
        'actions': [
          for (final action in widget.actions)
            {
              'label': action.label,
              'enabled': action.enabled,
              'isDefault': action.isDefault,
              'isDestructive': action.isDestructive,
            },
        ],
        'popoverWidth': widget.popoverWidth,
      });
      _lastTitle = widget.title;
      _lastMessage = widget.message;
      _lastActionsSignature = _actionsSignature;
      _lastPopoverWidth = widget.popoverWidth;
    }
    if (_lastBehavior != widget.behavior ||
        _lastPreferredEdge != widget.preferredEdge) {
      await ch.invokeMethod('setPopoverBehavior', {
        'behavior': widget.behavior.name,
        'preferredEdge': widget.preferredEdge.name,
      });
      _lastBehavior = widget.behavior;
      _lastPreferredEdge = widget.preferredEdge;
    }
    if (!mounted) return;
    if (_lastIconName != widget.buttonIcon?.name ||
        _lastIconSize != widget.buttonIcon?.size ||
        _lastIconColor !=
            resolveColorToArgb(widget.buttonIcon?.color, context)) {
      await ch.invokeMethod('setButtonIcon', {
        'buttonIconName': widget.buttonIcon?.name,
        'buttonIconSize': widget.buttonIcon?.size,
        'buttonIconColor': resolveColorToArgb(
          widget.buttonIcon?.color,
          context,
        ),
        'buttonIconRenderingMode': widget.buttonIcon?.mode?.name,
        'buttonIconPaletteColors': widget.buttonIcon?.paletteColors
            ?.map((c) => resolveColorToArgb(c, context))
            .toList(),
        'buttonIconGradientEnabled': widget.buttonIcon?.gradient,
        if (widget.isIconButton) 'round': true,
      });

      if (!mounted) return;
      _lastIconName = widget.buttonIcon?.name;
      _lastIconSize = widget.buttonIcon?.size;
      _lastIconColor = resolveColorToArgb(widget.buttonIcon?.color, context);
    }

    if (!mounted) return;
    if (_lastButtonTitle != widget.buttonLabel &&
        widget.buttonLabel != null &&
        !widget.hasChild) {
      await ch.invokeMethod('setButtonTitle', {'title': widget.buttonLabel});
      _lastButtonTitle = widget.buttonLabel;
      _requestIntrinsicSize();
    }
  }

  String get _actionsSignature => widget.actions
      .map(
        (action) =>
            '${action.label}|${action.enabled}|${action.isDefault}|${action.isDestructive}',
      )
      .join('||');

  Future<void> _syncBrightnessIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;
    final isDark = _isDark;
    if (_lastIsDark != isDark) {
      await ch.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }
  }

  Future<void> _requestIntrinsicSize() async {
    final ch = _channel;
    if (ch == null) return;
    try {
      final size = await ch.invokeMethod<Map>('getIntrinsicSize');
      final width = (size?['width'] as num?)?.toDouble();
      if (width != null && mounted) {
        setState(() => _intrinsicWidth = width);
      }
    } catch (_) {}
  }
}
