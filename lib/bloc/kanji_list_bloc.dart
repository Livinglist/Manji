import 'package:rxdart/rxdart.dart';

import 'package:kanji_dictionary/utils/list_extension.dart';
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

  void changeName(KanjiList kanjiList, String newName) {
    var temp = _kanjiLists.singleWhere((list) => list.uid == kanjiList.uid);
    temp.name = newName;
    repo.updateKanjiListName(temp);
  }

  void addKanji(KanjiList kanjiList, String kanjiStr) {
    var temp = _kanjiLists.singleWhere((list) => list == kanjiList);
    temp.kanjiStrs.add(kanjiStr);
    repo.updateKanjiListKanjis(temp);
  }

  void removeKanji(KanjiList kanjiList, String kanjiStr) {
    var temp = _kanjiLists.singleWhere((list) => list == kanjiList);
    temp.kanjiStrs.remove(kanjiStr);
    repo.updateKanjiListKanjis(temp);
  }

  void addKanjiList(String listName) {
    while (_kanjiLists.containsWhere((e) => e.name == listName) == true) {
      var regex = RegExp(r' [0-9]*$');
      var match = regex.firstMatch(listName);
      if (regex.hasMatch(listName)) {
        var num = int.parse(match.group(0)) + 1;
        listName = listName.replaceRange(listName.length - 1, listName.length, num.toString());
      } else {
        listName = listName.trim() + " 1";
      }
    }
    var temp = KanjiList(name: listName, kanjiStrs: []);
    _kanjiLists.add(temp);
    repo.addKanjiList(temp);
    if (!_kanjiListsFetcher.isClosed) _kanjiListsFetcher.sink.add(_kanjiLists);
  }

  void deleteKanjiList(KanjiList kanjiList) {
    _kanjiLists.remove(kanjiList);
    repo.deleteKanjiList(kanjiList);
    if (!_kanjiListsFetcher.isClosed) _kanjiListsFetcher.sink.add(_kanjiLists);
  }

  bool isInList(String listName, String kanjiStr) {
    return _kanjiLists.singleWhere((list) => list.name == listName).kanjiStrs.contains(kanjiStr);
  }

  void dispose() {
    _kanjiListsFetcher.close();
  }
}
