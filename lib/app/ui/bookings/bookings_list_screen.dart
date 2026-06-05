import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../auth_notifier.dart';
import '../../catalog_providers.dart';
import '../../data_providers.dart';
import '../widgets/components/app_bar_add_button.dart';
import '../../navigation/app_navigation.dart';
import '../../domain/model/booking.dart';
import '../../domain/model/booking_stats.dart';
import '../widgets/components/app_ui_tokens.dart';
import '../widgets/cards/booking_card.dart';
import '../widgets/lists/search_field.dart';

class BookingsListScreen extends ConsumerStatefulWidget {
  const BookingsListScreen({super.key});

  @override
  ConsumerState<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends ConsumerState<BookingsListScreen> {
  int _activeTab = 0;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const _tabDefs = [
    _BookingTab(label: 'Все', status: null, statsKey: _StatsKey.total),
    _BookingTab(label: 'Новые', status: 'NEW', statsKey: _StatsKey.newCount),
    _BookingTab(
      label: 'Подтвержденные',
      status: 'CONFIRMED',
      statsKey: _StatsKey.confirmed,
    ),
    _BookingTab(
      label: 'Завершенные',
      status: 'COMPLETED',
      statsKey: _StatsKey.completed,
    ),
  ];

  String? get _statusFilter => _tabDefs[_activeTab].status;

  BookingsQuery get _query => BookingsQuery(
        status: _statusFilter,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        final q = _searchController.text.trim();
        if (q != _searchQuery) setState(() => _searchQuery = q);
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _tabTitle(_BookingTab tab, BookingStats? stats) {
    if (stats == null) return tab.label;
    final count = switch (tab.statsKey) {
      _StatsKey.total => stats.total,
      _StatsKey.newCount => stats.newCount,
      _StatsKey.confirmed => stats.confirmed,
      _StatsKey.completed => stats.completed,
    };
    return '${tab.label} ($count)';
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(bookingsListProvider(_query));
    final statsAsync = ref.watch(bookingsStatsProvider);
    final isManager =
        ref.watch(authNotifierProvider).valueOrNull?.isManagerUser ?? false;
    final stats = statsAsync.valueOrNull;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        centerTitle: false,
        title: const Text(
          'Записи',
          style: TextStyle(
            color: AppUiTokens.primaryText,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Расписание',
            onPressed: () => openBookingsSchedule(context),
            icon: const Icon(Icons.calendar_month_outlined),
            color: AppUiTokens.primaryText,
          ),
          if (isManager)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AppBarAddButton(
                onPressed: () => openNewBooking(context),
              ),
            )
          else
            const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: SearchField(
              controller: _searchController,
              hintText: 'Поиск по клиенту...',
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _tabDefs.length,
              itemBuilder: (context, index) {
                final tab = _tabDefs[index];
                final isSelected = _activeTab == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setState(() => _activeTab = index),
                      borderRadius: BorderRadius.circular(8),
                      child: Ink(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected
                                  ? const Color(0xFFFFCC00)
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            _tabTitle(tab, stats),
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFFC6A400)
                                  : AppUiTokens.secondaryText,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppUiTokens.borderSubtle),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(bookingsListProvider);
                ref.invalidate(bookingsStatsProvider);
                await Future.wait([
                  ref.read(bookingsListProvider(_query).future),
                  ref.read(bookingsStatsProvider.future),
                ]);
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
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Не удалось загрузить записи.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                data: (bookings) {
                  if (bookings.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(child: Text('Записей пока нет')),
                      ],
                    );
                  }
                  final grouped = _groupByDay(bookings);
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    children: [
                      for (final entry in grouped.entries) ...[
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppUiTokens.primaryText,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...entry.value.map(
                          (data) => BookingCard(
                            booking: data,
                            onTap: () => openBookingDetail(context, data.id),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<Booking>> _groupByDay(List<Booking> bookings) {
    final sorted = [...bookings]
      ..sort((a, b) {
        final at = a.startsAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bt = b.startsAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return at.compareTo(bt);
      });
    final map = <String, List<Booking>>{};
    for (final b in sorted) {
      final label = _dayLabel(b.startsAt);
      map.putIfAbsent(label, () => []).add(b);
    }
    return map;
  }

  String _dayLabel(DateTime? dt) {
    if (dt == null) return 'Без даты';
    final local = dt.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    if (day == today) {
      return 'Сегодня, ${DateFormat('d MMMM', 'ru').format(local)}';
    }
    if (day == today.add(const Duration(days: 1))) {
      return 'Завтра, ${DateFormat('d MMMM', 'ru').format(local)}';
    }
    return DateFormat('d MMMM', 'ru').format(local);
  }
}

enum _StatsKey { total, newCount, confirmed, completed }

class _BookingTab {
  const _BookingTab({
    required this.label,
    required this.status,
    required this.statsKey,
  });

  final String label;
  final String? status;
  final _StatsKey statsKey;
}
