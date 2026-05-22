import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer' as developer;

import 'app/business_app.dart';

void main() {
  developer.log('🚀 main() started');
  WidgetsFlutterBinding.ensureInitialized();
  developer.log('✅ WidgetsFlutterBinding initialized');
  runApp(const ProviderScope(child: BusinessApp()));
  developer.log('✅ App started');
}
