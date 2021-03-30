import 'package:flutter/services.dart';

abstract class Kana {
  String kana;
  String pron;
  ByteData byteData;

  Kana({this.kana, this.pron});

  Kana.fromMap(Map map) {
    kana = map['Kana'];
    pron = map['Pron'];
  }
}

class Hiragana extends Kana {
  String get hiragana => super.kana;
  String get pron => super.pron;

  Hiragana({String hiragana, String pron}) : super(kana: hiragana, pron: pron);

  Hiragana.fromMap(Map map) {
    super.kana = map['Kana'];
    super.pron = map['Pron'];
  }
}

class Katakana extends Kana {
  String get katakana => super.kana;
  String get pron => super.pron;

  Katakana({String katakana, String pron}) : super(kana: katakana, pron: pron);

  Katakana.fromMap(Map map) {
    super.kana = map['Kana'];
    super.pron = map['Pron'];
  }
}
