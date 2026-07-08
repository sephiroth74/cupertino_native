// ignore_for_file: public_member_api_docs

import 'package:collection/collection.dart';
import 'package:cupertino_native/channel/params.dart';
import 'package:cupertino_native/components/widget_debug_id_mixin.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

@immutable
mixin CNWidget on Widget {
  late final BoxConstraints? constraints;
  late final Color? foregroundColor;
  late final bool shrink;
  late final Color? tint;

  Map<String, dynamic> toPayload(
    BuildContext context, {
    required Map<String, dynamic> payload,
    required BoxConstraints? constraints,
  }) {
    payload['foregroundColor'] = resolveColorToArgb(foregroundColor, context);
    payload['tint'] = resolveColorToArgb(tint, context);
    payload['shrink'] = shrink;

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
class CNTest extends StatefulWidget with CNWidget {
  CNTest({
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
  });

  final CNFont? font;
  final List<Color>? foregroundStyleColors;
  final CNSymbolColorRenderingMode? symbolColorRenderingMode;
  final CNSymbolRenderingMode? symbolRenderingMode;
  final String systemSymbolName;

  @override
  // ignore: overridden_fields
  final BoxConstraints? constraints;

  @override
  // ignore: overridden_fields
  final Color? foregroundColor;

  @override
  // ignore: overridden_fields
  final bool shrink;

  @override
  // ignore: overridden_fields
  final Color? tint;

  @override
  State<CNTest> createState() => _CNTestState();

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

class _CNTestState extends State<CNTest> with CNWidgetDebugIdMixin<CNTest> {
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
  void didUpdateWidget(covariant CNTest oldWidget) {
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

  void logDebug(String message) {
    debugPrint('$debugLogPrefix $message');
  }

  Future<void> syncPropsToNativeIfNeeded({required CNTest oldWidget}) async {
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

  Future<void> onPlatformViewCreated(int id) async {
    logDebug('onPlatformViewCreated id=$id');
    channel = MethodChannel('CupertinoNativeTest_$id');
    channel?.setMethodCallHandler(onMethodCall);
    //cacheCurrentProps();
  }

  Future<dynamic> onMethodCall(MethodCall call) async {
    logDebug('onMethodCall ${call.method} args=${call.arguments}');
    if (call.method == 'intrinsicSizeChanged') {
      final args = call.arguments as Map?;
      onIntrinsicSizeChanged((args?['width'] as num?)?.toDouble(), (args?['height'] as num?)?.toDouble());
    }
    return null;
  }

  Map<String, dynamic> toPayload({required BoxConstraints? constraints}) {
    final payload = widget.toMap(context, constraints: constraints);
    writeDebugWidgetId(payload);
    return payload;
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

  @override
  Widget build(BuildContext context) {
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
          viewType: 'CupertinoNativeTest',
          creationParams: lastPayload!,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: onPlatformViewCreated,
        );

        logDebug('build CNTest');
        logDebug(
          'constraints=$constraints, widget.constraints=${widget.constraints}, shrink=${widget.shrink}, intrinsicWidth=$intrinsicWidth, intrinsicHeight=$intrinsicHeight',
        );

        if (widget.shrink) {
          final resolvedWidth = intrinsicWidth ?? constraints.minWidth;
          final resolvedHeight = intrinsicHeight ?? constraints.minHeight;
          logDebug('shrink mode: resolvedWidth=$resolvedWidth, resolvedHeight=$resolvedHeight');
          return SizedBox(width: resolvedWidth, height: resolvedHeight, child: platformView);
        } else {
          logDebug('shrink=false mode: lastConstraints=$lastConstraints');

          double resolvedWidth = intrinsicWidth ?? lastConstraints!.tightWidth ?? lastConstraints!.maxWidth;
          double resolvedHeight = intrinsicHeight ?? lastConstraints!.tightHeight ?? lastConstraints!.maxHeight;

          logDebug('shrink=false mode: resolvedWidth=$resolvedWidth, resolvedHeight=$resolvedHeight');

          if (!resolvedWidth.isFinite) {
            resolvedWidth = 0;
          }

          if (!resolvedHeight.isFinite) {
            resolvedHeight = 0;
          }

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
