import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth_notifier.dart';

class MainShell extends ConsumerWidget {
  const MainShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = GoRouterState.of(context).uri.path;
    final isManager =
        ref.watch(authNotifierProvider).valueOrNull?.role.isManager ?? false;

    int indexFromPath() {
      if (loc.startsWith('/home')) return 0;
      if (loc.startsWith('/bookings')) return 1;
      if (loc.startsWith('/services')) return 2;
      if (loc.startsWith('/staff')) return 3;
      if (loc.startsWith('/profile')) return isManager ? 2 : 4;
      return 0;
    }

    if (isManager) {
      return Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          height: 68,
          selectedIndex: indexFromPath().clamp(0, 2),
          onDestinationSelected: (i) {
            switch (i) {
              case 0:
                context.go('/home');
                break;
              case 1:
                context.go('/bookings');
                break;
              case 2:
                context.go('/profile');
                break;
            }
          },
          destinations: const [
            NavigationDestination(
              icon: ImageIcon(AssetImage('assets/icons/home_icon.png')),
              label: 'Главная',
            ),
            NavigationDestination(
              icon: ImageIcon(AssetImage('assets/icons/booking_icon.png')),
              label: 'Записи',
            ),
            NavigationDestination(
              icon: ImageIcon(AssetImage('assets/icons/profile_icon.png')),
              label: 'Профиль',
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        height: 68,
        selectedIndex: indexFromPath().clamp(0, 4),
        onDestinationSelected: (i) {
          switch (i) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/bookings');
              break;
            case 2:
              context.go('/services');
              break;
            case 3:
              context.go('/staff');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: ImageIcon(AssetImage('assets/icons/home_icon.png')),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: ImageIcon(AssetImage('assets/icons/booking_icon.png')),
            label: 'Записи',
          ),
          NavigationDestination(
            icon: ImageIcon(AssetImage('assets/icons/services_icon.png')),
            label: 'Услуги',
          ),
          NavigationDestination(
            icon: ImageIcon(AssetImage('assets/icons/staff_icon.png')),
            label: 'Сотрудники',
          ),
          NavigationDestination(
            icon: ImageIcon(AssetImage('assets/icons/profile_icon.png')),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
