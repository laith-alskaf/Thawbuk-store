import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/dependency_injection.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(AppTheme.lightTheme, false)) {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = getIt<SharedPreferences>();
    final isDark = prefs.getBool(AppConstants.themeKey) ?? false;
    emit(ThemeState(
      isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      isDark,
    ));
  }

  void toggleTheme() async {
    final prefs = getIt<SharedPreferences>();
    final isDark = !state.isDark;
    
    await prefs.setBool(AppConstants.themeKey, isDark);
    emit(ThemeState(
      isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      isDark,
    ));
  }
}

class ThemeState {
  final ThemeData themeData;
  final bool isDark;

  ThemeState(this.themeData, this.isDark);
}