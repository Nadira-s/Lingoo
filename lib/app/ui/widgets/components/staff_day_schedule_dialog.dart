import 'package:flutter/material.dart';

import '../../../domain/model/staff_schedule.dart';
import 'app_ui_tokens.dart';
import 'primary_button.dart';

const _weekdayTitles = [
  'Понедельник',
  'Вторник',
  'Среда',
  'Четверг',
  'Пятница',
  'Суббота',
  'Воскресенье',
];

/// Диалог настройки рабочего дня (макет: рабочий день, время, обед).
Future<StaffScheduleDay?> showStaffDayScheduleDialog(
  BuildContext context, {
  required StaffScheduleDay day,
}) {
  return showDialog<StaffScheduleDay>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => _StaffDayScheduleDialog(day: day),
  );
}

class _StaffDayScheduleDialog extends StatefulWidget {
  const _StaffDayScheduleDialog({required this.day});

  final StaffScheduleDay day;

  @override
  State<_StaffDayScheduleDialog> createState() => _StaffDayScheduleDialogState();
}

class _StaffDayScheduleDialogState extends State<_StaffDayScheduleDialog> {
  late bool _isWorking;
  late bool _hasLunch;
  late TimeOfDay _start;
  late TimeOfDay _end;
  TimeOfDay? _lunchStart;
  TimeOfDay? _lunchEnd;

  static const _border = Color(0xFFE8E8E8);

  @override
  void initState() {
    super.initState();
    final d = widget.day;
    _isWorking = d.isWorking;
    _start = _parseTime(d.startTime, const TimeOfDay(hour: 9, minute: 0));
    _end = _parseTime(d.endTime, const TimeOfDay(hour: 18, minute: 0));
    _hasLunch = d.breakStart != null && d.breakEnd != null;
    _lunchStart = _hasLunch
        ? _parseTime(d.breakStart, const TimeOfDay(hour: 13, minute: 0))
        : null;
    _lunchEnd = _hasLunch
        ? _parseTime(d.breakEnd, const TimeOfDay(hour: 14, minute: 0))
        : null;
  }

  String get _title {
    if (widget.day.weekdayName.isNotEmpty) return widget.day.weekdayName;
    final i = widget.day.weekday;
    return i >= 0 && i < _weekdayTitles.length ? _weekdayTitles[i] : 'День';
  }

  TimeOfDay _parseTime(String? raw, TimeOfDay fallback) {
    if (raw == null || raw.length < 5) return fallback;
    final parts = raw.substring(0, 5).split(':');
    if (parts.length != 2) return fallback;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return fallback;
    return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
  }

  String _formatApi(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  String _formatDisplay(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime({
    required TimeOfDay initial,
    required ValueChanged<TimeOfDay> onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFCC00),
              onPrimary: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onPicked(picked);
  }

  void _apply() {
    if (_isWorking && _start.hour * 60 + _start.minute >= _end.hour * 60 + _end.minute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Время «до» должно быть позже «с»')),
      );
      return;
    }
    if (_isWorking && _hasLunch) {
      final ls = _lunchStart!;
      final le = _lunchEnd!;
      if (ls.hour * 60 + ls.minute >= le.hour * 60 + le.minute) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Конец обеда должен быть позже начала')),
        );
        return;
      }
    }
    Navigator.pop(
      context,
      widget.day.copyWith(
        isWorking: _isWorking,
        startTime: _isWorking ? _formatApi(_start) : null,
        endTime: _isWorking ? _formatApi(_end) : null,
        breakStart: _isWorking && _hasLunch ? _formatApi(_lunchStart!) : null,
        breakEnd: _isWorking && _hasLunch ? _formatApi(_lunchEnd!) : null,
        clearBreak: !_hasLunch || !_isWorking,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppUiTokens.primaryText,
              ),
            ),
            const SizedBox(height: 20),
            _CheckRow(
              label: 'Рабочий день',
              value: _isWorking,
              onChanged: (v) => setState(() => _isWorking = v ?? false),
            ),
            if (_isWorking) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TimeField(
                      label: 'с',
                      value: _formatDisplay(_start),
                      enabled: true,
                      onTap: () => _pickTime(
                        initial: _start,
                        onPicked: (t) => setState(() => _start = t),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeField(
                      label: 'до',
                      value: _formatDisplay(_end),
                      enabled: true,
                      onTap: () => _pickTime(
                        initial: _end,
                        onPicked: (t) => setState(() => _end = t),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            const Divider(height: 1, color: _border),
            const SizedBox(height: 16),
            _CheckRow(
              label: 'Обеденный час',
              value: _hasLunch,
              onChanged: _isWorking
                  ? (v) => setState(() {
                        _hasLunch = v ?? false;
                        if (_hasLunch) {
                          _lunchStart ??= const TimeOfDay(hour: 13, minute: 0);
                          _lunchEnd ??= const TimeOfDay(hour: 14, minute: 0);
                        }
                      })
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TimeField(
                    label: 'с',
                    value: _hasLunch && _lunchStart != null
                        ? _formatDisplay(_lunchStart!)
                        : '--:--',
                    enabled: _isWorking && _hasLunch,
                    onTap: _isWorking && _hasLunch
                        ? () => _pickTime(
                              initial: _lunchStart!,
                              onPicked: (t) => setState(() => _lunchStart = t),
                            )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeField(
                    label: 'до',
                    value: _hasLunch && _lunchEnd != null
                        ? _formatDisplay(_lunchEnd!)
                        : '--:--',
                    enabled: _isWorking && _hasLunch,
                    onTap: _isWorking && _hasLunch
                        ? () => _pickTime(
                              initial: _lunchEnd!,
                              onPicked: (t) => setState(() => _lunchEnd = t),
                            )
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: 'Применить', onPressed: _apply),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Отмена',
              isOutlined: true,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFE91E8C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: const BorderSide(color: Color(0xFFBDBDBD), width: 1.5),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: onChanged == null
                ? AppUiTokens.tertiaryText
                : AppUiTokens.primaryText,
          ),
        ),
      ],
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.enabled,
    this.onTap,
  });

  final String label;
  final String value;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppUiTokens.primaryText : AppUiTokens.tertiaryText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppUiTokens.secondaryText,
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: enabled ? const Color(0xFFF5F5F5) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.schedule_outlined,
                    size: 20,
                    color: enabled
                        ? AppUiTokens.secondaryText
                        : AppUiTokens.tertiaryText,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
