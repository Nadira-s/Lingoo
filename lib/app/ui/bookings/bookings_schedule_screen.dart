import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../catalog_providers.dart';
import '../../auth_notifier.dart';
import '../../navigation/app_navigation.dart';
import '../../domain/model/booking.dart';
import '../widgets/cards/schedule_booking_row.dart';
import '../widgets/components/app_ui_tokens.dart';
import '../widgets/components/primary_button.dart';
import '../widgets/components/week_day_selector.dart';

/// Расписание записей по дням (макет «Расписание»).
class BookingsScheduleScreen extends ConsumerStatefulWidget {
  const BookingsScheduleScreen({super.key});

  @override
  ConsumerState<BookingsScheduleScreen> createState() =>
      _BookingsScheduleScreenState();
}

class _BookingsScheduleScreenState
    extends ConsumerState<BookingsScheduleScreen> {
  late List<WeekDayItem> _days;
  late int _selectedIndex;
  int? _selectedBookingId;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _days = WeekDayItem.weekAround(today);
    _selectedIndex = today.weekday - 1;
  }

  DateTime get _selectedDate => _days[_selectedIndex].date;

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(dayBookingsProvider(_selectedDate));
    final isManager =
        ref.watch(authNotifierProvider).valueOrNull?.isManagerUser ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppUiTokens.primaryText,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Расписание',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          WeekDaySelector(
            days: _days,
            selectedIndex: _selectedIndex,
            onSelected: (i) => setState(() {
              _selectedIndex = i;
              _selectedBookingId = null;
            }),
          ),
          const Divider(height: 1, color: AppUiTokens.borderSubtle),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(dayBookingsProvider(_selectedDate));
                await ref.read(dayBookingsProvider(_selectedDate).future);
              },
              child: bookingsAsync.when(
                loading: () => ListView(
                  children: const [
                    SizedBox(height: 120),
                    Center(child: CircularProgressIndicator()),
                  ],
                ),
                error: (e, _) => ListView(
                  children: [
                    const SizedBox(height: 80),
                    Center(child: Text('Ошибка: $e')),
                  ],
                ),
                data: (bookings) {
                  final sorted = _sortByTime(bookings);
                  if (sorted.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(child: Text('Записей на этот день нет')),
                      ],
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    children: [
                      for (final b in sorted)
                        ScheduleBookingRow(
                          booking: b,
                          selected: _selectedBookingId == b.id,
                          onTap: () {
                            setState(() => _selectedBookingId = b.id);
                            openBookingDetail(context, b.id);
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isManager
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: PrimaryButton(
                  label: '+ Создать',
                  onPressed: () => openNewBooking(context),
                ),
              ),
            )
          : null,
    );
  }

  List<Booking> _sortByTime(List<Booking> list) {
    final copy = [...list];
    copy.sort((a, b) {
      final at = a.startsAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bt = b.startsAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return at.compareTo(bt);
    });
    return copy;
  }
}
