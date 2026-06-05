import 'user_role.dart';
import '../../data/api/json_helpers.dart';
import 'staff_member.dart';
import 'tenant.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.role,
    this.email = '',
    this.tenant,
    this.staffProfile,
  });

  final int id;
  final String username;
  final String email;
  final UserRole role;
  final Tenant? tenant;
  final StaffMember? staffProfile;

  /// Менеджер / исполнитель (не администратор арендатора).
  bool get isManagerUser {
    if (role.isTenantAdmin) return false;
    if (role.isManager) return true;
    final api = staffProfile?.apiRole.toUpperCase() ?? '';
    if (api.contains('MANAGER')) return true;
    // Связанный staff без прав админа — режим менеджера в приложении.
    if (staffProfile != null && staffProfile!.id > 0) return true;
    return false;
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final tenantRaw = json['tenant'] ?? json['tenant_info'];
    final staffProfile = _parseStaff(json);
    var role = UserRole.fromApi(
      json['role'] as String? ??
          json['role_name'] as String? ??
          (readBool(json, 'is_tenant_admin') ? 'TENANT_ADMIN' : null),
    );
    if (!role.isTenantAdmin && staffProfile != null) {
      final staffRole = UserRole.fromApi(staffProfile.apiRole);
      if (staffRole.isManager) {
        role = UserRole.manager;
      } else if (role == UserRole.unknown) {
        role = UserRole.manager;
      }
    }
    return UserProfile(
      id: readInt(json['id']) ?? 0,
      username: readString(json, 'username').isEmpty
          ? readString(json, 'login')
          : readString(json, 'username'),
      email: readString(json, 'email'),
      role: role,
      tenant: tenantRaw is Map ? Tenant.fromJson(asMap(tenantRaw)!) : null,
      staffProfile: staffProfile,
    );
  }

  static StaffMember? _parseStaff(Map<String, dynamic> json) {
    final keys = [
      'staff_profile',
      'staffProfile',
      'staff',
      'linked_staff',
    ];
    for (final k in keys) {
      final v = json[k];
      if (v is Map) {
        return StaffMember.fromJson(asMap(v)!);
      }
    }
    return null;
  }
}
