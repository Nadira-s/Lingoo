import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'utils/app_config.dart';
import 'data/api/business_api_client.dart';
import 'data/repository/token_storage.dart';
import 'force_logout.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final base = AppConfig.instance.apiBaseUrl;
  final dio = Dio(
    BaseOptions(
      baseUrl: base,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final path = options.uri.path;
        final isLogin =
            path.contains('auth/token') && options.method.toUpperCase() == 'POST';
        if (isLogin) {
          options.headers.remove('Authorization');
        } else {
          final token = await tokenStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          final path = e.requestOptions.uri.path;
          final isLogin =
              path.contains('auth/token') && e.requestOptions.method.toUpperCase() == 'POST';
          if (!isLogin) {
            await tokenStorage.clear();
            Future.microtask(() {
              try {
                ref.read(forceLogoutTickProvider.notifier).state++;
              } catch (_) {}
            });
          }
        }
        handler.next(e);
      },
    ),
  );
  return dio;
});

final businessApiProvider = Provider<BusinessApiClient>((ref) {
  return BusinessApiClient(ref.watch(dioProvider));
});
