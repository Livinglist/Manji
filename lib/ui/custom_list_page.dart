import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:kanji_dictionary/ui/components/furigana_text.dart';
import 'package:kanji_dictionary/bloc/kanji_list_bloc.dart';
import 'package:kanji_dictionary/ui/custom_list_detail_page.dart';

///This is the page that displays lists created by users
class MyListPage extends StatefulWidget {
  @override
  _MyListPageState createState() => _MyListPageState();
}

class _MyListPageState extends State<MyListPage> {
  final scrollController = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final textEditingController = TextEditingController();
  bool showShadow = false;

  @override
  void initState() {
    super.initState();

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
        elevation: showShadow?8:0,
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
                  controller: scrollController,
                  itemBuilder: (_, index) {
                    var kanjiList = kanjiLists[index];
                    return Dismissible(
                        key: ObjectKey(kanjiList),
                        onDismissed: (_) => onDismissed(kanjiList.name),
                        confirmDismiss: (_) => confirmDismiss(kanjiList.name),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20.0),
                          color: Colors.red,
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            kanjiList.name,
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text('${kanjiList.kanjiStrs.length} Kanji'),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ListDetailPage(kanjiList: kanjiList)));
                          },
                        ));
                  },
                  separatorBuilder: (_, index) => Divider(height: 0),
                  itemCount: kanjiLists.length);
            } else {
              return Container();
            }
          }),
    );
  }

  Future<bool> confirmDismiss(String listName) async {
    return showCupertinoModalPopup<bool>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              message: Text("Are you sure?"),
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  isDestructiveAction: true,
                  child: Text('Remove $listName'),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
              ],
            )).then((value) => value ?? false);
  }

  void onDismissed(String listName) {
    KanjiListBloc.instance.deleteKanjiList(listName);
  }
}
