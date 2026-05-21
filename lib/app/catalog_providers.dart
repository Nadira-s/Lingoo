import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_notifier.dart';
import 'domain/model/booking.dart';
import 'domain/model/branch.dart';
import 'domain/model/salon_service.dart';
import 'domain/model/staff_member.dart';
import 'network_providers.dart';

final branchesListProvider = FutureProvider.autoDispose<List<Branch>>((
  ref,
) async {
  if (ref.watch(authNotifierProvider).valueOrNull == null) return [];
  final (list, _) = await ref.read(businessApiProvider).fetchBranches();
  return list;
});

final servicesListProvider = FutureProvider.autoDispose<List<SalonService>>((
  ref,
) async {
  if (ref.watch(authNotifierProvider).valueOrNull == null) return [];
  final (list, _) = await ref.read(businessApiProvider).fetchServices();
  return list;
});

final staffListProvider = FutureProvider.autoDispose<List<StaffMember>>((
  ref,
) async {
  if (ref.watch(authNotifierProvider).valueOrNull == null) return [];
  final (list, _) = await ref.read(businessApiProvider).fetchStaff();
  return list;
});

final bookingsListProvider = FutureProvider.autoDispose
    .family<List<Booking>, BookingsQuery>((ref, query) async {
      if (ref.watch(authNotifierProvider).valueOrNull == null) return [];
      final (list, _) = await ref.read(businessApiProvider).fetchBookings(
        dateFrom: query.dateFrom,
        dateTo: query.dateTo,
        status: query.status,
        staffId: query.staffId,
      );
      return list;
    });

class BookingsQuery {
  const BookingsQuery({this.dateFrom, this.dateTo, this.status, this.staffId});

  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? status;
  final int? staffId;

  BookingsQuery copyWith({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? status,
    int? staffId,
  }) {
    return BookingsQuery(
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      status: status ?? this.status,
      staffId: staffId ?? this.staffId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingsQuery &&
          runtimeType == other.runtimeType &&
          dateFrom == other.dateFrom &&
          dateTo == other.dateTo &&
          status == other.status &&
          staffId == other.staffId;

  @override
  int get hashCode => Object.hash(dateFrom, dateTo, status, staffId);
}

final bookingDetailProvider = FutureProvider.autoDispose.family<Booking, int>((
  ref,
  id,
) async {
  return ref.read(businessApiProvider).fetchBooking(id);
});

final branchDetailProvider = FutureProvider.autoDispose.family<Branch, int>((
  ref,
  id,
) async {
  return ref.read(businessApiProvider).fetchBranch(id);
});

final serviceDetailProvider = FutureProvider.autoDispose
    .family<SalonService, int>((ref, id) async {
      return ref.read(businessApiProvider).fetchService(id);
    });

final staffDetailProvider = FutureProvider.autoDispose.family<StaffMember, int>(
  (ref, id) async {
    return ref.read(businessApiProvider).fetchStaffMember(id);
  },
);
