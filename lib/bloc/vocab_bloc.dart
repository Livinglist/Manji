import 'package:rxdart/rxdart.dart';

import 'package:kanji_dictionary/models/word.dart';
import 'package:kanji_dictionary/resource/repository.dart';

export 'package:kanji_dictionary/models/kanji.dart';
export 'package:kanji_dictionary/models/sentence.dart';
export 'package:kanji_dictionary/models/word.dart';

class VocabBloc {
  final _wordsFetcher = BehaviorSubject<List<Word>>();

  List<Word> _words = <Word>[];

  Stream<List<Word>> get words => _wordsFetcher.stream;

  VocabBloc();

  void fetchWordsByKanji(String kanji) async {
    _words.clear();
    repo.fetchWordsByKanji(kanji).listen((word) {
      if (!_wordsFetcher.isClosed) {
        _words.add(word);
        _wordsFetcher.sink.add(_words);
      }
    });
  }

  void dispose() {
    _wordsFetcher.close();
  }
}
