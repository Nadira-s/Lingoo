import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth_notifier.dart';
import '../../catalog_providers.dart';
import '../../navigation/app_navigation.dart';
import '../widgets/cards/booking_card.dart';
import '../widgets/components/app_ui_tokens.dart';
import '../widgets/components/section_header.dart';

/// Дашборд менеджера: записи на сегодня + мой филиал.
class ManagerDashboardBody extends ConsumerWidget {
  const ManagerDashboardBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final today = ref.watch(todayBookingsProvider);

    final branchName = user?.staffProfile?.branchName.isNotEmpty == true
        ? user!.staffProfile!.branchName
        : 'Не назначен';
    const address = 'Адрес уточняется у администратора';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('Сегодняшние записи'),
        const SizedBox(height: 16),
        today.when(
          data: (bookings) {
            if (bookings.isEmpty) {
              return const Text('Записей на сегодня нет');
            }
            return Column(
              children: bookings.take(5).map((b) {
                return BookingCard(
                  booking: b,
                  onTap: () => openBookingDetail(context, b.id),
                );
              }).toList(),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text(
            'Не удалось загрузить записи. Потяните вниз для обновления.',
            style: TextStyle(color: AppUiTokens.secondaryText),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.go('/bookings'),
            child: const Text(
              'Смотреть все',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader('Мой филиал'),
        const SizedBox(height: 12),
        _BranchCard(name: branchName, address: address),
      ],
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({required this.name, required this.address});

  final String name;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
        border: Border.all(color: AppUiTokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            address,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppUiTokens.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
