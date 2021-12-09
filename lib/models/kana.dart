abstract class Kana {
  final String kana;
  final String pron;

  Kana({required this.kana, required this.pron});

  Kana.fromMap(Map map)
      : kana = map['Kana'],
        pron = map['Pron'];
}

class Hiragana extends Kana {
  String get hiragana => super.kana;

  String get pron => super.pron;

  Hiragana({required String hiragana, required String pron})
      : super(kana: hiragana, pron: pron);

  Hiragana.fromMap(Map map) : super.fromMap(map);
}

class Katakana extends Kana {
  String get katakana => super.kana;

  String get pron => super.pron;

  Katakana({required String katakana, required String pron})
      : super(kana: katakana, pron: pron);

  Katakana.fromMap(Map map) : super.fromMap(map);
}
