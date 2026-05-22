import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_notifier.dart';
import 'di/app_providers.dart';
import 'domain/model/dashboard_data.dart';
import 'domain/model/dashboard_stats.dart';

final dashboardDataProvider = FutureProvider.autoDispose<DashboardData>((
  ref,
) async {
  if (ref.watch(authNotifierProvider).valueOrNull == null) {
    return const DashboardData(
      stats: DashboardStats(
        branches: 0,
        services: 0,
        staff: 0,
        bookings: 0,
      ),
    );
  }
  return ref.read(lingooRepositoryProvider).getDashboard();
});

final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((
  ref,
) async {
  final data = await ref.watch(dashboardDataProvider.future);
  return data.stats;
});
