import 'dart:convert';
import 'dart:math';

import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../bloc/kanji_bloc.dart';
import '../bloc/kanji_list_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../ui/sentence_detail_page.dart';
import '../ui/word_detail_page.dart';
import 'components/furigana_text.dart';
import 'components/kanji_list_tile.dart';
import 'kanji_detail_page/kanji_detail_page.dart';
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
  final stupidStrings = <String>[
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
    SchedulerBinding.instance.addPostFrameCallback((duration) {
      FeatureDiscovery.discoverFeatures(
        context,
        const <String>{
          'study_kanji',
        },
      );
    });

    super.initState();

    gridViewScrollController.addListener(() {
      if (mounted) {
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
      if (mounted) {
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
              builder: (_, snapshot) {
                print("snapshot: ${snapshot.data}");

                return DescribedFeatureOverlay(
                    featureId: 'study_kanji',
                    // Unique id that identifies this overlay.
                    tapTarget: const IconButton(
                        onPressed: null,
                        icon: Icon(FontAwesomeIcons.bookOpen, size: 16)),
                    // The widget that will be displayed as the tap target.
                    title: const Text('Study'),
                    description: const Text('Study this list by flash cards.'),
                    backgroundColor: Theme.of(context).primaryColor,
                    targetColor: Colors.white,
                    textColor: Colors.white,
                    child: IconButton(
                        icon: const Icon(FontAwesomeIcons.bookOpen, size: 16),
                        onPressed: () {
                          if (snapshot.hasData) {
                            if (snapshot.data.isEmpty) {
                              setState(() {
                                if (studyString.length > 50) {
                                  if (stupidStrings.isEmpty) {
                                    Navigator.pop(context);
                                  } else {
                                    final index = Random(DateTime.now()
                                            .millisecondsSinceEpoch)
                                        .nextInt(stupidStrings.length);
                                    final str = stupidStrings[index];
                                    stupidStrings.removeAt(index);
                                    studyString = str;
                                  }
                                } else {
                                  studyString += "!";
                                }
                              });
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => KanjiStudyPage(
                                          kanjis: snapshot.data)));
                            }
                          }
                        }));
              },
            ),
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: () {
                setState(() {
                  sortByStrokes = !sortByStrokes;
                });
              },
            ),
            IconButton(
              icon: AnimatedCrossFade(
                firstChild: const Icon(
                  Icons.view_headline,
                  color: Colors.white,
                ),
                secondChild: const Icon(
                  Icons.view_comfy,
                  color: Colors.white,
                ),
                crossFadeState: showGrid
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 200),
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
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              var kanjis = snapshot.data;

              final words = <Word>[];
              final sentences = <Sentence>[];

              for (final item
                  in widget.kanjiList.kanjiStrs.where((e) => e.length > 1)) {
                final json = jsonDecode(item);
                if (json.containsKey('meanings')) {
                  final word = Word.fromMap(json);
                  words.add(word);
                } else {
                  final sentence = Sentence.fromMap(json);
                  sentences.add(sentence);
                }
              }

              if (sortByStrokes) {
                kanjis.sort((a, b) => a.strokes.compareTo(b.strokes));
              } else {
                kanjis = snapshot.data;
              }

              if (kanjis.isEmpty && words.isEmpty && sentences.isEmpty) {
                return Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Text(
                      studyString,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              }

              return AnimatedCrossFade(
                  firstChild: buildGridView(kanjis),
                  secondChild: buildListView(kanjis, words, sentences),
                  crossFadeState: showGrid
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 200));
            } else {
              return const Center(child: CircularProgressIndicator());
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
              content: Text(
                  'Are you sure you want to remove $kanjiStr from ${widget.kanjiList.name}'),
              action: SnackBarAction(
                  label: 'Yes',
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();

                    widget.kanjiList.kanjiStrs.remove(kanjiStr);
                    KanjiBloc.instance
                        .fetchKanjisByKanjiStrs(widget.kanjiList.kanjiStrs);
                    KanjiListBloc.instance
                        .removeKanji(widget.kanjiList, kanjiStr);
                  }),
            ));
          },
        ));
  }

  Widget buildGridView(List<Kanji> kanjis) {
    print("Gridview: $kanjis");
    return GridView.count(
        controller: gridViewScrollController,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        crossAxisCount: Device.get().isTablet ? 10 : 5,
        children: List.generate(kanjis.length, (index) {
          final kanji = kanjis[index];
          return InkWell(
            child: Container(
                width: MediaQuery.of(context).size.width / 5,
                height: MediaQuery.of(context).size.width / 5,
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: StreamBuilder(
                        key: ObjectKey(kanji.kanji),
                        stream: SettingsBloc.instance.fontSelection,
                        initialData: SettingsBloc.instance.tempFontSelection,
                        builder: (_, snapshot) {
                          if (snapshot.hasData) {
                            return Text(kanji.kanji,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontFamily:
                                      snapshot.data == FontSelection.handwriting
                                          ? Fonts.kazei
                                          : Fonts.ming,
                                ));
                          }
                          return Container();
                        },
                      ),
                    ),
                    Positioned(
                      left: 4,
                      top: 4,
                      child: Text(
                        (index + 1).toString(),
                        style:
                            const TextStyle(fontSize: 8, color: Colors.white24),
                      ),
                    )
                  ],
                )),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => KanjiDetailPage(kanji: kanji)));
            },
            onLongPress: () {
              confirmDismiss(kanji);
            },
          );
        }));
  }

  Widget buildListView(
      List<Kanji> kanjis, List<Word> words, List<Sentence> sentences) {
    return ListView.separated(
        shrinkWrap: true,
        controller: listViewScrollController,
        itemBuilder: (_, index) {
          if (index < kanjis.length) {
            final kanji = kanjis[index];

            return Dismissible(
                direction: DismissDirection.endToStart,
                key: ObjectKey(kanji),
                onDismissed: (_) => onDismissed(kanji),
                confirmDismiss: (_) => confirmDismiss(kanji),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                child: KanjiListTile(kanji: kanji));
          } else if (index < (kanjis.length + words.length)) {
            index = index - kanjis.length;
            final word = words[index];

            return Dismissible(
                direction: DismissDirection.endToStart,
                key: UniqueKey(),
                onDismissed: (_) => onWordDismissed(word),
                //confirmDismiss: (_) => confirmDismiss(kanji),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => WordDetailPage(word: word)));
                  },
                  onLongPress: () {},
                  title: FuriganaText(
                    text: word.wordText,
                    tokens: [
                      Token(text: word.wordText, furigana: word.wordFurigana)
                    ],
                    style: const TextStyle(fontSize: 24),
                  ),
                  subtitle: Text(word.meanings,
                      style: const TextStyle(color: Colors.white54)),
                ));
          } else {
            index = index - kanjis.length - words.length;
            final sentence = sentences[index];

            return Dismissible(
                direction: DismissDirection.endToStart,
                key: UniqueKey(),
                onDismissed: (_) => onSentenceDismissed(sentence),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                child: ListTile(
                  title: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: FuriganaText(
                        text: sentence.text,
                        tokens: sentence.tokens,
                        style: const TextStyle(fontSize: 20),
                      )),
                  subtitle: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      sentence.englishText,
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => SentenceDetailPage(
                                  sentence: sentence,
                                )));
                  },
                ));
          }
        },
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemCount: kanjis.length + words.length + sentences.length);
  }

  Future<bool> confirmDismiss(Kanji kanji) async {
    return showCupertinoModalPopup<bool>(
        context: context,
        builder: (context) => CupertinoActionSheet(
              message: const Text("Are you sure?"),
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: const Text('Cancel'),
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
    final dismissedKanji = kanji.kanji;
    widget.kanjiList.kanjiStrs.remove(kanji.kanji);
    KanjiBloc.instance.fetchKanjisByKanjiStrs(widget.kanjiList.kanjiStrs);
    KanjiListBloc.instance.removeKanji(widget.kanjiList, dismissedKanji);
  }

  void onWordDismissed(Word word) {
    widget.kanjiList.kanjiStrs.remove(jsonEncode(word.toMap()));
    KanjiBloc.instance.fetchKanjisByKanjiStrs(widget.kanjiList.kanjiStrs);
    KanjiListBloc.instance.removeWord(widget.kanjiList, word);
  }

  void onSentenceDismissed(Sentence sentence) {
    widget.kanjiList.kanjiStrs.remove(jsonEncode(sentence.toMap()));
    KanjiBloc.instance.fetchKanjisByKanjiStrs(widget.kanjiList.kanjiStrs);
    KanjiListBloc.instance.removeSentence(widget.kanjiList, sentence);
  }
}
