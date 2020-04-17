import 'package:kanji_dictionary/models/sentence.dart';
import 'package:kanji_dictionary/models/word.dart';
import 'package:kanji_dictionary/models/kanji.dart';
import 'package:kanji_dictionary/models/kana.dart';
import 'package:kanji_dictionary/models/kanji_list.dart';
import 'package:kanji_dictionary/models/question.dart';
import 'jisho_api_provider.dart';
import 'db_provider.dart';
import 'firebase_api_provider.dart';
import 'shared_preferences_provider.dart';

export 'package:kanji_dictionary/models/kana.dart';
export 'package:kanji_dictionary/models/kanji.dart';
export 'package:kanji_dictionary/models/kanji_list.dart';
export 'package:kanji_dictionary/models/sentence.dart';
export 'package:kanji_dictionary/models/word.dart';
export 'package:kanji_dictionary/models/question.dart';

class Repository {
  final _jishoApiProvider = JishoApiProvider();
  final _firebaseApiProvider = FirebaseApiProvider();
  final _prefsProvider = SharedPreferencesProvider();

  Stream<Sentence> fetchSentencesByKanji(String kanji) => _jishoApiProvider.fetchSentencesByKanji(kanji);

  Stream<Word> fetchWordsByKanji(String kanji) => _jishoApiProvider.fetchWordsByKanji(kanji);

  Stream<Kanji> fetchKanjisByJLPTLevel(JLPTLevel jlptLevel) => _jishoApiProvider.fetchKanjisByJLPTLevel(jlptLevel);

  Future<List<Kanji>> getAllKanjisFromDB() => DBProvider.db.getAllKanjis();

  Future<List<Sentence>> getSentencesByKanji(String kanjiStr) async => DBProvider.db.getSentencesByKanji(kanjiStr);

  Stream<Sentence> getSentencesByKanjiStream(String kanjiStr) => DBProvider.db.getSentencesByKanjiStream(kanjiStr);

  Future<String> getSentencesJsonStringByKanji(String kanjiStr) => DBProvider.db.getSentencesJsonStringByKanji(kanjiStr);

  Future checkForUpdate(Map<String, Kanji> allLocalKanjis) => _firebaseApiProvider.checkForUpdate(allLocalKanjis);

  void updateKanji(Kanji kanji, [bool isDeleted = false]) {
    DBProvider.db.updateKanji(kanji);

    //If user did not delete from but added a new word to database, upload to firebase
    if (!isDeleted) {
      _firebaseApiProvider.uploadUserModifiedKanji(kanji);
    }
  }

  Future updateKanjiToFirestore(Kanji kanji) => _firebaseApiProvider.uploadUserModifiedKanji(kanji);

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

  void updateKanjiLists(List<KanjiList> kanjiLists) => _prefsProvider.updateKanjiLists(kanjiLists);

  Future<List<Question>> getIncorrectQuestions() => DBProvider.db.getIncorrectQuestions();

  Future addIncorrectQuestions(List<Question> qs) => DBProvider.db.addIncorrectQuestions(qs);

  Future deleteIncorrectQuestion(Question q) => DBProvider.db.deleteIncorrectQuestion(q);
}

final repo = Repository();

