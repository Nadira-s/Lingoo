/// Ошибка API или сети с сообщением для пользователя.
class ApiException implements Exception {
  ApiException({
    required this.userMessage,
    this.statusCode,
    this.code,
    this.debugMessage,
    this.fieldErrors,
  });

  final String userMessage;
  final int? statusCode;
  final String? code;
  final String? debugMessage;
  final Map<String, dynamic>? fieldErrors;

  @override
  String toString() =>
      'ApiException($statusCode, $code): $userMessage'
      '${debugMessage != null ? ' [$debugMessage]' : ''}';
}
