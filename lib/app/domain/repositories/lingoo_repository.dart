import '../model/booking.dart';
import '../model/booking_stats.dart';
import '../model/branch.dart';
import '../model/business_settings.dart';
import '../model/dashboard_data.dart';
import '../model/salon_service.dart';
import '../model/staff_member.dart';
import '../model/staff_schedule.dart';
import '../model/tariff_limits.dart';
import '../model/user_profile.dart';
import '../../data/dto/auth_tokens.dart';

/// Domain contract for all backend operations (Mobile API).
abstract class LingooRepository {
  Future<AuthLoginResult> login({
    required String username,
    required String password,
  });

  Future<AuthTokens> refreshToken(String refresh);

  Future<void> logout({String? refresh});

  Future<UserProfile> getCurrentUser();

  Future<DashboardData> getDashboard();

  Future<BookingStats> getBookingsStats();

  Future<Map<String, List<Booking>>> getBookingsCalendar({
    required int month,
    required int year,
  });

  Future<List<Booking>> getBookings({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? status,
    int? staffId,
    String? search,
  });

  Future<Booking> getBooking(int id);

  Future<Booking> createBooking(Booking draft);

  Future<Booking> updateBookingStatus(int id, String status);

  Future<Booking> updateBookingComment(int id, String adminComment);

  Future<List<Branch>> getBranches();

  Future<Branch> getBranch(int id);

  Future<Branch> createBranch(Branch draft);

  Future<Branch> updateBranch(Branch branch);

  Future<void> deleteBranch(int id);

  Future<List<SalonService>> getServices();

  Future<SalonService> getService(int id);

  Future<SalonService> createService(SalonService draft);

  Future<SalonService> updateService(SalonService service);

  Future<void> deleteService(int id);

  Future<List<StaffMember>> getStaff();

  Future<StaffMember> getStaffMember(int id);

  Future<StaffMember> createStaff(StaffMember draft, {String? password});

  Future<StaffMember> updateStaff(StaffMember staff, {String? password});

  Future<void> deleteStaff(int id);

  Future<StaffSchedule> getStaffSchedule(int staffId);

  Future<StaffSchedule> saveStaffSchedule(int staffId, StaffSchedule schedule);

  Future<BusinessSettings> getBusinessSettings();

  Future<BusinessSettings> updateBusinessSettings(BusinessSettings settings);

  Future<String> getPublicBookingUrl();

  Future<TariffLimits> getTariffLimits();
}
