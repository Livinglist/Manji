import 'dart:convert';

import 'word.dart';

enum JLPTLevel { n1, n2, n3, n4, n5 }
enum Grade { g1, g2, g3, g4, g5, g6, g7, g8 }
enum Yomikata { kunyomi, onyomi }

class Kanji {
  int id;
  String kanji;
  List<String> onyomi;
  List<String> kunyomi;
  String meaning;
  int strokes;
  //bool isJinmeiyo;
  bool isFaved;
  List<int> timeStamps = [];

  set timeStamp(int timeStamp) => timeStamps.add(timeStamp);

  JLPTLevel get jlptLevel {
    switch (jlpt) {
      case 1:
        return JLPTLevel.n1;
      case 2:
        return JLPTLevel.n2;
      case 3:
        return JLPTLevel.n3;
      case 4:
        return JLPTLevel.n4;
      case 5:
        return JLPTLevel.n5;
    }
    return null;
  }

  int grade;
  int jlpt;
  int frequency;
  List<String> parts;
  List<Word> onyomiWords;
  List<Word> kunyomiWords;

  Kanji(
      {this.id,
      this.kanji,
      this.onyomi,
      this.kunyomi,
      this.meaning,
      //this.isJinmeiyo = false,
      //this.isFaved = false,
      this.grade,
      this.jlpt,
      this.strokes,
      this.frequency,
      this.parts,
      this.onyomiWords,
      this.kunyomiWords,
      this.isFaved = false})
      : assert((grade >= 0 && grade <= 7)),
        assert(jlpt >= 0 && jlpt <= 5),
        assert(strokes != 0),
        assert(frequency >= 0);

  Map toMap() => {
        'grade': this.grade,
        'jlpt': this.jlpt,
        'kanji': this.kanji,
        'frequency': this.frequency,
        'onyomi': this.onyomi,
        'kunyomi': this.kunyomi,
        'strokes': this.strokes,
        'parts': this.parts,
        'meaning': this.meaning,
        'kunyomiWords': this.kunyomiWords,
        'onyomiWords': this.onyomiWords
      };

  Kanji.fromMap(Map map) {
    kanji = map['kanji'];
    meaning = map['meaning'];
    strokes = map['strokes'];
    grade = map['grade'];
    jlpt = map['jlpt'];
    frequency = map['frequency'];
    parts = ((map['pars'] as List) ?? []).cast<String>();
    kunyomi = (map['kunyomi'] as List ?? []).cast<String>();
    kunyomiWords = (map['kunyomiWords'] as List ?? []).cast<String>().map((str) => Word.fromString(str)).toList();
    onyomi = (map['onyomi'] as List ?? []).cast<String>();
    onyomiWords = (map['onyomiWords'] as List ?? []).cast<String>().map((str) => Word.fromString(str)).toList();
  }

  Map<String, dynamic> toDBMap() => {
        'id': id,
        'grade': this.grade,
        'jlpt': this.jlpt,
        'kanji': this.kanji,
        'frequency': this.frequency,
        'onyomi': jsonEncode(this.onyomi),
        'kunyomi': jsonEncode(this.kunyomi),
        'strokes': this.strokes,
        'parts': jsonEncode(this.parts),
        'meaning': this.meaning,
        'kunyomiWords': jsonEncode(this.kunyomiWords.map((word) => word.toMap()).toList()),
        'onyomiWords': jsonEncode(this.onyomiWords.map((word) => word.toMap()).toList()),
        'studiedTimeStamps': jsonEncode(this.timeStamps)
      };

  Kanji.fromDBMap(Map map) {
    id = map['id'];
    kanji = map['kanji'];
    meaning = map['meaning'];
    strokes = map['strokes'];
    grade = map['grade'];
    jlpt = map['jlpt'];
    frequency = map['frequency'];
    parts = (jsonDecode(map['parts']) as List).cast<String>();
    kunyomi = (jsonDecode(map['kunyomi']) as List).cast<String>();
    //print(jsonDecode(map['kunyomiWords']));
    kunyomiWords = (jsonDecode(map['kunyomiWords']) as List).map((str) => Word.fromMap(str)).toList();
    onyomi = (jsonDecode(map['onyomi']) as List).cast<String>();
    onyomiWords = (jsonDecode(map['onyomiWords']) as List).map((str) => Word.fromMap(str)).toList();
    timeStamps = (jsonDecode(map['studiedTimeStamps'] ?? '[]') as List).cast<int>();
  }

  String toString(){
    return 'Instance of Kanji: $kanji, meaning: $meaning';
  }
}

int jlptToIntConverter(JLPTLevel jlpt) {
  switch (jlpt) {
    case JLPTLevel.n1:
      return 1;
    case JLPTLevel.n2:
      return 2;
    case JLPTLevel.n3:
      return 3;
    case JLPTLevel.n4:
      return 4;
    case JLPTLevel.n5:
      return 5;
  }
  return 0;
}
