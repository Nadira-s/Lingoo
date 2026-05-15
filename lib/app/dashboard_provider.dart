import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/repository/mock_business_data.dart';
import 'domain/model/dashboard_stats.dart';
import 'domain/model/user_profile.dart';
import 'auth_notifier.dart';

final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((
  ref,
) async {
  final AsyncValue<UserProfile?> auth = ref.watch(authNotifierProvider);
  final user = auth.valueOrNull;
  if (user == null) {
    return const DashboardStats(
      branches: 0,
      services: 0,
      staff: 0,
      bookings: 0,
    );
  }

  final m = MockBusinessData.dashboardStats;
  return DashboardStats(
    branches: m.branches,
    services: m.services,
    staff: m.staff,
    bookings: m.bookingsToday,
  );
});
