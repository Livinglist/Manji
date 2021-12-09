import '../models/kanji.dart';

export '../models/kanji.dart';

enum ContentType { kanji, meaning, yomi }

class KanjiCardContent {
  final Kanji kanji;
  final ContentType contentType;
  final bool isMemorized;

  KanjiCardContent({
    required this.kanji,
    required this.contentType,
    required this.isMemorized,
  });

  KanjiCardContent copyWith({bool? isMemorized}) {
    return KanjiCardContent(
      kanji: kanji,
      contentType: contentType,
      isMemorized: isMemorized ?? this.isMemorized,
    );
  }

  String toString() {
    return "${kanji.kanji} $contentType";
  }
}
