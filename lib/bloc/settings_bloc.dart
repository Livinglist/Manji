import 'package:flutter/material.dart' show ThemeMode;
import 'package:rxdart/rxdart.dart';

import '../models/font_selection.dart';
import '../resource/shared_preferences_provider.dart';

export '../models/font_selection.dart';
export '../resource/constants.dart';

class SettingsBloc {
  final _themeModeFetcher = BehaviorSubject<ThemeMode>();
  final _fontFetcher = BehaviorSubject<FontSelection>();

  SettingsBloc._();

  static final instance = SettingsBloc._();

  Stream<ThemeMode> get themeMode => _themeModeFetcher.stream;

  Stream<FontSelection> get fontSelection => _fontFetcher.stream;

  FontSelection tempFontSelection = FontSelection.handwriting;

  void init() {
    SharedPreferencesProvider.instance.themeMode
        .then((val) => _themeModeFetcher.sink.add(val));
    SharedPreferencesProvider.instance.fontSelection.then((val) {
      tempFontSelection = val;
      _fontFetcher.sink.add(val);
    });
  }

  void setThemeMode(ThemeMode themeMode) {
    SharedPreferencesProvider.instance.setThemeMode(themeMode);
    _themeModeFetcher.sink.add(themeMode);
  }

  void setFont(FontSelection fontSelection) {
    SharedPreferencesProvider.instance.setFont(fontSelection);
    tempFontSelection = fontSelection;
    _fontFetcher.sink.add(fontSelection);
  }

  void dispose() {
    _themeModeFetcher.close();
    _fontFetcher.close();
  }
}
