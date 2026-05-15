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
