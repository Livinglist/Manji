import 'kanji.dart';

class Question {
  final Kanji targetedKanji;
  String rightAnswer;
  List<String> wrongAnswers;

  bool _isCorrect;
  bool get isCorrect => _isCorrect;

  int _selected;
  int get selected => _selected;
  set selected(int selected) {
    _selected = selected;

    if (choices[selected] == rightAnswer)
      _isCorrect = true;
    else
      _isCorrect = false;
  }

  List<String> _choices;
  List<String> get choices => _choices;

  Question({this.targetedKanji}) {
    this.rightAnswer = targetedKanji.onyomi.isNotEmpty ? targetedKanji.onyomi.first : "NO ONOMI";
    this.wrongAnswers = ['a', 'b', 'c'];

    _choices = [...wrongAnswers, rightAnswer]..shuffle();
  }
}
