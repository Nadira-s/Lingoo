import '../../data/api/json_helpers.dart';

class TariffLimitItem {
  const TariffLimitItem({
    required this.label,
    required this.used,
    required this.limit,
  });

  final String label;
  final int used;
  final int limit;
}

class TariffLimitHistoryEntry {
  const TariffLimitHistoryEntry({
    required this.title,
    this.subtitle = '',
    this.date = '',
  });

  final String title;
  final String subtitle;
  final String date;

  factory TariffLimitHistoryEntry.fromJson(Map<String, dynamic> json) {
    return TariffLimitHistoryEntry(
      title: readString(json, 'title').isEmpty
          ? readString(json, 'description')
          : readString(json, 'title'),
      subtitle: readString(json, 'subtitle').isEmpty
          ? readString(json, 'change')
          : readString(json, 'subtitle'),
      date: readString(json, 'date').isEmpty
          ? readString(json, 'created_at')
          : readString(json, 'date'),
    );
  }
}

class TariffLimits {
  const TariffLimits({
    this.planName = '',
    this.usagePercent = 0,
    this.items = const [],
    this.validUntil,
    this.staffLimit = 0,
    this.activeStaff = 0,
    this.activeServices = 0,
    this.activeBranches = 0,
    this.tariffLevel = '',
    this.platformTariffName = '',
    this.pricePerStaffMonth = 0,
    this.totalMonthlyCost = 0,
    this.currency = '₽',
    this.totalBookings = 0,
    this.servicesInCatalog = 0,
    this.branchesCount = 0,
    this.history = const [],
  });

  final String planName;
  final double usagePercent;
  final List<TariffLimitItem> items;
  final String? validUntil;

  /// Верхние карточки (как на веб «Тариф и лимиты»).
  final int staffLimit;
  final int activeStaff;
  final int activeServices;
  final int activeBranches;

  /// Блок «Текущий тариф».
  final String tariffLevel;
  final String platformTariffName;
  final double pricePerStaffMonth;
  final double totalMonthlyCost;
  final String currency;

  /// «Ключевые показатели».
  final int totalBookings;
  final int servicesInCatalog;
  final int branchesCount;

  final List<TariffLimitHistoryEntry> history;

  double get staffUsagePercent {
    if (staffLimit <= 0) return 0;
    return (activeStaff / staffLimit).clamp(0.0, 1.0);
  }

  factory TariffLimits.fromJson(Map<String, dynamic> json) {
    final staffLimit = _firstInt(json, [
      'staff_limit',
      'staff_limit_max',
      'max_staff',
    ]);
    final activeStaff = _firstInt(json, [
      'active_staff',
      'staff_active_count',
      'staff_active',
    ], fallback: _firstInt(json, ['total_staff', 'staff_count']));
    final activeServices = _firstInt(json, [
      'active_services',
      'services_active_count',
      'services_active',
    ], fallback: _firstInt(json, ['total_services', 'services_count']));
    final activeBranches = _firstInt(json, [
      'active_branches',
      'branches_active_count',
      'branches_active',
    ], fallback: _firstInt(json, ['total_branches', 'branches_count']));

    final items = <TariffLimitItem>[
      _item(json, 'Филиалы', ['total_branches', 'branches'], ['branches_limit']),
      _item(json, 'Сотрудники', ['total_staff', 'staff'], ['staff_limit', 'staff_limit_max']),
      _item(json, 'Услуги', ['total_services', 'services'], ['services_limit']),
      _item(
        json,
        'Записи',
        ['total_bookings', 'bookings'],
        ['bookings_limit', 'bookings_monthly_limit'],
      ),
    ].where((e) => e.limit > 0 || e.used > 0).toList();

    final historyRaw = json['limit_history'] ??
        json['history'] ??
        json['limit_changes'] ??
        json['changes'];
    final history = historyRaw is List
        ? historyRaw
            .whereType<Map>()
            .map((e) => TariffLimitHistoryEntry.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList()
        : const <TariffLimitHistoryEntry>[];

    final currency = readString(json, 'currency').isEmpty
        ? '₽'
        : readString(json, 'currency');

    return TariffLimits(
      planName: readString(json, 'pricing_plan_name').isEmpty
          ? readString(json, 'plan_name')
          : readString(json, 'pricing_plan_name'),
      usagePercent: readDouble(json['usage_percent']) ?? 0,
      items: items,
      validUntil: readString(json, 'valid_until').isEmpty
          ? null
          : readString(json, 'valid_until'),
      staffLimit: staffLimit,
      activeStaff: activeStaff,
      activeServices: activeServices,
      activeBranches: activeBranches,
      tariffLevel: readString(json, 'tariff_level').isEmpty
          ? readString(json, 'tier')
          : readString(json, 'tariff_level'),
      platformTariffName: readString(json, 'platform_tariff_name').isEmpty
          ? (readString(json, 'platform_tariff').isEmpty
              ? readString(json, 'pricing_plan_name')
              : readString(json, 'platform_tariff'))
          : readString(json, 'platform_tariff_name'),
      pricePerStaffMonth: _firstDouble(json, [
        'price_per_staff_month',
        'staff_price_monthly',
        'rate_per_staff',
        'price_per_staff',
      ]),
      totalMonthlyCost: _firstDouble(json, [
        'total_monthly_cost',
        'monthly_total',
        'total_for_limit',
        'total_monthly',
      ]),
      currency: currency,
      totalBookings: _firstInt(json, ['total_bookings', 'bookings_total']),
      servicesInCatalog: _firstInt(
        json,
        ['services_in_catalog', 'catalog_services', 'total_services'],
        fallback: activeServices,
      ),
      branchesCount: _firstInt(
        json,
        ['branches_count', 'total_branches'],
        fallback: activeBranches,
      ),
      history: history,
    );
  }

  static int _firstInt(
    Map<String, dynamic> json,
    List<String> keys, {
    int fallback = 0,
  }) {
    for (final k in keys) {
      final v = readInt(json[k]);
      if (v != null) return v;
    }
    return fallback;
  }

  static double _firstDouble(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = readDouble(json[k]);
      if (v != null) return v;
    }
    return 0;
  }

  static TariffLimitItem _item(
    Map<String, dynamic> json,
    String label,
    List<String> usedKeys,
    List<String> limitKeys,
  ) {
    var used = 0;
    var limit = 0;
    for (final k in usedKeys) {
      final v = readInt(json[k]);
      if (v != null) used = v;
    }
    for (final k in limitKeys) {
      final v = readInt(json[k]);
      if (v != null) limit = v;
    }
    return TariffLimitItem(label: label, used: used, limit: limit);
  }
}
