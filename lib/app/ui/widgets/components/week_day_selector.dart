import 'package:flutter/material.dart';

import 'app_ui_tokens.dart';

/// Горизонтальный выбор дня недели (как на макете «Расписание»).
class WeekDaySelector extends StatelessWidget {
  const WeekDaySelector({
    super.key,
    required this.days,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<WeekDayItem> days;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final d = days[index];
          final selected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 52,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFFCC00) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    d.weekdayLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppUiTokens.primaryText
                          : AppUiTokens.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${d.dayNumber}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? AppUiTokens.primaryText
                          : AppUiTokens.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class WeekDayItem {
  const WeekDayItem({
    required this.date,
    required this.weekdayLabel,
    required this.dayNumber,
  });

  final DateTime date;
  final String weekdayLabel;
  final int dayNumber;

  static List<WeekDayItem> weekAround(DateTime anchor) {
    final start = anchor.subtract(Duration(days: anchor.weekday - 1));
    const labels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return List.generate(7, (i) {
      final d = DateTime(start.year, start.month, start.day + i);
      return WeekDayItem(
        date: d,
        weekdayLabel: labels[i],
        dayNumber: d.day,
      );
    });
  }
}
