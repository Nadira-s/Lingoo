import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:developer' as developer;

import 'app/business_app.dart';

void main() async {
  developer.log('🚀 main() started');
  WidgetsFlutterBinding.ensureInitialized();
  developer.log('✅ WidgetsFlutterBinding initialized');
  
  await initializeDateFormatting('ru', null);
  developer.log('✅ Locale formatting initialized');
  
  runApp(const ProviderScope(child: BusinessApp()));
  developer.log('✅ App started');
}
