import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;

import '../auth_notifier.dart';
import '../force_logout.dart';
import '../ui/auth/login_screen.dart';
import '../ui/bookings/booking_detail_screen.dart';
import '../ui/bookings/bookings_list_screen.dart';
import '../ui/bookings/bookings_schedule_screen.dart';
import '../ui/bookings/booking_form_screen.dart';
import '../ui/branches/branch_form_screen.dart';
import '../ui/branches/branches_list_screen.dart';
import '../ui/dashboard/dashboard_screen.dart';
import '../ui/notifications/notifications_screen.dart';
import '../ui/profile/access_management_screen.dart';
import '../ui/profile/business_settings_screen.dart';
import '../ui/profile/profile_form_screen.dart';
import '../ui/profile/profile_screen.dart';
import '../ui/profile/tariff_limits_screen.dart';
import '../ui/services/service_form_screen.dart';
import '../ui/services/services_list_screen.dart';
import 'main_shell.dart';
import '../ui/staff/staff_form_screen.dart';
import '../ui/staff/staff_list_screen.dart';
import '../ui/staff/staff_schedule_screen.dart';

final _routerRefresh = ValueNotifier<int>(0);
final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  developer.log('🔄 goRouterProvider initializing...');
  ref.listen(authNotifierProvider, (previous, next) => _routerRefresh.value++);
  ref.listen(
      forceLogoutTickProvider, (previous, next) => _routerRefresh.value++);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: _routerRefresh,
    redirect: (context, state) {
      final auth = ref.read(authNotifierProvider);
      final loc = state.matchedLocation;
      developer.log(
          '🧭 Router redirect: location=$loc, auth=${auth.isLoading ? "loading" : (auth.hasValue ? "has_user" : "no_user")}');

      if (auth.isLoading) {
        if (loc == '/login') return null;
        if (loc != '/splash') return '/splash';
        return null;
      }

      final user = auth.valueOrNull;

      if (user == null) {
        if (loc != '/login' && loc != '/splash') return '/login';
        if (loc == '/splash') return '/login';
        return null;
      }

      if (loc == '/splash' || loc == '/login') return '/home';

      if (user.isManagerUser) {
        if (loc.startsWith('/branches')) return '/home';
        if (loc.startsWith('/services/new') ||
            RegExp(r'^/services/\d+/edit').hasMatch(loc)) {
          return '/services';
        }
        if (loc.startsWith('/staff/new') ||
            RegExp(r'^/staff/\d+/edit').hasMatch(loc)) {
          return '/staff';
        }
        final scheduleMatch =
            RegExp(r'^/staff/(\d+)/schedule').firstMatch(loc);
        if (scheduleMatch != null) {
          final id = int.tryParse(scheduleMatch.group(1) ?? '') ?? 0;
          final ownId = user.staffProfile?.id;
          if (ownId != null && ownId > 0 && id != ownId) return '/staff';
        }
        if (loc.startsWith('/profile/access') ||
            loc.startsWith('/profile/business') ||
            loc.startsWith('/profile/tariff')) {
          return '/profile';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/bookings',
            builder: (context, state) => const BookingsListScreen(),
          ),
          GoRoute(
            path: '/branches',
            builder: (context, state) => const BranchesListScreen(),
          ),
          GoRoute(
            path: '/services',
            builder: (context, state) => const ServicesListScreen(),
          ),
          GoRoute(
            path: '/staff',
            builder: (context, state) => const StaffListScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      // Записи вне ShellRoute (чтобы /bookings/new не попадал в :id)
      GoRoute(
        path: '/bookings/schedule',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const BookingsScheduleScreen(),
      ),
      GoRoute(
        path: '/bookings/new',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const BookingFormScreen(),
      ),
      GoRoute(
        path: '/bookings/:id',
        parentNavigatorKey: rootNavigatorKey,
        redirect: (context, state) {
          final raw = state.pathParameters['id'] ?? '';
          if (raw == 'new') return '/bookings/new';
          if (raw == 'schedule') return '/bookings/schedule';
          if (int.tryParse(raw) == null) return '/bookings';
          return null;
        },
        builder: (context, state) {
          final rawId = state.pathParameters['id'];
          final id = int.tryParse(rawId ?? '') ?? 0;
          developer.log(
            '🧭 Route match: /bookings/:id. rawId: $rawId, parsed id: $id',
          );
          return BookingDetailScreen(bookingId: id);
        },
      ),
      // Формы без нижней навигации (вне ShellRoute)
      GoRoute(
        path: '/branches/new',
        builder: (context, state) => BranchFormScreen(),
      ),
      GoRoute(
        path: '/branches/:id/edit',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return BranchFormScreen(branchId: id);
        },
      ),
      GoRoute(
        path: '/services/new',
        builder: (context, state) => const ServiceFormScreen(),
      ),
      GoRoute(
        path: '/services/:id/edit',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ServiceFormScreen(serviceId: id);
        },
      ),
      GoRoute(
        path: '/staff/new',
        builder: (context, state) => const StaffFormScreen(),
      ),
      GoRoute(
        path: '/staff/:id/edit',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return StaffFormScreen(staffId: id);
        },
      ),
      GoRoute(
        path: '/staff/:id/schedule',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return StaffScheduleScreen(staffId: id);
        },
      ),
      GoRoute(
        path: '/profile/access',
        builder: (context, state) => const AccessManagementScreen(),
      ),
      GoRoute(
        path: '/profile/form',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ProfileFormScreen(),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/profile/business',
        builder: (context, state) => const BusinessSettingsScreen(),
      ),
      GoRoute(
        path: '/profile/tariff',
        builder: (context, state) => const TariffLimitsScreen(),
      ),
    ],
  );
});

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
