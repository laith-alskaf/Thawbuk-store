import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import '../../../core/theme/app_theme.dart';

// States
class ThemeState extends Equatable {
  final ThemeData themeData;
  final bool isDarkMode;

  const ThemeState({
    required this.themeData,
    required this.isDarkMode,
  });

  @override
  List<Object> get props => [themeData, isDarkMode];
}

// Cubit
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(
    themeData: AppTheme.lightTheme,
    isDarkMode: false,
  ));

  void toggleTheme() {
    if (state.isDarkMode) {
      emit(ThemeState(
        themeData: AppTheme.lightTheme,
        isDarkMode: false,
      ));
    } else {
      emit(ThemeState(
        themeData: AppTheme.darkTheme,
        isDarkMode: true,
      ));
    }
  }

  void setLightTheme() {
    emit(ThemeState(
      themeData: AppTheme.lightTheme,
      isDarkMode: false,
    ));
  }

  void setDarkTheme() {
    emit(ThemeState(
      themeData: AppTheme.darkTheme,
      isDarkMode: true,
    ));
  }
}