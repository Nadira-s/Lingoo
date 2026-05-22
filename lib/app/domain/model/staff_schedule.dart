import '../../data/api/json_helpers.dart';

class StaffScheduleDay {
  const StaffScheduleDay({
    required this.weekday,
    required this.weekdayName,
    required this.isWorking,
    this.startTime,
    this.endTime,
    this.breakStart,
    this.breakEnd,
  });

  final int weekday;
  final String weekdayName;
  final bool isWorking;
  final String? startTime;
  final String? endTime;
  final String? breakStart;
  final String? breakEnd;

  factory StaffScheduleDay.fromJson(Map<String, dynamic> json) {
    return StaffScheduleDay(
      weekday: readInt(json['weekday']) ?? 0,
      weekdayName: readString(json, 'weekday_name'),
      isWorking: readBool(json, 'is_working'),
      startTime: readString(json, 'start_time').isEmpty
          ? null
          : readString(json, 'start_time'),
      endTime: readString(json, 'end_time').isEmpty
          ? null
          : readString(json, 'end_time'),
      breakStart: readString(json, 'break_start').isEmpty
          ? null
          : readString(json, 'break_start'),
      breakEnd: readString(json, 'break_end').isEmpty
          ? null
          : readString(json, 'break_end'),
    );
  }

  Map<String, dynamic> toJson() => {
        'weekday': weekday,
        'is_working': isWorking,
        if (startTime != null) 'start_time': startTime,
        if (endTime != null) 'end_time': endTime,
        if (breakStart != null) 'break_start': breakStart,
        if (breakEnd != null) 'break_end': breakEnd,
      };
}

class StaffSchedule {
  const StaffSchedule({required this.days});

  final List<StaffScheduleDay> days;

  factory StaffSchedule.fromJson(Map<String, dynamic> json) {
    final raw = json['days'];
    if (raw is! List) return const StaffSchedule(days: []);
    return StaffSchedule(
      days: raw
          .whereType<Map>()
          .map((e) => StaffScheduleDay.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toPutBody() => {
        'days': days.map((d) => d.toJson()).toList(),
      };
}
