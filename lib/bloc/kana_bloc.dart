import 'package:rxdart/rxdart.dart';

import 'package:kanji_dictionary/resource/repository.dart';

export 'package:kanji_dictionary/models/kana.dart';

class KanaBloc {
  final _hiraganaFetcher = BehaviorSubject<List<Hiragana>>();
  final _katakanaFetcher = BehaviorSubject<List<Katakana>>();

  Stream<List<Hiragana>> get hiragana => _hiraganaFetcher.stream;
  Stream<List<Katakana>> get katakana => _katakanaFetcher.stream;

  void init() {
    repo.getAllKatakana().then((katakanas) {
      if (!_katakanaFetcher.isClosed) _katakanaFetcher.sink.add(katakanas);
    });
    repo.getAllHiragana().then((hiraganas) {
      if (!_hiraganaFetcher.isClosed) _hiraganaFetcher.sink.add(hiraganas);
    });
  }

  void dispose() {
    _hiraganaFetcher.close();
    _katakanaFetcher.close();
  }
}

final kanaBloc = KanaBloc();
