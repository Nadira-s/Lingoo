import 'package:dio/dio.dart';

import 'api_endpoints.dart';

typedef TokenReader = Future<String?> Function();
typedef TokenWriter = Future<void> Function({
  required String access,
  String? refresh,
});
typedef RefreshTokens = Future<({String access, String? refresh})> Function(
  String refresh,
);
typedef OnUnauthorized = Future<void> Function();

/// Attaches JWT, refreshes on 401, retries the original request.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.dio,
    required this.readAccessToken,
    required this.readRefreshToken,
    required this.writeTokens,
    required this.refreshTokens,
    required this.onUnauthorized,
  });

  final Dio dio;
  final TokenReader readAccessToken;
  final TokenReader readRefreshToken;
  final TokenWriter writeTokens;
  final RefreshTokens refreshTokens;
  final OnUnauthorized onUnauthorized;

  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.uri.path;
    if (ApiEndpoints.isPublicAuth(path, options.method)) {
      options.headers.remove('Authorization');
    } else {
      final token = await readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final status = err.response?.statusCode;
    final req = err.requestOptions;
    final path = req.uri.path;
    final isLogin = ApiEndpoints.isAuthLogin(path, req.method);
    final isRefresh = ApiEndpoints.isAuthRefresh(path, req.method);

    if (status != 401 || isLogin || isRefresh) {
      handler.next(err);
      return;
    }

    final refresh = await readRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      await onUnauthorized();
      handler.next(err);
      return;
    }

    try {
      if (!_isRefreshing) {
        _isRefreshing = true;
        final tokens = await refreshTokens(refresh);
        if (tokens.access.isEmpty) {
          await onUnauthorized();
          handler.next(err);
          return;
        }
        await writeTokens(access: tokens.access, refresh: tokens.refresh ?? refresh);
      }
      req.headers['Authorization'] = 'Bearer ${await readAccessToken()}';
      final response = await dio.fetch<dynamic>(req);
      handler.resolve(response);
    } catch (_) {
      await onUnauthorized();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}
