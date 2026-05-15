/// Пути относительно [AppConfig.apiBaseUrl].
/// При смене backend скорректируйте здесь или вынесите в dart-define.
abstract final class ApiPaths {
  static const authToken = '/auth/token/';
  static const authRefresh = '/auth/token/refresh/';
  static const usersMe = '/users/me/';
  static const branches = '/branches/';
  static String branch(int id) => '/branches/$id/';
  static const services = '/services/';
  static String service(int id) => '/services/$id/';
  static const staff = '/staff/';
  static String staffMember(int id) => '/staff/$id/';
  static const bookings = '/bookings/';
  static String booking(int id) => '/bookings/$id/';
}
