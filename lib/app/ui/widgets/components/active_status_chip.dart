import 'package:flutter/material.dart';

import 'app_ui_tokens.dart';

/// Бейдж «Активен / Неактивен» и аналоги для списков.
class ActiveStatusChip extends StatelessWidget {
  const ActiveStatusChip({
    super.key,
    required this.active,
    this.activeLabel = 'Активен',
    this.inactiveLabel = 'Неактивен',
  });

  final bool active;
  final String activeLabel;
  final String inactiveLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFDDF5E4) : Color(0xFFDDDDDD),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        active ? activeLabel : inactiveLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: active ? const Color(0xFF1B7A3D) : AppUiTokens.secondaryText,
        ),
      ),
    );
  }
}
