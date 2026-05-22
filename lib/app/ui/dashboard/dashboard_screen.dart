import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/components/app_ui_tokens.dart';
import '../widgets/cards/booking_card.dart';
import '../widgets/components/dashboard_header.dart';
import '../widgets/cards/dashboard_stat_card.dart';
import '../widgets/components/section_header.dart';
import '../../auth_notifier.dart';
import '../../catalog_providers.dart';
import '../../dashboard_provider.dart';
import 'manager_dashboard_body.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final isManager = user?.role.isManager ?? false;
    final dashboard = ref.watch(dashboardDataProvider);

    final greetingName = isManager && user?.staffProfile?.name.isNotEmpty == true
        ? user!.staffProfile!.name.split(' ').first
        : (user?.username ?? '');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardDataProvider);
            if (isManager) {
              ref.invalidate(todayBookingsProvider);
            }
            await ref.read(dashboardDataProvider.future);
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                sliver: SliverToBoxAdapter(
                  child: DashboardHeader(
                    greeting: 'Привет, $greetingName 👋',
                    subtitle: user?.role.displayRu ?? 'Администратор',
                    onNotifications: () => context.push('/notifications'),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Divider(
                  color: AppUiTokens.borderSubtle,
                  thickness: 1,
                  height: 1,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                sliver: SliverToBoxAdapter(
                  child: isManager
                      ? const ManagerDashboardBody()
                      : dashboard.when(
                          data: (d) {
                            final staffSub =
                                d.staffLimit != null && d.staffLimit! > 0
                                    ? 'Лимит: ${d.staffUsed ?? d.stats.staff}/${d.staffLimit}'
                                    : 'Активные сотрудники';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SectionHeader('Статистика'),
                                const SizedBox(height: 16),
                                _StatsGrid(
                                  context: context,
                                  branches: d.stats.branches,
                                  services: d.stats.services,
                                  staff: d.stats.staff,
                                  bookings: d.stats.bookings,
                                  staffSubLabel: staffSub,
                                ),
                                const SizedBox(height: 32),
                                const SectionHeader('Сегодняшние записи'),
                                const SizedBox(height: 16),
                                if (d.recentBookings.isEmpty)
                                  const Text('Записей на сегодня нет')
                                else
                                  ...d.recentBookings.take(3).map(
                                        (b) => BookingCard(
                                          booking: b,
                                          onTap: () => context.push(
                                            '/bookings/${b.id}',
                                          ),
                                        ),
                                      ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => context.go('/bookings'),
                                    child: const Text(
                                      'Смотреть все',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (e, _) => Text(
                            'Ошибка статистики: $e',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.context,
    required this.branches,
    required this.services,
    required this.staff,
    required this.bookings,
    this.staffSubLabel = 'Активные сотрудники',
  });

  final BuildContext context;
  final int branches;
  final int services;
  final int staff;
  final int bookings;
  final String staffSubLabel;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.18,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        late String label;
        late int value;
        late String subLabel;
        late VoidCallback onTap;

        switch (index) {
          case 0:
            label = 'Филиалы';
            value = branches;
            subLabel = 'Активные филиалы';
            onTap = () => context.go('/branches');
            break;
          case 1:
            label = 'Услуги';
            value = services;
            subLabel = 'Всего услуг';
            onTap = () => context.go('/services');
            break;
          case 2:
            label = 'Сотрудники';
            value = staff;
            subLabel = staffSubLabel;
            onTap = () => context.go('/staff');
            break;
          case 3:
            label = 'Записи';
            value = bookings;
            subLabel = 'На сегодня';
            onTap = () => context.go('/bookings');
            break;
        }

        return DashboardStatCard(
          label: label,
          value: value,
          subLabel: subLabel,
          onTap: onTap,
        );
      },
    );
  }
}
