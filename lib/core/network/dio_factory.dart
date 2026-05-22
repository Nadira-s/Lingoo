import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_endpoints.dart';
import 'api_response_parser.dart';
import 'auth_interceptor.dart';
import 'envelope_interceptor.dart';

Dio createDio({
  required TokenStorage tokenStorage,
  required void Function() onUnauthorized,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.instance.apiBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.json,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    EnvelopeInterceptor(),
    AuthInterceptor(
      dio: dio,
      readAccessToken: tokenStorage.readAccessToken,
      readRefreshToken: tokenStorage.readRefreshToken,
      writeTokens: tokenStorage.writeTokens,
      refreshTokens: (refresh) async {
        final res = await dio.post<dynamic>(
          ApiEndpoints.authRefresh,
          data: {'refresh': refresh},
        );
        final map = parseEntityMap(res.data);
        return (
          access: map['access']?.toString() ?? '',
          refresh: map['refresh']?.toString(),
        );
      },
      onUnauthorized: () async {
        await tokenStorage.clear();
        onUnauthorized();
      },
    ),
  ]);

  return dio;
}
