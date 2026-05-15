import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/repository/mock_business_data.dart';
import 'domain/model/booking.dart';
import 'domain/model/branch.dart';
import 'domain/model/salon_service.dart';
import 'domain/model/staff_member.dart';

final branchesListProvider = FutureProvider.autoDispose<List<Branch>>((
  ref,
) async {
  return MockBusinessData.branches;
});

final servicesListProvider = FutureProvider.autoDispose<List<SalonService>>((
  ref,
) async {
  return MockBusinessData.services;
});

final staffListProvider = FutureProvider.autoDispose<List<StaffMember>>((
  ref,
) async {
  return MockBusinessData.staff;
});

final bookingsListProvider = FutureProvider.autoDispose
    .family<List<Booking>, BookingsQuery>((ref, query) async {
      return MockBusinessData.todayBookings;
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
  final b = MockBusinessData.bookingById(id);
  if (b != null) return b;
  throw StateError('Запись не найдена');
});

final branchDetailProvider = FutureProvider.autoDispose.family<Branch, int>((
  ref,
  id,
) async {
  final b = MockBusinessData.branchById(id);
  if (b != null) return b;
  throw StateError('Филиал не найден');
});

final serviceDetailProvider = FutureProvider.autoDispose
    .family<SalonService, int>((ref, id) async {
      final s = MockBusinessData.serviceById(id);
      if (s != null) return s;
      throw StateError('Услуга не найдена');
    });

final staffDetailProvider = FutureProvider.autoDispose.family<StaffMember, int>(
  (ref, id) async {
    final s = MockBusinessData.staffById(id);
    if (s != null) return s;
    throw StateError('Сотрудник не найден');
  },
);
