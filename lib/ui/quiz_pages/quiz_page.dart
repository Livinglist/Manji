import 'dart:math' show Random;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../bloc/kanji_bloc.dart';
import '../../bloc/kanji_list_bloc.dart';
import '../../bloc/incorrect_question_bloc.dart';
import '../components/snack_bar_collections.dart';
import 'quiz_detail_page.dart';
import 'incorrect_question_page.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  static final actionTextStyle = TextStyle(color: Colors.blue);
  final scrollController = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool showShadow = false;

  @override
  void initState() {
    super.initState();

    iqBloc.getAllIncorrectQuestions();

    scrollController.addListener(() {
      if (this.mounted) {
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
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: Text('クイズ'),
          elevation: showShadow ? 8 : 0,
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.all(8),
                child: Container(
                  height: kToolbarHeight,
                  child: StreamBuilder(
                      stream: iqBloc.incorrectQuestions,
                      builder: (_, AsyncSnapshot<List<Question>> snapshot) {
                        if (snapshot.hasData) {
                          return Center(
                            child: Text(snapshot.data.length.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 20)),
                          );
                        }
                        return Container();
                      }),
                )),
            IconButton(
              icon: Icon(FontAwesomeIcons.backpack),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => IncorrectQuestionsPage()));
              },
            )
          ],
        ),
        body: StreamBuilder(
          stream: KanjiListBloc.instance.kanjiLists,
          builder: (_, AsyncSnapshot<List<KanjiList>> snapshot) {
            if (snapshot.hasData) {
              var kanjiLists = snapshot.data;

              var children = buildChildren(kanjiLists);

              return ListView(
                controller: scrollController,
                children: <Widget>[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      runSpacing: 12,
                      spacing: 12,
                      children: <Widget>[
                        SizedBox(width: 12),
                        for (var n in [5, 4, 3, 2, 1])
                          ActionChip(
                              elevation: 4,
                              label: Text("N$n"),
                              onPressed: () =>
                                  showJLPTAmountDialog(n, 'N$n Kanji')),
                      ],
                    ),
                  ),
                  if (children.isEmpty)
                    Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: Text(
                          'Your own lists will also show up here (´・ω・`)',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  if (children.isNotEmpty) Divider(height: 0),
                  ...children
                ],
              );
            } else {
              return Container();
            }
          },
        ));
  }

  List<Widget> buildChildren(List<KanjiList> kanjiLists) {
    if (kanjiLists.isEmpty) return [];
    var children = <Widget>[];
    for (var kanjiList in kanjiLists) {
      children.add(ListTile(
        title: Text(
          kanjiList.name,
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          '${kanjiList.kanjiCount} Kanji',
          style: TextStyle(
              color: Theme.of(context).primaryColor == Colors.black
                  ? Colors.white60
                  : Colors.black54),
        ),
        onTap: () {
          if (kanjiList.kanjiCount != 0)
            showAmountDialog(
                kanjiList.kanjiStrs
                    .where((e) => e.length == 1)
                    .map((str) => KanjiBloc.instance.allKanjisMap[str])
                    .toList(),
                kanjiList.name);
          else
            ScaffoldMessenger.of(context)
                .showSnackBar(WarningSnackBar(message: "List is empty."));
        },
      ));
      children.add(Divider(height: 0));
    }

    children.removeLast();

    return children;
  }

  void showJLPTAmountDialog(int jlpt, String title) {
    showCupertinoModalPopup(
        context: context,
        builder: (_) {
          return CupertinoActionSheet(
            title: Text(title),
            actions: <Widget>[
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                QuizDetailPage(jlpt: jlpt, jlptAmount: 0)));
                  },
                  child: Text("All of N$jlpt Kanji", style: actionTextStyle)),
              CupertinoActionSheetAction(
                  onPressed: () => onJLPTAmountPressed(jlpt, 100),
                  child: Text("100 kanji", style: actionTextStyle)),
              CupertinoActionSheetAction(
                  onPressed: () => onJLPTAmountPressed(jlpt, 50),
                  child: Text("50 kanji", style: actionTextStyle)),
              CupertinoActionSheetAction(
                  onPressed: () => onJLPTAmountPressed(jlpt, 20),
                  child: Text("20 kanji", style: actionTextStyle)),
              CupertinoActionSheetAction(
                  onPressed: () => onJLPTAmountPressed(jlpt, 10),
                  child: Text("10 kanji", style: actionTextStyle)),
            ],
            cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel", style: actionTextStyle)),
          );
        });
  }

  void onJLPTAmountPressed(int jlpt, int amount) {
    Navigator.pop(context);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => QuizDetailPage(jlpt: jlpt, jlptAmount: amount)));
  }

  void showAmountDialog(List<Kanji> kanjis, String title) {
    if (kanjis.length <= 20) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => QuizDetailPage(kanjis: kanjis)));
      return;
    }

    showCupertinoModalPopup(
        context: context,
        builder: (_) {
          return CupertinoActionSheet(
            title: Text(title),
            actions: <Widget>[
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => QuizPage()));
                  },
                  child: Text("All of ${kanjis.length} kanji",
                      style: actionTextStyle)),
              if (kanjis.length >= 100)
                CupertinoActionSheetAction(
                    onPressed: () => onAmountPressed(100, kanjis),
                    child: Text("100 kanji", style: actionTextStyle)),
              if (kanjis.length >= 50)
                CupertinoActionSheetAction(
                    onPressed: () => onAmountPressed(50, kanjis),
                    child: Text("50 kanji", style: actionTextStyle)),
              CupertinoActionSheetAction(
                  onPressed: () => onAmountPressed(20, kanjis),
                  child: Text("20 kanji", style: actionTextStyle)),
              CupertinoActionSheetAction(
                  onPressed: () => onAmountPressed(10, kanjis),
                  child: Text("10 kanji", style: actionTextStyle)),
            ],
            cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel", style: actionTextStyle)),
          );
        });
  }

  void onAmountPressed(int amount, List<Kanji> kanjis) {
    Navigator.pop(context);
    var start = Random(DateTime.now().millisecondsSinceEpoch)
        .nextInt(kanjis.length - amount);
    var temp = kanjis.sublist(start, start + amount);
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => QuizDetailPage(kanjis: temp)));
  }
}
