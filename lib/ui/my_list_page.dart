import 'package:flutter/material.dart';

import 'package:kanji_dictionary/ui/components/furigana_text.dart';
import 'package:kanji_dictionary/bloc/kanji_list_bloc.dart';
import 'package:kanji_dictionary/ui/list_detail_page.dart';

///This is the page that displays lists created by users
class MyListPage extends StatefulWidget {
  @override
  _MyListPageState createState() => _MyListPageState();
}

class _MyListPageState extends State<MyListPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final textEditingController = TextEditingController();

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
        title: FuriganaText(
          text: '漢字リスト',
          tokens: [Token(text: '漢字', furigana: 'かんじ')],
          style: TextStyle(fontSize: 20),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) {
                    return Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Material(
                          //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: TextField(
                              onSubmitted: (str) {
                                KanjiListBloc.instance.addKanjiList(textEditingController.text);
                                Navigator.pop(context);
                              },
                              controller: textEditingController,
                              decoration: InputDecoration(hintText: 'List Name'),
                            ),
                          ),
                        ),
                      ),
                    );
                  });
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
                      title: Text(kanjiList.name, style: TextStyle(color: Colors.white),),
                      subtitle: Text('${kanjiList.kanjiStrs.length} Kanji'),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ListDetailPage(kanjiList: kanjiList)));
                      },
                      onLongPress: () {
//                        scaffoldKey.currentState.showBottomSheet((_) => BottomSheet
//                        );

                        showModalBottomSheet(context: context, builder: (_){
                          return Padding(
                            child: ListTile(
                              title: Text('Delete ${kanjiList.name}'),
                              onTap: () {
                                Navigator.pop(context);
                                scaffoldKey.currentState.showSnackBar(SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text('Are you sure you want to delete ${kanjiList.name}'),
                                  action: SnackBarAction(
                                      label: 'Yes',
                                      onPressed: () {
                                        scaffoldKey.currentState.hideCurrentSnackBar();
                                        KanjiListBloc.instance.deleteKanjiList(kanjiList.name);
                                      }),
                                ));
                              },
                            ),
                            padding: EdgeInsets.only(bottom: 16),
                          );
                        });
                      },
                    );
                  },
                  separatorBuilder: (_, index) => Divider(height: 0),
                  itemCount: kanjiLists.length);
            } else {
              return Container();
            }
          }),
    );
  }
}
