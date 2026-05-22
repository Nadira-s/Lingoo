import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

/// Казахстан / РФ: маска +7 (XXX) XXX-XX-XX, в API — `+7XXXXXXXXXX`.
class PhoneFormat {
  PhoneFormat._();

  /// Только цифры, всегда с ведущей 7 (до 11 цифр).
  static String normalizeDigits(String raw) {
    var d = raw.replaceAll(RegExp(r'\D'), '');
    if (d.isEmpty) return '';
    if (d.startsWith('8') && d.length >= 11) {
      d = '7${d.substring(1)}';
    } else if (!d.startsWith('7')) {
      d = '7$d';
    }
    if (d.length > 11) d = d.substring(0, 11);
    return d;
  }

  static String formatDisplay(String raw) {
    final d = normalizeDigits(raw);
    if (d.isEmpty) return '';
    final rest = d.length > 1 ? d.substring(1) : '';
    return _formatDisplayFromRest(rest);
  }

  static String _formatDisplayFromRest(String rest) {
    if (rest.isEmpty) return '+7';
    final p1 = rest.length >= 3 ? rest.substring(0, 3) : rest.padRight(3, '_');
    final p2 = rest.length > 3
        ? (rest.length >= 6 ? rest.substring(3, 6) : rest.substring(3).padRight(3, '_'))
        : '___';
    final p3 = rest.length > 6
        ? (rest.length >= 8 ? rest.substring(6, 8) : rest.substring(6).padRight(2, '_'))
        : '__';
    final p4 = rest.length > 8
        ? (rest.length >= 10 ? rest.substring(8, 10) : rest.substring(8).padRight(2, '_'))
        : '__';
    return '+7 ($p1) $p2-$p3-$p4';
  }

  /// Для отправки на сервер: `+77001234567` или пустая строка.
  static String forApi(String displayOrRaw) {
    final d = normalizeDigits(displayOrRaw);
    if (d.isEmpty) return '';
    return '+$d';
  }

  /// Инициализация контроллера из ответа API.
  static void applyToController(TextEditingController controller, String? raw) {
    if (raw == null || raw.trim().isEmpty) return;
    final formatted = formatDisplay(raw);
    if (formatted.isNotEmpty) {
      controller.text = formatted;
      controller.selection = TextSelection.collapsed(offset: formatted.length);
    }
  }
}

/// Маска ввода телефона +7 (XXX) XXX-XX-XX.
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = PhoneFormat.normalizeDigits(newValue.text);
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    final rest = digits.length > 1 ? digits.substring(1) : '';
    final formatted = PhoneFormat._formatDisplayFromRest(rest);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
