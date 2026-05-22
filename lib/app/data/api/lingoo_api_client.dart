import 'package:dio/dio.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_response_parser.dart';
import '../dto/auth_tokens.dart';
import '../../domain/model/booking.dart';
import '../../domain/model/branch.dart';
import '../../domain/model/booking_stats.dart';
import '../../domain/model/business_settings.dart';
import '../../domain/model/dashboard_data.dart';
import '../../domain/model/dashboard_stats.dart';
import '../../domain/model/staff_schedule.dart';
import '../../domain/model/tariff_limits.dart';
import '../../domain/model/salon_service.dart';
import '../../domain/model/staff_member.dart';
import '../../domain/model/user_profile.dart';

/// HTTP client for Lingoo Mobile API (`/api/v1`).
class LingooApiClient extends ApiClient {
  LingooApiClient(super.dio);

  Future<AuthLoginResult> login({
    required String username,
    required String password,
  }) async {
    final res = await post(
      ApiEndpoints.authLogin,
      data: {'username': username, 'password': password},
      options: Options(headers: {'Authorization': null}),
    );
    return parseAuthLoginResponse(res.data);
  }

  Future<AuthTokens> refreshToken(String refresh) async {
    final res = await post(
      ApiEndpoints.authRefresh,
      data: {'refresh': refresh},
    );
    return AuthTokens.fromJson(parseEntityMap(res.data));
  }

  Future<void> logout({String? refresh}) async {
    try {
      await post(
        ApiEndpoints.authLogout,
        data: refresh != null ? {'refresh': refresh} : null,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return;
      throw apiExceptionFromDio(e);
    }
  }

  Future<UserProfile> fetchCurrentUser() async {
    final res = await get(ApiEndpoints.authMe);
    final map = parseEntityMap(res.data);
    final userRaw = map['user'] ?? map;
    if (userRaw is! Map) {
      throw ApiException(userMessage: 'Некорректный профиль пользователя.');
    }
    return UserProfile.fromJson(Map<String, dynamic>.from(userRaw));
  }

  Future<DashboardData> fetchDashboard() async {
    final res = await get(ApiEndpoints.dashboard);
    final map = parseEntityMap(res.data);
    final recentRaw = map['recent_bookings'] ?? map['recent'];
    final recent = recentRaw is List
        ? recentRaw
            .whereType<Map>()
            .map((e) => Booking.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <Booking>[];
    return DashboardData(
      stats: DashboardStats(
        branches:
            _readCount(map, ['branch_count', 'branches', 'branches_count']),
        services:
            _readCount(map, ['service_count', 'services', 'services_count']),
        staff: _readCount(map, ['staff_count', 'staff']),
        bookings: _readCount(map, [
          'bookings_today',
          'bookings_today_count',
          'today_bookings',
          'bookings',
        ]),
      ),
      recentBookings: recent,
      staffUsed: readInt(map['staff_used']) ?? readInt(map['staff_count']),
      staffLimit: readInt(map['staff_limit']) ??
          readInt(map['staff_limit_max']) ??
          readInt(map['staff_limit_usage']),
    );
  }

  Future<BookingStats> fetchBookingsStats() async {
    final res = await get(ApiEndpoints.bookingsStats);
    return BookingStats.fromJson(parseEntityMap(res.data));
  }

  Future<Map<String, List<Booking>>> fetchBookingsCalendar({
    required int month,
    required int year,
  }) async {
    final res = await get(
      ApiEndpoints.bookingsCalendar,
      queryParameters: {'month': month, 'year': year},
    );
    final map = parseEntityMap(res.data);
    final result = <String, List<Booking>>{};
    map.forEach((key, value) {
      if (value is List) {
        result[key.toString()] = value
            .whereType<Map>()
            .map((e) => Booking.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    });
    return result;
  }

  Future<BusinessSettings> fetchBusinessSettings() async {
    final res = await get(ApiEndpoints.businessSettings);
    return BusinessSettings.fromJson(parseEntityMap(res.data));
  }

  Future<BusinessSettings> patchBusinessSettings(BusinessSettings s) async {
    final res = await patch(
      ApiEndpoints.businessSettings,
      data: s.toPatchBody(),
    );
    return BusinessSettings.fromJson(parseEntityMap(res.data));
  }

  Future<String> fetchPublicBookingUrl() async {
    final res = await get(ApiEndpoints.businessPublicBookingLink);
    final map = parseEntityMap(res.data);
    final url = readString(map, 'public_booking_url');
    if (url.isNotEmpty) return url;
    final slug = readString(map, 'tenant_slug');
    return slug.isEmpty ? '' : 'https://booking/$slug';
  }

  Future<TariffLimits> fetchTariffLimits() async {
    final res = await get(ApiEndpoints.tariffLimits);
    return TariffLimits.fromJson(parseEntityMap(res.data));
  }

  Future<StaffSchedule> fetchStaffSchedule(int staffId) async {
    final res = await get(ApiEndpoints.staffSchedule(staffId));
    return StaffSchedule.fromJson(parseEntityMap(res.data));
  }

  Future<StaffSchedule> putStaffSchedule(
      int staffId, StaffSchedule schedule) async {
    final res = await put(
      ApiEndpoints.staffSchedule(staffId),
      data: schedule.toPutBody(),
    );
    return StaffSchedule.fromJson(parseEntityMap(res.data));
  }

  int _readCount(Map<String, dynamic> map, List<String> keys) {
    for (final k in keys) {
      final v = readInt(map[k]);
      if (v != null) return v;
    }
    return 0;
  }

  Future<(List<Branch>, int)> fetchBranches() async {
    final res = await get(ApiEndpoints.branches);
    final list = parseResultList(res.data);
    return (list.map(Branch.fromJson).toList(), parseCount(res.data));
  }

  Future<Branch> fetchBranch(int id) async {
    final res = await get(ApiEndpoints.branch(id));
    return Branch.fromJson(parseEntityMap(res.data));
  }

  Future<Branch> createBranch(Branch draft) async {
    final res = await post(ApiEndpoints.branches, data: draft.toCreateBody());
    return Branch.fromJson(parseEntityMap(res.data));
  }

  Future<Branch> updateBranch(Branch branch) async {
    final res = await patch(
      ApiEndpoints.branch(branch.id),
      data: branch.toCreateBody(),
    );
    return Branch.fromJson(parseEntityMap(res.data));
  }

  Future<void> deleteBranch(int id) async {
    await delete(ApiEndpoints.branch(id));
  }

  Future<(List<SalonService>, int)> fetchServices() async {
    final res = await get(ApiEndpoints.services);
    final list = parseResultList(res.data);
    return (list.map(SalonService.fromJson).toList(), parseCount(res.data));
  }

  Future<SalonService> fetchService(int id) async {
    final res = await get(ApiEndpoints.service(id));
    return SalonService.fromJson(parseEntityMap(res.data));
  }

  Future<SalonService> createService(SalonService draft) async {
    final res = await post(ApiEndpoints.services, data: draft.toCreateBody());
    return SalonService.fromJson(parseEntityMap(res.data));
  }

  Future<SalonService> updateService(SalonService s) async {
    final res = await patch(ApiEndpoints.service(s.id), data: s.toCreateBody());
    return SalonService.fromJson(parseEntityMap(res.data));
  }

  Future<void> deleteService(int id) async {
    await delete(ApiEndpoints.service(id));
  }

  Future<(List<StaffMember>, int)> fetchStaff() async {
    final res = await get(ApiEndpoints.staff);
    final list = parseResultList(res.data);
    return (list.map(StaffMember.fromJson).toList(), parseCount(res.data));
  }

  Future<StaffMember> fetchStaffMember(int id) async {
    final res = await get(ApiEndpoints.staffMember(id));
    return StaffMember.fromJson(parseEntityMap(res.data));
  }

  Future<StaffMember> createStaff(StaffMember draft, {String? password}) async {
    final res = await post(
      ApiEndpoints.staff,
      data: draft.toCreateBody(password: password),
    );
    return StaffMember.fromJson(parseEntityMap(res.data));
  }

  Future<StaffMember> updateStaff(StaffMember s, {String? password}) async {
    final res = await patch(
      ApiEndpoints.staffMember(s.id),
      data: s.toCreateBody(password: password),
    );
    return StaffMember.fromJson(parseEntityMap(res.data));
  }

  Future<void> deleteStaff(int id) async {
    await delete(ApiEndpoints.staffMember(id));
  }

  Future<(List<Booking>, int)> fetchBookings({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? status,
    int? staffId,
    String? search,
  }) async {
    final q = <String, dynamic>{};
    if (dateFrom != null) q['date_from'] = formatApiDate(dateFrom);
    if (dateTo != null) q['date_to'] = formatApiDate(dateTo);
    if (status != null && status.isNotEmpty) q['status'] = status;
    if (staffId != null) q['staff'] = staffId;
    if (search != null && search.isNotEmpty) q['search'] = search;
    final res = await get(
      ApiEndpoints.bookings,
      queryParameters: q.isEmpty ? null : q,
    );
    final list = parseResultList(res.data);
    return (list.map(Booking.fromJson).toList(), parseCount(res.data));
  }

  Future<Booking> fetchBooking(int id) async {
    final res = await get(ApiEndpoints.booking(id));
    return Booking.fromJson(parseEntityMap(res.data));
  }

  Future<Booking> patchBookingStatus(int id, String status) async {
    final res = await patch(
      ApiEndpoints.bookingStatus(id),
      data: {'status': status.toUpperCase()},
    );
    return Booking.fromJson(parseEntityMap(res.data));
  }

  Future<Booking> patchBookingComment(int id, String adminComment) async {
    final res = await patch(
      ApiEndpoints.bookingComment(id),
      data: {'admin_comment': adminComment},
    );
    return Booking.fromJson(parseEntityMap(res.data));
  }
}

/// Backward-compatible alias.
typedef BusinessApiClient = LingooApiClient;
