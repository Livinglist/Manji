import 'package:rxdart/rxdart.dart';

import '../models/question.dart';
import '../resource/repository.dart';

export '../models/question.dart';

class IqBloc {
  final _iqFetcher = BehaviorSubject<List<Question>>();

  List<Question> _qs = [];
  Stream<List<Question>> get incorrectQuestions => _iqFetcher.stream;

  List<Kanji> get kanjisContainedInQuiz =>
      _qs.map((q) => q.targetedKanji).toList();

  void getAllIncorrectQuestions() {
    repo.getIncorrectQuestions().then((qs) {
      _qs = qs;
      _iqFetcher.sink.add(_qs);
    });
  }

  void addIncorrectQuestions(List<Question> questions) {
    repo.addIncorrectQuestions(questions).whenComplete(() {
      print("complete");
      print(questions);
      _qs.addAll(questions);
      _iqFetcher.sink.add(_qs);
    });
  }

  void deleteIncorrectQuestion(Question question) {
    repo.deleteIncorrectQuestion(question).whenComplete(() {
      _qs.remove(question);
      _iqFetcher.sink.add(_qs);
    });
  }

  void deleteAllIncorrectQuestions() {
    for (var q in _qs) {
      repo.deleteIncorrectQuestion(q);
    }
    _qs.clear();
    _iqFetcher.sink.add(_qs);
  }

  void dispose() {
    _iqFetcher.close();
  }
}

final iqBloc = IqBloc();
