import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_siri_suggestions/flutter_siri_suggestions.dart';
import 'package:rxdart/rxdart.dart';

import '../models/kanji.dart';
import '../models/sentence.dart';
import '../models/word.dart';
import '../resource/firebase_auth_provider.dart';
import '../resource/repository.dart';

export '../models/kanji.dart';
export '../models/sentence.dart';
export '../models/word.dart';

class KanjiBloc {
  static final instance = KanjiBloc._();

  KanjiBloc._();

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
  final Queue<BehaviorSubject<Kanji>> _singleKanjiFetchers =
      Queue<BehaviorSubject<Kanji>>();

  final _sentences = <Sentence>[];
  List<String> _unloadedSentencesStr = <String>[];
  final _words = <Word>[];
  List<Kanji> _kanjis = <Kanji>[];
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

  Stream<Kanji> get randomKanji => _randomKanjiFetcher.stream;
  Stream<List<Kanji>> get allFavKanjis => _allFavKanjisFetcher.stream;
  Stream<List<Kanji>> get allStarKanjis => _allStarKanjisFetcher.stream;

  List<Kanji> get allKanjisList => _allKanjisMap.values.toList();
  Map<String, Kanji> get allKanjisMap => _allKanjisMap;

  void getRandomKanji() {
    final ran = Random(DateTime.now().millisecond);
    if (!_randomKanjiFetcher.isClosed) {
      Kanji kanji;
      do {
        kanji =
            _allKanjisMap.values.elementAt(ran.nextInt(_allKanjisMap.length));
      } while (kanji.jlptLevel == null);
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
      final targetKanjis = _allKanjisMap.values
          .where((kanji) => kanji.jlptLevel == jlptLevel)
          .toList();
      return targetKanjis;
    }).then((kanjis) {
      _kanjis = kanjis;
      if (!_kanjisFetcher.isClosed) {
        _kanjisFetcher.add(_kanjis);
      }
    });
  }

  void fetchKanjisByKanjiStrs(List<String> kanjiStrs) {
    if (!_kanjisFetcher.isClosed) {
      _kanjisFetcher.add(kanjiStrs
          .map((str) => str.length == 1 ? _allKanjisMap[str] : null)
          .toList()
            ..removeWhere((e) => e == null));
    }
  }

  void getAllKanjis() async {
    repo.getAllKanjisFromDB().then((kanjis) {
      if (kanjis.isNotEmpty) {
        _allKanjisMap = Map.fromEntries(
            kanjis.map((kanji) => MapEntry(kanji.kanji, kanji)));
        _allKanjisFetcher.sink.add(_allKanjisMap.values.toList());
        getRandomKanji();

        final allFavKanjiStrs = repo.getAllFavKanjiStrs();
        _allFavKanjisMap = Map.fromEntries(
            allFavKanjiStrs.map((str) => MapEntry(str, _allKanjisMap[str])));
        _allFavKanjisFetcher.sink.add(_allFavKanjisMap.values.toList());

        final allStarKanjiStrs = repo.getAllStarKanjiStrs();
        _allStarKanjisMap = Map.fromEntries(
            allStarKanjiStrs.map((str) => MapEntry(str, _allKanjisMap[str])));
        _allStarKanjisFetcher.sink.add(_allStarKanjisMap.values.toList());
      }
    });
  }

  Future addSuggestion(Kanji kanji) async {
    print("adding the $kanji");
    return FlutterSiriSuggestions.instance.buildActivity(FlutterSiriActivity(
        kanji.kanji, kanji.kanji,
        isEligibleForSearch: true,
        isEligibleForPrediction: true,
        contentDescription: kanji.meaning,
        suggestedInvocationPhrase: "open my app"));
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
    final jsonStr = await repo.getSentencesJsonStringByKanji(kanjiStr);
    if (jsonStr != null) {
      final list = (jsonDecode(jsonStr) as List).cast<String>();
      //var sentences = list.sublist(0 + 10 * currentPortion, 10 + 10 * currentPortion).map((str) => Sentence.fromJsonString(str)).toList();
      final sentences = await jsonToSentences(
          list.sublist(0, list.length < 5 ? list.length : 5));

      list.removeRange(0, list.length < 5 ? list.length : 5);

      _unloadedSentencesStr = list;

      _sentences.addAll(sentences);

      if (sentences != null && !_sentencesFetcher.isClosed) {
        _sentencesFetcher.sink.add(_sentences);
      }
    } else {}
  }

  void getMoreSentencesByKanji() async {
    final sentences = await jsonToSentences(_unloadedSentencesStr.sublist(0,
        _unloadedSentencesStr.length < 10 ? _unloadedSentencesStr.length : 10));

    _unloadedSentencesStr.removeRange(0,
        _unloadedSentencesStr.length < 10 ? _unloadedSentencesStr.length : 10);

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

  void getKanjiInfoByKanjiStr(String kanjiStr) {
    final fetcher = BehaviorSubject<Kanji>();
    _singleKanjiFetchers.add(fetcher);
    final kanji = _allKanjisMap[kanjiStr];
    if (kanji != null && !_singleKanjiFetchers.last.isClosed) {
      _singleKanjiFetchers.last.add(kanji);
    } else {
      _singleKanjiFetchers.last.addError('No data found');
    }
  }

  // ignore: type_annotate_public_apis
  void updateKanji(Kanji kanji, {isDeleted = false}) {
    for (var i in kanji.kunyomiWords) {
      print(i.wordText);
    }
    _allKanjisMap[kanji.kanji] = kanji;
    _allKanjisFetcher.sink.add(_allKanjisMap.values.toList());
    _singleKanjiFetchers.last.sink.add(kanji);
    repo.updateKanji(kanji, isDeleted: isDeleted);
  }

  void addFav(String kanjiStr) {
    final allFav = _allFavKanjisMap.keys.toList();
    if (allFav.contains(kanjiStr) == false) {
      _allFavKanjisMap[kanjiStr] = _allKanjisMap[kanjiStr];
      _allFavKanjisFetcher.sink.add(_allFavKanjisMap.values.toList());
      repo.addFav(kanjiStr);

      if (FirebaseAuth.instance.currentUser != null) {
        repo.uploadFavKanjis(_allFavKanjisMap.keys.toList());
      }
    }
  }

  void removeFav(String kanjiStr) {
    _allFavKanjisMap.remove(kanjiStr);
    _allFavKanjisFetcher.sink.add(_allFavKanjisMap.values.toList());
    repo.removeFav(kanjiStr);

    if (FirebaseAuth.instance.currentUser != null) {
      repo.removeFavKanjiFromCloud(kanjiStr);
    }
  }

  bool getIsFaved(String kanji) {
    return _allFavKanjisMap.containsKey(kanji);
  }

  void addStar(String kanjiStr) {
    final allStar = _allStarKanjisMap.keys.toList();
    if (allStar.contains(kanjiStr) == false) {
      _allStarKanjisMap[kanjiStr] = _allKanjisMap[kanjiStr];
      _allStarKanjisFetcher.sink.add(_allStarKanjisMap.values.toList());
      repo.addStar(kanjiStr);

      if (FirebaseAuth.instance.currentUser != null) {
        repo.uploadMarkedKanjis(_allStarKanjisMap.keys.toList());
      }
    }
  }

  void removeStar(String kanjiStr) {
    _allStarKanjisMap.remove(kanjiStr);
    _allStarKanjisFetcher.sink.add(_allStarKanjisMap.values.toList());
    repo.removeStar(kanjiStr);

    if (FirebaseAuth.instance.currentUser != null) {
      repo.removeMarkedKanjiFromCloud(kanjiStr);
    }
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

  void updateTimeStampsForSingleKanji(Kanji kanji) =>
      repo.updateKanjiStudiedTimeStamps(kanji);

  void updateTimeStampsForKanjis(List<Kanji> kanjis) {
    for (var i in kanjis) {
      updateTimeStampsForSingleKanji(i);
    }
  }

  List<String> get getAllFavKanjis => _allFavKanjisMap.keys.toList();

  List<String> get getAllMarkedKanjis => _allStarKanjisMap.keys.toList();

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
  }
}
