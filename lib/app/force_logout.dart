import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Увеличивается при глобальном сбросе сессии (401). Слушатель вызывает [AuthNotifier.markLoggedOut].
final forceLogoutTickProvider = StateProvider<int>((ref) => 0);
