import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../ui/components/furigana_text.dart';
import '../bloc/kanji_list_bloc.dart';
import '../ui/custom_list_detail_page.dart';

const actionTextStyle = TextStyle(color: Colors.blue);

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
        elevation: showShadow ? 8 : 0,
        title: FuriganaText(
          text: '漢字リスト',
          tokens: [Token(text: '漢字', furigana: 'かんじ')],
          style: TextStyle(fontSize: 20),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showCreatingDialog();
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

                    var subtitle = '';

                    if (kanjiList.kanjiCount > 0) {
                      subtitle += '${kanjiList.kanjiCount} Kanji';
                    }

                    if (kanjiList.wordCount > 0) {
                      subtitle += (subtitle.isEmpty ? '' : ', ') +
                          '${kanjiList.wordCount} Words';
                    }

                    if (kanjiList.wordCount == 1)
                      subtitle = subtitle.substring(0, subtitle.length - 1);

                    if (kanjiList.sentenceCount > 0) {
                      subtitle += (subtitle.isEmpty ? '' : ', ') +
                          '${kanjiList.sentenceCount} Sentences';
                    }

                    if (kanjiList.sentenceCount == 1)
                      subtitle = subtitle.substring(0, subtitle.length - 1);

                    if (subtitle.isEmpty) {
                      subtitle = 'Empty';
                    }

                    return Dismissible(
                        key: ObjectKey(kanjiList),
                        onDismissed: (_) => onDismissed(kanjiList),
                        confirmDismiss: (_) => confirmDelete(kanjiList),
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
                          subtitle: Text(
                            subtitle,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor ==
                                        Colors.black
                                    ? Colors.white60
                                    : Colors.black54),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ListDetailPage(kanjiList: kanjiList)));
                          },
                          onLongPress: () => confirmChangeName(kanjiList),
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

  Future<bool> confirmChangeName(KanjiList kanjiList) async {
    var listName = kanjiList.name;
    return showCupertinoModalPopup<bool>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              title: Text("Choose an action"),
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text('Cancel', style: actionTextStyle),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  isDestructiveAction: false,
                  child: Text('Edit name of $listName', style: actionTextStyle),
                  onPressed: () {
                    Navigator.pop(context, true);
                    showNameChangingDialog(kanjiList);
                  },
                ),
                CupertinoActionSheetAction(
                  isDestructiveAction: true,
                  child: Text('Remove $listName'),
                  onPressed: () {
                    Navigator.pop(context, false);
                    confirmDelete(kanjiList).then((val) {
                      if (val) {
                        KanjiListBloc.instance.deleteKanjiList(kanjiList);
                      }
                    });
                  },
                ),
              ],
            )).then((value) => value ?? false);
  }

  void showNameChangingDialog(KanjiList kanjiList) {
    textEditingController.text = kanjiList.name;
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('Edit name of ${kanjiList.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 12),
                TextField(
                  controller: textEditingController,
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel")),
              TextButton(
                  onPressed: () {
                    var name = textEditingController.text;
                    if (name.isNotEmpty) {
                      textEditingController.clear();
                      Navigator.pop(context);
                      KanjiListBloc.instance.changeName(kanjiList, name);
                    }
                  },
                  child: Text("Confirm")),
            ],
          );
        }).whenComplete(() {
      print("clear");
      textEditingController.clear();
    });
  }

  void showCreatingDialog() => showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text("Create a list"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                decoration:
                    InputDecoration(labelText: "Enter the name of this list"),
                controller: textEditingController,
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel", style: actionTextStyle)),
            TextButton(
                onPressed: () {
                  var name = textEditingController.text;
                  if (name.isNotEmpty) {
                    textEditingController.clear();
                    KanjiListBloc.instance.addKanjiList(name);
                    Navigator.pop(context);
                  }
                },
                child: Text("Confirm", style: actionTextStyle)),
          ],
        );
      });

  Future<bool> confirmDelete(KanjiList kanjiList) async {
    return showCupertinoModalPopup<bool>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              message: Text("Are you sure?"),
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text('Cancel', style: actionTextStyle),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  isDestructiveAction: true,
                  child: Text('Remove ${kanjiList.name}'),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
              ],
            )).then((value) => value ?? false);
  }

  void onDismissed(KanjiList kanjiList) {
    print("on dimissed custom list");
    KanjiListBloc.instance.deleteKanjiList(kanjiList);
  }
}
