import '../../domain/model/user_profile.dart';
import '../../../core/network/api_response_parser.dart';

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
    final access = json['access']?.toString() ?? json['token']?.toString() ?? '';
    return AuthTokens(
      access: access,
      refresh: json['refresh']?.toString(),
    );
  }
}

AuthLoginResult parseAuthLoginResponse(dynamic raw) {
  final map = parseEntityMap(raw);
  final tokens = AuthTokens.fromJson(map);
  final userRaw = map['user'];
  UserProfile? user;
  if (userRaw is Map) {
    final userMap = Map<String, dynamic>.from(userRaw);
    final tenantRaw = map['tenant'];
    if (tenantRaw is Map && userMap['tenant'] == null) {
      userMap['tenant'] = tenantRaw;
    }
    user = UserProfile.fromJson(userMap);
  }
  return AuthLoginResult(tokens: tokens, user: user);
}
