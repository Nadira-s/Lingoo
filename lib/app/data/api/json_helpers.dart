List<Map<String, dynamic>> parseResultList(dynamic data) {
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
  if (data is Map && data['count'] is int) return data['count'] as int;
  if (data is List) return data.length;
  if (data is Map && data['results'] is List) return (data['results'] as List).length;
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

DateTime? parseDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  return null;
}
