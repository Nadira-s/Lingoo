import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/api_exception.dart';
import '../api/business_api_client.dart';
import 'token_storage.dart';
import '../../domain/model/user_profile.dart';
import '../../network_providers.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(businessApiProvider),
    ref.watch(tokenStorageProvider),
  );
});

class AuthRepository {
  AuthRepository(this._api, this._tokens);

  final BusinessApiClient _api;
  final TokenStorage _tokens;

  Future<UserProfile> login(String username, String password) async {
    await _tokens.clear();
    final result = await _api.login(username: username, password: password);
    if (result.tokens.access.isEmpty) {
      throw ApiException(userMessage: 'Некорректный ответ при входе.');
    }
    await _tokens.writeTokens(
      access: result.tokens.access,
      refresh: result.tokens.refresh,
    );
    if (result.user != null) return result.user!;
    return _api.fetchCurrentUser();
  }

  Future<UserProfile?> restoreSession() async {
    final access = await _tokens.readAccessToken();
    if (access == null || access.isEmpty) return null;
    try {
      return await _api.fetchCurrentUser();
    } catch (_) {
      final refresh = await _tokens.readRefreshToken();
      if (refresh == null || refresh.isEmpty) {
        await _tokens.clear();
        return null;
      }
      try {
        final tokens = await _api.refreshToken(refresh);
        if (tokens.access.isEmpty) {
          await _tokens.clear();
          return null;
        }
        await _tokens.writeTokens(
          access: tokens.access,
          refresh: tokens.refresh ?? refresh,
        );
        return await _api.fetchCurrentUser();
      } catch (_) {
        await _tokens.clear();
        return null;
      }
    }
  }

  Future<void> logout() async {
    final refresh = await _tokens.readRefreshToken();
    try {
      await _api.logout(refresh: refresh);
    } catch (_) {}
    await _tokens.clear();
  }
}
