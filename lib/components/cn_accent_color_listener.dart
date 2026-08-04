// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:cupertino_native/style/cn_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum CNAccentColorName {
  red,
  orange,
  yellow,
  green,
  graphite,
  blue,
  purple,
  pink,
}

/// The current system accent color with its resolved name.
class CNAccentColor {
  const CNAccentColor._(this.color, this.name);

  static const CNAccentColor blue = CNAccentColor._(
    CNColors.blue,
    CNAccentColorName.blue,
  );
  static const CNAccentColor graphite = CNAccentColor._(
    CNColors.gray,
    CNAccentColorName.graphite,
  );
  static const CNAccentColor green = CNAccentColor._(
    CNColors.green,
    CNAccentColorName.green,
  );
  static const CNAccentColor orange = CNAccentColor._(
    CNColors.orange,
    CNAccentColorName.orange,
  );
  static const CNAccentColor pink = CNAccentColor._(
    CNColors.pink,
    CNAccentColorName.pink,
  );
  static const CNAccentColor purple = CNAccentColor._(
    CNColors.purple,
    CNAccentColorName.purple,
  );
  static const CNAccentColor red = CNAccentColor._(
    CNColors.red,
    CNAccentColorName.red,
  );
  static const CNAccentColor yellow = CNAccentColor._(
    CNColors.yellow,
    CNAccentColorName.yellow,
  );

  final Color color;
  final CNAccentColorName name;
}

/// Provides synchronous access to the current macOS accent color and a stream
/// of changes.
///
/// Call [CNAccentColorListener.load] before `runApp()` to fetch the initial
/// value:
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await CNAccentColorListener.load();
///   runApp(const MyApp());
/// }
/// ```
///
/// Then use [CNAccentColorBuilder] to rebuild when the accent color changes:
///
/// ```dart
/// CNAccentColorBuilder(
///   builder: (context, accentColor) {
///     return Container(color: accentColor.accent);
///   },
/// )
/// ```
class CNAccentColorListener {
  CNAccentColorListener._();

  static CNAccentColor _accentColor = CNAccentColor.blue;
  static final StreamController<CNAccentColor> _controller =
      StreamController<CNAccentColor>.broadcast();
  static const EventChannel _eventChannel = EventChannel(
    'cupertino_native/accent_color',
  );
  static const MethodChannel _methodChannel = MethodChannel('cupertino_native');
  static StreamSubscription<dynamic>? _subscription;

  /// The current accent color (synchronous).
  ///
  /// Before [load] is called, this returns the default blue.
  static CNAccentColor get accentColor => _accentColor;

  /// Stream that emits whenever the system accent color changes.
  static Stream<CNAccentColor> get onChange => _controller.stream;

  /// Loads the current accent color from the native side and starts listening
  /// for changes.
  ///
  /// Call this once before `runApp()`. Subsequent calls are safe (no-op if
  /// already listening).
  static Future<void> load() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (defaultTargetPlatform != TargetPlatform.macOS) return;

    // Start event channel subscription (sends initial value immediately)
    _subscription ??= _eventChannel.receiveBroadcastStream().listen((event) {
      debugPrint('Accent color event: $event');
      final parsed = _parse(event);
      if (parsed != null && parsed != _accentColor) {
        _accentColor = parsed;
        _controller.add(_accentColor);
      }
    });

    // Wait for the first event to arrive so accentColor is populated
    // before runApp()
    try {
      await _controller.stream.first.timeout(const Duration(seconds: 2));
    } on TimeoutException {
      // Fallback: try method channel
      try {
        final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
          'getAccentColor',
        );
        debugPrint('Accent color method channel result: $result');
        final parsed = _parse(result);
        if (parsed != null) {
          _accentColor = parsed;
        }
      } on MissingPluginException {
        // Plugin not available, keep default
      }
    }
  }

  /// Releases resources. Usually not needed.
  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  static CNAccentColor? _parse(dynamic event) {
    if (event is! Map) return null;
    final colorInt = event['color'] as int?;
    final nameStr = (event['name'] as String?)?.toLowerCase();
    if (colorInt == null) return null;
    final color = Color(colorInt);

    final defaultValue = CNColors.accentColors.first;
    final CNAccentColor value;
    if (nameStr != null) {
      value = CNColors.accentColors.firstWhere(
        (color) => color.name.name.toLowerCase() == nameStr,
        orElse: () => defaultValue,
      );
    } else {
      value = CNColors.accentColors.firstWhere(
        (c) => c.color is CupertinoDynamicColor
            ? (c.color as CupertinoDynamicColor).color == color ||
                  (c.color as CupertinoDynamicColor).darkColor == color ||
                  (c.color as CupertinoDynamicColor).darkElevatedColor ==
                      color ||
                  (c.color as CupertinoDynamicColor).elevatedColor == color ||
                  (c.color as CupertinoDynamicColor).darkHighContrastColor ==
                      color ||
                  (c.color as CupertinoDynamicColor).highContrastColor == color
            : c.color == color,
        orElse: () => defaultValue,
      );
    }

    return value;
  }
}

/// A widget that rebuilds when the system accent color changes.
///
/// ```dart
/// CNAccentColorBuilder(
///   builder: (context, accentColor) {
///     return Text('Accent: ${accentColor.name}');
///   },
/// )
/// ```
class CNAccentColorBuilder extends StatelessWidget {
  const CNAccentColorBuilder({super.key, required this.builder});

  /// Builder called with the current accent color.
  final Widget Function(BuildContext context, CNAccentColor accentColor)
  builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CNAccentColor>(
      initialData: CNAccentColorListener.accentColor,
      stream: CNAccentColorListener.onChange,
      builder: (context, snapshot) {
        return builder(
          context,
          snapshot.data ?? CNAccentColorListener.accentColor,
        );
      },
    );
  }
}
