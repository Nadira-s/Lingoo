import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'api_exception.dart';

String mapDioExceptionToUserMessage(DioException e) {
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout) {
    return 'Сервер временно недоступен.';
  }
  if (e.type == DioExceptionType.connectionError) {
    if (kIsWeb) {
      return 'Браузер блокирует запрос к API (CORS). '
          'Запустите приложение на macOS или Android: flutter run -d macos';
    }
    return 'Нет подключения к интернету.';
  }

  final status = e.response?.statusCode;
  final data = e.response?.data;

  if (status == 400 || status == 422) {
    final msg = _messageFromBody(data);
    if (msg != null) {
      if (msg.toLowerCase().contains('tenant admin')) {
        return 'Учётная запись не является администратором арендатора для мобильного API. '
            'Попросите платформу выдать TENANT_ADMIN или активировать роль для этого логина.';
      }
      if (msg.contains('Invalid pk')) {
        return 'Сервер не может привязать филиал или услугу к сотруднику. '
            'Это ошибка API на сервере — передайте администратору платформы.';
      }
      return msg;
    }
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
  Map<String, dynamic>? fieldErrors;
  if (data is Map) {
    if (data['code'] is String) code = data['code'] as String;
    if (data['errors'] is Map) {
      fieldErrors = Map<String, dynamic>.from(data['errors'] as Map);
    }
  }
  return ApiException(
    userMessage: mapDioExceptionToUserMessage(e),
    statusCode: status,
    code: code,
    debugMessage: e.message,
    fieldErrors: fieldErrors,
  );
}

String? _messageFromBody(dynamic data) {
  if (data is Map) {
    final m = data['message'];
    final base = m is String && m.isNotEmpty ? _cleanApiMessage(m) : null;
    final fieldHint = _formatFieldErrors(data['errors']);
    if (base != null && fieldHint != null) return '$base $fieldHint';
    if (base != null) return base;
    if (fieldHint != null) return fieldHint;

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

String? _formatFieldErrors(dynamic errors) {
  if (errors is! Map || errors.isEmpty) return null;
  final parts = <String>[];
  for (final entry in errors.entries) {
    final v = entry.value;
    if (v is List && v.isNotEmpty) {
      parts.add('${entry.key}: ${v.first}');
    } else if (v != null) {
      parts.add('${entry.key}: $v');
    }
  }
  return parts.isEmpty ? null : '(${parts.join('; ')})';
}

String _cleanApiMessage(String raw) {
  final match = RegExp(r"string='([^']*)'").firstMatch(raw);
  if (match != null) return match.group(1)!;
  return raw;
}
