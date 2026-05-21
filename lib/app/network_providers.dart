import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'utils/app_config.dart';
import 'data/api/api_paths.dart';
import 'data/api/business_api_client.dart';
import 'data/repository/token_storage.dart';
import 'force_logout.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

bool _isAuthLogin(RequestOptions options) {
  return options.path.contains(ApiPaths.authLogin) &&
      options.method.toUpperCase() == 'POST';
}

bool _isAuthRefresh(RequestOptions options) {
  return options.path.contains(ApiPaths.authRefresh) &&
      options.method.toUpperCase() == 'POST';
}

bool _isPublicAuth(RequestOptions options) =>
    _isAuthLogin(options) || _isAuthRefresh(options);

final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final base = AppConfig.instance.apiBaseUrl;
  final dio = Dio(
    BaseOptions(
      baseUrl: base,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_isPublicAuth(options)) {
          options.headers.remove('Authorization');
        } else {
          final token = await tokenStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        final data = response.data;
        if (data is Map && data['success'] == false) {
          handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              type: DioExceptionType.badResponse,
            ),
          );
          return;
        }
        handler.next(response);
      },
      onError: (e, handler) async {
        final status = e.response?.statusCode;
        final isLogin = _isAuthLogin(e.requestOptions);
        final isRefresh = _isAuthRefresh(e.requestOptions);

        if (status == 401 && !isLogin && !isRefresh) {
          final refresh = await tokenStorage.readRefreshToken();
          if (refresh != null && refresh.isNotEmpty) {
            try {
              final client = BusinessApiClient(dio);
              final tokens = await client.refreshToken(refresh);
              if (tokens.access.isNotEmpty) {
                await tokenStorage.writeTokens(
                  access: tokens.access,
                  refresh: tokens.refresh ?? refresh,
                );
                final req = e.requestOptions;
                req.headers['Authorization'] = 'Bearer ${tokens.access}';
                final clone = await dio.fetch<dynamic>(req);
                handler.resolve(clone);
                return;
              }
            } catch (_) {}
          }
          await tokenStorage.clear();
          Future.microtask(() {
            try {
              ref.read(forceLogoutTickProvider.notifier).state++;
            } catch (_) {}
          });
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
