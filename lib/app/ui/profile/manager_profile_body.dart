import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth_notifier.dart';
import '../../data_providers.dart';
import '../../utils/phone_format.dart';
import '../widgets/components/active_status_chip.dart';
import '../widgets/components/app_ui_tokens.dart';
import '../widgets/profile/profile_header_card.dart';
import '../widgets/profile/profile_info_card.dart';

/// Профиль менеджера — данные из сессии, без блокирующей загрузки.
class ManagerProfileBody extends ConsumerWidget {
  const ManagerProfileBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final tariff = ref.watch(tariffLimitsProvider);

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

    final branchName = user?.staffProfile?.branchName.isNotEmpty == true
        ? user!.staffProfile!.branchName
        : '—';

    final planName = tariff.maybeWhen(
      data: (t) => t.planName.isEmpty ? 'Стандарт' : t.planName,
      orElse: () => 'Стандарт',
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        ProfileHeaderCard(
          name: name,
          roleLabel: user?.role.displayRu ?? 'Менеджер',
        ),
        const SizedBox(height: 24),
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
                'План: $planName',
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
        ProfileInfoCard(
          children: [
            ProfileInfoRow(label: 'Филиал', value: branchName),
            ProfileInfoRow(label: 'Email', value: email),
            ProfileInfoRow(label: 'Телефон', value: phoneDisplay),
          ],
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
                leading: const Icon(Icons.settings_outlined),
                title: const Text(
                  'Настройки аккаунта',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/profile/form'),
              ),
              const Divider(height: 1, color: AppUiTokens.borderSubtle),
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
