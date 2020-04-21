import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'kanji.dart';

const String idKey = "id";
const String kanjiKey = "kanji";
const String kanjiIdKey = "kanjiId";
const String rightAnswerKey = "rightAnswer";
const String choicesKey = "choices";
const String selectedIndexKey = "selectedIndex";

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

    if (choices[selected] == rightAnswer)
      _isCorrect = true;
    else
      _isCorrect = false;
  }

  List<String> _choices;
  List<String> get choices => _choices;

  Question({this.targetedKanji}) {
    generateChoices();
  }

  Question.from(Question question) : targetedKanji = question.targetedKanji {
    _choices = question.choices;
    _selected = question.selected;
    rightAnswer = question.rightAnswer;
  }

  Question.fromMap(Map map)
      : id = map[idKey],
        targetedKanji = map[kanjiKey],
        _choices = (jsonDecode(map[choicesKey]) as List).cast<String>(),
        rightAnswer = map[rightAnswerKey],
        _selected = map[selectedIndexKey];

  ///Currently this only generates questions for those kanji that have Onyomi.
  ///Todo: generate questions for kanji with Kunyomi
  void generateChoices() {
    String targetedKana;
    if (targetedKanji.onyomi.isNotEmpty) {
      var candidates = targetedKanji.onyomi.where((e) => e.contains(RegExp(r'[.-]')) == false)?.toList() ?? [];
      candidates.shuffle(Random(DateTime.now().millisecondsSinceEpoch));
      targetedKana = candidates.first;
    } else {
      targetedKana = targetedKanji.kunyomi.first;
    }
    rightAnswer = targetedKana;
    var firstKana = targetedKana[0];
    if (kanaShiftMap.containsKey(firstKana)) {
      List<String> shiftableKanas = List.from(kanaShiftMap[firstKana])..remove(firstKana);
      List<String> tempKanas = [];
      int pos = -1;
      for (int i = 0; i < 3; i++) {
        while (pos == -1 || tempKanas.contains(shiftableKanas[pos])) {
          pos = Random(DateTime.now().millisecondsSinceEpoch).nextInt(shiftableKanas.length);
        }
        tempKanas.add(shiftableKanas.elementAt(pos));
        wrongAnswers.add(rightAnswer.replaceFirst(firstKana, shiftableKanas.elementAt(pos)));
      }
    }

    _choices = [rightAnswer, ...wrongAnswers]..shuffle();
  }

  List<String> getShiftableKana(String kana) {
    return List.from(kanaShiftMap[kana])..remove(kana);
  }

  Map<String, dynamic> toMap() =>
      {kanjiIdKey: targetedKanji.id, choicesKey: jsonEncode(_choices), rightAnswerKey: rightAnswer, selectedIndexKey: _selected};

  String toString() => "kanji: ${this.targetedKanji}, choices: ${this._choices}, selected: ${this._selected}";
}

const List<String> hiraganaA = const ["あ", "か", "が", "さ", "ざ", "た", "だ", "な", "は", "ぱ", "ば", "ま", "や", "ら", "わ"];
const List<String> hiraganaI = const ["い", "き", "ぎ", "し", "じ", "ち", "に", "ひ", "び", "ぴ", "み", "り"];
const List<String> hiraganaU = const ["う","ぐ", "く", "す", "ず", "ぬ", "ふ", "ぶ", "ぷ", "む", "ゆ", "る", "つ"];
const List<String> hiraganaE = const ["え", "け", "げ", "せ", "ぜ", "て", "で", "ね", "へ", "べ", "ぺ", "れ", "め"];
const List<String> hiraganaO = const ["お", "こ", "ご", "そ", "ぞ", "と", "ど", "の", "ほ", "ぼ", "ぽ", "も", "よ", "ろ", "を"];

const List<String> katakanaA = const ["ア", "カ", "ガ", "サ", "ザ", "タ", "ダ", "ナ", "ハ", "パ", "バ", "マ", "ヤ", "ラ", "ワ"];
const List<String> katakanaI = const ["イ", "キ", "ギ", "シ", "ジ", "チ", "ニ", "ヒ", "ビ", "ピ", "ミ", "リ"];
const List<String> katakanaU = const ["ウ","グ", "ク", "ス", "ズ", "ヌ", "フ", "ブ", "プ", "ム", "ユ", "ル", "ツ"];
const List<String> katakanaE = const ["エ", "ケ", "ゲ", "セ", "ゼ", "テ", "デ", "ネ", "ヘ", "ベ", "ペ", "レ", "メ"];
const List<String> katakanaO = const ["オ", "コ", "ゴ", "ソ", "ゾ", "ト", "ド", "ノ", "ホ", "ボ", "ポ", "モ", "ヨ", "ロ", "ヲ"];

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
