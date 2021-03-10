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
    compute<List<Kanji>, Quiz>(generate, kanjis).then((quiz) {
      if (_quizFetcher.isClosed == false) _quizFetcher.sink.add(quiz);
    });
  }

  List<Kanji> generateQuizFromJLPT(int jlpt, {int amount = 0}) {
    var kanjis = KanjiBloc.instance.allKanjisList.where((kanji) => kanji.jlpt == jlpt).toList();
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
  var questions = <Question>[];

  if (kanjis.length < 4) {
    for (int i = 0; i < kanjis.length; i++) {
      questions.add(Question(targetedKanji: kanjis[i]));
    }
  } else {
    for (int i = 0; i < kanjis.length; i++) {
      //KanjiToKatakana
      questions.add(Question(targetedKanji: kanjis[i]));

      //KanjiToMeaning
      var random = Random(DateTime.now().millisecondsSinceEpoch + i).nextInt(kanjis.length - 2);
      while (random == i || (i - random <= 2 && i - random > 0)) {
        random = Random(DateTime.now().millisecondsSinceEpoch + i).nextInt(kanjis.length - 2);
      }
      var a = kanjis[random].meaning;
      var b = kanjis[random + 1].meaning;
      var c = kanjis[random + 2].meaning;

      questions.add(Question(targetedKanji: kanjis[i], mockChoices: [a, b, c], questionType: QuestionType.KanjiToMeaning));

      //KanjiToHiragana
      random = Random(DateTime.now().millisecondsSinceEpoch + i).nextInt(kanjis.length - 2);
      while (random == i || (i - random <= 2 && i - random > 0)) {
        print('i: $i random: $random');
        random = Random(DateTime.now().millisecondsSinceEpoch + i).nextInt(kanjis.length - 2);
      }
      a = kanjis[random].kunyomi.isEmpty ? '[すき]' : kanjis[random].kunyomi.toString();
      a = a.substring(1, a.length - 1);
      b = kanjis[random + 1].kunyomi.isEmpty ? '[すき]' : kanjis[random + 1].kunyomi.toString();
      b = b.substring(1, b.length - 1);
      c = kanjis[random + 2].kunyomi.isEmpty ? '[すき]' : kanjis[random + 2].kunyomi.toString();
      c = c.substring(1, c.length - 1);

      questions.add(Question(targetedKanji: kanjis[i], mockChoices: [a, b, c], questionType: QuestionType.KanjiToHiragana));
    }
  }

  var quiz = Quiz.from(questions);

  return quiz;
}
