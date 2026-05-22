import 'booking.dart';
import 'dashboard_stats.dart';

class DashboardData {
  const DashboardData({
    required this.stats,
    this.recentBookings = const [],
    this.staffUsed,
    this.staffLimit,
  });

  final DashboardStats stats;
  final List<Booking> recentBookings;
  final int? staffUsed;
  final int? staffLimit;
}
