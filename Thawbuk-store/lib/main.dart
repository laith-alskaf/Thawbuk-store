import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer';
import 'presentation/app_with_smart_initialization.dart';

void main() async {
  // التأكد من تهيئة Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // تكوين الشاشة
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // إعداد نمط شريط الحالة
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  log('🚀 Starting Thawbuk Store App...');

  // تشغيل التطبيق مع التهيئة الذكية
  runApp(const ThawbukStoreApp());
}

/// التطبيق الرئيسي لثوبك
class ThawbukStoreApp extends StatelessWidget {
  const ThawbukStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ثوبك - Thawbuk Store',
      debugShowCheckedModeBanner: false,
      
      // إعدادات اللغة والمنطقة
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [
        Locale('ar', 'SA'), // العربية
        Locale('en', 'US'), // الإنجليزية
      ],
      
      // إعدادات النصوص
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox(),
        );
      },
      
      // التطبيق مع التهيئة الذكية
      home: const AppWithSmartInitialization(),
    );
  }
}