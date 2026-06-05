import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/model/booking.dart';
import '../components/app_ui_tokens.dart';
import '../components/booking_status_badge.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.booking, required this.onTap});

  final Booking booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final timeText = booking.startsAt != null
        ? DateFormat('HH:mm').format(booking.startsAt!.toLocal())
        : '—';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
              border: Border.all(color: AppUiTokens.borderSubtle),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
                    child: Container(
                      width: 64,
                      height: 64,
                      color: AppUiTokens.surfaceMuted,
                      child: Icon(
                        Icons.person_rounded,
                        color: AppUiTokens.secondaryText.withValues(alpha: 0.7),
                        size: 32,
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
                            fontSize: 16,
                            color: AppUiTokens.primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${booking.serviceName.isEmpty ? 'Услуга' : booking.serviceName}, $timeText',
                          style: const TextStyle(
                            color: AppUiTokens.secondaryText,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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
    );
  }
}
