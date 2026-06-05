import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_factory.dart';
import '../../core/storage/token_storage.dart';
import '../data/api/lingoo_api_client.dart';
import '../data/repositories/lingoo_repository_impl.dart';
import '../data/repository/auth_repository.dart';
import '../domain/repositories/lingoo_repository.dart';
import '../force_logout.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return createDio(
    tokenStorage: storage,
    onUnauthorized: () {
      try {
        ref.read(forceLogoutTickProvider.notifier).state++;
      } catch (_) {}
    },
  );
});

final lingooApiClientProvider = Provider<LingooApiClient>((ref) {
  return LingooApiClient(ref.watch(dioProvider));
});

/// Backward-compatible alias.
final businessApiProvider = lingooApiClientProvider;

final lingooRepositoryProvider = Provider<LingooRepository>((ref) {
  return LingooRepositoryImpl(
    ref.watch(lingooApiClientProvider),
    ref.watch(tokenStorageProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(lingooRepositoryProvider),
    ref.watch(tokenStorageProvider),
  );
});
