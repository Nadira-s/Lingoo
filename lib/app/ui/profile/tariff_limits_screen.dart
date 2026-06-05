import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data_providers.dart';
import '../../domain/model/tariff_limits.dart';
import '../widgets/components/app_ui_tokens.dart';
import '../widgets/components/primary_button.dart';

/// «Тариф и лимиты» — как на веб-панели арендатора.
class TariffLimitsScreen extends ConsumerWidget {
  const TariffLimitsScreen({super.key});

  static final _money = NumberFormat('#,##0.00', 'ru');

  String _moneyStr(double v, String currency) {
    if (v <= 0) return '—';
    return '${_money.format(v)} $currency';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tariff = ref.watch(tariffLimitsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppUiTokens.primaryText,
        elevation: 0,
        title: const Text(
          'Тариф и лимиты',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: tariff.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (t) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(tariffLimitsProvider);
            await ref.read(tariffLimitsProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _SummaryGrid(t: t),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Текущий тариф',
                subtitle: 'Тариф платформы и стоимость по лимиту сотрудников',
                child: Column(
                  children: [
                    _InfoRow(
                      label: 'Уровень тарифа',
                      value: t.tariffLevel.isEmpty
                          ? (t.planName.isEmpty ? '—' : t.planName)
                          : t.tariffLevel,
                    ),
                    _InfoRow(
                      label: 'Тариф платформы',
                      value: t.platformTariffName.isEmpty
                          ? (t.planName.isEmpty ? '—' : t.planName)
                          : t.platformTariffName,
                    ),
                    _InfoRow(
                      label: 'Ставка за 1 сотрудника / мес',
                      value: _moneyStr(t.pricePerStaffMonth, t.currency),
                    ),
                    _InfoRow(
                      label: 'Итого за текущий лимит / мес',
                      value: _moneyStr(t.totalMonthlyCost, t.currency),
                      emphasize: true,
                    ),
                    if (t.validUntil != null && t.validUntil!.isNotEmpty)
                      _InfoRow(label: 'Действует до', value: t.validUntil!),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Использование по сотрудникам',
                subtitle: 'Сколько мест из лимита занято',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${t.activeStaff} из ${t.staffLimit > 0 ? t.staffLimit : '—'} сотрудников',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${(t.staffUsagePercent * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFC6A400),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: t.staffLimit > 0 ? t.staffUsagePercent : 0,
                        minHeight: 10,
                        backgroundColor: AppUiTokens.borderSubtle,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFFC107),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.push('/staff'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppUiTokens.primaryText,
                              side: const BorderSide(
                                color: AppUiTokens.borderSubtle,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Управлять сотрудниками',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: PrimaryButton(
                            label: 'Добавить',
                            onPressed: () => context.push('/staff/new'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Ключевые показатели',
                subtitle: 'Сводка по салону',
                child: Column(
                  children: [
                    _InfoRow(
                      label: 'Всего записей',
                      value: '${t.totalBookings}',
                    ),
                    _InfoRow(
                      label: 'Услуг в каталоге',
                      value: '${t.servicesInCatalog > 0 ? t.servicesInCatalog : t.activeServices}',
                    ),
                    _InfoRow(
                      label: 'Филиалов',
                      value: '${t.branchesCount > 0 ? t.branchesCount : t.activeBranches}',
                    ),
                  ],
                ),
              ),
              if (t.items.isNotEmpty) ...[
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Лимиты подписки',
                  subtitle: 'Использование по разделам',
                  child: Column(
                    children: [
                      for (var i = 0; i < t.items.length; i++) ...[
                        if (i > 0) const SizedBox(height: 14),
                        _LimitBar(item: t.items[i]),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _SectionCard(
                title: 'История изменений лимита',
                subtitle: 'Последние изменения тарифа',
                child: t.history.isEmpty
                    ? const Text(
                        'Изменений пока нет',
                        style: TextStyle(
                          color: AppUiTokens.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : Column(
                        children: [
                          for (var i = 0; i < t.history.length; i++) ...[
                            if (i > 0)
                              const Divider(height: 20, color: AppUiTokens.borderSubtle),
                            _HistoryRow(entry: t.history[i]),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.t});

  final TariffLimits t;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: [
        _StatTile(label: 'Лимит сотрудников', value: '${t.staffLimit}'),
        _StatTile(label: 'Активных сотрудников', value: '${t.activeStaff}'),
        _StatTile(label: 'Активных услуг', value: '${t.activeServices}'),
        _StatTile(label: 'Активных филиалов', value: '${t.activeBranches}'),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
        border: Border.all(color: AppUiTokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppUiTokens.secondaryText,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppUiTokens.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
        border: Border.all(color: AppUiTokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppUiTokens.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppUiTokens.secondaryText,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
                fontSize: emphasize ? 16 : 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LimitBar extends StatelessWidget {
  const _LimitBar({required this.item});

  final TariffLimitItem item;

  @override
  Widget build(BuildContext context) {
    final total = item.limit > 0 ? item.limit : 1;
    final pct = (item.used / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              '${item.used}/$total',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: AppUiTokens.borderSubtle,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFC107)),
          ),
        ),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});

  final TariffLimitHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title.isEmpty ? 'Изменение лимита' : entry.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (entry.subtitle.isNotEmpty)
                Text(
                  entry.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppUiTokens.secondaryText,
                  ),
                ),
            ],
          ),
        ),
        if (entry.date.isNotEmpty)
          Text(
            entry.date.length > 10 ? entry.date.substring(0, 10) : entry.date,
            style: const TextStyle(
              fontSize: 12,
              color: AppUiTokens.tertiaryText,
            ),
          ),
      ],
    );
  }
}
