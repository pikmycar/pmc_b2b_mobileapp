import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/theme_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final ThemeService _themeService;

  ThemeCubit(this._themeService) : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final mode = await _themeService.getThemeMode();
    emit(mode);
  }

  Future<void> updateTheme(ThemeMode mode) async {
    await _themeService.setThemeMode(mode);
    emit(mode);
  }
}
