import 'package:flutter/widgets.dart';

/// Contract for channel payload objects that need BuildContext to serialize.
abstract class CNChannelSerializable {
  /// Converts this object to a channel-safe map payload.
  Map<String, dynamic> toChannelMap(BuildContext context, {bool ignoreTheme = false});
}

/// Centralized helpers for serializing/deserializing channel payloads.
class CNChannelSerialization {
  /// Casts a dynamic value to a typed map when possible.
  static Map<String, dynamic>? asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  /// Casts a dynamic list to a list of typed maps when possible.
  static List<Map<String, dynamic>> asMapList(dynamic value) {
    if (value is! List) return const [];
    return value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Serializes an optional object implementing [CNChannelSerializable].
  static Map<String, dynamic>? object(CNChannelSerializable? value, BuildContext context, {bool ignoreTheme = false}) {
    return value?.toChannelMap(context, ignoreTheme: ignoreTheme);
  }

  /// Serializes a list of [CNChannelSerializable] objects.
  static List<Map<String, dynamic>> objects(Iterable<CNChannelSerializable> values, BuildContext context, {bool ignoreTheme = false}) {
    return values.map((e) => e.toChannelMap(context, ignoreTheme: ignoreTheme)).toList();
  }
}
