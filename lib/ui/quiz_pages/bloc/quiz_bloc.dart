import 'dart:math' show Random;

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

  List<Kanji> generateQuizFromJLPT(int jlpt, {int amount = 0}) {
    var kanjis = kanjiBloc.allKanjisList.where((kanji) => kanji.jlpt == jlpt).toList();
    print(amount);
    if (amount != 0 && amount <= kanjis.length) {
      var start = Random(DateTime.now().millisecondsSinceEpoch).nextInt(kanjis.length - amount);
      kanjis = kanjis.sublist(start, start + amount);
    }
    compute<List<Kanji>, Quiz>(generate, kanjis).then((quiz) {
      if (_quizFetcher.isClosed == false) _quizFetcher.sink.add(quiz);
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
