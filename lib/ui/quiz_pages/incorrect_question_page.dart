import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../bloc/incorrect_question_bloc.dart';
import '../../models/question.dart';
import '../../ui/kanji_study_pages/kanji_study_page.dart';
import '../../ui/quiz_pages/components/incorrect_question_list_tile.dart';

class IncorrectQuestionsPage extends StatefulWidget {
  @override
  _IncorrectQuestionsPageState createState() => _IncorrectQuestionsPageState();
}

class _IncorrectQuestionsPageState extends State<IncorrectQuestionsPage> {
  final scrollController = ScrollController();
  bool showShadow = false;

  @override
  void initState() {
    super.initState();

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: showShadow ? 8 : 0,
        actions: <Widget>[
          StreamBuilder(
              stream: iqBloc.incorrectQuestions,
              builder: (_, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.isEmpty) {
                    return Container();
                  }
                  return IconButton(
                      icon: const Icon(FontAwesomeIcons.bookOpen, size: 16),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => KanjiStudyPage(
                                    kanjis: iqBloc.kanjisContainedInQuiz)));
                      });
                }
                return Container();
              }),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => confirmDeleteAll().then((val) {
              if (val) iqBloc.deleteAllIncorrectQuestions();
            }),
          )
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: StreamBuilder(
          stream: iqBloc.incorrectQuestions,
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.isEmpty) {
                return const Center(
                  child: Text(
                      "Questions you got wrong\nwill appear here for you to study.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70)),
                );
              }
              return ListView(
                controller: scrollController,
                children: snapshot.data
                    .map((q) => Dismissible(
                          key: UniqueKey(),
                          child: IncorrectQuestionListTile(question: q),
                          onDismissed: (_) => onDismissed(q),
                          confirmDismiss: (_) => confirmDismiss(q),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20.0),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ))
                    .toList(),
              );
            }
            return Container();
          }),
    );
  }

  Future<bool> confirmDeleteAll() async {
    return showCupertinoModalPopup<bool>(
        context: context,
        builder: (context) => CupertinoActionSheet(
              message: const Text("Are you sure?"),
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  isDestructiveAction: true,
                  child: const Text('Remove all'),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
              ],
            )).then((value) => value ?? false);
  }

  Future<bool> confirmDismiss(Question q) async {
    return showCupertinoModalPopup<bool>(
        context: context,
        builder: (context) => CupertinoActionSheet(
              message: const Text("Are you sure?"),
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  isDestructiveAction: true,
                  child: Text('Remove ${q.targetedKanji.kanji}'),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
              ],
            )).then((value) => value ?? false);
  }

  void onDismissed(Question q) => iqBloc.deleteIncorrectQuestion(q);
}
