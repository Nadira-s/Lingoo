import 'dart:async';

import '../../../core/errors/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../../domain/model/user_profile.dart';
import '../../domain/repositories/lingoo_repository.dart';

class AuthRepository {
  AuthRepository(this._repo, this._tokens);

  final LingooRepository _repo;
  final TokenStorage _tokens;

  Future<UserProfile> login(String username, String password) async {
    await _tokens.clear();
    final result = await _repo.login(username: username, password: password);
    if (result.tokens.access.isEmpty) {
      throw ApiException(userMessage: 'Некорректный ответ при входе.');
    }
    await _tokens.writeTokens(
      access: result.tokens.access,
      refresh: result.tokens.refresh,
    );
    if (result.user != null) return result.user!;
    return _repo.getCurrentUser();
  }

  Future<UserProfile?> restoreSession() async {
    final access = await _tokens.readAccessToken();
    if (access == null || access.isEmpty) return null;
    try {
      return await _repo
          .getCurrentUser()
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      final refresh = await _tokens.readRefreshToken();
      if (refresh == null || refresh.isEmpty) {
        await _tokens.clear();
        return null;
      }
      try {
        final tokens = await _repo.refreshToken(refresh);
        if (tokens.access.isEmpty) {
          await _tokens.clear();
          return null;
        }
        await _tokens.writeTokens(
          access: tokens.access,
          refresh: tokens.refresh ?? refresh,
        );
        return await _repo
            .getCurrentUser()
            .timeout(const Duration(seconds: 15));
      } catch (_) {
        await _tokens.clear();
        return null;
      }
    }
  }

  Future<void> logout() async {
    final refresh = await _tokens.readRefreshToken();
    try {
      await _repo.logout(refresh: refresh);
    } catch (_) {}
    await _tokens.clear();
  }
}
