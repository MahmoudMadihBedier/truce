import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Locale locale;

  SettingsState({required this.themeMode, required this.locale});
}

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;

  SettingsCubit(this._prefs) : super(SettingsState(
    themeMode: ThemeMode.values[_prefs.getInt('themeMode') ?? 0],
    locale: Locale(_prefs.getString('languageCode') ?? 'en'),
  ));

  void toggleTheme() {
    final newMode = state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _prefs.setInt('themeMode', newMode.index);
    emit(SettingsState(themeMode: newMode, locale: state.locale));
  }

  void setLocale(String languageCode) {
    _prefs.setString('languageCode', languageCode);
    emit(SettingsState(themeMode: state.themeMode, locale: Locale(languageCode)));
  }
}
