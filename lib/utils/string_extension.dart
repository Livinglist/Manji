extension StringExtension on String {
  ///Get whether or not this string is a Chinese character.
  ///Length of the string must be 1.
  bool isKanji() {
    if (length == 1) {
      if (codeUnitAt(0) > 12543) return true;
      return false;
    } else {
      throw Exception("The length of String must be exactly 1.");
    }
  }

  bool isAllKanji() {
    for (var i in Iterable.generate(length)) {
      if (codeUnitAt(i) < 12543) {
        return false;
      }
    }
    return true;
  }

  bool isAllLatin() {
    for (var i in Iterable.generate(length)) {
      if (codeUnitAt(i) < 65 || codeUnitAt(i) > 122) {
        return false;
      }
    }
    return true;
  }

  ///Get all the kanjis in the string.
  List<String> getKanjis() {
    final kanjis = <String>[];
    for (var i = 0; i < length; i++) {
      if (codeUnitAt(i) > 12543 && kanjis.contains(this[i]) == false) {
        kanjis.add(this[i]);
      }
    }
    return kanjis;
  }

  String toKatakana() {
    var str = '';

    for (var i in Iterable.generate(length)) {
      final code = codeUnitAt(i);
      str += String.fromCharCode(code + 96);
    }

    return str;
  }

  String toHiragana() {
    var str = '';

    for (var i in Iterable.generate(length)) {
      final code = codeUnitAt(i);
      str += String.fromCharCode(code - 96);
    }

    return str;
  }

  bool isHiragana() {
    if (codeUnitAt(0) >= 12353 && codeUnitAt(0) <= 12447) return true;
    return false;
  }

  bool isKatakana() {
    if (codeUnitAt(0) >= 12448 && codeUnitAt(0) <= 12543) return true;
    return false;
  }
}
