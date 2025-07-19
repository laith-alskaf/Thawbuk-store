import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import '../../../core/theme/app_theme.dart';

// States
class ThemeState extends Equatable {
  final ThemeData themeData;
  final bool isDark;

  const ThemeState({
    required this.themeData,
    required this.isDark,
  });

  @override
  List<Object> get props => [themeData, isDark];
}

// Cubit
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(
    themeData: AppTheme.lightTheme,
    isDark: false,
  ));

  void toggleTheme() {
    if (state.isDark) {
      emit(ThemeState(
        themeData: AppTheme.lightTheme,
        isDark: false,
      ));
    } else {
      emit(ThemeState(
        themeData: AppTheme.darkTheme,
        isDark: true,
      ));
    }
  }

  void setLightTheme() {
    emit(ThemeState(
      themeData: AppTheme.lightTheme,
      isDark: false,
    ));
  }

  void setDarkTheme() {
    emit(ThemeState(
      themeData: AppTheme.darkTheme,
      isDark: true,
    ));
  }
}