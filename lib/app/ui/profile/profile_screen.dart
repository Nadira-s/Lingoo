import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth_notifier.dart';
import '../widgets/components/app_ui_tokens.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).valueOrNull;

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
          // Subscription Card
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
                const Text(
                  'План: Премиум',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppUiTokens.primaryText,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4EDDA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Активна',
                    style: TextStyle(
                      color: Color(0xFF155724),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Subscription Limits
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
                _SubscriptionLimitItem(label: 'Филиалы', current: 3, total: 5),
                const SizedBox(height: 16),
                _SubscriptionLimitItem(
                  label: 'Сотрудники',
                  current: 12,
                  total: 20,
                ),
                const SizedBox(height: 16),
                _SubscriptionLimitItem(label: 'Услуги', current: 24, total: 50),
                const SizedBox(height: 16),
                _SubscriptionLimitItem(
                  label: 'Записи в месяц',
                  current: 248,
                  total: 1000,
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Действует до 24.05.2026',
                    style: TextStyle(
                      color: AppUiTokens.tertiaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
