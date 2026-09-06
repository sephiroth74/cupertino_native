// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativeProgressView2';

class CNProgressView extends CNWidget {
  const CNProgressView({
    super.key,
    super.debugLog,
    this.value,
    this.total = 1.0,
    this.style = CNProgressViewStyle.linear,
    this.controlSize = CNControlSize.regular,
    this.shrink = true,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
    this.help,
    this.overlay,
    this.background,
  }) : assert(total > 0);

  /// Control size for the progress view.
  final CNControlSize controlSize;

  /// Progress view style (linear or circular).
  final CNProgressViewStyle style;

  /// Total value for determinate progress. Defaults to 1.0.
  final double total;

  /// Current progress value. Null means indeterminate.
  final double? value;

  @override
  final CNBackground? background;

  @override
  final BoxConstraints? constraints;

  @override
  final Color? foregroundColor;

  @override
  final String? help;

  @override
  final CNOverlay? overlay;

  @override
  final EdgeInsetsGeometry? paddings;

  @override
  final bool shrink;

  @override
  final Object? tint;

  @override
  State<CNProgressView> createState() => _CNProgressViewState();

  @override
  String get nativeViewType => _kNativeViewType;
}

class _CNProgressViewState extends CNWidgetState<CNProgressView> {
  @override
  Size computeDefaultSize() {
    if (widget.style == CNProgressViewStyle.circular) {
      final size = _circularSize();
      return Size(size, size);
    }
    return Size(double.infinity, _linearHeight());
  }

  @override
  double computeShrinkWidth({
    required BoxConstraints constraints,
    required double defaultWidth,
    double? intrinsicWidth,
  }) {
    double resolvedWidth;
    if (intrinsicWidth != null) {
      resolvedWidth = intrinsicWidth;
      logDebug('shrink mode: using intrinsicWidth');
    } else if (constraints.tightWidth != null) {
      resolvedWidth = constraints.tightWidth!;
      logDebug('shrink mode: using tightWidth from constraints');
    } else if (constraints.hasBoundedWidth) {
      resolvedWidth = constraints.maxWidth;
      logDebug('shrink mode: using maxWidth from constraints');
    } else {
      resolvedWidth = defaultWidth;
      logDebug('shrink mode: using defaultSize.width');
    }
    return resolvedWidth;
  }

  @override
  Map<String, dynamic> toWidgetPayload(
    BuildContext context, {
    required BoxConstraints? constraints,
  }) {
    final payload = <String, dynamic>{
      'style': widget.style.name,
      'controlSize': widget.controlSize.name,
      'value': widget.value,
      'total': widget.total,
    };

    widget.writeSharedFields(
      context,
      payload: payload,
      constraints: constraints,
      tintFallback: CNProgressTheme.of(context).tintColor,
    );
    return payload;
  }

  double _circularSize() {
    switch (widget.controlSize) {
      case CNControlSize.mini:
        return 10.0;
      case CNControlSize.small:
        return 16.0;
      case CNControlSize.regular:
        return 32.0;
      case CNControlSize.large:
        return 32.0;
      case CNControlSize.extraLarge:
        return 32.0;
    }
  }

  double _linearHeight() {
    switch (widget.controlSize) {
      case CNControlSize.mini:
        return 12.0;
      case CNControlSize.small:
        return 20.0;
      case CNControlSize.regular:
        return 20.0;
      case CNControlSize.large:
        return 20.0;
      case CNControlSize.extraLarge:
        return 20.0;
    }
  }
}
