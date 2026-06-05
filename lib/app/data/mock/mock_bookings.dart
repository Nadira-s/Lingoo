import '../../domain/model/booking.dart';

/// Демо-записи для списков, расписания и экрана деталей (без API).
List<Booking> buildMockBookings() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  Booking at(
    int id, {
    required int hour,
    required int minute,
    required String clientName,
    required String serviceName,
    required String status,
    String note = '',
    int dayOffset = 0,
    String? clientPhone,
  }) {
    return Booking(
      id: id,
      startsAt: today
          .add(Duration(days: dayOffset))
          .add(Duration(hours: hour, minutes: minute)),
      clientName: clientName,
      clientPhone: clientPhone,
      serviceName: serviceName,
      branchName: 'Филиал на Абая',
      staffName: 'Айкен Смагулова',
      status: status,
      note: note,
      serviceId: 1,
      branchId: 1,
      staffId: null,
    );
  }

  return [
    at(
      101,
      hour: 10,
      minute: 0,
      clientName: 'Алина Касымова',
      clientPhone: '+7 701 111 22 33',
      serviceName: 'Маникюр + гель-лак',
      status: 'NEW',
      note: 'Первый визит',
    ),
    at(
      102,
      hour: 12,
      minute: 30,
      clientName: 'Дана Серикова',
      clientPhone: '+7 702 222 33 44',
      serviceName: 'Стрижка женская',
      status: 'CONFIRMED',
    ),
    at(
      103,
      hour: 15,
      minute: 0,
      clientName: 'Мадина Оспанова',
      clientPhone: '+7 703 333 44 55',
      serviceName: 'Укладка вечерняя',
      status: 'NEW',
    ),
    at(
      104,
      hour: 11,
      minute: 0,
      dayOffset: 1,
      clientName: 'Аружан Толеуова',
      clientPhone: '+7 704 444 55 66',
      serviceName: 'Маникюр + гель-лак',
      status: 'CONFIRMED',
    ),
    at(
      105,
      hour: 16,
      minute: 30,
      dayOffset: -1,
      clientName: 'Жанар Бекенова',
      clientPhone: '+7 705 555 66 77',
      serviceName: 'Стрижка женская',
      status: 'COMPLETED',
      note: 'Оплата картой',
    ),
    at(
      106,
      hour: 9,
      minute: 30,
      dayOffset: 2,
      clientName: 'Сауле Нурланова',
      serviceName: 'Укладка вечерняя',
      status: 'CANCELLED',
    ),
  ];
}
