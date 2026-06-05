import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth_notifier.dart';
import '../../data_providers.dart';
import '../widgets/components/app_ui_tokens.dart';
import '../widgets/profile/profile_header_card.dart';
import 'manager_profile_body.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final isManager = user?.isManagerUser ?? false;

    if (isManager) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Профиль',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 28,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => context.push('/profile/form'),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFCC00),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: AppUiTokens.primaryText,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: const ManagerProfileBody(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Профиль',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
      ),
      body: _AdminProfileBody(userName: user?.username ?? '—', role: user?.role.displayRu ?? '—'),
    );
  }
}

class _AdminProfileBody extends ConsumerWidget {
  const _AdminProfileBody({required this.userName, required this.role});

  final String userName;
  final String role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tariff = ref.watch(tariffLimitsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        ProfileHeaderCard(
          name: userName,
          roleLabel: role,
          onEdit: () => context.push('/profile/form'),
        ),
        const SizedBox(height: 20),
        tariff.when(
          data: (t) {
            final plan = t.planName.isEmpty ? 'Тариф' : t.planName;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Подписка',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppUiTokens.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push('/profile/tariff'),
                    borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
                        border: Border.all(color: AppUiTokens.borderSubtle),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'План: $plan',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          if (t.usagePercent > 0)
                            Text(
                              '${t.usagePercent.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFC6A400),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Лимит подписки',
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
                  child: Column(
                    children: [
                      if (t.items.isEmpty)
                        const Text('Лимиты загружаются с API')
                      else
                        ...t.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _SubscriptionLimitItem(
                              label: item.label,
                              current: item.used,
                              total: item.limit > 0 ? item.limit : 1,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Тариф: $e'),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
            border: Border.all(color: AppUiTokens.borderSubtle),
          ),
          child: Column(
            children: [
              _ProfileMenuItem(
                icon: Icons.people_outline,
                title: 'Управление доступами',
                onTap: () => context.push('/profile/access'),
              ),
              const Divider(height: 1),
              _ProfileMenuItem(
                icon: Icons.store_outlined,
                title: 'Настройки бизнеса',
                onTap: () => context.push('/profile/business'),
              ),
              const Divider(height: 1),
              _ProfileMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Уведомления',
                onTap: () => context.push('/notifications'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubscriptionLimitItem extends StatelessWidget {
  const _SubscriptionLimitItem({
    required this.label,
    required this.current,
    required this.total,
  });

  final String label;
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percentage = (current / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              '$current/$total',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: AppUiTokens.borderSubtle,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFC107)),
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppUiTokens.primaryText),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, color: AppUiTokens.tertiaryText),
      onTap: onTap,
    );
  }
}
