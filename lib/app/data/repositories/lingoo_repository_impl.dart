import '../../../core/errors/api_exception.dart';
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
import '../../domain/repositories/lingoo_repository.dart';
import '../api/lingoo_api_client.dart';
import '../dto/auth_tokens.dart';

class LingooRepositoryImpl implements LingooRepository {
  LingooRepositoryImpl(this._api);

  final LingooApiClient _api;

  @override
  Future<AuthLoginResult> login({
    required String username,
    required String password,
  }) =>
      _api.login(username: username, password: password);

  @override
  Future<AuthTokens> refreshToken(String refresh) => _api.refreshToken(refresh);

  @override
  Future<void> logout({String? refresh}) => _api.logout(refresh: refresh);

  @override
  Future<UserProfile> getCurrentUser() => _api.fetchCurrentUser();

  @override
  Future<DashboardData> getDashboard() async {
    final dash = await _api.fetchDashboard();
    final (services, _) = await _api.fetchServices();
    final servicesCount = services.length;
    if (servicesCount == dash.stats.services) return dash;
    return DashboardData(
      stats: DashboardStats(
        branches: dash.stats.branches,
        services: servicesCount,
        staff: dash.stats.staff,
        bookings: dash.stats.bookings,
      ),
      recentBookings: dash.recentBookings,
      staffUsed: dash.staffUsed,
      staffLimit: dash.staffLimit,
    );
  }

  @override
  Future<BookingStats> getBookingsStats() => _api.fetchBookingsStats();

  @override
  Future<Map<String, List<Booking>>> getBookingsCalendar({
    required int month,
    required int year,
  }) =>
      _api.fetchBookingsCalendar(month: month, year: year);

  @override
  Future<List<Booking>> getBookings({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? status,
    int? staffId,
    String? search,
  }) async {
    final (list, _) = await _api.fetchBookings(
      dateFrom: dateFrom,
      dateTo: dateTo,
      status: status,
      staffId: staffId,
      search: search,
    );
    return list;
  }

  @override
  Future<Booking> getBooking(int id) => _api.fetchBooking(id);

  @override
  Future<Booking> updateBookingStatus(int id, String status) =>
      _api.patchBookingStatus(id, status);

  @override
  Future<Booking> updateBookingComment(int id, String adminComment) =>
      _api.patchBookingComment(id, adminComment);

  @override
  Future<List<Branch>> getBranches() async {
    final (list, _) = await _api.fetchBranches();
    return list;
  }

  @override
  Future<Branch> getBranch(int id) => _api.fetchBranch(id);

  @override
  Future<Branch> createBranch(Branch draft) => _api.createBranch(draft);

  @override
  Future<Branch> updateBranch(Branch branch) => _api.updateBranch(branch);

  @override
  Future<void> deleteBranch(int id) => _api.deleteBranch(id);

  @override
  Future<List<SalonService>> getServices() async {
    final (list, _) = await _api.fetchServices();
    return list;
  }

  @override
  Future<SalonService> getService(int id) => _api.fetchService(id);

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
    final (list, _) = await _api.fetchStaff();
    return list;
  }

  @override
  Future<StaffMember> getStaffMember(int id) => _api.fetchStaffMember(id);

  @override
  Future<StaffMember> createStaff(StaffMember draft, {String? password}) async {
    try {
      return await _api.createStaff(draft, password: password);
    } on ApiException catch (e) {
      if (!_isStaffBindingError(e)) rethrow;
      final hasBindings =
          draft.branchId != null || draft.serviceIds.isNotEmpty;
      if (!hasBindings) rethrow;

      final created = await _api.createStaff(
        draft.withoutBindings(),
        password: password,
      );
      throw ApiException(
        userMessage:
            'Сотрудник «${created.name}» создан, но сервер не принял филиал '
            'и услуги (ошибка API Invalid pk). Обратитесь к администратору '
            'платформы для исправления POST /staff/.',
        code: 'staff_partial_create',
        statusCode: e.statusCode,
      );
    }
  }

  bool _isStaffBindingError(ApiException e) {
    final msg = e.userMessage.toLowerCase();
    return msg.contains('invalid pk') ||
        (e.fieldErrors?.containsKey('branches') ?? false) ||
        (e.fieldErrors?.containsKey('services') ?? false);
  }

  @override
  Future<StaffMember> updateStaff(StaffMember staff, {String? password}) async {
    try {
      return await _api.updateStaff(staff, password: password);
    } on ApiException catch (e) {
      if (!_isStaffBindingError(e)) rethrow;
      if (staff.branchId == null && staff.serviceIds.isEmpty) rethrow;
      final base = await _api.updateStaff(
        staff.withoutBindings(),
        password: password,
      );
      throw ApiException(
        userMessage:
            'Данные «${base.name}» обновлены, но филиал и услуги не привязаны — '
            'ошибка API на сервере.',
        code: 'staff_partial_update',
        statusCode: e.statusCode,
      );
    }
  }

  @override
  Future<void> deleteStaff(int id) => _api.deleteStaff(id);

  @override
  Future<StaffSchedule> getStaffSchedule(int staffId) =>
      _api.fetchStaffSchedule(staffId);

  @override
  Future<StaffSchedule> saveStaffSchedule(int staffId, StaffSchedule schedule) =>
      _api.putStaffSchedule(staffId, schedule);

  @override
  Future<BusinessSettings> getBusinessSettings() => _api.fetchBusinessSettings();

  @override
  Future<BusinessSettings> updateBusinessSettings(BusinessSettings settings) =>
      _api.patchBusinessSettings(settings);

  @override
  Future<String> getPublicBookingUrl() => _api.fetchPublicBookingUrl();

  @override
  Future<TariffLimits> getTariffLimits() => _api.fetchTariffLimits();
}
