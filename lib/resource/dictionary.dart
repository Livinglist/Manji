import 'package:kanji_dictionary/models/kanji.dart';
import 'package:kanji_dictionary/resource/repository.dart';

class Dictionary {
  final List<Kanji> kanjis;

  Dictionary({required this.kanjis});
}

class DictionaryRepository {
  DictionaryRepository(){
    repo.getAllKanjisFromDB().then((kanjis) {
      if (kanjis.isNotEmpty) {
        _allKanjisMap = Map.fromEntries(
            kanjis.map((kanji) => MapEntry(kanji.kanji, kanji)));
        _allKanjisFetcher.sink.add(_allKanjisMap.values.toList());
        getRandomKanji();

        final allFavKanjiStrs = repo.getAllFavKanjiStrs();
        _allFavKanjisMap = Map.fromEntries(
            allFavKanjiStrs.map((str) => MapEntry(str, _allKanjisMap[str])));
        _allFavKanjisFetcher.sink.add(_allFavKanjisMap.values.toList());

        final allStarKanjiStrs = repo.getAllStarKanjiStrs();
        _allStarKanjisMap = Map.fromEntries(
            allStarKanjiStrs.map((str) => MapEntry(str, _allKanjisMap[str])));
        _allStarKanjisFetcher.sink.add(_allStarKanjisMap.values.toList());
      }
    });
  }
}
