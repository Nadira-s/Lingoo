import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'domain/model/user_profile.dart';
import 'di/app_providers.dart';

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, UserProfile?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    try {
      return await ref
          .read(authRepositoryProvider)
          .restoreSession()
          .timeout(const Duration(seconds: 20));
    } on TimeoutException {
      return null;
    }
  }

  Future<void> login(String username, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return ref.read(authRepositoryProvider).login(username, password);
    });
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }

  void markLoggedOut() {
    state = const AsyncData(null);
  }
}
