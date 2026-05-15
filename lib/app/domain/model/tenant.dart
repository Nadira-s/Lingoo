import '../../data/api/json_helpers.dart';

class Tenant {
  const Tenant({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: readInt(json['id']) ?? 0,
      name: readString(json, 'name').isEmpty
          ? readString(json, 'title')
          : readString(json, 'name'),
    );
  }
}
