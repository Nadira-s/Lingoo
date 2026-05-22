enum UserRole {
  tenantAdmin,
  manager,
  unknown;

  static UserRole fromApi(String? raw) {
    if (raw == null) return UserRole.unknown;
    final s = raw.toUpperCase().replaceAll('-', '_');
    if (s.contains('TENANT_ADMIN') || s == 'ADMIN') return UserRole.tenantAdmin;
    if (s.contains('MANAGER')) return UserRole.manager;
    return UserRole.unknown;
  }

  bool get isTenantAdmin => this == UserRole.tenantAdmin;
  bool get isManager => this == UserRole.manager;

  String get displayRu => switch (this) {
        UserRole.tenantAdmin => 'Администратор арендатора',
        UserRole.manager => 'Менеджер',
        UserRole.unknown => 'Сотрудник',
      };

  String get apiCode => switch (this) {
        UserRole.tenantAdmin => 'TENANT_ADMIN',
        UserRole.manager => 'MANAGER',
        UserRole.unknown => 'STAFF',
      };
}
