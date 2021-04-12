import 'dart:convert';

import 'package:rxdart/rxdart.dart';

import '../utils/list_extension.dart';
import '../resource/repository.dart';
import '../models/kanji_list.dart';

export '../models/kanji_list.dart';
export '../models/kanji.dart';

class KanjiListBloc {
  static final instance = KanjiListBloc();

  final _kanjiListsFetcher = BehaviorSubject<List<KanjiList>>();

  Stream<List<KanjiList>> get kanjiLists => _kanjiListsFetcher.stream;

  static List<KanjiList> _kanjiLists;

  List<KanjiList> get allKanjiLists {
    if (_kanjiLists == null) {
      _kanjiLists = repo.getAllKanjiList();

      if (!_kanjiListsFetcher.isClosed)
        _kanjiListsFetcher.sink.add(_kanjiLists);

      return _kanjiLists;
    }

    return _kanjiLists;
  }

  void init() {
    if (_kanjiLists == null) {
      _kanjiLists = repo.getAllKanjiList();
      if (!_kanjiListsFetcher.isClosed)
        _kanjiListsFetcher.sink.add(_kanjiLists);
    }
  }

  void changeName(KanjiList kanjiList, String newName) {
    var temp = _kanjiLists.singleWhere((list) => list.uid == kanjiList.uid);
    temp.name = newName;
    repo.updateKanjiListName(temp);
    repo.uploadKanjiList(kanjiList);
  }

  void addWord(KanjiList kanjiList, Word word) {
    var temp = _kanjiLists.singleWhere((list) => list == kanjiList);
    var jsonStr = jsonEncode(word.toMap());
    temp.kanjiStrs.add(jsonStr);
    repo.updateKanjiListKanjis(temp);
    if (!_kanjiListsFetcher.isClosed) _kanjiListsFetcher.sink.add(_kanjiLists);
    repo.uploadKanjiList(kanjiList);
  }

  void addSentence(KanjiList kanjiList, Sentence sentence) {
    var temp = _kanjiLists.singleWhere((list) => list == kanjiList);
    var jsonStr = jsonEncode(sentence.toMap());
    temp.kanjiStrs.add(jsonStr);
    repo.updateKanjiListKanjis(temp);
    if (!_kanjiListsFetcher.isClosed) _kanjiListsFetcher.sink.add(_kanjiLists);
    repo.uploadKanjiList(kanjiList);
  }

  void addKanji(KanjiList kanjiList, String kanjiStr) {
    var temp = _kanjiLists.singleWhere((list) => list == kanjiList);
    temp.kanjiStrs.add(kanjiStr);
    repo.updateKanjiListKanjis(temp);
    if (!_kanjiListsFetcher.isClosed) _kanjiListsFetcher.sink.add(_kanjiLists);
    repo.uploadKanjiList(kanjiList);
  }

  void removeWord(KanjiList kanjiList, Word word) {
    var temp = _kanjiLists.singleWhere((list) => list == kanjiList);
    var jsonStr = jsonEncode(word.toMap());
    temp.kanjiStrs.remove(jsonStr);
    repo.updateKanjiListKanjis(temp);
    if (!_kanjiListsFetcher.isClosed) _kanjiListsFetcher.sink.add(_kanjiLists);
    repo.uploadKanjiList(kanjiList);
  }

  void removeSentence(KanjiList kanjiList, Sentence sentence) {
    var temp = _kanjiLists.singleWhere((list) => list == kanjiList);
    var jsonStr = jsonEncode(sentence.toMap());
    temp.kanjiStrs.remove(jsonStr);
    repo.updateKanjiListKanjis(temp);
    if (!_kanjiListsFetcher.isClosed) _kanjiListsFetcher.sink.add(_kanjiLists);
    repo.uploadKanjiList(kanjiList);
  }

  void removeKanji(KanjiList kanjiList, String kanjiStr) {
    var temp = _kanjiLists.singleWhere((list) => list == kanjiList);
    temp.kanjiStrs.remove(kanjiStr);
    repo.updateKanjiListKanjis(temp);
    if (!_kanjiListsFetcher.isClosed) _kanjiListsFetcher.sink.add(_kanjiLists);
    repo.uploadKanjiList(kanjiList);
  }

  void addKanjiList(String listName) {
    while (_kanjiLists.containsWhere((e) => e.name == listName) == true) {
      var regex = RegExp(r' [0-9]*$');
      var match = regex.firstMatch(listName);
      if (regex.hasMatch(listName)) {
        var num = int.parse(match.group(0)) + 1;
        listName = listName.replaceRange(
            listName.length - 1, listName.length, num.toString());
      } else {
        listName = listName.trim() + " 1";
      }
    }
    var temp = KanjiList(name: listName, kanjiStrs: []);
    _kanjiLists.add(temp);
    repo.addKanjiList(temp);
    if (!_kanjiListsFetcher.isClosed) _kanjiListsFetcher.sink.add(_kanjiLists);
    repo.uploadKanjiList(temp);
  }

  void deleteKanjiList(KanjiList kanjiList) {
    _kanjiLists.remove(kanjiList);
    repo.deleteKanjiList(kanjiList);
    if (!_kanjiListsFetcher.isClosed) _kanjiListsFetcher.sink.add(_kanjiLists);
    repo.deleteKanjiListFromFirebase(kanjiList);
  }

  bool isInList(KanjiList list, String kanjiStr) {
    return _kanjiLists
        .singleWhere((li) => li == list)
        .kanjiStrs
        .contains(kanjiStr);
  }

  void clearThenAddKanjiLists(List<KanjiList> kanjiLists) {
    if (_kanjiLists == null) init();
    for (var list in kanjiLists) {
      if (_kanjiLists.contains(list)) {
        var remoteKanjis = list.kanjiStrs;
        var localKanjis = _kanjiLists.singleWhere((e) => e == list).kanjiStrs;
        var mergedKanjis = [...remoteKanjis, ...localKanjis].toSet().toList();
        list.kanjiStrs = mergedKanjis;

        repo.deleteKanjiList(list);
      } else {
        _kanjiLists.add(list);
      }
      repo.addKanjiList(list);
    }

    for (var list in _kanjiLists) {
      if (kanjiLists.contains(list) == false) {
        print("The list that should not exits");
        repo.deleteKanjiList(list);
      }
    }

    if (!_kanjiListsFetcher.isClosed) _kanjiListsFetcher.sink.add(_kanjiLists);
  }

  void dispose() {
    _kanjiListsFetcher.close();
  }
}
