import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/repository/mock_business_data.dart';
import '../../domain/model/booking.dart';
import '../widgets/components/app_ui_tokens.dart';
import '../widgets/cards/booking_card.dart';
import '../widgets/components/bordered_toolbar_icon.dart';

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});

  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen> {
  int _activeTab = 0;
  final List<String> _tabs = ['Все', 'Новые', 'Подтвержденные', 'Завершенные'];

  List<Booking> get _mockBookings => MockBusinessData.bookingsListDemo;

  @override
  Widget build(BuildContext context) {
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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: BorderedToolbarIcon(
              onPressed: () {},
              child: const Icon(Icons.search, color: AppUiTokens.primaryText),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
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
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          const Text(
            'Сегодня, 24 мая',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppUiTokens.primaryText,
            ),
          ),
          const SizedBox(height: 20),
          ..._mockBookings.map(
            (data) => BookingCard(
              booking: data,
              onTap: () => context.push('/bookings/${data.id}'),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Завтра, 25 мая',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppUiTokens.primaryText,
            ),
          ),
          const SizedBox(height: 20),
          BookingCard(
            booking: MockBusinessData.bookingsListDemo[3],
            onTap: () => context.push(
              '/bookings/${MockBusinessData.bookingsListDemo[3].id}',
            ),
          ),
        ],
      ),
    );
  }
}
