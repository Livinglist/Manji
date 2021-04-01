import 'package:flutter/material.dart' show ThemeMode;
import 'package:rxdart/rxdart.dart';

import '../resource/shared_preferences_provider.dart';

class SettingsBloc {
  final _themeModeFetcher = BehaviorSubject<ThemeMode>();

  SettingsBloc._();

  static final instance = SettingsBloc._();

  Stream<ThemeMode> get themeMode => _themeModeFetcher.stream;

  void init() {
    SharedPreferencesProvider.instance.themeMode.then((val) => _themeModeFetcher.sink.add(val));
  }

  void setThemeMode(ThemeMode themeMode) {
    SharedPreferencesProvider.instance.setThemeMode(themeMode);
    _themeModeFetcher.sink.add(themeMode);
  }

  void dispose() {
    _themeModeFetcher.close();
  }
}
