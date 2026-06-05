import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalog_providers.dart';
import '../../domain/model/staff_schedule.dart';
import '../../di/app_providers.dart';
import '../../utils/api_exception.dart';
import '../widgets/components/app_ui_tokens.dart';
import '../widgets/components/staff_day_schedule_dialog.dart';

class StaffScheduleScreen extends ConsumerStatefulWidget {
  const StaffScheduleScreen({super.key, required this.staffId});

  final int staffId;

  @override
  ConsumerState<StaffScheduleScreen> createState() =>
      _StaffScheduleScreenState();
}

class _StaffScheduleScreenState extends ConsumerState<StaffScheduleScreen> {
  List<StaffScheduleDay>? _days;
  bool _saving = false;

  static const _weekdayShort = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

  void _ensureDays(List<StaffScheduleDay> fromApi) {
    if (_days != null) return;
    if (fromApi.isNotEmpty) {
      _days = List.of(fromApi);
      return;
    }
    _days = List.generate(
      7,
      (i) => StaffScheduleDay(
        weekday: i,
        weekdayName: _weekdayShort[i],
        isWorking: i < 5,
        startTime: '09:00:00',
        endTime: '18:00:00',
      ),
    );
  }

  String _weekdayName(StaffScheduleDay day) {
    if (day.weekdayName.isNotEmpty) return day.weekdayName;
    final i = day.weekday;
    return i >= 0 && i < _weekdayShort.length ? _weekdayShort[i] : '$i';
  }

  String _shortTime(String? t) {
    if (t == null || t.isEmpty) return '—';
    return t.length >= 5 ? t.substring(0, 5) : t;
  }

  Future<void> _editDay(int index) async {
    final days = _days;
    if (days == null) return;
    final updated = await showStaffDayScheduleDialog(
      context,
      day: days[index],
    );
    if (updated != null && mounted) {
      setState(() => days[index] = updated);
    }
  }

  Future<void> _save() async {
    final days = _days;
    if (days == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(lingooRepositoryProvider).saveStaffSchedule(
        widget.staffId,
        StaffSchedule(days: days),
      );
      ref.invalidate(staffScheduleProvider(widget.staffId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Расписание сохранено')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        final msg = e is ApiException
            ? e.userMessage
            : 'Не удалось сохранить расписание';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(staffScheduleProvider(widget.staffId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Расписание',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppUiTokens.primaryText,
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Сохранить',
                    style: TextStyle(
                      color: Color(0xFFFFCC00),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (schedule) {
          _ensureDays(schedule.days);
          final days = _days!;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Text(
                'Нажмите на день, чтобы задать время работы и обед',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppUiTokens.secondaryText,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(days.length, (index) {
                final day = days[index];
                final title = _weekdayName(day);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
                    child: InkWell(
                      onTap: () => _editDay(index),
                      borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppUiTokens.radiusLg),
                          border: Border.all(color: AppUiTokens.borderSubtle),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (!day.isWorking)
                                      const Text(
                                        'Выходной',
                                        style: TextStyle(
                                          color: AppUiTokens.secondaryText,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    else ...[
                                      Text(
                                        'Работа: ${_shortTime(day.startTime)} — ${_shortTime(day.endTime)}',
                                        style: const TextStyle(
                                          color: AppUiTokens.secondaryText,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (day.breakStart != null &&
                                          day.breakEnd != null)
                                        Text(
                                          'Обед: ${_shortTime(day.breakStart)} — ${_shortTime(day.breakEnd)}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppUiTokens.tertiaryText,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: AppUiTokens.tertiaryText,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
