import 'package:flutter/material.dart';

import 'app_ui_tokens.dart';

class BookingStatusBadge extends StatelessWidget {
  const BookingStatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final ui = _styleFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ui.bg,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusSm),
      ),
      child: Text(
        ui.label,
        style: TextStyle(
          color: ui.text,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  _BookingStatusStyle _styleFor(String raw) {
    switch (raw.toLowerCase()) {
      case 'confirmed':
        return const _BookingStatusStyle(
          'Подтверждена',
          Color(0xFFE8F8EE),
          Color(0xFF1B7A3D),
        );
      case 'pending':
      case 'new':
        return const _BookingStatusStyle(
          'Новая',
          Color(0xFFE6F4FF),
          Color(0xFF0B57D0),
        );
      case 'cancelled':
        return const _BookingStatusStyle(
          'Отменена',
          Color(0xFFFFF1F0),
          Color(0xFFC62828),
        );
      case 'completed':
        return const _BookingStatusStyle(
          'Завершена',
          Color(0xFFF0F0F0),
          AppUiTokens.primaryText,
        );
      default:
        return const _BookingStatusStyle(
          'Ожидает',
          Color(0xFFFFF7E6),
          Color(0xFFB45309),
        );
    }
  }
}

class _BookingStatusStyle {
  const _BookingStatusStyle(this.label, this.bg, this.text);
  final String label;
  final Color bg;
  final Color text;
}
