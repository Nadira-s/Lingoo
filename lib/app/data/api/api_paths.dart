/// Пути относительно [AppConfig.apiBaseUrl] (`/api/v1`).
abstract final class ApiPaths {
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

  static const bookings = '/bookings/';
  static String booking(int id) => '/bookings/$id/';
  static String bookingStatus(int id) => '/bookings/$id/status/';
  static String bookingComment(int id) => '/bookings/$id/comment/';
  static const bookingsStats = '/bookings/stats/';
}
