import '../../domain/model/user_profile.dart';
import '../api/json_helpers.dart';

class AuthLoginResult {
  const AuthLoginResult({
    required this.tokens,
    this.user,
  });

  final AuthTokens tokens;
  final UserProfile? user;
}

class AuthTokens {
  const AuthTokens({
    required this.access,
    this.refresh,
  });

  final String access;
  final String? refresh;

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    final access = json['access'] as String? ?? json['token'] as String? ?? '';
    return AuthTokens(
      access: access,
      refresh: json['refresh'] as String?,
    );
  }
}

AuthLoginResult parseAuthLoginResponse(dynamic raw) {
  final map = parseEntityMap(raw);
  final tokens = AuthTokens.fromJson(map);
  final userRaw = map['user'];
  return AuthLoginResult(
    tokens: tokens,
    user: userRaw is Map ? UserProfile.fromJson(asMap(userRaw)!) : null,
  );
}
