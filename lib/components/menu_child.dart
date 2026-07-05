import 'package:cupertino_native/channel/channel_serialization.dart';
import 'package:equatable/equatable.dart';

/// Mixin contract for objects that can be embedded as children of [CNMenu].
mixin CNMenuChild implements CNChannelSerializable, EquatableMixin {
  /// Native discriminator used by the Swift menu deserializer.
  String get menuChildType;
}
