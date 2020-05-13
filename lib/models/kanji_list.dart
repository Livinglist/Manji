import 'dart:convert';
import 'package:uuid/uuid.dart';

class KanjiList {
  String uid;
  String name;
  List<String> kanjiStrs;

  KanjiList({this.name, this.kanjiStrs}) : uid = Uuid().v1();
  KanjiList.from({this.name, this.kanjiStrs, this.uid});

  KanjiList.fromMap(Map map) {
    uid = map['uid'] ?? Uuid().v1();
    name = map['name'];
    if (map['kanjiStrs'].runtimeType is String) {
      kanjiStrs = (jsonDecode(map['kanjiStrs']) as List).cast<String>();
    } else {
      kanjiStrs = (map['kanjiStrs'] as List).cast<String>();
    }
  }

  Map toMap() => {'uid': uid, 'name': name, 'kanjiStrs': jsonEncode(kanjiStrs)};

  @override
  bool operator ==(Object other) => other is KanjiList && this.uid == other.uid;

  @override
  int get hashCode => this.uid.hashCode;
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
