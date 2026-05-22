import '../../data/api/json_helpers.dart';

class BookingStats {
  const BookingStats({
    this.total = 0,
    this.today = 0,
    this.newCount = 0,
    this.confirmed = 0,
    this.completed = 0,
    this.cancelled = 0,
  });

  final int total;
  final int today;
  final int newCount;
  final int confirmed;
  final int completed;
  final int cancelled;

  factory BookingStats.fromJson(Map<String, dynamic> json) {
    return BookingStats(
      total: readInt(json['total']) ?? 0,
      today: readInt(json['today']) ?? readInt(json['bookings_today']) ?? 0,
      newCount: readInt(json['new']) ?? readInt(json['NEW']) ?? 0,
      confirmed: readInt(json['confirmed']) ?? readInt(json['CONFIRMED']) ?? 0,
      completed: readInt(json['completed']) ?? readInt(json['COMPLETED']) ?? 0,
      cancelled: readInt(json['cancelled']) ?? readInt(json['CANCELLED']) ?? 0,
    );
  }
}
