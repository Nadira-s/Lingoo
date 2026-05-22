import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../catalog_providers.dart';
import '../../data_providers.dart';
import '../../domain/model/booking.dart';
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
  final List<String> _tabs = ['Все', 'Новые', 'Подтвержденные', 'Завершенные'];
  final _searchController = TextEditingController();
  String _searchQuery = '';

  String? get _statusFilter => switch (_activeTab) {
        1 => 'NEW',
        2 => 'CONFIRMED',
        3 => 'COMPLETED',
        _ => null,
      };

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

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(bookingsListProvider(_query));
    final statsAsync = ref.watch(bookingsStatsProvider);

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
          statsAsync.when(
            data: (s) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  _StatChip(label: 'Всего', value: s.total),
                  const SizedBox(width: 8),
                  _StatChip(label: 'Сегодня', value: s.today),
                  const SizedBox(width: 8),
                  _StatChip(label: 'Новые', value: s.newCount),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
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
                            _tabs[index],
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
                await ref.read(bookingsListProvider(_query).future);
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
                            onTap: () => context.push('/bookings/${data.id}'),
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

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppUiTokens.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppUiTokens.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
