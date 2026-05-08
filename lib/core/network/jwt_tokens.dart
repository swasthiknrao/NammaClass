import 'dart:convert';

import 'package:jwt_decoder/jwt_decoder.dart';

/// Builds an unsigned JWT-shaped token for demo / dev (payload only).
String buildUnsignedJwt(Map<String, dynamic> payload) {
  final header = base64Url.encode(
    utf8.encode(jsonEncode({'alg': 'none', 'typ': 'JWT'})),
  );
  final body = base64Url.encode(utf8.encode(jsonEncode(payload)));
  return '$header.$body.';
}

Map<String, dynamic>? decodeJwtPayload(String token) {
  try {
    return JwtDecoder.decode(token);
  } catch (_) {
    return null;
  }
}

List<String> permissionsFromPayload(Map<String, dynamic> payload) {
  final raw = payload['permissions'];
  if (raw is List) {
    return raw.map((e) => e.toString()).toList();
  }
  return const [];
}
