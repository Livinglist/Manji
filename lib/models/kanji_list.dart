import 'dart:convert';

import 'package:uuid/uuid.dart';

class KanjiList {
  String uid;
  String name;
  List<String> kanjiStrs;

  int get kanjiCount {
    return kanjiStrs.where((e) => e.length == 1).length;
  }

  int get wordCount {
    var count = 0;

    for (var item in kanjiStrs.where((e) => e.length > 1)) {
      final Map json = jsonDecode(item);
      if (json.containsKey('meanings')) count++;
    }

    return count;
  }

  int get sentenceCount {
    var count = 0;

    for (var item in kanjiStrs.where((e) => e.length > 1)) {
      final Map json = jsonDecode(item);
      if (!json.containsKey('meanings')) count++;
    }

    return count;
  }

  KanjiList({this.name, this.kanjiStrs}) : uid = const Uuid().v1();

  KanjiList.from({this.name, this.kanjiStrs, this.uid});

  KanjiList.fromMap(Map map)
      : uid = map['uid'] ?? const Uuid().v1(),
        name = map['name'],
        kanjiStrs = map['kanjiStrs'].runtimeType is String
            ? (jsonDecode(map['kanjiStrs']) as List).cast<String>()
            : (map['kanjiStrs'] as List).cast<String>();

  Map toMap() => {'uid': uid, 'name': name, 'kanjiStrs': jsonEncode(kanjiStrs)};

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) => other is KanjiList && uid == other.uid;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => uid.hashCode;
}

List<KanjiList> kanjiListsFromJsonStr(String str) {
  if (str == null) {
    return <KanjiList>[];
  }
  final list = (jsonDecode(str) as List).cast<Map>();
  final kanjiLists = list.map((str) => KanjiList.fromMap(str)).toList();
  return kanjiLists;
}

String kanjiListsToJsonStr(List<KanjiList> kanjiLists) {
  return jsonEncode(kanjiLists.map((kanjiList) => kanjiList.toMap()).toList());
}
