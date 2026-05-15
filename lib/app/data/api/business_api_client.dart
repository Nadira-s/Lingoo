import 'package:dio/dio.dart';

import '../../utils/api_exception.dart';
import '../../utils/error_mapper.dart';
import '../../domain/model/user_role.dart';
import '../dto/auth_tokens.dart';
import '../../domain/model/booking.dart';
import '../../domain/model/branch.dart';
import '../../domain/model/salon_service.dart';
import '../../domain/model/staff_member.dart';
import '../../domain/model/user_profile.dart';
import 'api_paths.dart';
import 'json_helpers.dart';

// Включайте временно для быстрой отладки без backend.
const bool mockMode = true;
const String serverUnavailableMessage = 'Сервер временно недоступен';

class BusinessApiClient {
  BusinessApiClient(this._dio);

  final Dio _dio;

  Future<AuthTokens> login({
    required String username,
    required String password,
  }) async {
    if (mockMode) {
      // Mock login - любые учетные данные работают
      return const AuthTokens(
        access: 'mock_token_12345',
        refresh: 'mock_refresh_token_12345',
      );
    }
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiPaths.authToken,
        data: {'username': username, 'password': password},
      );
      final data = res.data;
      if (data == null) {
        throw ApiException(userMessage: 'Пустой ответ сервера.');
      }
      return AuthTokens.fromJson(data);
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<UserProfile> fetchCurrentUser() async {
    if (mockMode) {
      // Mock user profile
      return const UserProfile(
        id: 1,
        username: 'test_user',
        role: UserRole.tenantAdmin,
      );
    }
    try {
      final res = await _dio.get<Map<String, dynamic>>(ApiPaths.usersMe);
      final data = res.data;
      if (data == null) {
        throw ApiException(userMessage: 'Пустой ответ сервера.');
      }
      return UserProfile.fromJson(data);
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<(List<Branch>, int)> fetchBranches() async {
    if (mockMode) {
      return (<Branch>[], 0);
    }
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
    if (mockMode) {
      throw ApiException(userMessage: serverUnavailableMessage);
    }
    try {
      final res = await _dio.get<Map<String, dynamic>>(ApiPaths.branch(id));
      final data = res.data;
      if (data == null) {
        throw ApiException(userMessage: 'Пустой ответ сервера.');
      }
      return Branch.fromJson(data);
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<Branch> createBranch(Branch draft) async {
    if (mockMode) {
      throw ApiException(userMessage: serverUnavailableMessage);
    }
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiPaths.branches,
        data: draft.toCreateBody(),
      );
      final data = res.data;
      if (data == null) {
        throw ApiException(userMessage: 'Пустой ответ сервера.');
      }
      return Branch.fromJson(data);
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<Branch> updateBranch(Branch branch) async {
    if (mockMode) {
      throw ApiException(userMessage: serverUnavailableMessage);
    }
    try {
      final res = await _dio.patch<Map<String, dynamic>>(
        ApiPaths.branch(branch.id),
        data: branch.toCreateBody(),
      );
      final data = res.data;
      if (data == null) {
        throw ApiException(userMessage: 'Пустой ответ сервера.');
      }
      return Branch.fromJson(data);
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<void> deleteBranch(int id) async {
    if (mockMode) {
      throw ApiException(userMessage: serverUnavailableMessage);
    }
    try {
      await _dio.delete<void>(ApiPaths.branch(id));
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<(List<SalonService>, int)> fetchServices() async {
    if (mockMode) {
      return (<SalonService>[], 0);
    }
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
    if (mockMode) {
      throw ApiException(userMessage: serverUnavailableMessage);
    }
    try {
      final res = await _dio.get<Map<String, dynamic>>(ApiPaths.service(id));
      final data = res.data;
      if (data == null) {
        throw ApiException(userMessage: 'Пустой ответ сервера.');
      }
      return SalonService.fromJson(data);
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<SalonService> createService(SalonService draft) async {
    if (mockMode) {
      throw ApiException(userMessage: serverUnavailableMessage);
    }
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiPaths.services,
        data: draft.toCreateBody(),
      );
      final data = res.data;
      if (data == null) {
        throw ApiException(userMessage: 'Пустой ответ сервера.');
      }
      return SalonService.fromJson(data);
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<SalonService> updateService(SalonService s) async {
    if (mockMode) {
      throw ApiException(userMessage: serverUnavailableMessage);
    }
    try {
      final res = await _dio.patch<Map<String, dynamic>>(
        ApiPaths.service(s.id),
        data: s.toCreateBody(),
      );
      final data = res.data;
      if (data == null) {
        throw ApiException(userMessage: 'Пустой ответ сервера.');
      }
      return SalonService.fromJson(data);
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<void> deleteService(int id) async {
    if (mockMode) {
      throw ApiException(userMessage: serverUnavailableMessage);
    }
    try {
      await _dio.delete<void>(ApiPaths.service(id));
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<(List<StaffMember>, int)> fetchStaff() async {
    if (mockMode) {
      return (<StaffMember>[], 0);
    }
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
    if (mockMode) {
      throw ApiException(userMessage: serverUnavailableMessage);
    }
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        ApiPaths.staffMember(id),
      );
      final data = res.data;
      if (data == null) {
        throw ApiException(userMessage: 'Пустой ответ сервера.');
      }
      return StaffMember.fromJson(data);
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<StaffMember> createStaff(StaffMember draft) async {
    if (mockMode) {
      throw ApiException(userMessage: serverUnavailableMessage);
    }
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiPaths.staff,
        data: draft.toCreateBody(),
      );
      final data = res.data;
      if (data == null) {
        throw ApiException(userMessage: 'Пустой ответ сервера.');
      }
      return StaffMember.fromJson(data);
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<StaffMember> updateStaff(StaffMember s) async {
    if (mockMode) {
      throw ApiException(userMessage: serverUnavailableMessage);
    }
    try {
      final res = await _dio.patch<Map<String, dynamic>>(
        ApiPaths.staffMember(s.id),
        data: s.toCreateBody(),
      );
      final data = res.data;
      if (data == null) {
        throw ApiException(userMessage: 'Пустой ответ сервера.');
      }
      return StaffMember.fromJson(data);
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<void> deleteStaff(int id) async {
    if (mockMode) {
      throw ApiException(userMessage: serverUnavailableMessage);
    }
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
  }) async {
    if (mockMode) {
      return (<Booking>[], 0);
    }
    try {
      final q = <String, dynamic>{};
      if (dateFrom != null) q['date_from'] = dateFrom.toIso8601String();
      if (dateTo != null) q['date_to'] = dateTo.toIso8601String();
      if (status != null && status.isNotEmpty) q['status'] = status;
      if (staffId != null) q['staff'] = staffId;
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
    if (mockMode) {
      throw ApiException(userMessage: serverUnavailableMessage);
    }
    try {
      final res = await _dio.get<Map<String, dynamic>>(ApiPaths.booking(id));
      final data = res.data;
      if (data == null) {
        throw ApiException(userMessage: 'Пустой ответ сервера.');
      }
      return Booking.fromJson(data);
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }

  Future<Booking> patchBooking(int id, {String? status, String? note}) async {
    if (mockMode) {
      throw ApiException(userMessage: serverUnavailableMessage);
    }
    try {
      final body = <String, dynamic>{};
      if (status != null) body['status'] = status;
      if (note != null) body['note'] = note;
      final res = await _dio.patch<Map<String, dynamic>>(
        ApiPaths.booking(id),
        data: body,
      );
      final data = res.data;
      if (data == null) {
        throw ApiException(userMessage: 'Пустой ответ сервера.');
      }
      return Booking.fromJson(data);
    } on DioException catch (e) {
      throw apiExceptionFromDio(e);
    }
  }
}
