import 'kanji.dart';
import 'question.dart';
import 'quiz_result.dart';

export 'question.dart';

class Quiz {
  final List<Kanji> targetedKanjis;
  List<Question> questions;

  int _currentQuestionIndex = 0;

  int get questionsCount => questions.length;

  Question get currentQuestion => questions[_currentQuestionIndex];

  Quiz({this.targetedKanjis}) {
    questions = <Question>[];

    for (var i = 0; i < questionsCount; i++) {
      questions[i] = Question(targetedKanji: targetedKanjis[i]);
    }
  }

  Quiz.from(List<Question> questions)
      : targetedKanjis = questions.map((q) => q.targetedKanji).toList() {
    this.questions = questions..shuffle();
  }

  ///Submit user's answer to the current question.
  bool submitAnswer(int selected) {
    questions[_currentQuestionIndex].selected = selected;

    ++_currentQuestionIndex;

    return _currentQuestionIndex < questions.length;
  }

  QuizResult getQuizResult() => QuizResult(questions: questions);

  Question operator [](int index) => questions[index];
}
