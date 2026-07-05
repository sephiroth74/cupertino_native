import 'view_modifiable.dart';

/// Returns true when [value] can be serialized as a native SwiftUI tag.
bool isValidCNTagValue(Object? value) => value is int || value is String;

/// Allowed SwiftUI tag values supported by the plugin bridge.
typedef CNTagValue = Object;

/// Common contract for widgets that can carry a SwiftUI `.tag(...)` value.
mixin CNTaggable on CNViewModifiable {
  /// Optional SwiftUI tag value.
  @override
  CNTagValue? get tag;

  /// Adds `tag` to a channel payload map when present.
  void writeTag(Map<String, dynamic> payload) {
    final value = tag ?? viewModifiers?.tag;
    if (value != null) {
      payload['tag'] = value;
    }
  }
}
