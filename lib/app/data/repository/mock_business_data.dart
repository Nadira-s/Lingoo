import '../../domain/model/booking.dart';
import '../../domain/model/branch.dart';
import '../../domain/model/salon_service.dart';
import '../../domain/model/staff_member.dart';
import '../../domain/model/user_role.dart';

/// Демо-данные, пока API не подключён.
abstract final class MockBusinessData {
  static const dashboardStats = (
    branches: 3,
    services: 12,
    staff: 8,
    bookingsToday: 5,
  );

  static final List<Booking> todayBookings = [
    Booking(
      id: 101,
      startsAt: DateTime.now().add(const Duration(hours: 1)),
      clientName: 'Айгерим Н.',
      serviceName: 'Макияж и укладка',
      branchName: 'Центральный',
      staffName: 'Анна К.',
      status: 'new',
      note: '',
      clientPhone: '+7 (700) 123-45-67',
    ),
    Booking(
      id: 102,
      startsAt: DateTime.now().add(const Duration(hours: 3)),
      clientName: 'Арман И.',
      serviceName: 'Мужская стрижка',
      branchName: 'Центральный',
      staffName: 'Анна К.',
      status: 'confirmed',
      note: '',
      clientPhone: '+7 (700) 234-56-78',
    ),
    Booking(
      id: 103,
      startsAt: DateTime.now().add(const Duration(hours: 5)),
      clientName: 'Динара М.',
      serviceName: 'Маникюр + покрытие',
      branchName: 'Западный',
      staffName: 'Мария П.',
      status: 'pending',
      note: 'Гель-лак',
      clientPhone: '+7 (700) 345-67-89',
    ),
  ];

  static final List<Booking> bookingsListDemo = [
    Booking(
      id: 201,
      startsAt: DateTime(2026, 5, 24, 10, 0),
      clientName: 'Ольга Смирнова',
      serviceName: 'Стрижка + укладка',
      branchName: 'Main Branch',
      staffName: 'Анна Петрова',
      status: 'confirmed',
      note:
          'Клиент попросил не использовать сильные ароматизаторы из-за аллергии. '
          'Предпочитает укладку без лака — только текстурирующее средство. '
          'При опоздании более 15 минут просила позвонить заранее.',
      clientPhone: '+7 (789) 654 32 10',
    ),
    Booking(
      id: 202,
      startsAt: DateTime(2026, 5, 24, 11, 30),
      clientName: 'Мария Иванова',
      serviceName: 'Маникюр',
      branchName: 'Центральный',
      staffName: 'Мария П.',
      status: 'pending',
      note: '',
      clientPhone: '+7 (700) 555-12-34',
    ),
    Booking(
      id: 203,
      startsAt: DateTime(2026, 5, 24, 12, 0),
      clientName: 'Ольга Макова',
      serviceName: 'Стрижка + укладка',
      branchName: 'Центральный',
      staffName: 'Анна К.',
      status: 'confirmed',
      note: '',
      clientPhone: '+7 (700) 555-99-00',
    ),
    Booking(
      id: 204,
      startsAt: DateTime(2026, 5, 25, 14, 0),
      clientName: 'Елена В.',
      serviceName: 'Окрашивание',
      branchName: 'Западный',
      staffName: 'Мария П.',
      status: 'confirmed',
      note: '',
      clientPhone: '+7 (700) 444-77-88',
    ),
  ];

  static final List<Branch> branches = [
    const Branch(
      id: 1,
      name: 'Центральный',
      address: 'ул. Абая, 150',
      phone: '+7 700 000-00-01',
      isActive: true,
    ),
    const Branch(
      id: 2,
      name: 'Западный',
      address: 'пр. Достык, 89',
      phone: '+7 700 000-00-02',
      isActive: true,
    ),
    const Branch(
      id: 3,
      name: 'Склад',
      address: 'ул. Промышленная, 4',
      phone: '',
      isActive: false,
    ),
  ];

  static final List<SalonService> services = [
    const SalonService(
      id: 1,
      name: 'Женская стрижка',
      description: 'Стрижка и укладка',
      price: 8000,
      durationMinutes: 60,
      isActive: true,
    ),
    const SalonService(
      id: 2,
      name: 'Маникюр',
      description: 'Классический или аппаратный',
      price: 6000,
      durationMinutes: 90,
      isActive: true,
    ),
    const SalonService(
      id: 3,
      name: 'Макияж дневной',
      description: '',
      price: 12000,
      durationMinutes: 75,
      isActive: true,
    ),
    const SalonService(
      id: 4,
      name: 'Мужская стрижка',
      description: '',
      price: 5000,
      durationMinutes: 45,
      isActive: true,
    ),
  ];

  static final List<StaffMember> staff = [
    StaffMember(
      id: 1,
      name: 'Анна Ковалёва',
      phone: '+7 700 111-22-33',
      email: 'anna@example.com',
      role: UserRole.unknown,
      apiRole: 'STAFF',
      branchId: 1,
      branchName: 'Центральный',
      isActive: true,
    ),
    StaffMember(
      id: 2,
      name: 'Мария Петрова',
      phone: '+7 700 222-33-44',
      email: 'maria@example.com',
      role: UserRole.unknown,
      apiRole: 'STAFF',
      branchId: 1,
      branchName: 'Центральный',
      isActive: true,
    ),
    StaffMember(
      id: 3,
      name: 'Алия Нурланова',
      phone: '+7 700 333-44-55',
      email: '',
      role: UserRole.manager,
      apiRole: 'MANAGER',
      branchId: 2,
      branchName: 'Западный',
      isActive: true,
    ),
  ];

  static List<Booking> get allBookings => [
        ...todayBookings,
        ...bookingsListDemo,
      ];

  static Booking? bookingById(int id) {
    for (final b in allBookings) {
      if (b.id == id) return b;
    }
    return null;
  }

  static Branch? branchById(int id) {
    for (final b in branches) {
      if (b.id == id) return b;
    }
    return null;
  }

  static SalonService? serviceById(int id) {
    for (final s in services) {
      if (s.id == id) return s;
    }
    return null;
  }

  static StaffMember? staffById(int id) {
    for (final s in staff) {
      if (s.id == id) return s;
    }
    return null;
  }
}
