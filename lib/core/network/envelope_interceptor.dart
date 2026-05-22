import 'package:dio/dio.dart';

/// Rejects HTTP 200 responses where API envelope has `success: false`.
class EnvelopeInterceptor extends Interceptor {
  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
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
  }
}
