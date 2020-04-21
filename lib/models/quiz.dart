import 'kanji.dart';
import 'question.dart';
import 'quiz_result.dart';

export 'question.dart';

class Quiz {
  final List<Kanji> targetedKanjis;
  List<Question> questions;

  int _currentQuestionIndex = 0;

  int get questionsCount => targetedKanjis.length;

  Question get currentQuestion => questions[_currentQuestionIndex];

  Quiz({this.targetedKanjis}) {
    questions = List<Question>(targetedKanjis.length);

    for (int i = 0; i < questionsCount; i++) {
      questions[i] = Question(targetedKanji: targetedKanjis[i]);
    }
  }

  Quiz.from(List<Question> questions) : this.targetedKanjis = questions.map((q) => q.targetedKanji).toList() {
    this.questions = questions;
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
