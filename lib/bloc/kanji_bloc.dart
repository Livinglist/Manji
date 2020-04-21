import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'dart:collection';

import 'package:rxdart/rxdart.dart';

import 'package:kanji_dictionary/models/kanji.dart';
import 'package:kanji_dictionary/models/sentence.dart';
import 'package:kanji_dictionary/models/word.dart';
import 'package:kanji_dictionary/resource/repository.dart';

export 'package:kanji_dictionary/models/kanji.dart';
export 'package:kanji_dictionary/models/sentence.dart';
export 'package:kanji_dictionary/models/word.dart';

import 'package:kanji_dictionary/utils/string_extension.dart';

class KanjiBloc {
  //final repo = Repository();
  final _sentencesFetcher = BehaviorSubject<List<Sentence>>();
  final _wordsFetcher = BehaviorSubject<List<Word>>();
  final _kanjisFetcher = BehaviorSubject<List<Kanji>>();
  final _allKanjisFetcher = BehaviorSubject<List<Kanji>>();
  final _singleKanjiFetcher = BehaviorSubject<Kanji>();
  final _randomKanjiFetcher = BehaviorSubject<Kanji>();
  final _allFavKanjisFetcher = BehaviorSubject<List<Kanji>>();
  final _allStarKanjisFetcher = BehaviorSubject<List<Kanji>>();
  final _allKanjisByKanaFetcher = BehaviorSubject<List<Kanji>>();
  final _kanjiByKanaFetcher = BehaviorSubject<Kanji>();
  final _searchResultsFetcher = BehaviorSubject<List<Kanji>>();
  final Queue<BehaviorSubject<Kanji>> _singleKanjiFetchers = Queue<BehaviorSubject<Kanji>>();

  List<Sentence> _sentences = <Sentence>[];
  List<String> _unloadedSentencesStr = List<String>();
  List<Word> _words = <Word>[];
  List<Kanji> _kanjis = <Kanji>[];
  //List<Kanji> _allKanjis = <Kanji>[];
  Map<String, Kanji> _allKanjisMap = <String, Kanji>{};
  Map<String, Kanji> _allFavKanjisMap = <String, Kanji>{};
  Map<String, Kanji> _allStarKanjisMap = <String, Kanji>{};

  Stream<List<Sentence>> get sentences => _sentencesFetcher.stream;
  Stream<List<Word>> get words => _wordsFetcher.stream;
  Stream<List<Kanji>> get kanjis => _kanjisFetcher.stream;
  Stream<List<Kanji>> get allKanjis => _allKanjisFetcher.stream;
  Stream<List<Kanji>> get allKanjisByKana => _allKanjisByKanaFetcher.stream;
  Stream<Kanji> get kanjiByKana => _kanjiByKanaFetcher.stream;
  Stream<Kanji> get kanji {
    if (_singleKanjiFetchers.isNotEmpty) {
      return _singleKanjiFetchers.last.stream;
    } else {
      _singleKanjiFetchers.add(BehaviorSubject<Kanji>()); //add a dummy
      return _singleKanjiFetchers.last.stream;
    }
  }

  Stream<List<Kanji>> get searchResults => _searchResultsFetcher.stream;

  Stream<Kanji> get randomKanji => _randomKanjiFetcher.stream;
  Stream<List<Kanji>> get allFavKanjis => _allFavKanjisFetcher.stream;
  Stream<List<Kanji>> get allStarKanjis => _allStarKanjisFetcher.stream;

  List<Kanji> get allKanjisList => _allKanjisMap.values.toList();
  Map<String, Kanji> get allKanjisMap => _allKanjisMap;

  void getRandomKanji() {
    var ran = Random(DateTime.now().millisecond);
    if (!_randomKanjiFetcher.isClosed) {
      var kanji = _allKanjisMap.values.elementAt(ran.nextInt(_allKanjisMap.length));
      _randomKanjiFetcher.sink.add(kanji);
    }
  }

  void fetchSentencesByKanji(String kanjiStr) {
    _sentences.clear();
    repo.fetchSentencesByKanji(kanjiStr).listen((sentence) {
      if (!_sentencesFetcher.isClosed) {
        _sentences.add(sentence);
        _sentencesFetcher.sink.add(_sentences);
      }
    });
  }

  void fetchWordsByKanji(String kanji) async {
    _words.clear();
    repo.fetchWordsByKanji(kanji).listen((word) {
      if (!_wordsFetcher.isClosed) {
        _words.add(word);
        _wordsFetcher.sink.add(_words);
      }
    });
  }

  void fetchKanjisByJLPTLevel(JLPTLevel jlptLevel) {
    Future<List<Kanji>>(() {
      var targetKanjis = _allKanjisMap.values.where((kanji) => kanji.jlptLevel == jlptLevel).toList();
      return targetKanjis;
    }).then((kanjis) {
      _kanjis = kanjis;
      if (!_kanjisFetcher.isClosed) {
        _kanjisFetcher.add(_kanjis);
      }
    });
  }

//  void fetchKanjisByGrade(int grade) {
//    Future<List<Kanji>>(() {
//      var targetKanjis = _allKanjisMap.values.where((kanji) => kanji.grade == grade).toList();
//      return targetKanjis;
//    }).then((kanjis) {
//      _kanjis = kanjis;
//      if (!_kanjisFetcher.isClosed) {
//        _kanjisFetcher.add(_kanjis);
//      }
//    });
//  }

  void fetchKanjisByKanjiStrs(List<String> kanjiStrs) {
    if (!_kanjisFetcher.isClosed) {
      _kanjisFetcher.add(kanjiStrs.map((str) => _allKanjisMap[str]).toList());
    }
  }

  void getAllKanjis() async {
    repo.getAllKanjisFromDB().then((kanjis) {
      if (kanjis.isNotEmpty) {
        _allKanjisMap = Map.fromEntries(kanjis.map((kanji) => MapEntry(kanji.kanji, kanji)));
        _allKanjisFetcher.sink.add(_allKanjisMap.values.toList());
        getRandomKanji();

        var allFavKanjiStrs = repo.getAllFavKanjiStrs();
        _allFavKanjisMap = Map.fromEntries(allFavKanjiStrs.map((str) => MapEntry(str, _allKanjisMap[str])));
        _allFavKanjisFetcher.sink.add(_allFavKanjisMap.values.toList());

        var allStarKanjiStrs = repo.getAllStarKanjiStrs();
        _allStarKanjisMap = Map.fromEntries(allStarKanjiStrs.map((str) => MapEntry(str, _allKanjisMap[str])));
        _allStarKanjisFetcher.sink.add(_allStarKanjisMap.values.toList());
      }
      //firebaseApiProvider.completeDatabase();
    });
  }

  Stream<Kanji> findKanjiByKana(String kana, Yomikata yomikata) async* {
    if (yomikata == Yomikata.kunyomi) {
      for (var kanji in _allKanjisFetcher.stream.value) {
        if (kanji.kunyomi.contains(kana)) {
          yield kanji;
        }
      }
    } else {
      for (var kanji in _allKanjisFetcher.stream.value) {
        if (kanji.onyomi.contains(kana)) {
          yield kanji;
        }
      }
    }
  }

  void getSentencesByKanji(String kanjiStr) async {
    var jsonStr = await repo.getSentencesJsonStringByKanji(kanjiStr);
    if (jsonStr != null) {
      var list = (jsonDecode(jsonStr) as List).cast<String>();
      //var sentences = list.sublist(0 + 10 * currentPortion, 10 + 10 * currentPortion).map((str) => Sentence.fromJsonString(str)).toList();
      var sentences = await jsonToSentences(list.sublist(0, list.length < 5 ? list.length : 5));

      list.removeRange(0, list.length < 5 ? list.length : 5);

      _unloadedSentencesStr = list;

      _sentences.addAll(sentences);

      if (sentences != null && !_sentencesFetcher.isClosed) {
        _sentencesFetcher.sink.add(_sentences);
      }
    } else {}
  }

  void getMoreSentencesByKanji() async {
    var sentences = await jsonToSentences(_unloadedSentencesStr.sublist(0, _unloadedSentencesStr.length < 10 ? _unloadedSentencesStr.length : 10));

    _unloadedSentencesStr.removeRange(0, _unloadedSentencesStr.length < 10 ? _unloadedSentencesStr.length : 10);

    _sentences.addAll(sentences);

    if (sentences != null && !_sentencesFetcher.isClosed) {
      _sentencesFetcher.sink.add(_sentences);
    }
  }

  void resetSentencesFetcher() {
    _sentencesFetcher.drain();
    _sentences.clear();
    _unloadedSentencesStr.clear();
  }

  void getKanjiInfoByKanjiStr(String kanjiStr) async {
//    var kanji = await compute(_filterKanji, [_allKanjis, kanjiStr]);

    var fetcher = BehaviorSubject<Kanji>();
    _singleKanjiFetchers.add(fetcher);
    var kanji = _allKanjisMap[kanjiStr];
    if (kanji != null && !_singleKanjiFetchers.last.isClosed)
      _singleKanjiFetchers.last.add(kanji);
    else
      _singleKanjiFetchers.last.addError('No data found');
  }

  void updateKanji(Kanji kanji, {isDeleted = false}) {
    for (var i in kanji.kunyomiWords) {
      print(i.wordText);
    }
    _allKanjisMap[kanji.kanji] = kanji;
    _allKanjisFetcher.sink.add(_allKanjisMap.values.toList());
    _singleKanjiFetchers.last.sink.add(kanji);
    repo.updateKanji(kanji, isDeleted);
  }

  static Kanji _filterKanji(List list) {
    var kanjis = list.elementAt(0);
    var kanjiStr = list.elementAt(1);
    return kanjis.singleWhere((kanji) => kanji.kanji == kanjiStr);
  }

  void addFav(String kanjiStr) {
    _allFavKanjisMap[kanjiStr] = _allKanjisMap[kanjiStr];
    _allFavKanjisFetcher.sink.add(_allFavKanjisMap.values.toList());
    repo.addFav(kanjiStr);
  }

  void removeFav(String kanjiStr) {
    _allFavKanjisMap.remove(kanjiStr);
    _allFavKanjisFetcher.sink.add(_allFavKanjisMap.values.toList());
    repo.removeFav(kanjiStr);
  }

  bool getIsFaved(String kanji) {
    return _allFavKanjisMap.containsKey(kanji);
  }

  void addStar(String kanjiStr) {
    _allStarKanjisMap[kanjiStr] = _allKanjisMap[kanjiStr];
    _allStarKanjisFetcher.sink.add(_allStarKanjisMap.values.toList());
    repo.addStar(kanjiStr);
  }

  void removeStar(String kanjiStr) {
    _allStarKanjisMap.remove(kanjiStr);
    _allStarKanjisFetcher.sink.add(_allStarKanjisMap.values.toList());
    repo.removeStar(kanjiStr);
  }

  bool getIsStared(String kanji) {
    return _allStarKanjisMap.containsKey(kanji);
  }

  void reset() {
    //_singleKanjiFetcher.drain();
    if (_singleKanjiFetchers.isNotEmpty) _singleKanjiFetchers.removeLast();
  }

  Kanji getKanjiInfo(String kanjiStr) {
    return _allKanjisMap[kanjiStr];
  }

  void searchKanjiInfosByStr(String text) {
    if (text == null || text.isEmpty) {
      _searchResultsFetcher.sink.add(allKanjisList);
      return;
    }
    var list = <Kanji>[];
    String hiraganaText = '';
    String katakanaText = '';

    if (text.codeUnitAt(0) >= 12353 && text.codeUnitAt(0) <= 12447) {
      hiraganaText = text;
      katakanaText = text.toKatakana();
    } else if (text.codeUnitAt(0) >= 12448 && text.codeUnitAt(0) <= 12543) {
      katakanaText = text;
      hiraganaText = text.toHiragana();
    }

    for (var kanji in _allKanjisMap.values) {
      if (hiraganaText.isEmpty && kanji.meaning.contains(text)) {
        list.add(kanji);
        continue;
      }

      if (katakanaText.isNotEmpty) {
        var onyomiMatch = kanji.onyomi.where((str) => str == katakanaText);
        if (onyomiMatch.isNotEmpty) {
          list.add(kanji);
          continue;
        }
      }

      if (hiraganaText.isNotEmpty) {
        var kunyomiMatch = kanji.kunyomi.where((str) => str == hiraganaText);
        if (kunyomiMatch.isNotEmpty) {
          list.add(kanji);
          continue;
        }
      }

      if (hiraganaText.isEmpty) {
        var onyomiWords = kanji.onyomiWords.where((word) => word.meanings.contains(text) || word.wordText.contains(text));
        if (onyomiWords.isNotEmpty) {
          list.add(kanji);
          continue;
        }
        var kunyomiWords = kanji.kunyomiWords.where((word) => word.meanings.contains(text) || word.wordText.contains(text));
        if (kunyomiWords.isNotEmpty) {
          list.add(kanji);
          continue;
        }
      }
    }

    list.sort((a, b) => a.strokes.compareTo(b.strokes));
    _searchResultsFetcher.sink.add(list);
  }

  void filterKanji(Map<int, bool> jlptMap, Map<int, bool> gradeMap) {
    var list = <Kanji>[];
    for (var kanji in allKanjisList) {
      if (kanji.jlpt == 0) continue;
      if (jlptMap[kanji.jlpt] || gradeMap[kanji.grade]) list.add(kanji);
    }

    if (list.isEmpty) list = List.from(allKanjisList);
    list.sort((a, b) => a.strokes.compareTo(b.strokes));
    _searchResultsFetcher.sink.add(list);
  }

  void dispose() {
    _sentencesFetcher.close();
    _wordsFetcher.close();
    _kanjisFetcher.close();
    _allKanjisFetcher.close();
    _randomKanjiFetcher.close();
    _allFavKanjisFetcher.close();
    _allStarKanjisFetcher.close();
    _singleKanjiFetcher.close();
    _allKanjisByKanaFetcher.close();
    _kanjiByKanaFetcher.close();
    _searchResultsFetcher.close();
  }
}

final kanjiBloc = KanjiBloc();
