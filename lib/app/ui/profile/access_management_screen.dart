import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../access_providers.dart';
import '../../auth_notifier.dart';
import '../../catalog_providers.dart';
import '../widgets/cards/access_list_card.dart';
import '../widgets/components/app_bar_add_button.dart';
import '../widgets/components/app_ui_tokens.dart';

/// Управление доступами: текущий админ + сотрудники с учётными записями (API).
class AccessManagementScreen extends ConsumerStatefulWidget {
  const AccessManagementScreen({super.key});

  @override
  ConsumerState<AccessManagementScreen> createState() =>
      _AccessManagementScreenState();
}

class _AccessManagementScreenState extends ConsumerState<AccessManagementScreen> {
  int _tab = 0;
  static const _tabs = ['Пользователи', 'Роли'];

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(accessUsersProvider);
    final isAdmin =
        ref.watch(authNotifierProvider).valueOrNull?.role.isTenantAdmin ?? false;

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
          if (isAdmin && _tab == 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AppBarAddButton(
                onPressed: () => context.push('/staff/new'),
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
      body: _tab == 0
          ? RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(accessUsersProvider);
                ref.invalidate(staffListProvider);
                await ref.read(accessUsersProvider.future);
              },
              child: usersAsync.when(
                loading: () => ListView(
                  children: const [
                    SizedBox(height: 120),
                    Center(child: CircularProgressIndicator()),
                  ],
                ),
                error: (e, _) => ListView(
                  children: [
                    const SizedBox(height: 80),
                    Center(child: Text('Ошибка: $e')),
                  ],
                ),
                data: (users) {
                  if (users.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(child: Text('Нет пользователей')),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    itemCount: users.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _InfoBanner(
                          text: isAdmin
                              ? 'Менеджеров добавляют как сотрудников с email и '
                                  'паролем — они смогут войти в приложение и '
                                  'работать с записями.'
                              : 'Список учётных записей вашего салона.',
                        );
                      }
                      final u = users[index - 1];
                      return AccessListCard(
                        title: u.isYou ? '${u.name} (вы)' : u.name,
                        secondaryLine:
                            u.email.isNotEmpty ? u.email : 'Email не указан',
                        tertiaryLine: u.roleLabel,
                        isActive: u.isActive,
                        leading: AccessListAvatar(name: u.name),
                        onTap: () {
                          if (u.staffId != null) {
                            context.push('/staff/${u.staffId}/edit');
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Это ваша учётная запись администратора. '
                                'Настройки салона — в «Настройки бизнеса».',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              itemCount: accessRolesCatalog.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final r = accessRolesCatalog[index];
                return AccessListCard(
                  title: r.title,
                  secondaryLine: r.apiCode,
                  tertiaryLine: r.description,
                  isActive: true,
                  activeLabel: 'В системе',
                  inactiveLabel: '',
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ColoredBox(
                      color: const Color(0xFFE8E0FF),
                      child: Center(
                        child: Icon(
                          r.apiCode == 'TENANT_ADMIN'
                              ? Icons.admin_panel_settings_outlined
                              : Icons.badge_outlined,
                          color: AppUiTokens.primaryText,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (ctx) => Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              r.description,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppUiTokens.secondaryText,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              r.howToCreate,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                            if (r.apiCode == 'MANAGER' && isAdmin) ...[
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    context.push('/staff/new');
                                  },
                                  child: const Text('Добавить менеджера'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8D6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFC6A400), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppUiTokens.primaryText,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
