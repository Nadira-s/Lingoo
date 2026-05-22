import 'package:flutter/material.dart';

import '../../../utils/phone_format.dart';

/// Поле телефона по умолчанию: маска +7 (XXX) XXX-XX-XX.
class PhoneTextField extends StatefulWidget {
  const PhoneTextField({
    super.key,
    required this.controller,
    this.labelText = 'Телефон',
    this.hintText = '+7 (___) ___-__-__',
    this.validator,
    this.required = false,
  });

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String? Function(String?)? validator;
  final bool required;

  @override
  State<PhoneTextField> createState() => _PhoneTextFieldState();
}

class _PhoneTextFieldState extends State<PhoneTextField> {
  @override
  void initState() {
    super.initState();
    if (widget.controller.text.isNotEmpty) {
      PhoneFormat.applyToController(widget.controller, widget.controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1C1E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: TextInputType.phone,
          inputFormatters: [PhoneInputFormatter()],
          autofillHints: const [AutofillHints.telephoneNumber],
          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            fillColor: const Color(0xFFFFFFFF),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFB2AFAF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFB2AFAF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFFCC00),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE53935)),
            ),
          ),
          validator: widget.validator ??
              (widget.required
                  ? (v) {
                      final d = PhoneFormat.normalizeDigits(v ?? '');
                      if (d.length < 11) return 'Введите номер полностью';
                      return null;
                    }
                  : null),
        ),
      ],
    );
  }
}
