import 'package:flutter/foundation.dart';
import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import 'package:rxdart/rxdart.dart';

import 'package:kanji_dictionary/models/kanji.dart';
import 'package:kanji_dictionary/models/quiz.dart';

class QuizBloc {
  final _quizFetcher = BehaviorSubject<Quiz>();

  Stream<Quiz> get quiz => _quizFetcher.stream;

  void generateQuiz(List<Kanji> kanjis) {
    var questions = List<Question>(kanjis.length);

    for (int i = 0; i < kanjis.length; i++) {
      questions[i] = Question(targetedKanji: kanjis[i]);
    }

    var quiz = Quiz.from(questions);

    _quizFetcher.sink.add(quiz);
  }

  List<Kanji> generateQuizFromJLPT(int jlpt) {
    var kanjis = kanjiBloc.allKanjisList.where((kanji) => kanji.jlpt == jlpt).toList();
    compute<List<Kanji>, Quiz>(generate, kanjis).then((quiz) {
      _quizFetcher.sink.add(quiz);
    });
    return kanjis;
  }

  dispose() {
    _quizFetcher.close();
  }
}

Quiz generate(List<Kanji> kanjis) {
  var questions = List<Question>(kanjis.length);

  for (int i = 0; i < kanjis.length; i++) {
    questions[i] = Question(targetedKanji: kanjis[i]);
  }

  var quiz = Quiz.from(questions);

  return quiz;
}
