
enum WordType {noun, verb, adjective}

class Word {
  //String kanji;
  String wordText;
  String wordFurigana;
  String meanings;
//  bool containsKanji;
//  bool containsFurigana;

  Word({this.wordText, this.wordFurigana, this.meanings});

  @override
  String toString() {
    return "$wordText^$wordFurigana^$meanings";
  }

  Word.fromString(String str){
    var subStrs = str.split('^');
    wordText = subStrs[0];
    wordFurigana = subStrs[1];
    meanings = subStrs[2];
  }

  Map toMap()=>{
    'wordText':wordText,
    'wordFurigana':wordFurigana,
    'meanings':meanings
  };

  Word.fromMap(Map map){
    wordText = map['wordText'];
    wordFurigana = map['wordFurigana'];
    meanings = map['meanings'];
  }
}

String wordTypeToString(WordType wordType){
  switch(wordType){
    case WordType.noun: return 'noun';
    case WordType.verb: return 'verb';
    case WordType.adjective: return 'adjective';
  }
  return '';
}
