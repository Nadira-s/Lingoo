import 'dart:convert';

import '../errors/api_exception.dart';

dynamic _normalizeRaw(dynamic raw) {
  if (raw is String && raw.trim().isNotEmpty) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      throw ApiException(userMessage: 'Некорректный ответ сервера.');
    }
  }
  return raw;
}

dynamic unwrapApiData(dynamic raw) {
  raw = _normalizeRaw(raw);
  if (raw is Map<String, dynamic> && raw.containsKey('data')) {
    return raw['data'];
  }
  if (raw is Map && raw.containsKey('data')) {
    return raw['data'];
  }
  return raw;
}

Map<String, dynamic> parseEntityMap(dynamic raw) {
  raw = _normalizeRaw(raw);
  if (raw == null) {
    throw ApiException(userMessage: 'Пустой ответ сервера.');
  }
  final unwrapped = unwrapApiData(raw);
  if (unwrapped is Map) {
    return Map<String, dynamic>.from(unwrapped);
  }
  if (raw is Map) {
    return Map<String, dynamic>.from(raw);
  }
  throw ApiException(userMessage: 'Некорректный формат ответа сервера.');
}

List<Map<String, dynamic>> parseResultList(dynamic data) {
  data = unwrapApiData(data);
  if (data is Map && data['results'] is List) {
    return (data['results'] as List)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  if (data is List) {
    return data
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  return const [];
}

int parseCount(dynamic data) {
  data = unwrapApiData(data);
  if (data is Map && data['count'] is int) return data['count'] as int;
  if (data is List) return data.length;
  if (data is Map && data['results'] is List) {
    return (data['results'] as List).length;
  }
  return 0;
}

Map<String, dynamic>? asMap(dynamic v) {
  if (v is Map) return Map<String, dynamic>.from(v);
  return null;
}

String readString(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v == null) return '';
  return v.toString();
}

bool readBool(Map<String, dynamic> json, String key, {bool fallback = false}) {
  final v = json[key];
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final l = v.toLowerCase();
    return l == 'true' || l == '1' || l == 'yes';
  }
  return fallback;
}

double? readDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

int? readInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

/// ID сущности из JSON (`id`, `pk`, …). 0 — невалидный id.
int readEntityId(
  Map<String, dynamic> json, [
  List<String> keys = const ['id', 'pk'],
]) {
  for (final k in keys) {
    final v = readInt(json[k]);
    if (v != null && v > 0) return v;
  }
  return 0;
}

DateTime? parseDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  return null;
}

String formatApiDate(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}
