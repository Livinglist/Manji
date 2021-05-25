import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../bloc/incorrect_question_bloc.dart';
import '../../bloc/kanji_bloc.dart';
import '../../bloc/quiz_bloc.dart';
import '../../models/kanji_list.dart';
import '../../models/quiz.dart';
import '../../models/quiz_result.dart';
import '../../resource/constants.dart';
import 'components/correct_question_list_tile.dart';
import 'components/incorrect_question_list_tile.dart';

class QuizDetailPage extends StatefulWidget {
  final List<Kanji> kanjis;
  final KanjiList kanjiList;
  final int jlpt;
  final int jlptAmount;

  QuizDetailPage({this.kanjiList, this.kanjis, this.jlpt, this.jlptAmount})
      : assert((kanjiList != null && kanjiList.kanjiStrs.isNotEmpty) ||
            (kanjis != null && kanjis.isNotEmpty) ||
            jlpt != null),
        assert((jlpt != null && jlptAmount != null) || jlpt == null);

  @override
  _QuizDetailPageState createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  final confettiController =
      ConfettiController(duration: const Duration(seconds: 6));
  final scrollController = ScrollController();
  final quizBloc = QuizBloc();
  bool showShadow = false;

  int currentIndex = 0;
  int total;

  bool showResult = false, confettiPlayed = false;
  QuizResult quizResult;

  @override
  void initState() {
    super.initState();

    var kanjis = <Kanji>[];
    if (widget.kanjis != null) {
      kanjis = widget.kanjis;
      quizBloc.generateQuiz(kanjis);
    } else if (widget.kanjiList != null) {
      for (var kanjiString in widget.kanjiList.kanjiStrs) {
        kanjis.add(KanjiBloc.instance.allKanjisMap[kanjiString]);
      }
      quizBloc.generateQuiz(kanjis);
    } else {
      kanjis =
          quizBloc.generateQuizFromJLPT(widget.jlpt, amount: widget.jlptAmount);
    }

    total = kanjis.length;

    scrollController.addListener(() {
      if (mounted) {
        if (scrollController.offset <= 0) {
          setState(() {
            showShadow = false;
          });
        } else if (showShadow == false) {
          setState(() {
            showShadow = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    quizBloc.dispose();
    scrollController.dispose();
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((context) {
      if (showResult &&
          (quizResult?.percentage ?? 0) >= 90 &&
          confettiPlayed == false) {
        confettiController.play();
        confettiPlayed = true;
      }
    });

    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
            elevation: showShadow ? 8 : 0,
            actions: <Widget>[
              StreamBuilder(
                stream: quizBloc.quiz,
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                        padding: const EdgeInsets.all(12),
                        child: Center(
                            child: Text(
                                '$currentIndex/${snapshot.data.questionsCount}',
                                style: const TextStyle(fontSize: 18))));
                  }
                  return Container();
                },
              )
            ],
            bottom: PreferredSize(
                child: StreamBuilder(
                  stream: quizBloc.quiz,
                  builder: (_, snapshot) {
                    if (snapshot.hasData) {
                      return showResult
                          ? Container()
                          : Stack(
                              children: <Widget>[
                                LinearProgressIndicator(
                                    value: currentIndex /
                                        snapshot.data.questionsCount,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.blueGrey),
                                    backgroundColor: Colors.grey),
                              ],
                            );
                    }
                    return Stack(
                      children: const <Widget>[
                        LinearProgressIndicator(
                            value: 0.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                            backgroundColor: Colors.grey),
                      ],
                    );
                  },
                ),
                preferredSize: const Size.fromHeight(0))),
        body: showResult ? buildResultView() : buildQuizView());
  }

  Widget buildResultView() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            ListView(
              controller: scrollController,
              children: <Widget>[
                Container(
                  height: 220,
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "${quizResult.percentage.toStringAsFixed(0)}%",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 96),
                      ),
                      Icon(getCharm(quizResult.percentage),
                          color: Colors.white, size: 90)
                    ],
                  )),
                ),
                Row(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(FontAwesomeIcons.timesCircle,
                          color: Colors.white),
                    ),
                    Text("Incorrect: ${quizResult.totalIncorrect}",
                        style: const TextStyle(color: Colors.white)),
                    const Spacer(),
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(FontAwesomeIcons.checkCircle,
                          color: Colors.white),
                    ),
                    Text("Correct: ${quizResult.totalCorrect}",
                        style: const TextStyle(color: Colors.white)),
                    const SizedBox(width: 12)
                  ],
                ),
                ...quizResult.incorrectQuestions
                    .map((question) =>
                        IncorrectQuestionListTile(question: question))
                    .toList(),
                ...quizResult.correctQuestions
                    .map((question) =>
                        CorrectQuestionListTile(question: question))
                    .toList()
              ],
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: confettiController,
                blastDirection: pi / 2,
                maxBlastForce: 5, // set a lower max blast force
                minBlastForce: 2, // set a lower min blast force
                emissionFrequency: 0.05,
                numberOfParticles: 50, // a lot of particles at once
                gravity: 1,
              ),
            ),
          ],
        ));
  }

  Widget buildQuizView() {
    print(MediaQuery.of(context).devicePixelRatio);
    return StreamBuilder(
      stream: quizBloc.quiz,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          final quiz = snapshot.data;

          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Flex(
              mainAxisSize: MainAxisSize.min,
              direction: Axis.vertical,
              children: <Widget>[
                Flexible(
                  flex: 2,
                  child: Container(
                    child: Center(
                        child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(quiz.currentQuestion.targetedKanji.kanji,
                                style: TextStyle(
                                    fontSize: 128,
                                    color: Colors.white,
                                    fontFamily: Fonts.kazei)),
                            Text(quiz.currentQuestion.targetedKanji.kanji,
                                style: TextStyle(
                                    fontSize: 128,
                                    color: Colors.white,
                                    fontFamily: Fonts.ming)),
                          ],
                        ),
                      ],
                    )),
                  ),
                ),
                if (quiz.currentQuestion.questionType ==
                        QuestionType.kanjiToMeaning ||
                    quiz.currentQuestion.questionType ==
                        QuestionType.kanjiToHiragana)
                  Flexible(
                      flex: 4,
                      child: ListView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: List.generate(
                              quiz.currentQuestion.choices.length, (index) {
                            return Padding(
                                padding: const EdgeInsets.all(12),
                                child: Material(
                                  elevation: 4,
                                  child: Ink(
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          currentIndex++;
                                          if (quiz.submitAnswer(index) ==
                                              false) {
                                            showResult = true;
                                            quizResult = quiz.getQuizResult();
                                            iqBloc.addIncorrectQuestions(
                                                quizResult.incorrectQuestions);
                                          }
                                        });
                                      },
                                      child: Container(
                                        height: 72,
                                        child: Center(
                                            child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Text(
                                            quiz.currentQuestion.choices[index],
                                            style:
                                                const TextStyle(fontSize: 18),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )),
                                      ),
                                    ),
                                  ),
                                ));
                          }))),
                if (quiz.currentQuestion.questionType ==
                    QuestionType.kanjiToKatakana)
                  Flexible(
                      flex: 4,
                      child: Container(
                        constraints:
                            const BoxConstraints(maxWidth: 640, maxHeight: 640),
                        child: GridView.count(
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            childAspectRatio: 1,
                            children: List.generate(
                                quiz.currentQuestion.choices.length, (index) {
                              return Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Material(
                                    elevation: 4,
                                    child: Ink(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            currentIndex++;
                                            if (quiz.submitAnswer(index) ==
                                                false) {
                                              showResult = true;
                                              quizResult = quiz.getQuizResult();
                                              iqBloc.addIncorrectQuestions(
                                                  quizResult
                                                      .incorrectQuestions);
                                            }
                                          });
                                        },
                                        child: Container(
                                          child: Center(
                                            child: Text(
                                                quiz.currentQuestion
                                                    .choices[index],
                                                style: const TextStyle(
                                                    fontSize: 24)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ));
                            })),
                      ))
              ],
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  IconData getCharm(double percentage) {
    if (percentage == 100) {
      return FontAwesomeIcons.award;
    } else if (percentage >= 95) {
      return FontAwesomeIcons.badgeCheck;
    } else if (percentage >= 90) {
      return FontAwesomeIcons.certificate;
    } else if (percentage >= 80) {
      return FontAwesomeIcons.dragon;
    } else {
      return FontAwesomeIcons.bookReader;
    }
  }
}
