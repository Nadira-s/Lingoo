import 'package:dio/dio.dart';

import 'api_exception.dart';

String mapDioExceptionToUserMessage(DioException e) {
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout) {
    return 'Сервер временно недоступен.';
  }
  if (e.type == DioExceptionType.connectionError) {
    return 'Нет подключения к интернету.';
  }

  final status = e.response?.statusCode;
  final data = e.response?.data;

  if (status == 400 || status == 422) {
    final msg = _messageFromBody(data);
    if (msg != null) return msg;
    return 'Ошибка валидации данных.';
  }
  if (status == 401) {
    return 'Неверный логин или пароль.';
  }
  if (status == 403) {
    return _messageFromBody(data) ?? 'У вас нет доступа к этим данным.';
  }
  if (status == 404) {
    return _messageFromBody(data) ?? 'Данные не найдены.';
  }
  if (status == 500) {
    return 'Сервер временно недоступен.';
  }

  final msg = _messageFromBody(data);
  if (msg != null) return msg;

  return 'Произошла ошибка. Попробуйте позже.';
}

ApiException apiExceptionFromDio(DioException e) {
  final status = e.response?.statusCode;
  final data = e.response?.data;
  String? code;
  if (data is Map && data['code'] is String) {
    code = data['code'] as String;
  }
  return ApiException(
    userMessage: mapDioExceptionToUserMessage(e),
    statusCode: status,
    code: code,
    debugMessage: e.message,
  );
}

String? _messageFromBody(dynamic data) {
  if (data is Map) {
    final m = data['message'];
    if (m is String && m.isNotEmpty) return m;
    final detail = data['detail'];
    if (detail is String && detail.isNotEmpty) return detail;
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is String) return first;
      if (first is Map && first['msg'] is String) return first['msg'] as String;
    }
  }
  return null;
}
