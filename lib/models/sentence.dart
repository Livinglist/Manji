import 'dart:convert';

class Token {
  String text;
  String furigana;
  bool containsKanji;

  Token({this.text, this.furigana})
      : assert(text != null),
        containsKanji = furigana != null;

  Map toMap() => {
        'text': text,
        'furigana': furigana,
      };

  Token.fromMap(Map map) {
    text = map['text'];
    furigana = map['furigana'];
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
    text = map['text'];
    englishText = map['englishText'];
    tokens = (map['tokens'] as List)
        .map((map) => Token.fromMap(jsonDecode(map)))
        .toList();
  }

  Map toMap() => {
        'text': text,
        'englishText': englishText,
        'tokens': tokens.map((token) => jsonEncode(token.toMap())).toList()
      };

  Map toDBMap() => {
        'id': id,
        'text': text,
        'englishText': englishText,
        'tokens': jsonEncode(
            tokens.map((token) => jsonEncode(token.toMap())).toList())
      };

  Sentence.fromDBMap(Map map) {
    id = map['id'];
    text = map['text'];
    englishText = map['englishText'];
    tokens = (jsonDecode(map['tokens']) as List)
        .map((map) => Token.fromMap(jsonDecode(map)))
        .toList();
  }

  Sentence.fromJsonString(String str) {
    var map = jsonDecode(str);
    id = map['id'];
    text = map['text'];
    englishText = map['englishText'];
    tokens = (jsonDecode(map['tokens']) as List)
        .map((map) => Token.fromMap(jsonDecode(map)))
        .toList();
  }

  String toJsonString() {
    var map = toMap();
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
  var list = jsonDecode(jsonStr) as List;
  return Future<List<Sentence>>(() {
    return list.map((sen) => Sentence.fromMap(jsonDecode(sen))).toList();
  });
}

Stream<Sentence> jsonToSentencesStream(String jsonStr) async* {
  var list = jsonDecode(jsonStr) as List;
  for (var sen in list) {
    yield Sentence.fromMap(jsonDecode(sen));
  }
}
