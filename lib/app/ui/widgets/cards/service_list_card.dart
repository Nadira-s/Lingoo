import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/model/salon_service.dart';
import '../components/active_status_chip.dart';
import 'catalog_item_card.dart';

/// Карточка услуги на базе [CatalogItemCard].
class ServiceListCard extends StatelessWidget {
  const ServiceListCard({
    super.key,
    required this.service,
    required this.onEdit,
    this.onSchedule,
    this.readOnly = false,
  });

  final SalonService service;
  final VoidCallback onEdit;
  final VoidCallback? onSchedule;
  final bool readOnly;

  static final _priceFormat = NumberFormat('#,###', 'ru');

  static (String emoji, Color bg) _visualFor(SalonService s) {
    final n = s.name.toLowerCase();
    const lilac = Color(0xFFE8E0FF);
    const pink = Color(0xFFFFE8F0);
    const blue = Color(0xFFE8F4FF);
    if (n.contains('маникюр') || n.contains('педикюр')) {
      return ('💅', lilac);
    }
    if (n.contains('стриж') || n.contains('уклад')) {
      return ('💇‍♀️', lilac);
    }
    if (n.contains('макияж')) {
      return ('💄', pink);
    }
    if (n.contains('окраш') || n.contains('краск')) {
      return ('🎨', blue);
    }
    if (n.contains('мужск')) {
      return ('💇', lilac);
    }
    return ('✨', lilac);
  }

  String _formatPrice(double price) {
    final n = price.round();
    return '${_priceFormat.format(n).replaceAll(',', ' ')} ₸';
  }

  @override
  Widget build(BuildContext context) {
    final (emoji, thumbBg) = _visualFor(service);
    final name = service.name.isEmpty ? 'Услуга' : service.name;
    final subtitle = '${service.durationMinutes} мин';

    return CatalogItemCard(
      statusBadge: ActiveStatusChip(
        active: service.isActive,
        activeLabel: 'Активен',
        inactiveLabel: 'Неактивен',
      ),
      title: name,
      subtitle: subtitle,
      trailingVisual: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ColoredBox(
          color: thumbBg,
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 46)),
          ),
        ),
      ),
      primaryAction: readOnly
          ? null
          : CatalogItemCardAction(
              label: _formatPrice(service.price),
              icon: Icons.payments_outlined,
              onPressed: onEdit,
              style: CatalogItemCardButtonStyle.outlined,
            ),
      secondaryAction: readOnly
          ? null
          : CatalogItemCardAction(
              label: 'Расписание',
              icon: Icons.calendar_today_outlined,
              onPressed: onSchedule ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Расписание (скоро)')),
                    );
                  },
              style: CatalogItemCardButtonStyle.filledAccent,
            ),
      onCardTap: readOnly ? null : onEdit,
    );
  }
}
