import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:kanji_dictionary/models/kanji_list.dart';

const favKanjiStrsKey = 'favKanjiStrs';
const starKanjiStrsKey = 'starKanjiStrs';
const kanjiListStrKey = 'kanjiListStr';

class SharedPreferencesProvider {
  SharedPreferences _sharedPreferences;

  SharedPreferencesProvider() {
    initSharedPrefs();
  }

  Future initSharedPrefs() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    if (!_sharedPreferences.containsKey(favKanjiStrsKey)) {
      _sharedPreferences.setStringList(favKanjiStrsKey, []);
      _sharedPreferences.setStringList(starKanjiStrsKey, ['字']);
    }
  }

  List<String> getAllFavKanjiStrs() => _sharedPreferences.getStringList(favKanjiStrsKey);

  void addFav(String kanjiStr) {
    var favKanjiStrs = _sharedPreferences.getStringList(favKanjiStrsKey);
    favKanjiStrs.add(kanjiStr);
    _sharedPreferences.setStringList(favKanjiStrsKey, favKanjiStrs);
  }

  void removeFav(String kanjiStr) {
    var favKanjiStrs = _sharedPreferences.getStringList(favKanjiStrsKey);
    favKanjiStrs.remove(kanjiStr);
  }

  List<String> getAllStarKanjiStrs() => _sharedPreferences.getStringList(starKanjiStrsKey);

  void addStar(String kanjiStr) {
    var starKanjiStrs = _sharedPreferences.getStringList(starKanjiStrsKey);
    starKanjiStrs.add(kanjiStr);
    _sharedPreferences.setStringList(favKanjiStrsKey, starKanjiStrs);
  }

  void removeStar(String kanjiStr) {
    var starKanjiStrs = _sharedPreferences.getStringList(starKanjiStrsKey);
    starKanjiStrs.remove(kanjiStr);
  }

  List<KanjiList> getAllKanjiLists() => kanjiListsFromJsonStr(_sharedPreferences.getString(kanjiListStrKey));

  void updateKanjiLists(List<KanjiList> kanjiLists) => _sharedPreferences.setString(kanjiListStrKey, kanjiListsToJsonStr(kanjiLists));
}
