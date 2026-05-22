import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_notifier.dart';
import 'di/app_providers.dart';
import 'domain/model/booking_stats.dart';
import 'domain/model/business_settings.dart';
import 'domain/model/tariff_limits.dart';

final bookingsStatsProvider = FutureProvider.autoDispose<BookingStats>((
  ref,
) async {
  if (ref.watch(authNotifierProvider).valueOrNull == null) {
    return const BookingStats();
  }
  return ref.read(lingooRepositoryProvider).getBookingsStats();
});

final businessSettingsProvider = FutureProvider.autoDispose<BusinessSettings>((
  ref,
) async {
  if (ref.watch(authNotifierProvider).valueOrNull == null) {
    return const BusinessSettings();
  }
  return ref.read(lingooRepositoryProvider).getBusinessSettings();
});

final tariffLimitsProvider = FutureProvider.autoDispose<TariffLimits>((
  ref,
) async {
  if (ref.watch(authNotifierProvider).valueOrNull == null) {
    return const TariffLimits();
  }
  return ref.read(lingooRepositoryProvider).getTariffLimits();
});

final publicBookingUrlProvider = FutureProvider.autoDispose<String>((ref) async {
  if (ref.watch(authNotifierProvider).valueOrNull == null) return '';
  return ref.read(lingooRepositoryProvider).getPublicBookingUrl();
});
