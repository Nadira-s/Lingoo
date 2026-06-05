import 'package:business/app/business_app.dart';
import 'package:business/app/data/api/lingoo_api_client.dart';
import 'package:business/app/data/repositories/lingoo_repository_impl.dart';
import 'package:business/app/domain/model/booking.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BusinessApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(BusinessApp), findsOneWidget);
  });

  test('LingooRepositoryImpl create and get booking locally', () async {
    final client = LingooApiClient(Dio());
    final repo = LingooRepositoryImpl(client, null);
    final draft = Booking(
      id: 0,
      startsAt: DateTime.now(),
      clientName: 'Test Client',
      clientPhone: '+77777777777',
      branchId: 1,
      branchName: 'Branch 1',
      serviceId: 2,
      serviceName: 'Service 2',
      staffId: 3,
      staffName: 'Staff 3',
      status: 'NEW',
      note: 'Note',
    );
    
    final created = await repo.createBooking(draft);
    expect(created.id, -1001);
    
    final retrieved = await repo.getBooking(-1001);
    expect(retrieved.clientName, 'Test Client');
    expect(retrieved.id, -1001);
  });
}
