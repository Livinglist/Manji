import '../models/kanji.dart';

export '../models/kanji.dart';

enum ContentType { kanji, meaning, yomi }

class KanjiCardContent {
  final Kanji kanji;
  final ContentType contentType;
  bool isMemorized = false;

  KanjiCardContent({this.kanji, this.contentType});

  String toString() {
    return "${kanji.kanji} $contentType";
  }
}
