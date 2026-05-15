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
    );
  }

  Map<String, dynamic> toCreateBody() => {
        'name': name,
        if (phone.isNotEmpty) 'phone': phone,
        if (email.isNotEmpty) 'email': email,
        'role': apiRole,
        if (branchId != null) 'branch_id': branchId,
        if (branchId != null) 'branch': branchId,
        'is_active': isActive,
      };
}
