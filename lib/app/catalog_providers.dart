import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'di/app_providers.dart';
import 'domain/model/booking.dart';
import 'domain/model/branch.dart';
import 'domain/model/salon_service.dart';
import 'domain/model/staff_member.dart';
import 'domain/model/staff_schedule.dart';
import 'domain/model/user_role.dart';
import 'provider_helpers.dart';

/// Данные для формы «Новая запись».
class BookingFormCatalog {
  const BookingFormCatalog({
    required this.branches,
    required this.services,
    required this.staff,
  });

  final List<Branch> branches;
  final List<SalonService> services;
  final List<StaffMember> staff;
}

final bookingFormCatalogProvider =
    FutureProvider.autoDispose<BookingFormCatalog>((ref) async {
  final user = await waitForUser(ref);
  if (user == null) {
    return const BookingFormCatalog(
      branches: [],
      services: [],
      staff: [],
    );
  }

  final repo = ref.read(lingooRepositoryProvider);

  if (user.isManagerUser && user.staffProfile != null) {
    final profile = user.staffProfile!;
    final branchesRaw =
        await apiWithTimeout(repo.getBranches(), <Branch>[]);
    final servicesRaw =
        await apiWithTimeout(repo.getServices(), defaultServices);
    return BookingFormCatalog(
      branches: branchesForUser(user, branchesRaw),
      services: servicesForManager(user, servicesRaw),
      staff: [profile],
    );
  }

  final results = await Future.wait([
    apiWithTimeout(repo.getBranches(), <Branch>[]),
    apiWithTimeout(repo.getServices(), defaultServices),
    apiWithTimeout(repo.getStaff(), defaultStaff),
  ]);

  return BookingFormCatalog(
    branches: results[0] as List<Branch>,
    services: results[1] as List<SalonService>,
    staff: results[2] as List<StaffMember>,
  );
});

final branchesListProvider = FutureProvider.autoDispose<List<Branch>>((
  ref,
) async {
  final user = await waitForUser(ref);
  if (user == null) return [];
  final raw = await apiWithTimeout(
    ref.read(lingooRepositoryProvider).getBranches(),
    <Branch>[],
  );
  return branchesForUser(user, raw);
});

final servicesListProvider = FutureProvider.autoDispose<List<SalonService>>((
  ref,
) async {
  final user = await waitForUser(ref);
  if (user == null) return [];
  final repo = ref.read(lingooRepositoryProvider);
  final raw = await apiWithTimeout(repo.getServices(), defaultServices);
  if (user.isManagerUser) {
    return servicesForManager(user, raw);
  }
  return raw;
});

final staffListProvider = FutureProvider.autoDispose<List<StaffMember>>((
  ref,
) async {
  final user = await waitForUser(ref);
  if (user == null) return [];
  if (user.isManagerUser && user.staffProfile != null) {
    return [user.staffProfile!];
  }
  return apiWithTimeout(
    ref.read(lingooRepositoryProvider).getStaff(),
    defaultStaff,
  );
});

final bookingsListProvider = FutureProvider.autoDispose
    .family<List<Booking>, BookingsQuery>((ref, query) async {
      final user = await waitForUser(ref);
      if (user == null) return [];

      var staffId = query.staffId;
      if (user.isManagerUser && user.staffProfile != null) {
        staffId = user.staffProfile!.id;
      }

      return ref.read(lingooRepositoryProvider).getBookings(
        dateFrom: query.dateFrom,
        dateTo: query.dateTo,
        status: query.status,
        staffId: staffId,
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
  final list = await ref.read(branchesListProvider.future);
  for (final b in list) {
    if (b.id == id) return b;
  }
  return apiWithTimeout(
    ref.read(lingooRepositoryProvider).getBranch(id),
    Branch(
      id: id,
      name: 'Филиал',
      address: '',
      phone: '',
      isActive: true,
    ),
  );
});

final serviceDetailProvider = FutureProvider.autoDispose
    .family<SalonService, int>((ref, id) async {
      final list = await ref.read(servicesListProvider.future);
      for (final s in list) {
        if (s.id == id) return s;
      }
      return SalonService(
        id: id,
        name: 'Услуга',
        description: '',
        price: 0,
        durationMinutes: 60,
        isActive: true,
      );
    });

final staffDetailProvider = FutureProvider.autoDispose.family<StaffMember, int>(
  (ref, id) async {
    final user = await waitForUser(ref);
    if (user?.staffProfile?.id == id) {
      return user!.staffProfile!;
    }
    final list = await ref.read(staffListProvider.future);
    for (final s in list) {
      if (s.id == id) return s;
    }
    return apiWithTimeout(
      ref.read(lingooRepositoryProvider).getStaffMember(id),
      StaffMember(
        id: id,
        name: 'Сотрудник',
        phone: '',
        email: '',
        role: UserRole.manager,
        apiRole: 'MANAGER',
        branchId: 1,
        branchName: '',
        isActive: true,
      ),
    );
  },
);

final staffScheduleProvider =
    FutureProvider.autoDispose.family<StaffSchedule, int>((ref, staffId) async {
  return apiWithTimeout(
    ref.read(lingooRepositoryProvider).getStaffSchedule(staffId),
    const StaffSchedule(days: []),
  );
});

final dayBookingsProvider = FutureProvider.autoDispose
    .family<List<Booking>, DateTime>((ref, day) async {
  final user = await waitForUser(ref);
  if (user == null) return [];

  int? staffId;
  if (user.isManagerUser && user.staffProfile != null) {
    staffId = user.staffProfile!.id;
  }

  final start = DateTime(day.year, day.month, day.day);
  final end =
      start.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
  return ref.read(lingooRepositoryProvider).getBookings(
    dateFrom: start,
    dateTo: end,
    staffId: staffId,
  );
});

final todayBookingsProvider = FutureProvider.autoDispose<List<Booking>>((
  ref,
) async {
  final now = DateTime.now();
  return ref.read(dayBookingsProvider(now).future);
});
