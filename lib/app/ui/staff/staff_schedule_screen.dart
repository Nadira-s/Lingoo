import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalog_providers.dart';
import '../../domain/model/staff_schedule.dart';
import '../../di/app_providers.dart';
import '../../utils/api_exception.dart';
import '../widgets/components/app_ui_tokens.dart';
class StaffScheduleScreen extends ConsumerStatefulWidget {
  const StaffScheduleScreen({super.key, required this.staffId});

  final int staffId;

  @override
  ConsumerState<StaffScheduleScreen> createState() =>
      _StaffScheduleScreenState();
}

class _StaffScheduleScreenState extends ConsumerState<StaffScheduleScreen> {
  List<StaffScheduleDay> _days = [];
  bool _saving = false;

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
          if (_days.isEmpty && schedule.days.isNotEmpty) {
            _days = List.of(schedule.days);
          } else if (_days.isEmpty) {
            _days = List.generate(
              7,
              (i) => StaffScheduleDay(
                weekday: i,
                weekdayName: _weekdayName(i),
                isWorking: i < 5,
                startTime: '09:00:00',
                endTime: '18:00:00',
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const Text(
                'Рабочие дни и перерывы (неделя)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppUiTokens.secondaryText,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(_days.length, (index) {
                final day = _days[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
                    border: Border.all(color: AppUiTokens.borderSubtle),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                day.weekdayName.isEmpty
                                    ? _weekdayName(day.weekday)
                                    : day.weekdayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Switch(
                              value: day.isWorking,
                              activeColor: const Color(0xFFFFCC00),
                              onChanged: (v) => setState(() {
                                _days[index] = StaffScheduleDay(
                                  weekday: day.weekday,
                                  weekdayName: day.weekdayName,
                                  isWorking: v,
                                  startTime: day.startTime,
                                  endTime: day.endTime,
                                  breakStart: day.breakStart,
                                  breakEnd: day.breakEnd,
                                );
                              }),
                            ),
                          ],
                        ),
                        if (day.isWorking) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${_shortTime(day.startTime)} — ${_shortTime(day.endTime)}',
                            style: const TextStyle(
                              color: AppUiTokens.secondaryText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (day.breakStart != null && day.breakEnd != null)
                            Text(
                              'Перерыв: ${_shortTime(day.breakStart)} — ${_shortTime(day.breakEnd)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppUiTokens.tertiaryText,
                              ),
                            ),
                        ],
                      ],
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

  String _weekdayName(int i) {
    const names = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return i >= 0 && i < names.length ? names[i] : '$i';
  }

  String _shortTime(String? t) {
    if (t == null || t.isEmpty) return '—';
    return t.length >= 5 ? t.substring(0, 5) : t;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(lingooRepositoryProvider).saveStaffSchedule(
        widget.staffId,
        StaffSchedule(days: _days),
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
}
