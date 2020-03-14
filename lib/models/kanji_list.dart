import 'dart:convert';

class KanjiList {
  String name;
  List<String> kanjiStrs;

  KanjiList({this.name, this.kanjiStrs});

  KanjiList.fromMap(Map map) {
    name = map['name'];
    kanjiStrs = (jsonDecode(map['kanjiStrs']) as List).cast<String>();
  }

  Map toMap() => {'name': name, 'kanjiStrs': jsonEncode(kanjiStrs)};
}

List<KanjiList> kanjiListsFromJsonStr(String str) {
  if (str == null) {
    return <KanjiList>[];
  }
  List<Map> list = (jsonDecode(str) as List).cast<Map>();
  var kanjiLists = list.map((str) => KanjiList.fromMap(str)).toList();
  return kanjiLists;
}

String kanjiListsToJsonStr(List<KanjiList> kanjiLists) {
  return jsonEncode(kanjiLists.map((kanjiList) => kanjiList.toMap()).toList());
}
