import 'package:cupertino_native/channel/channel_serialization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// Mixin contract for widgets that can be embedded as children of [CNButton].
mixin CNButtonChild on Widget implements CNChannelSerializable, Equatable {
  /// Native discriminator used by the Swift button deserializer.
  String get buttonChildType;
}
