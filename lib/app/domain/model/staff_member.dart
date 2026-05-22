import 'user_role.dart';
import '../../data/api/json_helpers.dart';

class StaffMember {
  const StaffMember({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.apiRole,
    required this.branchId,
    required this.branchName,
    required this.isActive,
    this.serviceIds = const [],
    this.bufferMinutes = 0,
  });

  final int id;
  final String name;
  final String phone;
  final String email;
  final UserRole role;
  /// Строка роли как в API (MANAGER, TENANT_ADMIN, …).
  final String apiRole;
  final int? branchId;
  final String branchName;
  final bool isActive;
  final List<int> serviceIds;
  final int bufferMinutes;

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    final branch = asMap(json['branch']);
    final branchDetails = json['branch_details'];
    final roleStr = json['role'] as String? ?? '';
    final email = readString(json, 'email').isEmpty
        ? readString(json, 'user_email')
        : readString(json, 'email');
    return StaffMember(
      id: readInt(json['id']) ?? 0,
      name: readString(json, 'name').isEmpty
          ? readString(json, 'full_name')
          : readString(json, 'name'),
      phone: readString(json, 'phone'),
      email: email,
      role: UserRole.fromApi(roleStr),
      apiRole: roleStr.isEmpty ? 'MANAGER' : roleStr,
      branchId: readInt(json['branch_id']) ??
          _firstRelationId(json['branches']) ??
          _firstDetailId(branchDetails),
      branchName: branch != null
          ? readString(branch, 'name')
          : _firstDetailName(branchDetails),
      isActive: readBool(json, 'is_active', fallback: true),
      serviceIds: _parseServiceIds(json['services'] ?? json['service_details']),
      bufferMinutes: readInt(json['buffer_minutes']) ?? 0,
    );
  }

  static int? _firstRelationId(dynamic raw) {
    if (raw is! List || raw.isEmpty) return null;
    final first = raw.first;
    if (first is int) return first;
    if (first is Map) return readInt(first['id']);
    return null;
  }

  static int? _firstDetailId(dynamic raw) {
    if (raw is! List || raw.isEmpty) return null;
    final first = raw.first;
    if (first is Map) return readInt(first['id']);
    return null;
  }

  static String _firstDetailName(dynamic raw) {
    if (raw is! List || raw.isEmpty) return '';
    final first = raw.first;
    if (first is Map) {
      return readString(Map<String, dynamic>.from(first), 'name');
    }
    return '';
  }

  static List<int> _parseServiceIds(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((e) {
          if (e is int) return e;
          if (e is Map) return readInt(e['id']);
          return null;
        })
        .whereType<int>()
        .toList();
  }

  List<int> get branchIds => branchId != null ? [branchId!] : const [];

  /// Тело POST `/staff/` и PATCH `/staff/<id>/` по Mobile API Reference.
  Map<String, dynamic> toApiBody({String? password}) => {
        'name': name,
        'email': email,
        if (password != null && password.isNotEmpty) 'password': password,
        'branches': branchIds,
        'services': serviceIds,
        'is_active': isActive,
        'buffer_minutes': bufferMinutes,
      };

  StaffMember withoutBindings() => StaffMember(
        id: id,
        name: name,
        phone: phone,
        email: email,
        role: role,
        apiRole: apiRole,
        branchId: null,
        branchName: branchName,
        isActive: isActive,
        serviceIds: const [],
        bufferMinutes: bufferMinutes,
      );
}
