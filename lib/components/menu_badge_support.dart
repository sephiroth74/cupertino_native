// ignore: public_member_api_docs
Map<String, dynamic>? serializeMenuBadge(Object? badge) {
  if (badge == null) {
    return null;
  }

  if (badge is int) {
    return {'type': 'value', 'payload': badge};
  }

  if (badge is String) {
    return {'type': 'text', 'payload': badge};
  }

  throw ArgumentError.value(badge, 'badge', 'Expected a String or int badge value');
}
