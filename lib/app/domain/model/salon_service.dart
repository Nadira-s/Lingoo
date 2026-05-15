import '../../data/api/json_helpers.dart';

class SalonService {
  const SalonService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.isActive,
  });

  final int id;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final bool isActive;

  factory SalonService.fromJson(Map<String, dynamic> json) {
    return SalonService(
      id: readInt(json['id']) ?? 0,
      name: readString(json, 'name'),
      description: readString(json, 'description'),
      price: readDouble(json['price']) ?? 0,
      durationMinutes:
          readInt(json['duration_minutes']) ?? readInt(json['duration']) ?? 0,
      isActive: readBool(json, 'is_active', fallback: true),
    );
  }

  Map<String, dynamic> toCreateBody() => {
        'name': name,
        'description': description,
        'price': price,
        'duration_minutes': durationMinutes,
        'is_active': isActive,
      };
}
