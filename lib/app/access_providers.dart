import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_notifier.dart';
import 'di/app_providers.dart';

/// Пользователь в разделе «Управление доступами».
class AccessUserItem {
  const AccessUserItem({
    required this.name,
    required this.email,
    required this.roleLabel,
    required this.isActive,
    this.isYou = false,
    this.staffId,
  });

  final String name;
  final String email;
  final String roleLabel;
  final bool isActive;
  final bool isYou;
  final int? staffId;
}

/// Роль в системе (справочник по Mobile API).
class AccessRoleInfo {
  const AccessRoleInfo({
    required this.title,
    required this.apiCode,
    required this.description,
    required this.howToCreate,
  });

  final String title;
  final String apiCode;
  final String description;
  final String howToCreate;
}

const accessRolesCatalog = [
  AccessRoleInfo(
    title: 'Администратор арендатора',
    apiCode: 'TENANT_ADMIN',
    description:
        'Полный доступ к mobile API: дашборд, записи, филиалы, услуги, '
        'сотрудники, настройки бизнеса.',
    howToCreate:
        'Выдаётся платформой при создании салона. Вход в приложение — '
        'логин арендатора (например test), не название салона.',
  ),
  AccessRoleInfo(
    title: 'Менеджер',
    apiCode: 'MANAGER',
    description:
        'Работа с записями и клиентами. В приложении: главная и раздел '
        '«Записи» (без управления филиалами и каталогом).',
    howToCreate:
        'Создайте сотрудника: Сотрудники → «+» → имя, email, пароль, '
        'филиал и услуги. Email и пароль — для входа менеджера в приложение.',
  ),
];

final accessUsersProvider = FutureProvider.autoDispose<List<AccessUserItem>>((
  ref,
) async {
  final auth = ref.watch(authNotifierProvider).valueOrNull;
  if (auth == null) return [];

  final items = <AccessUserItem>[
    AccessUserItem(
      name: auth.username,
      email: auth.email.isNotEmpty
          ? auth.email
          : (auth.staffProfile?.email ?? ''),
      roleLabel: auth.role.displayRu,
      isActive: true,
      isYou: true,
    ),
  ];

  final staff = await ref.read(lingooRepositoryProvider).getStaff();
  for (final s in staff) {
    final email = s.email.trim();
    items.add(
      AccessUserItem(
        name: s.name,
        email: email,
        roleLabel: 'Менеджер',
        isActive: s.isActive,
        staffId: s.id,
      ),
    );
  }
  return items;
});
