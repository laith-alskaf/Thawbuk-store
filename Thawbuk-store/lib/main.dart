import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/di/dependency_injection.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة Hive للتخزين المحلي
  await Hive.initFlutter();
  
  // تهيئة Dependency Injection
  await configureDependencies();
  
  runApp(const ThawbukApp());
}

class ThawbukApp extends StatelessWidget {
  const ThawbukApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}