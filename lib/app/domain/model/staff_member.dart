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
    final roleStr = json['role'] as String? ?? '';
    return StaffMember(
      id: readInt(json['id']) ?? 0,
      name: readString(json, 'name').isEmpty
          ? readString(json, 'full_name')
          : readString(json, 'name'),
      phone: readString(json, 'phone'),
      email: readString(json, 'email'),
      role: UserRole.fromApi(roleStr),
      apiRole: roleStr.isEmpty ? 'MANAGER' : roleStr,
      branchId: readInt(json['branch_id']) ?? readInt(branch?['id']),
      branchName: branch != null ? readString(branch, 'name') : '',
      isActive: readBool(json, 'is_active', fallback: true),
      serviceIds: _parseServiceIds(json['services']),
      bufferMinutes: readInt(json['buffer_minutes']) ?? 0,
    );
  }

  static List<int> _parseServiceIds(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((e) => e is int ? e : (e is Map ? readInt(e['id']) : null))
        .whereType<int>()
        .toList();
  }

  Map<String, dynamic> toCreateBody({String? password}) => {
        'name': name,
        'email': email,
        if (password != null && password.isNotEmpty) 'password': password,
        if (branchId != null) 'branches': [branchId],
        if (serviceIds.isNotEmpty) 'services': serviceIds,
        'is_active': isActive,
        if (bufferMinutes > 0) 'buffer_minutes': bufferMinutes,
      };
}
