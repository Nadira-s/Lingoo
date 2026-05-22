import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

import 'auth_notifier.dart';
import 'force_logout.dart';
import 'navigation/app_router.dart';
import 'ui/widgets/components/app_ui_tokens.dart';

class BusinessApp extends ConsumerWidget {
  const BusinessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    developer.log('🏗️ BusinessApp.build() started');

    ref.listen<int>(forceLogoutTickProvider, (prev, next) {
      if (prev != null && prev != next) {
        ref.read(authNotifierProvider.notifier).markLoggedOut();
      }
    });

    developer.log('🌐 Watching goRouterProvider...');
    final router = ref.watch(goRouterProvider);
    developer.log('✅ Router initialized');

    return MaterialApp.router(
      title: 'Управление записями',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFCC00),
          primary: const Color(0xFFFFCC00),
          secondary: const Color(0xFF1A1C1E),
          surface: Colors.white,
          error: const Color(0xFFE53935),
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: AppUiTokens.primaryText,
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
          titleLarge: TextStyle(
            color: AppUiTokens.primaryText,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
          titleMedium: TextStyle(
            color: AppUiTokens.primaryText,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
          bodyLarge: TextStyle(
            color: AppUiTokens.primaryText,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: TextStyle(
            color: AppUiTokens.secondaryText,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          bodySmall: TextStyle(
            color: AppUiTokens.tertiaryText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          labelLarge: TextStyle(
            color: AppUiTokens.primaryText,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.06),
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppUiTokens.radiusLg),
            side: const BorderSide(color: AppUiTokens.borderSubtle, width: 1),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppUiTokens.surfaceMuted,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppUiTokens.borderSubtle),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppUiTokens.borderSubtle),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFFCC00), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE53935), width: 1),
          ),
          hintStyle: const TextStyle(
            color: AppUiTokens.tertiaryText,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFFCC00),
            foregroundColor: AppUiTokens.primaryText,
            elevation: 0,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size.fromHeight(56),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: Colors.transparent,
          indicatorShape: const RoundedRectangleBorder(),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected
                  ? const Color(0xFFC6A400)
                  : AppUiTokens.secondaryText,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return IconThemeData(
              size: 26,
              color: isSelected
                  ? const Color(0xFFC6A400)
                  : AppUiTokens.secondaryText,
            );
          }),
        ),
      ),
      routerConfig: router,
    );
  }
}
