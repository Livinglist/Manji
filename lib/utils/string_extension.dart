extension StringExention on String {
  ///Get whether or not this string is a Chinese character.
  ///Length of the string must be 1.
  bool isKanji() {
    if (this.length == 1) {
      if (this.codeUnitAt(0) > 12543) return true;
      return false;
    } else {
      throw Exception("The length of String must be exactly 1.");
    }
  }

  ///Get all the kanjis in the string.
  List<String> getKanjis() {
    var kanjis = <String>[];
    for (int i = 0; i < this.length; i++) {
      if (this.codeUnitAt(i) > 12543) {
        kanjis.add(this[i]);
      }
    }
    return kanjis;
  }
}
