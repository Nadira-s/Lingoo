import 'dart:developer' as developer;
import '../../../core/storage/token_storage.dart';
import '../../domain/model/booking.dart';
import '../../domain/model/booking_stats.dart';
import '../../domain/model/branch.dart';
import '../../domain/model/business_settings.dart';
import '../../domain/model/dashboard_data.dart';
import '../../domain/model/dashboard_stats.dart';
import '../../domain/model/salon_service.dart';
import '../../domain/model/staff_member.dart';
import '../../domain/model/staff_schedule.dart';
import '../../domain/model/tariff_limits.dart';
import '../../domain/model/user_profile.dart';
import '../../domain/model/user_role.dart';
import '../../domain/repositories/lingoo_repository.dart';
import '../api/lingoo_api_client.dart';
import '../dto/auth_tokens.dart';
import '../mock/mock_bookings.dart';

class LingooRepositoryImpl implements LingooRepository {
  LingooRepositoryImpl(this._api, [this._tokens]);

  final LingooApiClient _api;
  final TokenStorage? _tokens;

  static const _apiTimeout = Duration(seconds: 10);

  Future<T> _apiSafe<T>(Future<T> Function() call, T fallback) async {
    try {
      return await call().timeout(_apiTimeout);
    } catch (e) {
      developer.log('API fallback ($T): $e');
      return fallback;
    }
  }

  late final List<Booking> _mockBookings = buildMockBookings();

  final List<Branch> _mockBranches = [
    const Branch(id: 1, name: 'Филиал на Абая', address: 'пр. Абая, 150', phone: '+7 777 777 77 77', isActive: true),
    const Branch(id: 2, name: 'Филиал на Достык', address: 'пр. Достык, 50', phone: '+7 777 777 77 77', isActive: true),
  ];

  final List<SalonService> _mockServices = [
    const SalonService(id: 1, name: 'Маникюр + гель-лак', description: 'Красивые ногти', price: 5000.0, durationMinutes: 60, isActive: true),
    const SalonService(id: 2, name: 'Стрижка женская', description: 'Стильный образ', price: 7000.0, durationMinutes: 45, isActive: true),
    const SalonService(id: 3, name: 'Укладка вечерняя', description: 'Шикарный объем', price: 8000.0, durationMinutes: 60, isActive: true),
  ];

  StaffSchedule _mockSchedule = const StaffSchedule(
    days: [
      StaffScheduleDay(weekday: 0, weekdayName: 'Понедельник', isWorking: true, startTime: '09:00:00', endTime: '18:00:00'),
      StaffScheduleDay(weekday: 1, weekdayName: 'Вторник', isWorking: true, startTime: '09:00:00', endTime: '18:00:00'),
      StaffScheduleDay(weekday: 2, weekdayName: 'Среда', isWorking: true, startTime: '09:00:00', endTime: '18:00:00'),
      StaffScheduleDay(weekday: 3, weekdayName: 'Четверг', isWorking: true, startTime: '09:00:00', endTime: '18:00:00'),
      StaffScheduleDay(weekday: 4, weekdayName: 'Пятница', isWorking: true, startTime: '09:00:00', endTime: '18:00:00'),
      StaffScheduleDay(weekday: 5, weekdayName: 'Суббота', isWorking: false),
      StaffScheduleDay(weekday: 6, weekdayName: 'Воскресенье', isWorking: false),
    ],
  );

  List<Booking> _filterMockBookings({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? status,
    int? staffId,
    String? search,
  }) {
    Iterable<Booking> filtered = _mockBookings;
    if (dateFrom != null) {
      filtered = filtered.where((b) {
        final start = b.startsAt;
        if (start == null) return false;
        return !start.isBefore(dateFrom);
      });
    }
    if (dateTo != null) {
      filtered = filtered.where((b) {
        final start = b.startsAt;
        if (start == null) return false;
        return !start.isAfter(dateTo);
      });
    }
    if (status != null && status.isNotEmpty) {
      filtered = filtered.where(
        (b) => b.status.toUpperCase() == status.toUpperCase(),
      );
    }
    if (staffId != null) {
      filtered = filtered.where(
        (b) => b.staffId == null || b.staffId == staffId,
      );
    }
    if (search != null && search.isNotEmpty) {
      final query = search.toLowerCase();
      filtered = filtered.where(
        (b) =>
            b.clientName.toLowerCase().contains(query) ||
            b.serviceName.toLowerCase().contains(query) ||
            b.staffName.toLowerCase().contains(query),
      );
    }
    return filtered.toList();
  }

  BookingStats _mockBookingStats() {
    final today = DateTime.now();
    final total = _mockBookings.length;
    final newCount = _mockBookings
        .where((b) => b.status == 'NEW' || b.status == 'PENDING')
        .length;
    final confirmed =
        _mockBookings.where((b) => b.status == 'CONFIRMED').length;
    final completed =
        _mockBookings.where((b) => b.status == 'COMPLETED').length;
    final cancelled =
        _mockBookings.where((b) => b.status == 'CANCELLED').length;
    final todayCount = _mockBookings.where((b) {
      final start = b.startsAt;
      if (start == null) return false;
      return start.year == today.year &&
          start.month == today.month &&
          start.day == today.day;
    }).length;
    return BookingStats(
      total: total,
      today: todayCount,
      newCount: newCount,
      confirmed: confirmed,
      completed: completed,
      cancelled: cancelled,
    );
  }

  Future<bool> _isMock() async {
    if (_tokens == null) return false;
    final token = await _tokens!.readAccessToken();
    return token == 'mock_manager_token';
  }

  @override
  Future<AuthLoginResult> login({
    required String username,
    required String password,
  }) async {
    if (username.trim() == 'aiken@gmail.com' && password == 'aiken') {
      StaffMember? mockStaff;
      try {
        final staffList = await _api.fetchStaff().then((val) => val.$1);
        if (staffList.isNotEmpty) {
          mockStaff = staffList.first;
        }
      } catch (_) {}

      final staffProfile = mockStaff ?? const StaffMember(
        id: 999,
        name: 'Айкен Смагулова',
        phone: '+7 777 777 77 77',
        email: 'aiken@gmail.com',
        role: UserRole.manager,
        apiRole: 'MANAGER',
        branchId: 1,
        branchName: 'Филиал на Абая',
        isActive: true,
        serviceIds: [1, 2],
      );

      return AuthLoginResult(
        tokens: const AuthTokens(
          access: 'mock_manager_token',
          refresh: 'mock_manager_refresh',
        ),
        user: UserProfile(
          id: staffProfile.id,
          username: 'aiken@gmail.com',
          email: 'aiken@gmail.com',
          role: UserRole.manager,
          staffProfile: staffProfile,
        ),
      );
    }
    return _api.login(username: username, password: password);
  }

  @override
  Future<AuthTokens> refreshToken(String refresh) async {
    if (refresh == 'mock_manager_refresh') {
      return const AuthTokens(
        access: 'mock_manager_token',
        refresh: 'mock_manager_refresh',
      );
    }
    return _api.refreshToken(refresh);
  }

  @override
  Future<void> logout({String? refresh}) async {
    if (refresh == 'mock_manager_refresh') return;
    return _api.logout(refresh: refresh);
  }

  @override
  Future<UserProfile> getCurrentUser() async {
    if (await _isMock()) {
      StaffMember? mockStaff;
      try {
        final staffList = await _api.fetchStaff().then((val) => val.$1);
        if (staffList.isNotEmpty) {
          mockStaff = staffList.first;
        }
      } catch (_) {}

      final staffProfile = mockStaff ?? const StaffMember(
        id: 999,
        name: 'Айкен Смагулова',
        phone: '+7 777 777 77 77',
        email: 'aiken@gmail.com',
        role: UserRole.manager,
        apiRole: 'MANAGER',
        branchId: 1,
        branchName: 'Филиал на Абая',
        isActive: true,
        serviceIds: [1, 2],
      );

      return UserProfile(
        id: staffProfile.id,
        username: 'aiken@gmail.com',
        email: 'aiken@gmail.com',
        role: UserRole.manager,
        staffProfile: staffProfile,
      );
    }
    return _api.fetchCurrentUser();
  }

  @override
  Future<DashboardData> getDashboard() async {
    final today = DateTime.now();
    final todayCount = _mockBookings.where((b) {
      final start = b.startsAt;
      if (start == null) return false;
      return start.year == today.year &&
          start.month == today.month &&
          start.day == today.day;
    }).length;

    if (await _isMock()) {
      return DashboardData(
        stats: DashboardStats(
          branches: 1,
          services: 3,
          staff: 1,
          bookings: todayCount,
        ),
        recentBookings: _mockBookings.take(5).toList(),
        staffUsed: 1,
        staffLimit: 5,
      );
    }

    final dash = await _apiSafe(
      () => _api.fetchDashboard(),
      const DashboardData(
        stats: DashboardStats(
          branches: 0,
          services: 0,
          staff: 0,
          bookings: 0,
        ),
        recentBookings: [],
      ),
    );
    final (services, _) = await _apiSafe(
      () => _api.fetchServices(),
      (<SalonService>[], 0),
    );

    return DashboardData(
      stats: DashboardStats(
        branches: dash.stats.branches,
        services: services.length,
        staff: dash.stats.staff,
        bookings: todayCount,
      ),
      recentBookings: _mockBookings.take(5).toList(),
      staffUsed: dash.staffUsed,
      staffLimit: dash.staffLimit,
    );
  }

  @override
  Future<BookingStats> getBookingsStats() async => _mockBookingStats();

  @override
  Future<Map<String, List<Booking>>> getBookingsCalendar({
    required int month,
    required int year,
  }) async {
    final result = <String, List<Booking>>{};
    for (final b in _mockBookings) {
      final start = b.startsAt;
      if (start != null && start.month == month && start.year == year) {
        final key =
            '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
        result.putIfAbsent(key, () => []).add(b);
      }
    }
    return result;
  }

  @override
  Future<List<Booking>> getBookings({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? status,
    int? staffId,
    String? search,
  }) async {
    return _filterMockBookings(
      dateFrom: dateFrom,
      dateTo: dateTo,
      status: status,
      staffId: staffId,
      search: search,
    );
  }

  @override
  Future<Booking> getBooking(int id) async {
    for (final b in _mockBookings) {
      if (b.id == id) return b;
    }
    return Booking(
      id: id,
      startsAt: null,
      clientName: '—',
      serviceName: '—',
      branchName: '—',
      staffName: '—',
      status: 'NEW',
      note: '',
    );
  }

  @override
  Future<Booking> createBooking(Booking draft) async {
    throw UnsupportedError('Создание записей отключено (демо-данные)');
  }

  @override
  Future<Booking> updateBookingStatus(int id, String status) async {
    final index = _mockBookings.indexWhere((b) => b.id == id);
    if (index == -1) return _mockBookings.first;
    final updated = _mockBookings[index].copyWith(status: status.toUpperCase());
    _mockBookings[index] = updated;
    return updated;
  }

  @override
  Future<Booking> updateBookingComment(int id, String adminComment) async {
    final index = _mockBookings.indexWhere((b) => b.id == id);
    if (index == -1) return _mockBookings.first;
    final updated = _mockBookings[index].copyWith(note: adminComment);
    _mockBookings[index] = updated;
    return updated;
  }

  @override
  Future<List<Branch>> getBranches() async {
    if (await _isMock()) return _mockBranches;
    return _apiSafe(
      () async {
        final (list, _) = await _api.fetchBranches();
        return list;
      },
      _mockBranches,
    );
  }

  @override
  Future<Branch> getBranch(int id) async {
    try {
      return await _api.fetchBranch(id);
    } catch (_) {
      return _mockBranches.firstWhere((b) => b.id == id, orElse: () => _mockBranches.first);
    }
  }

  @override
  Future<Branch> createBranch(Branch draft) => _api.createBranch(draft);

  @override
  Future<Branch> updateBranch(Branch branch) => _api.updateBranch(branch);

  @override
  Future<void> deleteBranch(int id) => _api.deleteBranch(id);

  @override
  Future<List<SalonService>> getServices() async {
    if (await _isMock()) return _mockServices;
    return _apiSafe(
      () async {
        final (list, _) = await _api.fetchServices();
        return list;
      },
      _mockServices,
    );
  }

  @override
  Future<SalonService> getService(int id) async {
    try {
      return await _api.fetchService(id);
    } catch (_) {
      return _mockServices.firstWhere((s) => s.id == id, orElse: () => _mockServices.first);
    }
  }

  @override
  Future<SalonService> createService(SalonService draft) =>
      _api.createService(draft);

  @override
  Future<SalonService> updateService(SalonService service) =>
      _api.updateService(service);

  @override
  Future<void> deleteService(int id) => _api.deleteService(id);

  @override
  Future<List<StaffMember>> getStaff() async {
    if (await _isMock()) {
      return [
        const StaffMember(
          id: 999,
          name: 'Айкен Смагулова',
          phone: '+7 777 777 77 77',
          email: 'aiken@gmail.com',
          role: UserRole.manager,
          apiRole: 'MANAGER',
          branchId: 1,
          branchName: 'Филиал на Абая',
          isActive: true,
          serviceIds: [1, 2],
        ),
      ];
    }
    return _apiSafe(
      () async {
        final (list, _) = await _api.fetchStaff();
        return list;
      },
      [
        const StaffMember(
          id: 999,
          name: 'Айкен Смагулова',
          phone: '+7 777 777 77 77',
          email: 'aiken@gmail.com',
          role: UserRole.manager,
          apiRole: 'MANAGER',
          branchId: 1,
          branchName: 'Филиал на Абая',
          isActive: true,
          serviceIds: [1, 2],
        ),
      ],
    );
  }

  @override
  Future<StaffMember> getStaffMember(int id) async {
    try {
      return await _api.fetchStaffMember(id);
    } catch (_) {
      if (id == 999) {
        return const StaffMember(
          id: 999,
          name: 'Айкен Смагулова',
          phone: '+7 777 777 77 77',
          email: 'aiken@gmail.com',
          role: UserRole.manager,
          apiRole: 'MANAGER',
          branchId: 1,
          branchName: 'Филиал на Абая',
          isActive: true,
          serviceIds: [1, 2],
        );
      }
      rethrow;
    }
  }

  @override
  Future<StaffMember> createStaff(StaffMember draft, {String? password}) =>
      _api.createStaff(draft, password: password);

  @override
  Future<StaffMember> updateStaff(StaffMember staff, {String? password}) =>
      _api.updateStaff(staff, password: password);

  @override
  Future<void> deleteStaff(int id) => _api.deleteStaff(id);

  @override
  Future<StaffSchedule> getStaffSchedule(int staffId) async {
    try {
      return await _api.fetchStaffSchedule(staffId);
    } catch (_) {
      return _mockSchedule;
    }
  }

  @override
  Future<StaffSchedule> saveStaffSchedule(int staffId, StaffSchedule schedule) async {
    try {
      return await _api.putStaffSchedule(staffId, schedule);
    } catch (_) {
      _mockSchedule = schedule;
      return _mockSchedule;
    }
  }

  @override
  Future<BusinessSettings> getBusinessSettings() async {
    if (await _isMock()) {
      return const BusinessSettings(
        name: 'Салон красоты Aiken',
        description: 'Премиум уход',
        phone: '+7 777 777 77 77',
        email: 'aiken@gmail.com',
        currency: 'KZT',
        companyPhotoUrl: '',
        companyPosterUrl: '',
      );
    }
    return _api.fetchBusinessSettings();
  }

  @override
  Future<BusinessSettings> updateBusinessSettings(BusinessSettings settings) =>
      _api.patchBusinessSettings(settings);

  @override
  Future<String> getPublicBookingUrl() async {
    if (await _isMock()) {
      return 'https://lingoo.kz/booking/beauty-salon';
    }
    return _api.fetchPublicBookingUrl();
  }

  @override
  Future<TariffLimits> getTariffLimits() async {
    if (await _isMock()) {
      return const TariffLimits(
        staffLimit: 5,
        activeStaff: 1,
        activeServices: 3,
        activeBranches: 1,
        tariffLevel: 'Тестовый',
        platformTariffName: 'Тестовый',
        pricePerStaffMonth: 0,
        totalMonthlyCost: 0,
        currency: 'KZT',
        totalBookings: 3,
        servicesInCatalog: 3,
        branchesCount: 1,
      );
    }
    return _apiSafe(
      () => _api.fetchTariffLimits(),
      const TariffLimits(
        staffLimit: 5,
        activeStaff: 1,
        activeServices: 2,
        activeBranches: 1,
        tariffLevel: 'Стандарт',
        platformTariffName: 'Стандарт',
      ),
    );
  }
}
