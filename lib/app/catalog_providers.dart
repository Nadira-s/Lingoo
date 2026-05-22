import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_notifier.dart';
import 'di/app_providers.dart';
import 'domain/model/booking.dart';
import 'domain/model/branch.dart';
import 'domain/model/salon_service.dart';
import 'domain/model/staff_member.dart';
import 'domain/model/staff_schedule.dart';

final branchesListProvider = FutureProvider.autoDispose<List<Branch>>((
  ref,
) async {
  if (ref.watch(authNotifierProvider).valueOrNull == null) return [];
  return ref.read(lingooRepositoryProvider).getBranches();
});

final servicesListProvider = FutureProvider.autoDispose<List<SalonService>>((
  ref,
) async {
  if (ref.watch(authNotifierProvider).valueOrNull == null) return [];
  return ref.read(lingooRepositoryProvider).getServices();
});

final staffListProvider = FutureProvider.autoDispose<List<StaffMember>>((
  ref,
) async {
  if (ref.watch(authNotifierProvider).valueOrNull == null) return [];
  return ref.read(lingooRepositoryProvider).getStaff();
});

final bookingsListProvider = FutureProvider.autoDispose
    .family<List<Booking>, BookingsQuery>((ref, query) async {
      if (ref.watch(authNotifierProvider).valueOrNull == null) return [];
      return ref.read(lingooRepositoryProvider).getBookings(
        dateFrom: query.dateFrom,
        dateTo: query.dateTo,
        status: query.status,
        staffId: query.staffId,
        search: query.search,
      );
    });

class BookingsQuery {
  const BookingsQuery({
    this.dateFrom,
    this.dateTo,
    this.status,
    this.staffId,
    this.search,
  });

  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? status;
  final int? staffId;
  final String? search;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingsQuery &&
          dateFrom == other.dateFrom &&
          dateTo == other.dateTo &&
          status == other.status &&
          staffId == other.staffId &&
          search == other.search;

  @override
  int get hashCode => Object.hash(dateFrom, dateTo, status, staffId, search);
}

final bookingDetailProvider = FutureProvider.autoDispose.family<Booking, int>((
  ref,
  id,
) async {
  return ref.read(lingooRepositoryProvider).getBooking(id);
});

final branchDetailProvider = FutureProvider.autoDispose.family<Branch, int>((
  ref,
  id,
) async {
  return ref.read(lingooRepositoryProvider).getBranch(id);
});

final serviceDetailProvider = FutureProvider.autoDispose
    .family<SalonService, int>((ref, id) async {
      return ref.read(lingooRepositoryProvider).getService(id);
    });

final staffDetailProvider = FutureProvider.autoDispose.family<StaffMember, int>(
  (ref, id) async {
    return ref.read(lingooRepositoryProvider).getStaffMember(id);
  },
);

final staffScheduleProvider =
    FutureProvider.autoDispose.family<StaffSchedule, int>((ref, staffId) async {
  return ref.read(lingooRepositoryProvider).getStaffSchedule(staffId);
});

/// Записи на выбранный календарный день.
final dayBookingsProvider = FutureProvider.autoDispose
    .family<List<Booking>, DateTime>((ref, day) async {
  if (ref.watch(authNotifierProvider).valueOrNull == null) return [];
  final start = DateTime(day.year, day.month, day.day);
  final end = start.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
  return ref.read(lingooRepositoryProvider).getBookings(
        dateFrom: start,
        dateTo: end,
      );
    });

/// Записи на сегодня (дашборд менеджера).
final todayBookingsProvider = FutureProvider.autoDispose<List<Booking>>((
  ref,
) async {
  final now = DateTime.now();
  return ref.read(dayBookingsProvider(now).future);
});
