import 'package:shared_preferences/shared_preferences.dart';

import 'package:kanji_dictionary/models/kanji_list.dart';

const favKanjiStrsKey = 'favKanjiStrs';
const starKanjiStrsKey = 'starKanjiStrs';
const kanjiListStrKey = 'kanjiListStr';
const uidsKey = 'uids';
const lastFetchedAtKey = 'lastFetchedAt';

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
    if (!_sharedPreferences.containsKey(favKanjiStrsKey)) {
      _sharedPreferences.setStringList(favKanjiStrsKey, []);
      _sharedPreferences.setStringList(starKanjiStrsKey, ['字']);
      var list = KanjiList(name: "My list", kanjiStrs: ["一", "二", "三"]);
      addKanjiList(list);
    }
  }

  List<String> getAllFavKanjiStrs() => _sharedPreferences.getStringList(favKanjiStrsKey);

  List<String> uids = [];

  void addFav(String kanjiStr) {
    var favKanjiStrs = _sharedPreferences.getStringList(favKanjiStrsKey);
    favKanjiStrs.add(kanjiStr);
    _sharedPreferences.setStringList(favKanjiStrsKey, favKanjiStrs);
  }

  void removeFav(String kanjiStr) {
    var favKanjiStrs = _sharedPreferences.getStringList(favKanjiStrsKey);
    favKanjiStrs.remove(kanjiStr);
    _sharedPreferences.setStringList(favKanjiStrsKey, favKanjiStrs);
  }

  List<String> getAllStarKanjiStrs() => _sharedPreferences.getStringList(starKanjiStrsKey);

  void addStar(String kanjiStr) {
    var starKanjiStrs = _sharedPreferences.getStringList(starKanjiStrsKey);
    starKanjiStrs.add(kanjiStr);
    _sharedPreferences.setStringList(starKanjiStrsKey, starKanjiStrs);
  }

  void removeStar(String kanjiStr) {
    var starKanjiStrs = _sharedPreferences.getStringList(starKanjiStrsKey);
    starKanjiStrs.remove(kanjiStr);
    _sharedPreferences.setStringList(starKanjiStrsKey, starKanjiStrs);
  }

  List<KanjiList> getAllKanjiLists() {
    uids = _sharedPreferences.getStringList(uidsKey) ?? [];
    var kanjiLists = <KanjiList>[];
    for (var uid in uids) {
      kanjiLists.add(getKanjiListByUid(uid));
    }
    return kanjiLists;
  }

  void addKanjiList(KanjiList kanjiList) {
    uids.add(kanjiList.uid);
    _sharedPreferences.setStringList(uidsKey, uids);
    _sharedPreferences.setStringList(kanjiList.uid + 'kanjis', kanjiList.kanjiStrs);
    _sharedPreferences.setString(kanjiList.uid + 'name', kanjiList.name);
  }

  void updateKanjiListKanjis(KanjiList kanjiList) {
    _sharedPreferences.setStringList(kanjiList.uid + 'kanjis', kanjiList.kanjiStrs);
  }

  void updateKanjiListName(KanjiList kanjiList) {
    _sharedPreferences.setString(kanjiList.uid + 'name', kanjiList.name);
  }

  void deleteKanjiList(KanjiList kanjiList) {
    uids.remove(kanjiList.uid);
    _sharedPreferences.setStringList(uidsKey, uids);
    _sharedPreferences.remove(kanjiList.uid + 'kanjis');
    _sharedPreferences.remove(kanjiList.uid + 'name');
  }

  KanjiList getKanjiListByUid(String uid) {
    var kanjiStrs = _sharedPreferences.getStringList(uid + 'kanjis');
    var name = _sharedPreferences.getString(uid + 'name');
    var list = KanjiList.from(uid: uid, name: name, kanjiStrs: kanjiStrs);
    return list;
  }

  bool getIsFirstTimeUser() {
    var res = !_sharedPreferences.containsKey('mark');
    _sharedPreferences.setBool('mark', true);
    return res;
  }

  int get lastFetchedAt => _sharedPreferences.getInt(lastFetchedAtKey);

  set lastFetchedAt(int timestamp) => _sharedPreferences.setInt(lastFetchedAtKey, timestamp);

  //List<KanjiList> getAllKanjiLists() => kanjiListsFromJsonStr(_sharedPreferences.getString(kanjiListStrKey));

  //void updateKanjiLists(List<KanjiList> kanjiLists) => _sharedPreferences.setString(kanjiListStrKey, kanjiListsToJsonStr(kanjiLists));
}
