import '../../../core/network/api_endpoints.dart';

export '../../../core/network/api_endpoints.dart';

/// Legacy name — same paths as [ApiEndpoints].
abstract final class ApiPaths {
  static const authLogin = ApiEndpoints.authLogin;
  static const authRefresh = ApiEndpoints.authRefresh;
  static const authLogout = ApiEndpoints.authLogout;
  static const authMe = ApiEndpoints.authMe;
  static const dashboard = ApiEndpoints.dashboard;
  static const branches = ApiEndpoints.branches;
  static String branch(int id) => ApiEndpoints.branch(id);
  static const services = ApiEndpoints.services;
  static String service(int id) => ApiEndpoints.service(id);
  static const staff = ApiEndpoints.staff;
  static String staffMember(int id) => ApiEndpoints.staffMember(id);
  static String staffSchedule(int id) => ApiEndpoints.staffSchedule(id);
  static const bookings = ApiEndpoints.bookings;
  static String booking(int id) => ApiEndpoints.booking(id);
  static String bookingStatus(int id) => ApiEndpoints.bookingStatus(id);
  static String bookingComment(int id) => ApiEndpoints.bookingComment(id);
  static const bookingsStats = ApiEndpoints.bookingsStats;
  static const bookingsCalendar = ApiEndpoints.bookingsCalendar;
  static const businessSettings = ApiEndpoints.businessSettings;
  static const businessPublicBookingLink = ApiEndpoints.businessPublicBookingLink;
  static const tariffLimits = ApiEndpoints.tariffLimits;
}
