import 'package:collection/collection.dart';
import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/components/cn_widget_debug_id_mixin.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativeImage2';

@immutable
/// Base class for SwiftUI native macOS image widgets.
mixin CNWidget on Widget {
  /// Optional constraints to apply to the widget. If null, the image will size itself to its intrinsic size.
  late final BoxConstraints? constraints;

  /// The foreground color to apply to the widget. If null, the image will be rendered with its original colors.
  late final Color? foregroundColor;

  /// Native view type to use for the widget for the SwiftUI native macOS view. This is used to register the view with the Flutter platform view system.
  late final String? nativeViewType;

  /// Optional paddings to apply to the widget. If null, the image will size itself to its intrinsic size.
  late final EdgeInsetsGeometry? paddings;

  /// Whether the widget should shrink to fit its content. If true, the widget will size itself to the intrinsic size of the image. If false, the widget will expand to fill its parent constraints.
  late final bool shrink;

  /// The tint color to apply to the widget. If null, the image will be rendered with its original colors.
  late final Color? tint;

  /// Converts the widget to a payload map for sending to the native SwiftUI view.
  Map<String, dynamic> toPayload(
    BuildContext context, {
    required Map<String, dynamic> payload,
    required BoxConstraints? constraints,
  }) {
    payload['foregroundColor'] = resolveColorToArgb(foregroundColor, context);
    payload['tint'] = resolveColorToArgb(tint, context);
    payload['shrink'] = shrink;

    if (paddings != null) {
      final resolvedPadding = paddings!.resolve(Directionality.of(context));
      payload['paddings'] = {
        'top': resolvedPadding.top,
        'leading': resolvedPadding.left,
        'bottom': resolvedPadding.bottom,
        'trailing': resolvedPadding.right,
      };
    }

    if (constraints != null) {
      payload['constraints'] = {
        'minWidth': constraints.minWidth.isNaN ? null : (constraints.minWidth.isFinite ? constraints.minWidth : "infinity"),
        'maxWidth': constraints.maxWidth.isNaN ? null : (constraints.maxWidth.isFinite ? constraints.maxWidth : "infinity"),
        'minHeight': constraints.minHeight.isNaN ? null : (constraints.minHeight.isFinite ? constraints.minHeight : "infinity"),
        'maxHeight': constraints.maxHeight.isNaN ? null : (constraints.maxHeight.isFinite ? constraints.maxHeight : "infinity"),
      };
    }
    return payload;
  }
}

@immutable
/// A SwiftUI Image-backed native macOS image widget.
class CNImage2 extends StatefulWidget with CNWidget {
  /// Creates a new image widget.
  CNImage2({
    super.key,
    required this.systemSymbolName,
    this.shrink = false,
    this.constraints,
    this.font,
    this.foregroundColor,
    this.tint,
    this.symbolRenderingMode,
    this.symbolColorRenderingMode,
    this.foregroundStyleColors,
    this.paddings,
  });

  /// Optional font to apply to the image. If null, the image will be rendered with its original size.
  final CNFont? font;

  /// Optional list of colors to apply to the image's foreground style. If null, the image will be rendered with its original colors.
  final List<Color>? foregroundStyleColors;

  /// Optional SwiftUI symbol color rendering mode.
  final CNSymbolColorRenderingMode? symbolColorRenderingMode;

  /// Optional SwiftUI symbol rendering mode.
  final CNSymbolRenderingMode? symbolRenderingMode;

  /// The name of the system symbol to display. This should be a valid SF Symbols name.
  final String systemSymbolName;

  /// Optional constraints to apply to the image. If null, the image will size itself to its intrinsic size.
  /// If shrink is true, the image will size itself to its intrinsic size regardless of the constraints.
  @override
  // ignore: overridden_fields
  final BoxConstraints? constraints;

  /// The foreground color to apply to the image. If null, the image will be rendered with its original colors.
  @override
  // ignore: overridden_fields
  final Color? foregroundColor;

  @override
  // ignore: overridden_fields
  final EdgeInsetsGeometry? paddings;

  /// Whether the widget should shrink to fit its content. If true, the widget will size itself to the intrinsic size of the image. If false, the widget will expand to fill its parent constraints.
  @override
  // ignore: overridden_fields
  final bool shrink;

  /// The tint color to apply to the image. If null, the image will be rendered with its original colors.
  @override
  // ignore: overridden_fields
  final Color? tint;

  @override
  State<CNImage2> createState() => _CNImage2State();

  /// Native swift view type
  @override
  String get nativeViewType => _kNativeViewType;

  Map<String, dynamic> toMap(BuildContext context, {BoxConstraints? constraints}) {
    final payload = <String, dynamic>{'systemSymbolName': systemSymbolName};
    payload['font'] = font?.toMap();
    payload['symbolRenderingMode'] = symbolRenderingMode?.name;
    payload['symbolColorRenderingMode'] = symbolColorRenderingMode?.name;
    payload['foregroundStyleColors'] = foregroundStyleColors?.map((c) => resolveColorToArgb(c, context)).toList();

    toPayload(context, payload: payload, constraints: constraints);
    return payload;
  }
}

class _CNImage2State extends State<CNImage2> with CNWidgetDebugIdMixin<CNImage2> {
  MethodChannel? channel;
  double? intrinsicHeight;
  double? intrinsicWidth;
  BoxConstraints? lastConstraints;
  Map<String, dynamic>? lastPayload;

  @override
  void didChangeDependencies() {
    logDebug('didChangeDependencies');
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant CNImage2 oldWidget) {
    logDebug('didUpdateWidget');
    super.didUpdateWidget(oldWidget);
    syncPropsToNativeIfNeeded(oldWidget: oldWidget);
  }

  @override
  void dispose() {
    channel?.setMethodCallHandler(null);
    channel = null;
    super.dispose();
  }

  Size computeDefaultSize() {
    final double fontSize;
    if (widget.font != null) {
      if (widget.font!.size.points != null) {
        fontSize = widget.font!.size.points! + 4;
      } else if (widget.font!.size.preset != null) {
        switch (widget.font!.size.preset!) {
          case CNFontSizePreset.system:
            fontSize = 18;
            break;
          case CNFontSizePreset.smallSystem:
            fontSize = 15;
            break;
          case CNFontSizePreset.label:
            fontSize = 14;
            break;
        }
      } else {
        fontSize = 36;
      }
    } else {
      fontSize = 36;
    }

    final double defaultWidth = fontSize + (widget.paddings?.horizontal ?? 0);
    final double defaultHeight = fontSize + (widget.paddings?.vertical ?? 0);

    return Size(defaultWidth, defaultHeight);
  }

  Map<String, dynamic> computePatch(Map<String, dynamic> oldMap, Map<String, dynamic> newMap) {
    final patch = <String, dynamic>{};

    if (newMap['shrink'] != oldMap['shrink']) {
      patch['shrink'] = newMap['shrink'];
    }

    if (newMap['foregroundColor'] != oldMap['foregroundColor']) {
      patch['foregroundColor'] = newMap['foregroundColor'];
    }

    if (newMap['tint'] != oldMap['tint']) {
      patch['tint'] = newMap['tint'];
    }

    if (!mapEquals(newMap['constraints'], oldMap['constraints'])) {
      patch['constraints'] = newMap['constraints'];
    }

    if (!mapEquals(newMap['paddings'], oldMap['paddings'])) {
      patch['paddings'] = newMap['paddings'];
    }

    if (!DeepCollectionEquality().equals(newMap['font'], oldMap['font'])) {
      patch['font'] = newMap['font'];
    }

    if (newMap['systemSymbolName'] != oldMap['systemSymbolName']) {
      patch['systemSymbolName'] = newMap['systemSymbolName'];
    }

    if (newMap['symbolRenderingMode'] != oldMap['symbolRenderingMode']) {
      patch['symbolRenderingMode'] = newMap['symbolRenderingMode'];
    }

    if (newMap['symbolColorRenderingMode'] != oldMap['symbolColorRenderingMode']) {
      patch['symbolColorRenderingMode'] = newMap['symbolColorRenderingMode'];
    }

    if (!ListEquality().equals(newMap['foregroundStyleColors'], oldMap['foregroundStyleColors'])) {
      patch['foregroundStyleColors'] = newMap['foregroundStyleColors'];
    }

    return patch;
  }

  void logDebug(String message) {
    debugPrint('$debugLogPrefix $message');
  }

  void onIntrinsicSizeChanged(double? width, double? height) {
    logDebug('received intrinsic size change: width=$width, height=$height');
    if (!mounted || width == null || height == null) return;

    final normalizedWidth = width > 0 ? width : null;
    final normalizedHeight = height > 0 ? height : null;
    if (normalizedWidth == intrinsicWidth && normalizedHeight == intrinsicHeight) {
      return;
    }

    setState(() {
      intrinsicWidth = normalizedWidth;
      intrinsicHeight = normalizedHeight;
    });
  }

  Future<dynamic> onMethodCall(MethodCall call) async {
    logDebug('onMethodCall ${call.method} args=${call.arguments}');
    if (call.method == 'intrinsicSizeChanged') {
      final args = call.arguments as Map?;
      onIntrinsicSizeChanged((args?['width'] as num?)?.toDouble(), (args?['height'] as num?)?.toDouble());
    }
    return null;
  }

  Future<void> onPlatformViewCreated(int id) async {
    logDebug('onPlatformViewCreated id=$id');
    channel = MethodChannel('${widget.nativeViewType}_$id');
    channel?.setMethodCallHandler(onMethodCall);
    //cacheCurrentProps();
  }

  Future<void> syncPropsToNativeIfNeeded({required CNImage2 oldWidget}) async {
    logDebug('syncPropsToNativeIfNeeded');

    if (channel == null) return;
    if (lastPayload == null) return;

    // requires a full rebuild if shrink is changed
    if (oldWidget.shrink != widget.shrink) {
      logDebug('shrink changed, requires full rebuild');
      lastPayload = toPayload(constraints: lastConstraints);
      await channel?.invokeMethod('setData', lastPayload);
      return;
    }

    final patch = toPayload(constraints: lastConstraints);

    // compare with last payload to avoid unnecessary updates
    // compute the difference between the last payload and the new payload
    final diff = computePatch(lastPayload!, patch);
    if (diff.isEmpty) {
      logDebug('no changes detected, skipping update');
      return;
    } else {
      logDebug('changes detected, sending patch: $diff');
      await channel?.invokeMethod('applyPatch', diff);
    }
    lastPayload = patch;
  }

  Map<String, dynamic> toPayload({required BoxConstraints? constraints}) {
    final payload = widget.toMap(context, constraints: constraints);
    writeDebugWidgetId(payload);
    return payload;
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.macOS) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        lastConstraints = !widget.shrink && widget.constraints != null
            ? BoxConstraints(
                minWidth: constraints.minWidth > widget.constraints!.minWidth ? constraints.minWidth : widget.constraints!.minWidth,
                maxWidth: constraints.maxWidth < widget.constraints!.maxWidth ? constraints.maxWidth : widget.constraints!.maxWidth,
                minHeight: constraints.minHeight > widget.constraints!.minHeight
                    ? constraints.minHeight
                    : widget.constraints!.minHeight,
                maxHeight: constraints.maxHeight < widget.constraints!.maxHeight
                    ? constraints.maxHeight
                    : widget.constraints!.maxHeight,
              )
            : constraints;

        lastPayload = toPayload(constraints: lastConstraints);

        Widget platformView = AppKitView(
          viewType: widget.nativeViewType,
          creationParams: lastPayload!,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: onPlatformViewCreated,
        );

        logDebug('build CNTest');
        logDebug(
          'constraints=$constraints, widget.constraints=${widget.constraints}, shrink=${widget.shrink}, intrinsicWidth=$intrinsicWidth, intrinsicHeight=$intrinsicHeight',
        );

        if (widget.shrink) {
          final defaultSize = computeDefaultSize();
          final resolvedWidth = intrinsicWidth ?? constraints.tightWidth ?? defaultSize.width;
          final resolvedHeight = intrinsicHeight ?? constraints.tightHeight ?? defaultSize.height;
          logDebug('shrink mode: resolvedWidth=$resolvedWidth, resolvedHeight=$resolvedHeight');
          return SizedBox(width: resolvedWidth, height: resolvedHeight, child: platformView);
        } else {
          logDebug('shrink=false mode: lastConstraints=$lastConstraints');

          double resolvedWidth = lastConstraints!.tightWidth ?? lastConstraints!.maxWidth;
          double resolvedHeight = lastConstraints!.tightHeight ?? lastConstraints!.maxHeight;

          logDebug('shrink=false mode: resolvedWidth=$resolvedWidth, resolvedHeight=$resolvedHeight');

          assert(
            resolvedWidth.isFinite && resolvedHeight.isFinite,
            'Resolved width and height must be finite when shrink is false.',
          );

          return ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: resolvedWidth,
              maxWidth: resolvedWidth,
              minHeight: resolvedHeight,
              maxHeight: resolvedHeight,
            ),
            child: platformView,
          );
        }
      },
    );
  }
}
