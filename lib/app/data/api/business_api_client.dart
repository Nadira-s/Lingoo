import 'package:dio/dio.dart';

import '../../utils/api_exception.dart';
import '../../utils/error_mapper.dart';
import '../dto/auth_tokens.dart';
import '../../domain/model/booking.dart';
import '../../domain/model/branch.dart';
import '../../domain/model/dashboard_stats.dart';
import '../../domain/model/salon_service.dart';
import '../../domain/model/staff_member.dart';
import '../../domain/model/user_profile.dart';
import 'api_paths.dart';
import 'json_helpers.dart';

class BusinessApiClient {
  BusinessApiClient(this._dio);

  final Dio _dio;

  Future<AuthLoginResult> login({
    required String username,
    required String password,
  }) async {
    try {
      final res = await _dio.post<dynamic>(
        ApiPaths.authLogin,
        data: {'username': username, 'password': password},
      );
      return parseAuthLoginResponse(res.data);
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<AuthTokens> refreshToken(String refresh) async {
    try {
      final res = await _dio.post<dynamic>(
        ApiPaths.authRefresh,
        data: {'refresh': refresh},
      );
      final map = parseEntityMap(res.data);
      return AuthTokens.fromJson(map);
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<void> logout({String? refresh}) async {
    try {
      await _dio.post<void>(
        ApiPaths.authLogout,
        data: refresh != null ? {'refresh': refresh} : null,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return;
      throw apiExceptionFromDio(e);
    }
  }

  Future<UserProfile> fetchCurrentUser() async {
    try {
      final res = await _dio.get<dynamic>(ApiPaths.authMe);
      final map = parseEntityMap(res.data);
      final userRaw = map['user'] ?? map;
      if (userRaw is! Map) {
        throw ApiException(userMessage: 'Некорректный профиль пользователя.');
      }
      return UserProfile.fromJson(Map<String, dynamic>.from(userRaw));
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<DashboardStats> fetchDashboard() async {
    try {
      final res = await _dio.get<dynamic>(ApiPaths.dashboard);
      final map = parseEntityMap(res.data);
      return DashboardStats(
        branches: _readCount(map, ['branch_count', 'branches', 'branches_count']),
        services: _readCount(map, ['service_count', 'services', 'services_count']),
        staff: _readCount(map, ['staff_count', 'staff']),
        bookings: _readCount(map, [
          'bookings_today',
          'bookings_today_count',
          'today_bookings',
          'bookings',
        ]),
      );
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  int _readCount(Map<String, dynamic> map, List<String> keys) {
    for (final k in keys) {
      final v = readInt(map[k]);
      if (v != null) return v;
    }
    return 0;
  }

  Future<(List<Branch>, int)> fetchBranches() async {
    try {
      final res = await _dio.get<dynamic>(ApiPaths.branches);
      final list = parseResultList(res.data);
      final count = parseCount(res.data);
      return (list.map(Branch.fromJson).toList(), count);
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<Branch> fetchBranch(int id) async {
    try {
      final res = await _dio.get<dynamic>(ApiPaths.branch(id));
      return Branch.fromJson(parseEntityMap(res.data));
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<Branch> createBranch(Branch draft) async {
    try {
      final res = await _dio.post<dynamic>(
        ApiPaths.branches,
        data: draft.toCreateBody(),
      );
      return Branch.fromJson(parseEntityMap(res.data));
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<Branch> updateBranch(Branch branch) async {
    try {
      final res = await _dio.patch<dynamic>(
        ApiPaths.branch(branch.id),
        data: branch.toCreateBody(),
      );
      return Branch.fromJson(parseEntityMap(res.data));
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<void> deleteBranch(int id) async {
    try {
      await _dio.delete<void>(ApiPaths.branch(id));
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<(List<SalonService>, int)> fetchServices() async {
    try {
      final res = await _dio.get<dynamic>(ApiPaths.services);
      final list = parseResultList(res.data);
      final count = parseCount(res.data);
      return (list.map(SalonService.fromJson).toList(), count);
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<SalonService> fetchService(int id) async {
    try {
      final res = await _dio.get<dynamic>(ApiPaths.service(id));
      return SalonService.fromJson(parseEntityMap(res.data));
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<SalonService> createService(SalonService draft) async {
    try {
      final res = await _dio.post<dynamic>(
        ApiPaths.services,
        data: draft.toCreateBody(),
      );
      return SalonService.fromJson(parseEntityMap(res.data));
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<SalonService> updateService(SalonService s) async {
    try {
      final res = await _dio.patch<dynamic>(
        ApiPaths.service(s.id),
        data: s.toCreateBody(),
      );
      return SalonService.fromJson(parseEntityMap(res.data));
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<void> deleteService(int id) async {
    try {
      await _dio.delete<void>(ApiPaths.service(id));
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<(List<StaffMember>, int)> fetchStaff() async {
    try {
      final res = await _dio.get<dynamic>(ApiPaths.staff);
      final list = parseResultList(res.data);
      final count = parseCount(res.data);
      return (list.map(StaffMember.fromJson).toList(), count);
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<StaffMember> fetchStaffMember(int id) async {
    try {
      final res = await _dio.get<dynamic>(ApiPaths.staffMember(id));
      return StaffMember.fromJson(parseEntityMap(res.data));
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<StaffMember> createStaff(StaffMember draft) async {
    try {
      final res = await _dio.post<dynamic>(
        ApiPaths.staff,
        data: draft.toCreateBody(),
      );
      return StaffMember.fromJson(parseEntityMap(res.data));
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<StaffMember> updateStaff(StaffMember s) async {
    try {
      final res = await _dio.patch<dynamic>(
        ApiPaths.staffMember(s.id),
        data: s.toCreateBody(),
      );
      return StaffMember.fromJson(parseEntityMap(res.data));
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<void> deleteStaff(int id) async {
    try {
      await _dio.delete<void>(ApiPaths.staffMember(id));
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<(List<Booking>, int)> fetchBookings({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? status,
    int? staffId,
    String? search,
  }) async {
    try {
      final q = <String, dynamic>{};
      if (dateFrom != null) q['date_from'] = formatApiDate(dateFrom);
      if (dateTo != null) q['date_to'] = formatApiDate(dateTo);
      if (status != null && status.isNotEmpty) q['status'] = status;
      if (staffId != null) q['staff'] = staffId;
      if (search != null && search.isNotEmpty) q['search'] = search;
      final res = await _dio.get<dynamic>(
        ApiPaths.bookings,
        queryParameters: q.isEmpty ? null : q,
      );
      final list = parseResultList(res.data);
      final count = parseCount(res.data);
      return (list.map(Booking.fromJson).toList(), count);
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<Booking> fetchBooking(int id) async {
    try {
      final res = await _dio.get<dynamic>(ApiPaths.booking(id));
      return Booking.fromJson(parseEntityMap(res.data));
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<Booking> patchBookingStatus(int id, String status) async {
    try {
      final res = await _dio.patch<dynamic>(
        ApiPaths.bookingStatus(id),
        data: {'status': status.toUpperCase()},
      );
      return Booking.fromJson(parseEntityMap(res.data));
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<Booking> patchBookingComment(int id, String adminComment) async {
    try {
      final res = await _dio.patch<dynamic>(
        ApiPaths.bookingComment(id),
        data: {'admin_comment': adminComment},
      );
      return Booking.fromJson(parseEntityMap(res.data));
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }
}
