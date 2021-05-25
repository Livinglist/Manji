import 'dart:convert';

import '../resource/constants.dart';

class Token {
  String text;
  String furigana;
  bool containsKanji;

  Token({this.text, this.furigana})
      : assert(text != null),
        containsKanji = furigana != null;

  Map toMap() => {
        Keys.textKey: text,
        Keys.furiganaKey: furigana,
      };

  Token.fromMap(Map map) {
    text = map[Keys.textKey];
    furigana = map[Keys.furiganaKey];
    containsKanji = furigana != null;
  }
}

class Sentence {
  int id;
  String kanji;
  List<Token> tokens;
  String text = '';
  String englishText = '';

  Sentence({this.id, this.kanji, this.tokens, this.text, this.englishText});

  Sentence.fromMap(Map<String, dynamic> map) {
    text = map[Keys.textKey];
    englishText = map[Keys.englishTextKey];
    tokens = (map[Keys.tokensKey] as List)
        .map((map) => Token.fromMap(map is String ? jsonDecode(map) : map))
        .toList();
  }

  Map toMap() => {
        Keys.textKey: text,
        Keys.englishTextKey: englishText,
        Keys.tokensKey:
            tokens.map((token) => jsonEncode(token.toMap())).toList()
      };

  Map toDBMap() => {
        Keys.idKey: id,
        Keys.textKey: text,
        Keys.englishTextKey: englishText,
        Keys.tokensKey: jsonEncode(
            tokens.map((token) => jsonEncode(token.toMap())).toList())
      };

  Sentence.fromDBMap(Map map) {
    id = map[Keys.idKey];
    text = map[Keys.textKey];
    englishText = map[Keys.englishTextKey];
    tokens = (jsonDecode(map[Keys.tokensKey]) as List)
        .map((map) => Token.fromMap(jsonDecode(map)))
        .toList();
  }

  Sentence.fromJsonString(String str) {
    final map = jsonDecode(str);
    id = map[Keys.idKey];
    text = map[Keys.textKey];
    englishText = map[Keys.englishTextKey];
    tokens = (jsonDecode(map[Keys.tokensKey]) as List)
        .map((map) => Token.fromMap(jsonDecode(map)))
        .toList();
  }

  String toJsonString() {
    final map = toMap();
    return jsonEncode(map);
  }
}

String sentencesToJson(List<Sentence> sentences) {
  return jsonEncode(sentences.map((sen) => jsonEncode(sen.toMap())).toList());
}

Future<List<Sentence>> jsonToSentences(List<String> jsonStrs) async {
  return Future<List<Sentence>>(() {
    return jsonStrs.map((sen) => Sentence.fromMap(jsonDecode(sen))).toList();
  });
}

Future<List<Sentence>> jsonStringToSentences(String jsonStr) async {
  final list = jsonDecode(jsonStr) as List;
  return Future<List<Sentence>>(() {
    return list.map((sen) => Sentence.fromMap(jsonDecode(sen))).toList();
  });
}

Stream<Sentence> jsonToSentencesStream(String jsonStr) async* {
  final list = jsonDecode(jsonStr) as List;
  for (var sen in list) {
    yield Sentence.fromMap(jsonDecode(sen));
  }
}
