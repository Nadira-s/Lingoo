import '../../data/api/json_helpers.dart';

class Booking {
  const Booking({
    required this.id,
    required this.startsAt,
    required this.clientName,
    required this.serviceName,
    required this.branchName,
    required this.staffName,
    required this.status,
    required this.note,
    this.serviceId,
    this.branchId,
    this.staffId,
    this.clientAvatarUrl,
    this.clientPhone,
  });

  final int id;
  final DateTime? startsAt;
  final String clientName;
  final String serviceName;
  final String branchName;
  final String staffName;
  final String status;
  final String note;
  final int? serviceId;
  final int? branchId;
  final int? staffId;
  final String? clientAvatarUrl;
  /// Телефон клиента (если пришёл из API).
  final String? clientPhone;

  // ДОБАВЬТЕ ЭТОТ МЕТОД:
  Booking copyWith({
    int? id,
    DateTime? startsAt,
    String? clientName,
    String? serviceName,
    String? branchName,
    String? staffName,
    String? status,
    String? note,
    int? serviceId,
    int? branchId,
    int? staffId,
    String? clientAvatarUrl,
    String? clientPhone,
  }) {
    return Booking(
      id: id ?? this.id,
      startsAt: startsAt ?? this.startsAt,
      clientName: clientName ?? this.clientName,
      serviceName: serviceName ?? this.serviceName,
      branchName: branchName ?? this.branchName,
      staffName: staffName ?? this.staffName,
      status: status ?? this.status,
      note: note ?? this.note,
      serviceId: serviceId ?? this.serviceId,
      branchId: branchId ?? this.branchId,
      staffId: staffId ?? this.staffId,
      clientAvatarUrl: clientAvatarUrl ?? this.clientAvatarUrl,
      clientPhone: clientPhone ?? this.clientPhone,
    );
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    final service = asMap(json['service']);
    final branch = asMap(json['branch']);
    final staff = asMap(json['staff']) ?? asMap(json['executor']);
    final clientPhoneRaw = readString(json, 'client_phone').isEmpty
        ? readString(json, 'phone')
        : readString(json, 'client_phone');
    return Booking(
      id: readInt(json['id']) ?? 0,
      startsAt:
          parseDateTime(json['starts_at']) ??
          parseDateTime(json['start_at']) ??
          parseDateTime(json['datetime']),
      clientName: readString(json, 'client_name').isEmpty
          ? readString(json, 'client')
          : readString(json, 'client_name'),
      serviceName: service != null
          ? readString(service, 'name')
          : readString(json, 'service_name'),
      branchName: branch != null
          ? readString(branch, 'name')
          : readString(json, 'branch_name'),
      staffName: staff != null
          ? readString(staff, 'name').isEmpty
                ? readString(staff, 'full_name')
                : readString(staff, 'name')
          : readString(json, 'staff_name'),
      status: readString(json, 'status').isEmpty
          ? readString(json, 'state')
          : readString(json, 'status'),
      note: readString(json, 'note').isEmpty
          ? readString(json, 'comment')
          : readString(json, 'note'),
      serviceId: readInt(json['service_id']) ?? readInt(service?['id']),
      branchId: readInt(json['branch_id']) ?? readInt(branch?['id']),
      staffId: readInt(json['staff_id']) ?? readInt(staff?['id']),
      clientAvatarUrl: readString(json, 'client_avatar_url'),
      clientPhone: clientPhoneRaw.isEmpty ? null : clientPhoneRaw,
    );
  }
}
