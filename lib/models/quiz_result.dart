import 'question.dart';

class QuizResult {
  final List<Question> questions;
  double get percentage => (totalCorrect / questions.length) * 100;
  int get totalCorrect => questions.where((e) => e.isCorrect).length;
  int get totalIncorrect => questions.where((e) => e.isCorrect == false).length;
  List<Question> get correctQuestions =>
      questions.where((e) => e.isCorrect).toList();
  List<Question> get incorrectQuestions =>
      questions.where((e) => e.isCorrect == false).toList();

  QuizResult({this.questions});
}
