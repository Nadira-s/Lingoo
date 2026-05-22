import '../../data/api/json_helpers.dart';

class BusinessSettings {
  const BusinessSettings({
    this.name = '',
    this.description = '',
    this.phone = '',
    this.email = '',
    this.currency = '',
    this.companyPhotoUrl,
    this.companyPosterUrl,
  });

  final String name;
  final String description;
  final String phone;
  final String email;
  final String currency;
  final String? companyPhotoUrl;
  final String? companyPosterUrl;

  factory BusinessSettings.fromJson(Map<String, dynamic> json) {
    return BusinessSettings(
      name: readString(json, 'name'),
      description: readString(json, 'description'),
      phone: readString(json, 'phone'),
      email: readString(json, 'email'),
      currency: readString(json, 'currency'),
      companyPhotoUrl: readString(json, 'company_photo').isEmpty
          ? readString(json, 'company_photo_url')
          : readString(json, 'company_photo'),
      companyPosterUrl: readString(json, 'company_poster').isEmpty
          ? readString(json, 'company_poster_url')
          : readString(json, 'company_poster'),
    );
  }

  Map<String, dynamic> toPatchBody() => {
        'name': name,
        'description': description,
        'phone': phone,
        'email': email,
        'currency': currency,
      };
}
