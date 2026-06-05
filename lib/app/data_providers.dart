import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'di/app_providers.dart';
import 'domain/model/booking_stats.dart';
import 'domain/model/business_settings.dart';
import 'domain/model/tariff_limits.dart';
import 'provider_helpers.dart';

final bookingsStatsProvider = FutureProvider.autoDispose<BookingStats>((
  ref,
) async {
  final user = await waitForUser(ref);
  if (user == null) return defaultBookingStats;
  return apiWithTimeout(
    ref.read(lingooRepositoryProvider).getBookingsStats(),
    defaultBookingStats,
  );
});

final businessSettingsProvider = FutureProvider.autoDispose<BusinessSettings>((
  ref,
) async {
  final user = await waitForUser(ref);
  if (user == null) return const BusinessSettings();
  return apiWithTimeout(
    ref.read(lingooRepositoryProvider).getBusinessSettings(),
    const BusinessSettings(),
  );
});

final tariffLimitsProvider = FutureProvider.autoDispose<TariffLimits>((
  ref,
) async {
  final user = await waitForUser(ref);
  if (user == null) return defaultTariffLimits;
  return apiWithTimeout(
    ref.read(lingooRepositoryProvider).getTariffLimits(),
    defaultTariffLimits,
  );
});

final publicBookingUrlProvider = FutureProvider.autoDispose<String>((ref) async {
  final user = await waitForUser(ref);
  if (user == null) return '';
  return apiWithTimeout(
    ref.read(lingooRepositoryProvider).getPublicBookingUrl(),
    '',
  );
});
