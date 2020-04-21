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
                    return Dismissible(
                        key: ObjectKey(kanjiList),
                        onDismissed: (_) => onDismissed(kanjiList.name),
                        confirmDismiss: (_) => confirmDelete(kanjiList.name),
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
                          onLongPress: () => confirmChangeName(kanjiList.name),
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

  Future<bool> confirmChangeName(String listName) async {
    return showCupertinoModalPopup<bool>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              title: Text("Choose an action"),
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  isDestructiveAction: false,
                  child: Text('Edit name of $listName'),
                  onPressed: () {
                    Navigator.pop(context, true);
                    showNameChangingDialog(listName);
                  },
                ),
                CupertinoActionSheetAction(
                  isDestructiveAction: true,
                  child: Text('Remove $listName'),
                  onPressed: () {
                    Navigator.pop(context, false);
                    confirmDelete(listName).then((val) {
                      if (val) {
                        KanjiListBloc.instance.deleteKanjiList(listName);
                      }
                    });
                  },
                ),
              ],
            )).then((value) => value ?? false);
  }

  void showNameChangingDialog(String listName) => showCupertinoDialog(
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
          content: Flex(
            direction: Axis.vertical,
            children: <Widget>[
              SizedBox(height: 12),
              CupertinoTextField(
                style: TextStyle(color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.black : Colors.white),
                controller: textEditingController,
              )
            ],
          ),
          actions: <Widget>[
            CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel")),
            CupertinoActionSheetAction(
                onPressed: () {
                  var name = textEditingController.text;
                  if (name.isNotEmpty) {
                    textEditingController.clear();
                    Navigator.pop(context);
                    KanjiListBloc.instance.changeName(listName, name);
                  }
                },
                child: Text("Confirm"),
                isDefaultAction: true),
          ],
        );
      });

  void showCreatingDialog() => showCupertinoDialog(
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text("Create a list"),
          content: Flex(
            direction: Axis.vertical,
            children: <Widget>[
              SizedBox(height: 12),
              CupertinoTextField(
                style: TextStyle(color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.black : Colors.white),
                controller: textEditingController,
              )
            ],
          ),
          actions: <Widget>[
            CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel")),
            CupertinoActionSheetAction(
                onPressed: () {
                  var name = textEditingController.text;
                  if (name.isNotEmpty) {
                    textEditingController.clear();
                    KanjiListBloc.instance.addKanjiList(name);
                    Navigator.pop(context);
                  }
                },
                child: Text("Confirm"),
                isDefaultAction: true),
          ],
        );
      });

  Future<bool> confirmDelete(String listName) async {
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
    print("on dimissed custom list");
    KanjiListBloc.instance.deleteKanjiList(listName);
  }
}
