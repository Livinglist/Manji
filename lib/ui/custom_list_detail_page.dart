import 'dart:math';

import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_device_type/flutter_device_type.dart';

import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import 'package:kanji_dictionary/bloc/kanji_list_bloc.dart';
import 'components/kanji_list_tile.dart';
import 'package:kanji_dictionary/ui/kanji_detail_page.dart';
import 'kanji_study_pages/kanji_study_page.dart';

///This is the page that displays the list created by the user
class ListDetailPage extends StatefulWidget {
  final KanjiList kanjiList;

  ListDetailPage({this.kanjiList}) : assert(kanjiList != null);

  @override
  _ListDetailPageState createState() => _ListDetailPageState();
}

class _ListDetailPageState extends State<ListDetailPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final gridViewScrollController = ScrollController();
  final listViewScrollController = ScrollController();
  bool showGrid = false, showShadow = false;
  bool sortByStrokes = false;
  String studyString = 'When will you start studying！ (╯°Д°）╯';
  var stupidStrings = [
    "You can stop it now...",
    "emmmm......",
    "why?",
    "you know this is pointless",
    "really, nothing special here",
    "just some random sh*t",
    "you really think you can deal with this?",
    "3...2...1...BOOM",
    "give me a five star review, or..."
  ];

  @override
  void initState() {
    KanjiListBloc.instance.init();
    KanjiBloc.instance.fetchKanjisByKanjiStrs(widget.kanjiList.kanjiStrs);
    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      FeatureDiscovery.discoverFeatures(
        context,
        const <String>{
          'study_kanji',
        },
      );
    });

    super.initState();

    gridViewScrollController.addListener(() {
      if (this.mounted) {
        if (gridViewScrollController.offset <= 0) {
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

    listViewScrollController.addListener(() {
      if (this.mounted) {
        if (listViewScrollController.offset <= 0) {
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
          title: Text(widget.kanjiList.name),
          actions: <Widget>[
            StreamBuilder(
              stream: KanjiBloc.instance.kanjis,
              builder: (_, AsyncSnapshot<List<Kanji>> snapshot) {
                return DescribedFeatureOverlay(
                  featureId: 'study_kanji',
                  // Unique id that identifies this overlay.
                  tapTarget: IconButton(
                      onPressed: null,
                      icon: Icon(FontAwesomeIcons.bookOpen, size: 16)),
                  // The widget that will be displayed as the tap target.
                  title: Text('Study'),
                  description: Text(
                      'Study this list by flash cards.'),
                  backgroundColor: Theme.of(context).primaryColor,
                  targetColor: Colors.white,
                  textColor: Colors.white,
                  child: IconButton(
                      icon: Icon(FontAwesomeIcons.bookOpen, size: 16),
                      onPressed: () {
                        if (snapshot.hasData) {
                          if (snapshot.data.isEmpty) {
                            setState(() {
                              if (studyString.length > 50) {
                                if (stupidStrings.isEmpty) {
                                  Navigator.pop(context);
                                } else {
                                  var index = Random(DateTime.now().millisecondsSinceEpoch).nextInt(stupidStrings.length);
                                  var str = stupidStrings[index];
                                  stupidStrings.removeAt(index);
                                  studyString = str;
                                }
                              } else {
                                studyString += "!";
                              }
                            });
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => KanjiStudyPage(kanjis: snapshot.data)));
                          }
                        }
                      })
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.sort),
              onPressed: () {
                setState(() {
                  sortByStrokes = !sortByStrokes;
                });
              },
            ),
            IconButton(
              icon: AnimatedCrossFade(
                firstChild: Icon(
                  Icons.view_headline,
                  color: Colors.white,
                ),
                secondChild: Icon(
                  Icons.view_comfy,
                  color: Colors.white,
                ),
                crossFadeState: showGrid ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                duration: Duration(milliseconds: 200),
              ),
              onPressed: () {
                if (widget.kanjiList.kanjiStrs.isNotEmpty) {
                  if (listViewScrollController.position.maxScrollExtent > 0) {
                    setState(() {
                      listViewScrollController.position.moveTo(0);
                      showGrid = !showGrid;
                    });
                  } else {
                    setState(() {
                      showGrid = !showGrid;
                    });
                  }
                }
              },
            ),
          ],
        ),
        body: StreamBuilder(
          stream: KanjiBloc.instance.kanjis,
          builder: (_, AsyncSnapshot<List<Kanji>> snapshot) {
            if (snapshot.hasData) {
              var kanjis = snapshot.data;
              //kanjis.sort((kanjiLeft, kanjiRight)=>kanjiLeft.strokes.compareTo(kanjiRight.strokes));
              //return KanjiGridView(kanjis: kanjis);
              if (sortByStrokes) {
                kanjis.sort((a, b) => a.strokes.compareTo(b.strokes));
              } else {
                kanjis = snapshot.data;
              }

              if (kanjis.isEmpty) {
                return Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Text(
                      studyString,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              }

              return AnimatedCrossFade(
                  firstChild: buildGridView(kanjis),
                  secondChild: buildListView(kanjis),
                  crossFadeState: showGrid ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  duration: Duration(milliseconds: 200));
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ));
  }

  void onLongPressed(String kanjiStr) {
    scaffoldKey.currentState.showBottomSheet((_) => ListTile(
          title: Text('Remove $kanjiStr from ${widget.kanjiList.name}'),
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.red,
              content: Text('Are you sure you want to remove $kanjiStr from ${widget.kanjiList.name}'),
              action: SnackBarAction(
                  label: 'Yes',
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();

                    widget.kanjiList.kanjiStrs.remove(kanjiStr);
                    KanjiBloc.instance.fetchKanjisByKanjiStrs(widget.kanjiList.kanjiStrs);
                    KanjiListBloc.instance.removeKanji(widget.kanjiList, kanjiStr);
                  }),
            ));
          },
        ));
  }

  Widget buildGridView(List<Kanji> kanjis) {
    return GridView.count(
        controller: gridViewScrollController,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        crossAxisCount: Device.get().isTablet ? 10 : 5,
        children: List.generate(kanjis.length, (index) {
          var kanji = kanjis[index];
          return InkWell(
            child: Container(
                width: MediaQuery.of(context).size.width / 5,
                height: MediaQuery.of(context).size.width / 5,
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Text(kanji.kanji, style: TextStyle(color: Colors.white, fontSize: 48, fontFamily: 'kazei')),
                    ),
                    Positioned(
                      left: 4,
                      top: 4,
                      child: Text(
                        (index + 1).toString(),
                        style: TextStyle(fontSize: 8, color: Colors.white24),
                      ),
                    )
                  ],
                )),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => KanjiDetailPage(kanji: kanji)));
            },
            onLongPress: () {
              confirmDismiss(kanji);
            },
          );
        }));
  }

  Widget buildListView(List<Kanji> kanjis) {
    return ListView.separated(
        controller: listViewScrollController,
        itemBuilder: (_, index) {
          var kanji = kanjis[index];

          return Dismissible(
              direction: DismissDirection.endToStart,
              key: ObjectKey(kanji),
              onDismissed: (_) => onDismissed(kanji),
              confirmDismiss: (_) => confirmDismiss(kanji),
              background: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20.0),
                color: Colors.red,
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              child: KanjiListTile(kanji: kanji));
        },
        separatorBuilder: (_, __) => Divider(height: 0),
        itemCount: kanjis.length);
  }

  Future<bool> confirmDismiss(Kanji kanji) async {
    return showCupertinoModalPopup<bool>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              message: Text("Are you sure?"),
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context, false);
                  return false;
                },
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  isDestructiveAction: true,
                  child: Text('Remove ${kanji.kanji}'),
                  onPressed: () {
                    Navigator.pop(context, true);
                    return true;
                  },
                ),
              ],
            )).then((value) => value ?? false);
  }

  void onDismissed(Kanji kanji) {
    String dismissedKanji = kanji.kanji;
    widget.kanjiList.kanjiStrs.remove(kanji.kanji);
    KanjiBloc.instance.fetchKanjisByKanjiStrs(widget.kanjiList.kanjiStrs);
    KanjiListBloc.instance.removeKanji(widget.kanjiList, dismissedKanji);
  }
}
