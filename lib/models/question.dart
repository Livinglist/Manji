import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import '../resource/constants.dart';
import 'kanji.dart';

enum QuestionType {
  kanjiToKatakana, //choose the correct katakana for the kanji
  kanjiToMeaning, //choose the correct meaning for the kanji
  kanjiToHiragana,
  meaningToKanji, //choose the correct kanji for the meaning
  yomikataToKanji //choose the correct kanji for the pronunciation
}

class Question {
  int id;

  final Kanji targetedKanji;
  String rightAnswer;
  List<String> wrongAnswers = [];

  bool _isCorrect;

  bool get isCorrect => _isCorrect;

  int _selected;

  int get selected => _selected;

  set selected(int selected) {
    _selected = selected;

    if (choices[selected] == rightAnswer) {
      _isCorrect = true;
    } else {
      _isCorrect = false;
    }
  }

  List<String> _choices;

  List<String> get choices => _choices;

  final QuestionType questionType;

  Question(
      {this.targetedKanji,
      this.questionType = QuestionType.kanjiToKatakana,
      List<String> mockChoices})
      : assert(questionType != QuestionType.kanjiToMeaning ||
            (questionType == QuestionType.kanjiToMeaning &&
                mockChoices != null &&
                mockChoices.isNotEmpty &&
                mockChoices.length == 3)) {
    switch (questionType) {
      case QuestionType.kanjiToKatakana:
        generateKanjiToKatakanaChoices();
        break;
      case QuestionType.kanjiToMeaning:
        generateKanjiToMeaningChoices(mockChoices);
        break;
      case QuestionType.kanjiToHiragana:
        generateKanjiToHiraganaChoices(mockChoices);
        break;
      case QuestionType.meaningToKanji:
        generateKanjiToKatakanaChoices();
        break;
      case QuestionType.yomikataToKanji:
        generateKanjiToKatakanaChoices();
        break;
      default:
        break;
    }
  }

  Question.from(Question question)
      : targetedKanji = question.targetedKanji,
        questionType = question.questionType {
    _choices = question.choices;
    _selected = question.selected;
    rightAnswer = question.rightAnswer;
  }

  Question.fromMap(Map map)
      : id = map[Keys.idKey],
        targetedKanji = map[Keys.kanjiKey],
        _choices = (jsonDecode(map[Keys.choicesKey]) as List).cast<String>(),
        rightAnswer = map[Keys.rightAnswerKey],
        _selected = map[Keys.selectedIndexKey],
        questionType =
            QuestionType.values.elementAt(map[Keys.questionTypeKey] ?? 0);

  void generateKanjiToKatakanaChoices() {
    String targetedKana;
    if (targetedKanji.onyomi.isNotEmpty) {
      final candidates = targetedKanji.onyomi
              .where((e) => e.contains(RegExp(r'[.-]')) == false)
              ?.toList() ??
          [];
      candidates.shuffle(Random(DateTime.now().millisecondsSinceEpoch));
      targetedKana = candidates.first;
    } else {
      targetedKana = targetedKanji.kunyomi.first;
    }
    rightAnswer = targetedKana;
    final firstKana = targetedKana[0];
    if (kanaShiftMap.containsKey(firstKana)) {
      final shiftableKanas = List<String>.from(kanaShiftMap[firstKana])
        ..remove(firstKana);
      final tempKanas = <String>[];
      var pos = -1;
      for (var i = 0; i < 3; i++) {
        while (pos == -1 || tempKanas.contains(shiftableKanas[pos])) {
          pos = Random(DateTime.now().millisecondsSinceEpoch)
              .nextInt(shiftableKanas.length);
        }
        tempKanas.add(shiftableKanas.elementAt(pos));
        wrongAnswers.add(
            rightAnswer.replaceFirst(firstKana, shiftableKanas.elementAt(pos)));
      }
    }

    _choices = [rightAnswer, ...wrongAnswers]..shuffle();
  }

  void generateKanjiToMeaningChoices(List<String> mockChoices) {
    final targetedMeaning = targetedKanji.meaning;
    rightAnswer = targetedMeaning;

    wrongAnswers.addAll(mockChoices);

    _choices = [rightAnswer, ...wrongAnswers]..shuffle();
  }

  void generateKanjiToHiraganaChoices(List<String> mockChoices) {
    var targetedHiragana = targetedKanji.kunyomi.toString();
    targetedHiragana = targetedKanji.kunyomi
        .toString()
        .substring(1, targetedHiragana.length - 1);
    rightAnswer = targetedHiragana;

    wrongAnswers.addAll(mockChoices);

    _choices = [rightAnswer, ...wrongAnswers]..shuffle();
  }

  List<String> getShiftableKana(String kana) {
    return List.from(kanaShiftMap[kana])..remove(kana);
  }

  Map<String, dynamic> toMap() => {
        Keys.kanjiIdKey: targetedKanji.id,
        Keys.choicesKey: jsonEncode(_choices),
        Keys.rightAnswerKey: rightAnswer,
        Keys.selectedIndexKey: _selected,
        Keys.questionTypeKey: questionType.index
      };

  String toString() =>
      "kanji: $targetedKanji, choices: $_choices, selected: $_selected";
}

const List<String> hiraganaA = [
  "あ",
  "か",
  "が",
  "さ",
  "ざ",
  "た",
  "だ",
  "な",
  "は",
  "ぱ",
  "ば",
  "ま",
  "や",
  "ら",
  "わ"
];
const List<String> hiraganaI = [
  "い",
  "き",
  "ぎ",
  "し",
  "じ",
  "ち",
  "に",
  "ひ",
  "び",
  "ぴ",
  "み",
  "り"
];
const List<String> hiraganaU = [
  "う",
  "ぐ",
  "く",
  "す",
  "ず",
  "ぬ",
  "ふ",
  "ぶ",
  "ぷ",
  "む",
  "ゆ",
  "る",
  "つ"
];
const List<String> hiraganaE = [
  "え",
  "け",
  "げ",
  "せ",
  "ぜ",
  "て",
  "で",
  "ね",
  "へ",
  "べ",
  "ぺ",
  "れ",
  "め"
];
const List<String> hiraganaO = [
  "お",
  "こ",
  "ご",
  "そ",
  "ぞ",
  "と",
  "ど",
  "の",
  "ほ",
  "ぼ",
  "ぽ",
  "も",
  "よ",
  "ろ",
  "を"
];

const List<String> katakanaA = [
  "ア",
  "カ",
  "ガ",
  "サ",
  "ザ",
  "タ",
  "ダ",
  "ナ",
  "ハ",
  "パ",
  "バ",
  "マ",
  "ヤ",
  "ラ",
  "ワ"
];
const List<String> katakanaI = [
  "イ",
  "キ",
  "ギ",
  "シ",
  "ジ",
  "チ",
  "ニ",
  "ヒ",
  "ビ",
  "ピ",
  "ミ",
  "リ"
];
const List<String> katakanaU = [
  "ウ",
  "グ",
  "ク",
  "ス",
  "ズ",
  "ヌ",
  "フ",
  "ブ",
  "プ",
  "ム",
  "ユ",
  "ル",
  "ツ"
];
const List<String> katakanaE = [
  "エ",
  "ケ",
  "ゲ",
  "セ",
  "ゼ",
  "テ",
  "デ",
  "ネ",
  "ヘ",
  "ベ",
  "ペ",
  "レ",
  "メ"
];
const List<String> katakanaO = [
  "オ",
  "コ",
  "ゴ",
  "ソ",
  "ゾ",
  "ト",
  "ド",
  "ノ",
  "ホ",
  "ボ",
  "ポ",
  "モ",
  "ヨ",
  "ロ",
  "ヲ"
];

final HashMap<String, List<String>> kanaShiftMap = HashMap.fromEntries([
  ...hiraganaA.map((kana) => MapEntry<String, List<String>>(kana, hiraganaA)),
  ...hiraganaI.map((kana) => MapEntry<String, List<String>>(kana, hiraganaI)),
  ...hiraganaU.map((kana) => MapEntry<String, List<String>>(kana, hiraganaU)),
  ...hiraganaE.map((kana) => MapEntry<String, List<String>>(kana, hiraganaE)),
  ...hiraganaO.map((kana) => MapEntry<String, List<String>>(kana, hiraganaO)),
  ...katakanaA.map((kana) => MapEntry<String, List<String>>(kana, katakanaA)),
  ...katakanaI.map((kana) => MapEntry<String, List<String>>(kana, katakanaI)),
  ...katakanaU.map((kana) => MapEntry<String, List<String>>(kana, katakanaU)),
  ...katakanaE.map((kana) => MapEntry<String, List<String>>(kana, katakanaE)),
  ...katakanaO.map((kana) => MapEntry<String, List<String>>(kana, katakanaO)),
]);
