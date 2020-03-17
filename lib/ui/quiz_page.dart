import 'package:flutter/material.dart';

import 'package:kanji_dictionary/bloc/kanji_list_bloc.dart';

import 'components/snack_bar_collections.dart';
import 'quiz_detail_page.dart';

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: Text('クイズ'),
          elevation: 0,
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
                      'When will you start studying！ (╯°Д°）╯',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              }

              return ListView.separated(
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
