import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:kanji_dictionary/models/kanji_list.dart';
import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import 'package:kanji_dictionary/models/question.dart';
import 'package:kanji_dictionary/models/quiz.dart';
import 'package:kanji_dictionary/models/quiz_result.dart';

class QuizDetailPage extends StatefulWidget {
  final KanjiList kanjiList;

  QuizDetailPage({this.kanjiList}) : assert(kanjiList != null && kanjiList.kanjiStrs.isNotEmpty);

  @override
  _QuizDetailPageState createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  int currentIndex = 0;
  bool showResult = false;
  QuizResult quizResult;
  Quiz quiz;

  @override
  void initState() {
    var kanjis = <Kanji>[];
    for (var kanjiString in widget.kanjiList.kanjiStrs) {
      kanjis.add(kanjiBloc.allKanjisMap[kanjiString]);
    }

    quiz = Quiz(targetedKanjis: kanjis);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(),
      body: showResult
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: Text('Correct: ${quizResult.totalCorrect}\nIncorrect: ${quizResult.totalIncorrect}'),
              ))
          : Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Flex(
                direction: Axis.vertical,
                children: <Widget>[
                  Flexible(
                    flex: 4,
                    child: Container(
                      child: Center(
                        child: Text(quiz.currentQuestion.targetedKanji.kanji),
                      ),
                    ),
                  ),
                  Flexible(
                      flex: 6,
                      child: GridView.count(
                          crossAxisCount: 2,
                          children: List.generate(quiz.currentQuestion.choices.length, (index) {
                            return Padding(
                                padding: EdgeInsets.all(12),
                                child: Material(
                                  child: Ink(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (quiz.submitAnswer(index) == false) {
                                            showResult = true;
                                            quizResult = quiz.getQuizResult();
                                          }
                                        });
                                      },
                                      child: Container(
                                        child: Center(
                                          child: Text(quiz.currentQuestion.choices[index]),
                                        ),
                                      ),
                                    ),
                                  ),
                                ));
                          })))
                ],
              ),
            ),
    );
  }
}
