import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth_notifier.dart';
import '../../catalog_providers.dart';
import '../../data_providers.dart';
import '../../utils/phone_format.dart';
import '../widgets/components/active_status_chip.dart';
import '../widgets/components/app_ui_tokens.dart';
import '../widgets/profile/profile_header_card.dart';
import '../widgets/profile/profile_info_card.dart';

/// Профиль менеджера (по макету: филиал, контакты, уведомления).
class ManagerProfileBody extends ConsumerWidget {
  const ManagerProfileBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final tariff = ref.watch(tariffLimitsProvider);
    final branches = ref.watch(branchesListProvider);

    final name = user?.staffProfile?.name.isNotEmpty == true
        ? user!.staffProfile!.name
        : (user?.username ?? '—');
    final email = user?.email.isNotEmpty == true
        ? user!.email
        : (user?.staffProfile?.email ?? '');
    final phoneRaw = user?.staffProfile?.phone ?? '';
    final phoneDisplay = phoneRaw.isEmpty
        ? '—'
        : PhoneFormat.formatDisplay(phoneRaw);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        ProfileHeaderCard(
          name: name,
          roleLabel: user?.role.displayRu ?? 'Менеджер',
          onEdit: () {
            final staffId = user?.staffProfile?.id;
            if (staffId != null && staffId > 0) {
              context.push('/staff/$staffId/edit');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Редактирование профиля через раздел сотрудников.'),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 24),
        tariff.when(
          data: (t) {
            final plan = t.planName.isEmpty ? 'Стандарт' : t.planName;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Подписка',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
                    border: Border.all(color: AppUiTokens.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'План: $plan',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      const ActiveStatusChip(
                        active: true,
                        activeLabel: 'Активна',
                        inactiveLabel: '',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        branches.when(
          data: (list) {
            final branchName = user?.staffProfile?.branchName.isNotEmpty == true
                ? user!.staffProfile!.branchName
                : (list.isNotEmpty ? list.first.name : '—');
            final address = list.isNotEmpty ? list.first.address : '';
            return ProfileInfoCard(
              children: [
                ProfileInfoRow(
                  label: 'Филиал',
                  value: branchName,
                  onTap: list.length > 1
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(address.isEmpty ? branchName : address)),
                          );
                        }
                      : null,
                ),
                ProfileInfoRow(label: 'Email', value: email),
                ProfileInfoRow(label: 'Телефон', value: phoneDisplay),
                ProfileInfoRow(
                  label: 'Лимиты',
                  value: 'Подписка салона',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Лимиты задаёт администратор салона.'),
                      ),
                    );
                  },
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('$e'),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
            border: Border.all(color: AppUiTokens.borderSubtle),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text(
                  'Уведомления',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/notifications'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
