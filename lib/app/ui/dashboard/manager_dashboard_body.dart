import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth_notifier.dart';
import '../../catalog_providers.dart';
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
    final branches = ref.watch(branchesListProvider);

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
                  onTap: () => context.push('/bookings/${b.id}'),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Ошибка: $e'),
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
        branches.when(
          data: (list) {
            final branchName = user?.staffProfile?.branchName.isNotEmpty == true
                ? user!.staffProfile!.branchName
                : (list.isNotEmpty ? list.first.name : 'Не назначен');
            final address = list.isNotEmpty && list.first.address.isNotEmpty
                ? list.first.address
                : 'Адрес не указан';
            return _BranchCard(name: branchName, address: address);
          },
          loading: () => const _BranchCard(name: '…', address: ''),
          error: (_, __) => const _BranchCard(
            name: 'Филиал',
            address: 'Не удалось загрузить',
          ),
        ),
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
