import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kanji_dictionary/bloc/kanji_bloc.dart';

import 'package:kanji_dictionary/bloc/kanji_list_bloc.dart';
import 'package:kanji_dictionary/bloc/incorrect_question_bloc.dart';

import '../components/snack_bar_collections.dart';
import 'quiz_detail_page.dart';
import 'incorrect_question_page.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
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
                            child: Text(snapshot.data.length.toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
                          );
                        }
                        return Container();
                      }),
                )),
            IconButton(
              icon: Icon(FontAwesomeIcons.backpack),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => IncorrectQuestionsPage()));
              },
            )
          ],
        ),
        body: StreamBuilder(
          stream: KanjiListBloc.instance.kanjiLists,
          builder: (_, AsyncSnapshot<List<KanjiList>> snapshot) {
            if (snapshot.hasData) {
              var kanjiLists = snapshot.data;

              if (kanjiLists.isEmpty) {
                return Center(
                  child: Text(
                    'Create your kanji list at Kanji Lists page first.',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

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
                        for (var n in [1, 2, 3, 4, 5])
                          ActionChip(
                              elevation: 4,
                              label: Text("N$n"),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => QuizDetailPage(jlpt: n)));
                              }),
                      ],
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
    var children = <Widget>[];
    for (var kanjiList in kanjiLists) {
      children.add(ListTile(
        title: Text(
          kanjiList.name,
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Text('${kanjiList.kanjiStrs.length} Kanji'),
        onTap: () {
          if (kanjiList.kanjiStrs.isNotEmpty)
            Navigator.push(context, MaterialPageRoute(builder: (_) => QuizDetailPage(kanjiList: kanjiList)));
          else
            scaffoldKey.currentState.showSnackBar(WarningSnackBar(message: "List is empty."));
        },
      ));
      children.add(Divider(height: 0));
    }

    children.removeLast();

    return children;
  }
}
