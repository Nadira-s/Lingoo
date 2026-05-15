import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/cards/access_list_card.dart';
import '../widgets/components/app_bar_add_button.dart';
import '../widgets/components/app_ui_tokens.dart';

/// Демо-пользователь для списка доступов.
class AccessUserRow {
  const AccessUserRow({
    required this.name,
    required this.email,
    required this.role,
    required this.active,
  });

  final String name;
  final String email;
  final String role;
  final bool active;
}

/// Демо-роль.
class AccessRoleRow {
  const AccessRoleRow({
    required this.name,
    required this.description,
    required this.active,
  });

  final String name;
  final String description;
  final bool active;
}

/// Управление доступами: AppBar и вкладки в стиле [BookingsListScreen].
class AccessManagementScreen extends StatefulWidget {
  const AccessManagementScreen({super.key});

  static const _users = <AccessUserRow>[
    AccessUserRow(
      name: 'Анна Петрова',
      email: 'admin123@mail.ru',
      role: 'Администратор',
      active: true,
    ),
    AccessUserRow(
      name: 'Иван Сидоров',
      email: 'ivansid@mail.ru',
      role: 'Менеджер',
      active: false,
    ),
    AccessUserRow(
      name: 'Мария Ивановна',
      email: 'marya777@gmail.com',
      role: 'Менеджер',
      active: true,
    ),
    AccessUserRow(
      name: 'Дмитрий Колканов',
      email: 'kolkanov@mail.ru',
      role: 'Менеджер',
      active: false,
    ),
  ];

  static const _roles = <AccessRoleRow>[
    AccessRoleRow(
      name: 'Администратор',
      description: 'Полный доступ ко всем разделам',
      active: true,
    ),
    AccessRoleRow(
      name: 'Менеджер',
      description: 'Записи, сотрудники, услуги',
      active: true,
    ),
    AccessRoleRow(
      name: 'Сотрудник',
      description: 'Только собственное расписание',
      active: true,
    ),
  ];

  @override
  State<AccessManagementScreen> createState() => _AccessManagementScreenState();
}

class _AccessManagementScreenState extends State<AccessManagementScreen> {
  int _tab = 0;
  static const _tabs = ['Пользователи', 'Роли'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppUiTokens.primaryText,
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Управление доступами',
          style: TextStyle(
            color: AppUiTokens.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AppBarAddButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Добавление (скоро)')),
                );
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: Row(
                  children: List.generate(_tabs.length, (index) {
                    final isSelected = _tab == index;
                    return Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => setState(() => _tab = index),
                          child: Ink(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: isSelected
                                      ? const Color(0xFFFFCC00)
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _tabs[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFFC6A400)
                                      : AppUiTokens.secondaryText,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const Divider(height: 1, color: AppUiTokens.borderSubtle),
            ],
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        itemCount: _tab == 0
            ? AccessManagementScreen._users.length
            : AccessManagementScreen._roles.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (_tab == 0) {
            final u = AccessManagementScreen._users[index];
            return AccessListCard(
              title: u.name,
              secondaryLine: u.email,
              tertiaryLine: u.role,
              isActive: u.active,
              leading: AccessListAvatar(name: u.name),
              onTap: () {
                context.push('/profile/form');
              },
            );
          }
          final r = AccessManagementScreen._roles[index];
          return AccessListCard(
            title: r.name,
            secondaryLine: r.description,
            tertiaryLine: '',
            isActive: r.active,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ColoredBox(
                color: const Color(0xFFE8E0FF),
                child: const Center(
                  child: Icon(
                    Icons.shield_outlined,
                    color: AppUiTokens.primaryText,
                    size: 28,
                  ),
                ),
              ),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Роль: ${r.name}')),
              );
            },
          );
        },
      ),
    );
  }
}
