import '../resource/constants.dart';

enum WordType { noun, verb, adjective }

class Word {
  String wordText;
  String wordFurigana;
  String meanings;

  Word({this.wordText, this.wordFurigana, this.meanings});

  @override
  String toString() {
    return "$wordText^$wordFurigana^$meanings";
  }

  Word.fromString(String str) {
    final subStrs = str.split('^');
    wordText = subStrs[0];
    wordFurigana = subStrs[1];
    meanings = subStrs[2];
  }

  Map toMap() => {
        Keys.wordTextKey: wordText,
        Keys.wordFuriganaKey: wordFurigana,
        Keys.wordMeaningsKey: meanings
      };

  Word.fromMap(Map map) {
    wordText = map[Keys.wordTextKey];
    wordFurigana = map[Keys.wordFuriganaKey];
    meanings = map[Keys.wordMeaningsKey];
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) {
    if (other is Word &&
        other.wordText == wordText &&
        other.meanings == meanings) return true;
    return false;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => wordText.hashCode + meanings.hashCode;
}

String wordTypeToString(WordType wordType) {
  switch (wordType) {
    case WordType.noun:
      return 'noun';
    case WordType.verb:
      return 'verb';
    case WordType.adjective:
      return 'adjective';
  }
  return '';
}
