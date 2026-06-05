import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_notifier.dart';
import 'domain/model/booking_stats.dart';
import 'domain/model/branch.dart';
import 'domain/model/salon_service.dart';
import 'domain/model/staff_member.dart';
import 'domain/model/tariff_limits.dart';
import 'domain/model/user_profile.dart';
import 'domain/model/user_role.dart';

/// Таймаут сетевых запросов для UI (сек).
const kProviderApiTimeout = Duration(seconds: 10);

Future<T> apiWithTimeout<T>(Future<T> future, T fallback) async {
  try {
    return await future.timeout(kProviderApiTimeout);
  } on TimeoutException {
    return fallback;
  } catch (_) {
    return fallback;
  }
}

/// Дождаться завершения auth и вернуть пользователя.
Future<UserProfile?> waitForUser(Ref ref) async {
  var auth = ref.read(authNotifierProvider);
  if (auth.isLoading) {
    try {
      await ref.read(authNotifierProvider.future).timeout(
            const Duration(seconds: 20),
          );
    } catch (_) {
      return null;
    }
    auth = ref.read(authNotifierProvider);
  }
  return auth.valueOrNull;
}

List<Branch> branchesForUser(UserProfile user, List<Branch> fromApi) {
  if (fromApi.isNotEmpty) return fromApi;
  final profile = user.staffProfile;
  if (profile != null && (profile.branchId ?? 0) > 0) {
    return [
      Branch(
        id: profile.branchId!,
        name: profile.branchName.isEmpty ? 'Мой филиал' : profile.branchName,
        address: '',
        phone: '',
        isActive: true,
      ),
    ];
  }
  return fromApi;
}

List<SalonService> servicesForManager(
  UserProfile user,
  List<SalonService> fromApi,
) {
  final ids = user.staffProfile?.serviceIds ?? const <int>[];
  if (fromApi.isNotEmpty) {
    if (ids.isEmpty) return fromApi;
    final filtered = fromApi.where((s) => ids.contains(s.id)).toList();
    return filtered.isEmpty ? fromApi : filtered;
  }
  if (ids.isEmpty) {
    return defaultServices;
  }
  return [
    for (final id in ids)
      SalonService(
        id: id,
        name: 'Услуга #$id',
        description: '',
        price: 0,
        durationMinutes: 60,
        isActive: true,
      ),
  ];
}

const defaultServices = [
  SalonService(
    id: 1,
    name: 'Маникюр + гель-лак',
    description: '',
    price: 5000,
    durationMinutes: 60,
    isActive: true,
  ),
  SalonService(
    id: 2,
    name: 'Стрижка женская',
    description: '',
    price: 7000,
    durationMinutes: 45,
    isActive: true,
  ),
];

const defaultStaff = [
  StaffMember(
    id: 1,
    name: 'Сотрудник',
    phone: '',
    email: '',
    role: UserRole.manager,
    apiRole: 'MANAGER',
    branchId: 1,
    branchName: 'Филиал',
    isActive: true,
    serviceIds: [1, 2],
  ),
];

const defaultBookingStats = BookingStats();

const defaultTariffLimits = TariffLimits(
  staffLimit: 5,
  activeStaff: 1,
  activeServices: 2,
  activeBranches: 1,
  tariffLevel: 'Стандарт',
  platformTariffName: 'Стандарт',
);
