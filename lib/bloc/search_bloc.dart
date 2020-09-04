import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

import 'package:kanji_dictionary/utils/string_extension.dart';
import 'kanji_bloc.dart';

class SearchBloc {
  static final instance = SearchBloc._();

  SearchBloc._();

  final _resultsFetcher = BehaviorSubject<List<Kanji>>();

  Stream<List<Kanji>> get results => _resultsFetcher.stream;

  List<Kanji> get _allKanjisList => KanjiBloc.instance.allKanjisList;
  Map<String, Kanji> get _allKanjisMap => KanjiBloc.instance.allKanjisMap;

  void clear() {
    _resultsFetcher.drain();
    _resultsFetcher.sink.add([]);
  }

  void search(String text) {
    var comparison = (Kanji a, Kanji b) {
      var aSimilarity = _findSimilarity(a, text);
      var bSimilarity = _findSimilarity(b, text);
    };
    var queue = HeapPriorityQueue<Kanji>();
    if (text == null || text.isEmpty) {
      _resultsFetcher.sink.add(_allKanjisList);
      return;
    }

    var list = <Kanji>[];
    String hiraganaText = '';
    String katakanaText = '';

    if (text.isAllKanji()) {
      for (var i in Iterable.generate(text.length)) {
        var kanjiStr = text[i];
        if (_allKanjisMap.containsKey(kanjiStr)) {
          list.add(_allKanjisMap[kanjiStr]);
        }
      }

      _resultsFetcher.add(list);
      return;
    }

    if (text.codeUnitAt(0) >= 12353 && text.codeUnitAt(0) <= 12447) {
      hiraganaText = text;
      katakanaText = text.toKatakana();
    } else if (text.codeUnitAt(0) >= 12448 && text.codeUnitAt(0) <= 12543) {
      katakanaText = text;
      hiraganaText = text.toHiragana();
    }

    for (var kanji in _allKanjisList) {
      if (hiraganaText.isEmpty) {
        if (kanji.meaning.contains(text)) {
          list.add(kanji);
          continue;
        }

        bool matched = false;

        for (var word in kanji.onyomiWords) {
          if (word.meanings.contains(text)) {
            list.add(kanji);
            matched = true;
            break;
          }
        }

        if (matched) continue;

        for (var word in kanji.kunyomiWords) {
          if (word.meanings.contains(text)) {
            list.add(kanji);
            matched = true;
            break;
          }
        }

        if (matched) continue;
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
    _resultsFetcher.sink.add(list);
  }

  void filter(Map<int, bool> jlptMap, Map<int, bool> gradeMap, Map<String, bool> radicalsMap) {
    var list = <Kanji>[];

    _filterKanjiStream(jlptMap, gradeMap, radicalsMap).listen((kanji) {
      list.add(kanji);
      if (list.isEmpty) list = List.from(_allKanjisList);
      list.sort((a, b) => a.strokes.compareTo(b.strokes));
      _resultsFetcher.sink.add(list);
    });
  }

  Stream<Kanji> _filterKanjiStream(Map<int, bool> jlptMap, Map<int, bool> gradeMap, Map<String, bool> radicalsMap) async* {
    bool jlptIsEmpty = !jlptMap.containsValue(true), gradeIsEmpty = !gradeMap.containsValue(true), radicalIsEmpty = !radicalsMap.containsValue(true);

    for (var kanji in _allKanjisList) {
      if (kanji.jlpt == 0) continue;
      if ((jlptIsEmpty || jlptMap[kanji.jlpt]) && (gradeIsEmpty || gradeMap[kanji.grade]) && (radicalIsEmpty || radicalsMap[kanji.radicals]))
        yield kanji;
    }
  }

  int _findSimilarity(Kanji kanji, String text) {
    if (text == kanji.kanji) {
      return -1;
    }
    return 0;

    ///TODO:
  }

  dispose() {
    _resultsFetcher.close();
  }
}
