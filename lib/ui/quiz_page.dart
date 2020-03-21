import 'package:flutter/material.dart';

import 'package:kanji_dictionary/bloc/kanji_list_bloc.dart';

import 'components/snack_bar_collections.dart';
import 'quiz_detail_page.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final scrollController = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  double elevation = 0;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (this.mounted) {
        if (scrollController.offset <= 0) {
          setState(() {
            elevation = 0;
          });
        } else {
          setState(() {
            elevation = 8;
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
          elevation: elevation,
        ),
        body: StreamBuilder(
          stream: KanjiListBloc.instance.kanjiLists,
          builder: (_, AsyncSnapshot<List<KanjiList>> snapshot) {
            if (snapshot.hasData) {
              var kanjiLists = snapshot.data;

              if (kanjiLists.isEmpty) {
                return Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Text(
                      'Creating your kanji list at Kanji Lists page first.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              }

              return ListView.separated(
                  controller: scrollController,
                  itemBuilder: (_, index) {
                    var kanjiList = kanjiLists[index];
                    return ListTile(
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
                    );
                  },
                  separatorBuilder: (_, index) => Divider(height: 0),
                  itemCount: kanjiLists.length);
            } else {
              return Container();
            }
          },
        ));
  }
}
