import '../../data/api/json_helpers.dart';

class Branch {
  const Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.isActive,
  });

  final int id;
  final String name;
  final String address;
  final String phone;
  final bool isActive;

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: readInt(json['id']) ?? 0,
      name: readString(json, 'name'),
      address: readString(json, 'address'),
      phone: readString(json, 'phone'),
      isActive: readBool(json, 'is_active', fallback: true) ||
          readBool(json, 'active', fallback: true),
    );
  }

  Map<String, dynamic> toCreateBody() => {
        'name': name,
        'address': address,
        'phone': phone,
        'is_active': isActive,
      };
}
