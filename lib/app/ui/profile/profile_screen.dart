import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth_notifier.dart';
import '../../data_providers.dart';
import '../widgets/components/app_ui_tokens.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final tariff = ref.watch(tariffLimitsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Профиль',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 28,
            color: AppUiTokens.primaryText,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => context.push('/profile/form'),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC107),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.edit_outlined,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // User Profile Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppUiTokens.surfaceMuted,
                  child: const Icon(
                    Icons.person_outline,
                    size: 40,
                    color: AppUiTokens.secondaryText,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.username ?? '—',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppUiTokens.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.role.displayRu ?? '—',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppUiTokens.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          tariff.when(
            data: (t) {
              final plan = t.planName.isEmpty ? 'Тариф' : t.planName;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Подписка',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppUiTokens.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
                      border: Border.all(color: AppUiTokens.borderSubtle),
                    ),
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
                  const SizedBox(height: 20),
                  Text(
                    'Лимит подписки',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppUiTokens.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                        if (t.validUntil != null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Действует до ${t.validUntil}',
                              style: const TextStyle(
                                color: AppUiTokens.tertiaryText,
                                fontSize: 14,
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
          const SizedBox(height: 20),
          // Menu Items
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
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
                  icon: Icons.settings_outlined,
                  title: 'Настройки аккаунта',
                  onTap: () => context.push('/profile/form'),
                ),
                const Divider(height: 1),
                _ProfileMenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Уведомления',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Уведомления')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionLimitItem extends StatelessWidget {
  final String label;
  final int current;
  final int total;

  const _SubscriptionLimitItem({
    required this.label,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = current / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppUiTokens.primaryText,
              ),
            ),
            Text(
              '$current/$total',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppUiTokens.primaryText,
              ),
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
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppUiTokens.primaryText, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppUiTokens.primaryText,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppUiTokens.tertiaryText),
          ],
        ),
      ),
    );
  }
}
