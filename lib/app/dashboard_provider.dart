import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'di/app_providers.dart';
import 'domain/model/dashboard_data.dart';
import 'domain/model/dashboard_stats.dart';
import 'provider_helpers.dart';

final dashboardDataProvider = FutureProvider.autoDispose<DashboardData>((
  ref,
) async {
  final user = await waitForUser(ref);
  if (user == null) {
    return const DashboardData(
      stats: DashboardStats(
        branches: 0,
        services: 0,
        staff: 0,
        bookings: 0,
      ),
    );
  }
  return apiWithTimeout(
    ref.read(lingooRepositoryProvider).getDashboard(),
    const DashboardData(
      stats: DashboardStats(
        branches: 0,
        services: 0,
        staff: 0,
        bookings: 0,
      ),
    ),
  );
});

final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((
  ref,
) async {
  final data = await ref.watch(dashboardDataProvider.future);
  return data.stats;
});
