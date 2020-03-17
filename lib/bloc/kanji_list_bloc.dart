import 'package:rxdart/rxdart.dart';

import 'package:kanji_dictionary/resource/repository.dart';

import 'package:kanji_dictionary/models/kanji_list.dart';

export 'package:kanji_dictionary/models/kanji_list.dart';
export 'package:kanji_dictionary/models/kanji.dart';

class KanjiListBloc {
  static final instance = KanjiListBloc();

  final _kanjiListsFetcher = BehaviorSubject<List<KanjiList>>();

  Stream<List<KanjiList>> get kanjiLists => _kanjiListsFetcher.stream;

  List<KanjiList> _kanjiLists;

  void init() {
    _kanjiLists = repo.getAllKanjiList();
    print("init ${_kanjiLists.length}");
    if (!_kanjiListsFetcher.isClosed) _kanjiListsFetcher.sink.add(_kanjiLists);
  }

  void addKanji(String listName, String kanjiStr) {
    _kanjiLists.singleWhere((list) => list.name == listName).kanjiStrs.add(kanjiStr);
    repo.updateKanjiLists(_kanjiLists);
  }

  void removeKanji(String listName, String kanjiStr) {
    _kanjiLists.singleWhere((list) => list.name == listName).kanjiStrs.remove(kanjiStr);
    repo.updateKanjiLists(_kanjiLists);
  }

  void addKanjiList(String listName) {
    _kanjiLists.add(KanjiList(name: listName, kanjiStrs: []));
    repo.updateKanjiLists(_kanjiLists);
    if (!_kanjiListsFetcher.isClosed) _kanjiListsFetcher.sink.add(_kanjiLists);
  }

  void deleteKanjiList(String listName) {
    _kanjiLists.removeWhere((kanjiList) => kanjiList.name == listName);
    repo.updateKanjiLists(_kanjiLists);
    if (!_kanjiListsFetcher.isClosed) _kanjiListsFetcher.sink.add(_kanjiLists);
  }

  bool isInList(String listName, String kanjiStr) {
    return _kanjiLists.singleWhere((list) => list.name == listName).kanjiStrs.contains(kanjiStr);
  }

  void dispose() {
    _kanjiListsFetcher.close();
  }
}
