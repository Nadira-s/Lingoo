/// REST paths relative to [AppConfig.apiBaseUrl].
abstract final class ApiEndpoints {
  static const authLogin = '/auth/login/';
  static const authRefresh = '/auth/refresh/';
  static const authLogout = '/auth/logout/';
  static const authMe = '/auth/me/';

  static const dashboard = '/dashboard/';

  static const branches = '/branches/';
  static String branch(int id) => '/branches/$id/';
  static const services = '/services/';
  static String service(int id) => '/services/$id/';
  static const staff = '/staff/';
  static String staffMember(int id) => '/staff/$id/';
  static String staffSchedule(int id) => '/staff/$id/schedule/';

  static const bookings = '/bookings/';
  static String booking(int id) => '/bookings/$id/';
  static String bookingStatus(int id) => '/bookings/$id/status/';
  static String bookingComment(int id) => '/bookings/$id/comment/';
  static const bookingsStats = '/bookings/stats/';
  static const bookingsCalendar = '/bookings/calendar/';

  static const businessSettings = '/business/settings/';
  static const businessPublicBookingLink = '/business/public-booking-link/';
  static const tariffLimits = '/tariff/limits/';

  static bool isAuthLogin(String path, String method) =>
      path.contains(authLogin) && method.toUpperCase() == 'POST';

  static bool isAuthRefresh(String path, String method) =>
      path.contains(authRefresh) && method.toUpperCase() == 'POST';

  static bool isPublicAuth(String path, String method) =>
      isAuthLogin(path, method) || isAuthRefresh(path, method);
}
