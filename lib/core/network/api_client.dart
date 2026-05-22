import 'package:dio/dio.dart';

import '../errors/error_mapper.dart';

/// Base HTTP executor — maps [DioException] to [ApiException].
abstract class ApiClient {
  ApiClient(this.dio);

  final Dio dio;

  Future<T> run<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      run(() => dio.get<dynamic>(path, queryParameters: queryParameters));

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Options? options,
  }) =>
      run(() => dio.post<dynamic>(path, data: data, options: options));

  Future<Response<dynamic>> patch(
    String path, {
    Object? data,
  }) =>
      run(() => dio.patch<dynamic>(path, data: data));

  Future<Response<dynamic>> put(
    String path, {
    Object? data,
  }) =>
      run(() => dio.put<dynamic>(path, data: data));

  Future<Response<dynamic>> delete(String path) =>
      run(() => dio.delete<dynamic>(path));
}
