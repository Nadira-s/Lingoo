import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'domain/model/dashboard_stats.dart';
import 'domain/model/user_profile.dart';
import 'auth_notifier.dart';
import 'network_providers.dart';

final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((
  ref,
) async {
  final AsyncValue<UserProfile?> auth = ref.watch(authNotifierProvider);
  if (auth.valueOrNull == null) {
    return const DashboardStats(
      branches: 0,
      services: 0,
      staff: 0,
      bookings: 0,
    );
  }
  return ref.read(businessApiProvider).fetchDashboard();
});
