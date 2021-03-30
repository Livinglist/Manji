import 'package:rxdart/rxdart.dart';

import '../models/word.dart';
import '../resource/repository.dart';

export '../models/kanji.dart';
export '../models/sentence.dart';
export '../models/word.dart';

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
