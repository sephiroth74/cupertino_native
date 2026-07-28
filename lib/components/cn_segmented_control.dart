// ignore_for_file: public_member_api_docs

import 'package:cupertino_native/components/cn_widget.dart';
import 'package:cupertino_native/components/cn_widget_state.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _kNativeViewType = 'CupertinoNativeSegmentedControl';

/// The visual style of an NSSegmentedControl.
enum CNSegmentStyle {
  /// The system decides the best style based on context.
  automatic,

  /// Rounded segment style (default on modern macOS).
  rounded,

  /// Textured rounded style.
  texturedRounded,

  /// Capsule-shaped segments.
  capsule,

  /// Textured square style.
  texturedSquare,

  /// Separated segments (each segment is visually distinct).
  separated,
}

/// The tracking mode of an NSSegmentedControl.
enum CNSegmentTrackingMode {
  /// Only one segment can be selected at a time.
  selectOne,

  /// Multiple segments can be selected simultaneously.
  selectAny,

  /// Segments act as momentary push buttons.
  momentary,
}

/// The segment distribution strategy.
enum CNSegmentDistribution {
  /// Segments fill the available space.
  fill,

  /// Segments are sized to fit their content.
  fit,

  /// All segments are sized equally.
  fillEqually,

  /// Segments are sized proportionally to their content.
  fillProportionally,
}

/// A segment item within a [CNSegmentedControl].
class CNSegment {
  const CNSegment({
    this.label,
    this.systemImage,
    this.tag,
    this.enabled = true,
  }) : assert(label != null || systemImage != null, 'A segment must have a label or a systemImage');

  /// Whether this segment is individually enabled.
  final bool enabled;

  /// The text label for this segment.
  final String? label;

  /// An SF Symbol name to display in this segment.
  final String? systemImage;

  /// An optional tag to identify this segment in callbacks.
  final String? tag;

  Map<String, dynamic> toMap() => {
        'label': label,
        'systemImage': systemImage,
        'tag': tag,
        'enabled': enabled,
      };
}

/// A native macOS segmented control backed by NSSegmentedControl.
///
/// Displays a horizontal set of segments, each of which can have a label
/// and/or an SF Symbol image. Supports single selection, multi-selection,
/// and momentary (push-button) modes.
class CNSegmentedControl extends CNWidget {
  const CNSegmentedControl({
    super.key,
    super.debugLog,
    required this.segments,
    this.selectedIndex = 0,
    this.selectedIndices = const {},
    this.segmentStyle = CNSegmentStyle.automatic,
    this.trackingMode = CNSegmentTrackingMode.selectOne,
    this.segmentDistribution = CNSegmentDistribution.fit,
    this.controlSize = CNControlSize.regular,
    this.enabled = true,
    this.onChanged,
    this.onSelectAnyChanged,
    this.shrink = true,
    this.constraints,
    this.tint,
    this.foregroundColor,
    this.paddings,
    this.help,
  });

  /// The size of the native AppKit control.
  final CNControlSize controlSize;

  /// Whether the control is enabled.
  final bool enabled;

  /// Called when a segment is selected (for [CNSegmentTrackingMode.selectOne]
  /// and [CNSegmentTrackingMode.momentary] modes).
  /// The argument is the index of the selected segment.
  final ValueChanged<int>? onChanged;

  /// Called when selections change in [CNSegmentTrackingMode.selectAny] mode.
  /// The argument is the set of currently selected segment indices.
  final ValueChanged<Set<int>>? onSelectAnyChanged;

  /// The segment distribution strategy.
  final CNSegmentDistribution segmentDistribution;

  /// The visual style of the segmented control.
  final CNSegmentStyle segmentStyle;

  /// The segments to display.
  final List<CNSegment> segments;

  /// The currently selected segment index (for [CNSegmentTrackingMode.selectOne]).
  /// Use -1 for no selection.
  final int selectedIndex;

  /// The set of selected segment indices (for [CNSegmentTrackingMode.selectAny]).
  final Set<int> selectedIndices;

  /// The tracking mode determining selection behavior.
  final CNSegmentTrackingMode trackingMode;

  @override
  final BoxConstraints? constraints;

  @override
  final Color? foregroundColor;

  @override
  final String? help;

  @override
  final EdgeInsetsGeometry? paddings;

  @override
  final bool shrink;

  @override
  final Object? tint;

  @override
  State<CNSegmentedControl> createState() => _CNSegmentedControlState();

  @override
  String get nativeViewType => _kNativeViewType;
}

class _CNSegmentedControlState extends CNWidgetState<CNSegmentedControl> {
  @override
  Size computeDefaultSize() => const Size(200, 24);

  @override
  Future<dynamic> onNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'selectionChanged':
        final index = call.arguments as int? ?? -1;
        logDebug('selectionChanged: $index');
        widget.onChanged?.call(index);
      case 'selectAnyChanged':
        final indices = (call.arguments as List<dynamic>?)?.cast<int>().toSet() ?? <int>{};
        logDebug('selectAnyChanged: $indices');
        widget.onSelectAnyChanged?.call(indices);
    }
    return null;
  }

  @override
  Map<String, dynamic> toWidgetPayload(
    BuildContext context, {
    required BoxConstraints? constraints,
  }) {
    final payload = <String, dynamic>{
      'segments': widget.segments.map((s) => s.toMap()).toList(),
      'selectedIndex': widget.selectedIndex,
      'selectedIndices': widget.selectedIndices.toList(),
      'segmentStyle': widget.segmentStyle.name,
      'trackingMode': widget.trackingMode.name,
      'segmentDistribution': widget.segmentDistribution.name,
      'controlSize': widget.controlSize.name,
      'enabled': widget.enabled,
    };

    widget.writeSharedFields(context, payload: payload, constraints: constraints);
    return payload;
  }
}
