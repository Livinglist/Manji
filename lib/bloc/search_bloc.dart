import 'package:rxdart/rxdart.dart';

import '../utils/string_extension.dart';
import 'kanji_bloc.dart';

enum SearchFor { meaning, pronunciation, kanji }

class SearchBloc {
  final _resultsFetcher = BehaviorSubject<List<Kanji>>();

  Stream<List<Kanji>> get results => _resultsFetcher.stream;

  List<Kanji> get _allKanjisList => KanjiBloc.instance.allKanjisList;

  Map<String, Kanji> get _allKanjisMap => KanjiBloc.instance.allKanjisMap;

  void clear() {
    _resultsFetcher.drain();
    _resultsFetcher.sink.add([]);
  }

  void search(String text) {
    if (text == null || text.isEmpty) {
      _resultsFetcher.sink.add(_allKanjisList);
      return;
    }

    final kanjiSet = <Kanji>{};
    var hiraganaText = '';
    var katakanaText = '';

    if (text.isAllKanji()) {
      for (var i in Iterable.generate(text.length)) {
        final kanjiStr = text[i];
        if (_allKanjisMap.containsKey(kanjiStr)) {
          kanjiSet.add(_allKanjisMap[kanjiStr]);
        }
      }

      _resultsFetcher.add(kanjiSet.toList());
      return;
    } else if (text.isAllLatin()) {
      for (var kanji in _allKanjisList) {
        if (kanji.meaning.contains(text)) {
          kanjiSet.add(kanji);
        }
      }

      _resultsFetcher.add(kanjiSet.toList());
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
          kanjiSet.add(kanji);
          continue;
        }

        var matched = false;

        for (var word in kanji.onyomiWords) {
          if (word.meanings.contains(text)) {
            kanjiSet.add(kanji);
            matched = true;
            break;
          }
        }

        if (matched) continue;

        for (var word in kanji.kunyomiWords) {
          if (word.meanings.contains(text)) {
            kanjiSet.add(kanji);
            matched = true;
            break;
          }
        }

        if (matched) continue;
      }

      if (katakanaText.isNotEmpty) {
        final onyomiMatch = kanji.onyomi.where((str) => str == katakanaText);
        if (onyomiMatch.isNotEmpty) {
          kanjiSet.add(kanji);
          continue;
        }
      }

      if (hiraganaText.isNotEmpty) {
        final kunyomiMatch = kanji.kunyomi.where((str) => str == hiraganaText);
        if (kunyomiMatch.isNotEmpty) {
          kanjiSet.add(kanji);
          continue;
        }
      }

      if (hiraganaText.isEmpty) {
        final onyomiWords = kanji.onyomiWords.where((word) =>
            word.meanings.contains(text) || word.wordText.contains(text));
        if (onyomiWords.isNotEmpty) {
          kanjiSet.add(kanji);
          continue;
        }
        final kunyomiWords = kanji.kunyomiWords.where((word) =>
            word.meanings.contains(text) || word.wordText.contains(text));
        if (kunyomiWords.isNotEmpty) {
          kanjiSet.add(kanji);
          continue;
        }
      }
    }

    _resultsFetcher.sink.add(kanjiSet.toList());
  }

  void filter(Map<int, bool> jlptMap, Map<int, bool> gradeMap,
      Map<String, bool> radicalsMap) {
    final list = <Kanji>[];

    clear();

    _filterKanjiStream(jlptMap, gradeMap, radicalsMap).listen((kanji) {
      if (kanji == null) {
        _resultsFetcher.sink.add(_allKanjisList);
      } else {
        list.add(kanji);

        list.sort((a, b) => a.strokes.compareTo(b.strokes));

        _resultsFetcher.sink.add(list);
      }
    });
  }

  Stream<Kanji> _filterKanjiStream(Map<int, bool> jlptMap,
      Map<int, bool> gradeMap, Map<String, bool> radicalsMap) async* {
    final jlptIsEmpty = !jlptMap.containsValue(true),
        gradeIsEmpty = !gradeMap.containsValue(true),
        radicalIsEmpty = !radicalsMap.containsValue(true);

    if (jlptIsEmpty && gradeIsEmpty && radicalIsEmpty) {
      yield null;
    } else {
      for (var kanji in _allKanjisList) {
        //if (kanji.jlpt == 0) continue;

        if ((jlptIsEmpty || jlptMap[kanji.jlpt]) &&
            (gradeIsEmpty || gradeMap[kanji.grade]) &&
            (radicalIsEmpty || radicalsMap[kanji.radicals])) yield kanji;
      }
    }
  }

  void dispose() {
    _resultsFetcher.close();
  }
}
