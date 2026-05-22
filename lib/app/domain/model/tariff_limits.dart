import '../../data/api/json_helpers.dart';

class TariffLimitItem {
  const TariffLimitItem({required this.label, required this.used, required this.limit});

  final String label;
  final int used;
  final int limit;
}

class TariffLimits {
  const TariffLimits({
    this.planName = '',
    this.usagePercent = 0,
    this.items = const [],
    this.validUntil,
  });

  final String planName;
  final double usagePercent;
  final List<TariffLimitItem> items;
  final String? validUntil;

  factory TariffLimits.fromJson(Map<String, dynamic> json) {
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

    return TariffLimits(
      planName: readString(json, 'pricing_plan_name').isEmpty
          ? readString(json, 'plan_name')
          : readString(json, 'pricing_plan_name'),
      usagePercent: readDouble(json['usage_percent']) ?? 0,
      items: items,
      validUntil: readString(json, 'valid_until').isEmpty
          ? null
          : readString(json, 'valid_until'),
    );
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
