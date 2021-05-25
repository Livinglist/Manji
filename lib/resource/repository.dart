import '../models/kana.dart';
import '../models/kanji.dart';
import '../models/kanji_list.dart';
import '../models/question.dart';
import '../models/sentence.dart';
import '../models/word.dart';
import 'db_provider.dart';
import 'firebase_api_provider.dart';
import 'firestore_provider.dart';
import 'jisho_api_provider.dart';
import 'shared_preferences_provider.dart';

export '../models/kana.dart';
export '../models/kanji.dart';
export '../models/kanji_list.dart';
export '../models/question.dart';
export '../models/sentence.dart';
export '../models/word.dart';

class Repository {
  final _jishoApiProvider = JishoApiProvider();
  final _firebaseApiProvider = FirebaseApiProvider();
  final _prefsProvider = SharedPreferencesProvider();

  Stream<Sentence> fetchSentencesByKanji(String kanji, {int currentPage = 0}) =>
      _jishoApiProvider.fetchSentencesByKanji(kanji, currentPage: currentPage);

  Stream<Word> fetchWordsByKanji(String kanji) =>
      _jishoApiProvider.fetchWordsByKanji(kanji);

  Stream<Kanji> fetchKanjisByJLPTLevel(JLPTLevel jlptLevel) =>
      _jishoApiProvider.fetchKanjisByJLPTLevel(jlptLevel);

  Future<List<Kanji>> getAllKanjisFromDB() => DBProvider.db.getAllKanjis();

  Future<String> getSentencesJsonStringByKanji(String kanjiStr) =>
      DBProvider.db.getSentencesJsonStringByKanji(kanjiStr);

  Future updateKanjiStudiedTimeStamps(Kanji kanji) =>
      DBProvider.db.updateKanjiStudiedTimeStamps(kanji);

  Future checkForUpdate(Map<String, Kanji> allLocalKanjis) =>
      _firebaseApiProvider.checkForUpdate(allLocalKanjis);

  void updateKanji(Kanji kanji, {bool isDeleted = false}) {
    DBProvider.db.updateKanji(kanji);

    //If user did not delete from but added a new word to database,
    // upload to firebase
    if (!isDeleted) {
      _firebaseApiProvider.uploadUserModifiedKanji(kanji);
    }
  }

  Future updateKanjiToFirestore(Kanji kanji) =>
      _firebaseApiProvider.uploadUserModifiedKanji(kanji);

  Future<bool> getIsUpdated() => _firebaseApiProvider.getIsUpdated();

  Future fetchUpdates() => _firebaseApiProvider.fetchUpdates();

  List<String> getAllFavKanjiStrs() => _prefsProvider.getAllFavKanjiStrs();

  void addFav(String kanjiStr) => _prefsProvider.addFav(kanjiStr);

  void removeFav(String kanjiStr) => _prefsProvider.removeFav(kanjiStr);

  List<String> getAllStarKanjiStrs() => _prefsProvider.getAllStarKanjiStrs();

  void addStar(String kanjiStr) => _prefsProvider.addStar(kanjiStr);

  void removeStar(String kanjiStr) => _prefsProvider.removeStar(kanjiStr);

  Future<List<Hiragana>> getAllHiragana() => DBProvider.db.getAllHiragana();

  Future<List<Katakana>> getAllKatakana() => DBProvider.db.getAllKatakana();

  List<KanjiList> getAllKanjiList() => _prefsProvider.getAllKanjiLists();

  void updateKanjiListName(KanjiList kanjiList) =>
      _prefsProvider.updateKanjiListName(kanjiList);

  void updateKanjiListKanjis(KanjiList kanjiList) =>
      _prefsProvider.updateKanjiListKanjis(kanjiList);

  void deleteKanjiList(KanjiList kanjiList) =>
      _prefsProvider.deleteKanjiList(kanjiList);

  void addKanjiList(KanjiList kanjiList) =>
      _prefsProvider.addKanjiList(kanjiList);

  bool getIsFirstTimeUser() => _prefsProvider.getIsFirstTimeUser();

  Future<List<Question>> getIncorrectQuestions() =>
      DBProvider.db.getIncorrectQuestions();

  Future addIncorrectQuestions(List<Question> qs) =>
      DBProvider.db.addIncorrectQuestions(qs);

  Future deleteIncorrectQuestion(Question q) =>
      DBProvider.db.deleteIncorrectQuestion(q);

  Future uploadFavKanjis(List<String> kanjis) =>
      FirestoreProvider.instance.uploadFavKanjis(kanjis);

  Future uploadMarkedKanjis(List<String> kanjis) =>
      FirestoreProvider.instance.uploadMarkedKanjis(kanjis);

  Future uploadKanjiList(KanjiList kanjiList) =>
      FirestoreProvider.instance.uploadKanjiList(kanjiList);

  Future deleteKanjiListFromFirebase(KanjiList kanjiList) =>
      FirestoreProvider.instance.deleteKanjiList(kanjiList);

  Future<List<String>> fetchFavKanjis() =>
      FirestoreProvider.instance.fetchFavKanjis();

  Future<List<String>> fetchMarkedKanjis() =>
      FirestoreProvider.instance.fetchMarkedKanjis();

  Stream<KanjiList> fetchKanjiLists() =>
      FirestoreProvider.instance.fetchKanjiLists();

  Future removeFavKanjiFromCloud(String kanji) =>
      FirestoreProvider.instance.removeFavKanji(kanji);

  Future removeMarkedKanjiFromCloud(String kanji) =>
      FirestoreProvider.instance.removeMarkedKanji(kanji);
}

final repo = Repository();
