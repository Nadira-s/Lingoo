import 'package:flutter/material.dart';

import '../../../domain/model/staff_member.dart';
import '../components/active_status_chip.dart';
import '../components/app_ui_tokens.dart';
import 'catalog_item_card.dart';

/// Карточка сотрудника на базе [CatalogItemCard].
class StaffListCard extends StatelessWidget {
  const StaffListCard({
    super.key,
    required this.member,
    required this.onEdit,
    this.onSchedule,
    this.readOnly = false,
    this.showSchedule = true,
  });

  final StaffMember member;
  final VoidCallback onEdit;
  final VoidCallback? onSchedule;
  final bool readOnly;
  final bool showSchedule;

  String _subtitle() {
    final roleRu = switch (member.apiRole.toUpperCase()) {
      'STAFF' => 'Сотрудник',
      'MANAGER' => 'Менеджер',
      _ => member.apiRole,
    };
    if (member.branchName.isEmpty) return roleRu;
    return '$roleRu · ${member.branchName}';
  }

  String _initials() {
    final parts = member.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      final s = parts.first;
      return s.length >= 2 ? s.substring(0, 2).toUpperCase() : s.toUpperCase();
    }
    return (parts.first[0] + parts.elementAt(1)[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final title = member.name.isEmpty ? 'Сотрудник' : member.name;

    return CatalogItemCard(
      statusBadge: ActiveStatusChip(
        active: member.isActive,
        activeLabel: 'Активен',
        inactiveLabel: 'В отпуске',
      ),
      title: title,
      subtitle: _subtitle(),
      trailingVisual: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ColoredBox(
          color: AppUiTokens.surfaceMuted,
          child: Center(
            child: Text(
              _initials(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppUiTokens.primaryText,
              ),
            ),
          ),
        ),
      ),
      primaryAction: readOnly
          ? null
          : CatalogItemCardAction(
              label: 'Редактировать',
              icon: Icons.edit_outlined,
              onPressed: onEdit,
            ),
      secondaryAction: showSchedule
          ? CatalogItemCardAction(
              label: 'Расписание',
              icon: Icons.calendar_today_outlined,
              onPressed: onSchedule ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Расписание: $title')),
                    );
                  },
              style: CatalogItemCardButtonStyle.filledAccent,
            )
          : null,
    );
  }
}
