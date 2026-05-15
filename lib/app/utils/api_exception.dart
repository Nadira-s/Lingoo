/// Ошибка API или сети с сообщением для пользователя.
class ApiException implements Exception {
  ApiException({
    required this.userMessage,
    this.statusCode,
    this.code,
    this.debugMessage,
  });

  final String userMessage;
  final int? statusCode;
  final String? code;
  final String? debugMessage;

  @override
  String toString() =>
      'ApiException($statusCode, $code): $userMessage${debugMessage != null ? ' [$debugMessage]' : ''}';
}
