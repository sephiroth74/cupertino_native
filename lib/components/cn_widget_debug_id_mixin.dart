import 'package:flutter/widgets.dart';

/// Shared state mixin that assigns a unique debug ID to each CN widget instance.
mixin CNWidgetDebugIdMixin<T extends StatefulWidget> on State<T> {
  /// Generated per-widget-instance identifier used for debug correlation.
  late final String cnWidgetDebugId = _buildDebugId();

  static int _sequence = 0;
  static final int _sessionSeed = DateTime.now().microsecondsSinceEpoch;

  @protected
  /// Standard log prefix containing runtime type and [cnWidgetDebugId].
  String get debugLogPrefix => '[${widget.runtimeType}:$cnWidgetDebugId]';

  @protected
  /// Writes [cnWidgetDebugId] into outgoing channel payloads.
  void writeDebugWidgetId(Map<String, dynamic> payload) {
    payload['debugWidgetId'] = cnWidgetDebugId;
  }

  String _buildDebugId() {
    final next = _sequence++;
    return '${widget.runtimeType}-${_sessionSeed.toRadixString(16)}-${next.toRadixString(16)}';
  }
}
