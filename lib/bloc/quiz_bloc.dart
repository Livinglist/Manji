import 'dart:math' show Random;

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../bloc/kanji_bloc.dart';
import '../models/kanji.dart';
import '../models/quiz.dart';

class QuizBloc {
  final _quizFetcher = BehaviorSubject<Quiz>();

  Stream<Quiz> get quiz => _quizFetcher.stream;

  void generateQuiz(List<Kanji> kanjis) {
    final quiz = generate(kanjis);
    if (_quizFetcher.isClosed == false) _quizFetcher.sink.add(quiz);
  }

  List<Kanji> generateQuizFromJLPT(int jlpt, {int amount = 0}) {
    var kanjis = KanjiBloc.instance.allKanjisList
        .where((kanji) => kanji.jlpt == jlpt)
        .toList();
    print(amount);
    if (amount != 0 && amount <= kanjis.length) {
      final start = Random(DateTime.now().millisecondsSinceEpoch)
          .nextInt(kanjis.length - amount);
      kanjis = kanjis.sublist(start, start + amount);
    }
    compute<List<Kanji>, Quiz>(generate, kanjis).then((quiz) {
      if (_quizFetcher.isClosed == false) _quizFetcher.sink.add(quiz);
    });
    return kanjis;
  }

  void dispose() {
    _quizFetcher.close();
  }
}

Quiz generate(List<Kanji> kanjis) {
  final questions = <Question>[];

  kanjis.shuffle();

  if (kanjis.length < 4) {
    for (var i = 0; i < kanjis.length; i++) {
      questions.add(Question(targetedKanji: kanjis[i]));
    }
  } else {
    for (var i = 0; i < kanjis.length; i++) {
      //KanjiToKatakana
      questions.add(Question(targetedKanji: kanjis[i]));

      //KanjiToMeaning
      final random = Random(DateTime.now().millisecondsSinceEpoch + i);
      final set = <int>{};
      while (set.length != 3) {
        final index = random.nextInt(kanjis.length);
        if (index != i) set.add(index);
      }

      var indexes = set.toList();
      var a = kanjis[indexes[0]].meaning;
      var b = kanjis[indexes[1]].meaning;
      var c = kanjis[indexes[2]].meaning;

      questions.add(Question(
          targetedKanji: kanjis[i],
          mockChoices: [a, b, c],
          questionType: QuestionType.kanjiToMeaning));

      //KanjiToHiragana
      set.clear();
      while (set.length != 3) {
        final index = random.nextInt(kanjis.length);
        if (index != i) set.add(index);
      }
      indexes = set.toList();
      a = kanjis[indexes[0]].kunyomi.isEmpty
          ? '[すき]'
          : kanjis[indexes[0]].kunyomi.toString();
      a = a.substring(1, a.length - 1);
      b = kanjis[indexes[1]].kunyomi.isEmpty
          ? '[すき]'
          : kanjis[indexes[1]].kunyomi.toString();
      b = b.substring(1, b.length - 1);
      c = kanjis[indexes[2]].kunyomi.isEmpty
          ? '[すき]'
          : kanjis[indexes[2]].kunyomi.toString();
      c = c.substring(1, c.length - 1);

      questions.add(Question(
          targetedKanji: kanjis[i],
          mockChoices: [a, b, c],
          questionType: QuestionType.kanjiToHiragana));
    }
  }

  final quiz = Quiz.from(questions);

  return quiz;
}
