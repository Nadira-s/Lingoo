import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/components/app_ui_tokens.dart';
import '../widgets/cards/booking_card.dart';
import '../widgets/components/bordered_toolbar_icon.dart';
import '../widgets/cards/dashboard_stat_card.dart';
import '../widgets/components/section_header.dart';
import '../../auth_notifier.dart';
import '../../dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).valueOrNull;
    final dashboard = ref.watch(dashboardDataProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardDataProvider);
            await ref.read(dashboardDataProvider.future);
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Привет, ${user?.username ?? 'Анна'} 👋',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppUiTokens.primaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            Text(
                              user?.role.displayRu ?? 'Администратор',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppUiTokens.secondaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      BorderedToolbarIcon(
                        onPressed: () {},
                        child: Image.asset(
                          'assets/icons/Vector.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ],
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
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SectionHeader('Статистика'),
                    const SizedBox(height: 16),
                    dashboard.when(
                      data: (d) {
                        final staffSub = d.staffLimit != null && d.staffLimit! > 0
                            ? 'Лимит: ${d.staffUsed ?? d.stats.staff}/${d.staffLimit}'
                            : 'Активные сотрудники';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                                      onTap: () =>
                                          context.push('/bookings/${b.id}'),
                                    ),
                                  ),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text(
                        'Ошибка статистики: $e',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.go('/bookings'),
                        child: Text(
                          'Смотреть все',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ),
                  ]),
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
