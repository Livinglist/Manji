import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/font_selection.dart';
import '../models/kanji_list.dart';
import 'constants.dart';

class SharedPreferencesProvider {
  static SharedPreferences _sharedPreferences;

  SharedPreferencesProvider._() {
    if (_sharedPreferences == null) initSharedPrefs();
  }

  static final instance = SharedPreferencesProvider._();

  SharedPreferencesProvider() {
    initSharedPrefs();
  }

  Future initSharedPrefs() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    if (!_sharedPreferences.containsKey(Keys.favKanjiStrsKey)) {
      _sharedPreferences.setStringList(Keys.favKanjiStrsKey, []);
      _sharedPreferences.setStringList(Keys.starKanjiStrsKey, ['字']);
      final list = KanjiList(name: "My list", kanjiStrs: ["一", "二", "三"]);
      addKanjiList(list);
    }
  }

  List<String> getAllFavKanjiStrs() =>
      _sharedPreferences.getStringList(Keys.favKanjiStrsKey);

  List<String> uids = [];

  void addFav(String kanjiStr) {
    final favKanjiStrs = _sharedPreferences.getStringList(Keys.favKanjiStrsKey);
    favKanjiStrs.add(kanjiStr);
    _sharedPreferences.setStringList(Keys.favKanjiStrsKey, favKanjiStrs);
  }

  void removeFav(String kanjiStr) {
    final favKanjiStrs = _sharedPreferences.getStringList(Keys.favKanjiStrsKey);
    favKanjiStrs.remove(kanjiStr);
    _sharedPreferences.setStringList(Keys.favKanjiStrsKey, favKanjiStrs);
  }

  List<String> getAllStarKanjiStrs() =>
      _sharedPreferences.getStringList(Keys.starKanjiStrsKey);

  void addStar(String kanjiStr) {
    final starKanjiStrs =
        _sharedPreferences.getStringList(Keys.starKanjiStrsKey);
    starKanjiStrs.add(kanjiStr);
    _sharedPreferences.setStringList(Keys.starKanjiStrsKey, starKanjiStrs);
  }

  void removeStar(String kanjiStr) {
    final starKanjiStrs =
        _sharedPreferences.getStringList(Keys.starKanjiStrsKey);
    starKanjiStrs.remove(kanjiStr);
    _sharedPreferences.setStringList(Keys.starKanjiStrsKey, starKanjiStrs);
  }

  List<KanjiList> getAllKanjiLists() {
    uids = _sharedPreferences.getStringList(Keys.uidsKey) ?? [];
    final kanjiLists = <KanjiList>[];
    for (var uid in uids) {
      kanjiLists.add(getKanjiListByUid(uid));
    }
    return kanjiLists;
  }

  void addKanjiList(KanjiList kanjiList) {
    uids.add(kanjiList.uid);
    _sharedPreferences.setStringList(Keys.uidsKey, uids);
    _sharedPreferences.setStringList(
        '${kanjiList.uid}kanjis', kanjiList.kanjiStrs);
    _sharedPreferences.setString('${kanjiList.uid}name', kanjiList.name);
  }

  void updateKanjiListKanjis(KanjiList kanjiList) {
    _sharedPreferences.setStringList(
        '${kanjiList.uid}kanjis', kanjiList.kanjiStrs);
  }

  void updateKanjiListName(KanjiList kanjiList) {
    _sharedPreferences.setString('${kanjiList.uid}name', kanjiList.name);
  }

  void deleteKanjiList(KanjiList kanjiList) {
    uids.remove(kanjiList.uid);
    _sharedPreferences.setStringList(Keys.uidsKey, uids);
    _sharedPreferences.remove('${kanjiList.uid}kanjis');
    _sharedPreferences.remove('${kanjiList.uid}name');
  }

  void setThemeMode(ThemeMode themeMode) {
    _sharedPreferences.setInt(Keys.themeModeKey, themeMode.index);
  }

  Future<ThemeMode> get themeMode =>
      SharedPreferences.getInstance().then((prefs) {
        final set = prefs.containsKey(Keys.themeModeKey);
        if (set) {
          final index = prefs.getInt(Keys.themeModeKey);
          return ThemeMode.values.elementAt(index);
        } else {
          prefs.setInt(Keys.themeModeKey, ThemeMode.system.index);
          return ThemeMode.system;
        }
      });

  void setFont(FontSelection fontSelection) {
    _sharedPreferences.setInt(Keys.fontKey, fontSelection.index);
  }

  Future<FontSelection> get fontSelection =>
      SharedPreferences.getInstance().then((prefs) {
        final set = prefs.containsKey(Keys.fontKey);
        if (set) {
          final index = prefs.getInt(Keys.fontKey);
          return FontSelection.values.elementAt(index);
        } else {
          prefs.setInt(Keys.fontKey, FontSelection.handwriting.index);
          return FontSelection.handwriting;
        }
      });

  KanjiList getKanjiListByUid(String uid) {
    final kanjiStrs = _sharedPreferences.getStringList('${uid}kanjis');
    final name = _sharedPreferences.getString('${uid}name');
    final list = KanjiList.from(uid: uid, name: name, kanjiStrs: kanjiStrs);
    return list;
  }

  bool getIsFirstTimeUser() {
    final res = !_sharedPreferences.containsKey('mark');
    if (!res) _sharedPreferences.setBool('mark', true);
    return res;
  }

  Future<bool> get isFirstTimeUser =>
      SharedPreferences.getInstance().then((prefs) {
        final res = !prefs.containsKey('mark');
        prefs.setBool('mark', true);
        return res;
      });

  int get lastFetchedAt => _sharedPreferences.getInt(Keys.lastFetchedAtKey);

  set lastFetchedAt(int timestamp) =>
      _sharedPreferences.setInt(Keys.lastFetchedAtKey, timestamp);
}
