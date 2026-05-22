import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/model/booking.dart';
import '../components/app_ui_tokens.dart';
import '../components/booking_status_badge.dart';

/// Строка расписания: время слева + карточка записи.
class ScheduleBookingRow extends StatelessWidget {
  const ScheduleBookingRow({
    super.key,
    required this.booking,
    required this.onTap,
    this.selected = false,
  });

  final Booking booking;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final time = booking.startsAt != null
        ? DateFormat('HH:mm').format(booking.startsAt!.toLocal())
        : '—';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppUiTokens.secondaryText,
              ),
            ),
          ),
          Expanded(
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF2196F3)
                          : AppUiTokens.borderSubtle,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppUiTokens.radiusMd),
                          child: Container(
                            width: 48,
                            height: 48,
                            color: AppUiTokens.surfaceMuted,
                            child: Icon(
                              Icons.person_rounded,
                              color: AppUiTokens.secondaryText
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.clientName.isEmpty
                                    ? 'Клиент'
                                    : booking.clientName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                booking.serviceName.isEmpty
                                    ? 'Услуга'
                                    : booking.serviceName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppUiTokens.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        BookingStatusBadge(status: booking.status),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
