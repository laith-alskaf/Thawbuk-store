import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:thawbuk_store/firebase_options.dart';
import 'core/di/dependency_injection.dart';
import 'presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة Hive للتخزين المحلي
  await Hive.initFlutter();
  // تهيئة Dependency Injection
  await configureDependencies();
    try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    (e);
  }
  
  runApp(const ThawbukApp());
}

class ThawbukApp extends StatelessWidget {
  const ThawbukApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}