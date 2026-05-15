import 'package:flutter/material.dart';

import '../components/active_status_chip.dart';
import '../components/app_ui_tokens.dart';

/// Карточка строки в списках «Пользователи / роли» (управление доступами).
class AccessListCard extends StatelessWidget {
  const AccessListCard({
    super.key,
    required this.title,
    required this.leading,
    required this.isActive,
    this.secondaryLine,
    required this.tertiaryLine,
    this.activeLabel = 'Активен',
    this.inactiveLabel = 'Неактивен',
    this.onTap,
  });

  final String title;
  final Widget leading;
  final bool isActive;
  /// Email пользователя или описание роли.
  final String? secondaryLine;
  /// Роль пользователя или доп. текст.
  final String tertiaryLine;
  final String activeLabel;
  final String inactiveLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppUiTokens.borderSubtle),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 56, height: 56, child: leading),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppUiTokens.primaryText,
                          height: 1.2,
                        ),
                      ),
                      if (secondaryLine != null &&
                          secondaryLine!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          secondaryLine!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: AppUiTokens.secondaryText,
                          ),
                        ),
                      ],
                      if (tertiaryLine.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          tertiaryLine,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: AppUiTokens.secondaryText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ActiveStatusChip(
                  active: isActive,
                  activeLabel: activeLabel,
                  inactiveLabel: inactiveLabel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Квадратное превью с инициалами (пока нет фото из API).
class AccessListAvatar extends StatelessWidget {
  const AccessListAvatar({super.key, required this.name});

  final String name;

  String _initials() {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final s = parts.first;
      return s.length >= 2 ? s.substring(0, 2).toUpperCase() : s.toUpperCase();
    }
    return (parts.first[0] + parts.elementAt(1)[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ColoredBox(
        color: AppUiTokens.surfaceMuted,
        child: Center(
          child: Text(
            _initials(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppUiTokens.primaryText,
            ),
          ),
        ),
      ),
    );
  }
}
