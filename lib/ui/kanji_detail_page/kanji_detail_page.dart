import 'dart:math';

import 'package:app_review/app_review.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/kanji_bloc.dart';
import '../../bloc/kanji_list_bloc.dart';
import '../../bloc/sentence_bloc.dart';
import '../components/fancy_icon_button.dart';
import '../components/furigana_text.dart';
import '../components/label_divider.dart';
import '../kana_detail_page.dart';
import '../sentence_detail_page.dart';
import 'components/compound_word_column.dart';
import 'components/kanji_block.dart';
import 'components/kanji_info_column.dart';

class KanjiDetailPage extends StatefulWidget {
  final Kanji kanji;
  final String kanjiStr;
  final String tag;

  KanjiDetailPage({this.kanji, this.kanjiStr, String tag})
      : assert(kanji != null || kanjiStr != null),
        tag = tag ?? kanjiStr ?? kanji.kanji;

  @override
  State<StatefulWidget> createState() => _KanjiDetailPageState();
}

class _KanjiDetailPageState extends State<KanjiDetailPage>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  final scrollController = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final sentenceBloc = SentenceBloc();
  String kanjiStr;
  bool isFaved;
  bool isStared;
  Kanji kanji;
  double elevation = 0;
  double opacity = 0;

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, lowerBound: 0, upperBound: 1.1)
          ..value = 1;
    kanjiStr = widget.kanjiStr ?? widget.kanji.kanji;
    isFaved = KanjiBloc.instance.getIsFaved(kanjiStr);
    isStared = KanjiBloc.instance.getIsStared(kanjiStr);

    SchedulerBinding.instance.addPostFrameCallback((duration) {
      FeatureDiscovery.discoverFeatures(
        context,
        const <String>{'wikitionary', 'add_item', 'more_radicals'},
      );
    });

    super.initState();

    scrollController.addListener(() {
      if (mounted &&
          scrollController.offset ==
              scrollController.position.maxScrollExtent) {
        sentenceBloc.getMoreSentencesByKanji();
      }
    });

    scrollController.addListener(() {
      final offset = scrollController.offset;
      if (mounted) {
        if (offset <= 0) {
          setState(() {
            elevation = 0;
            opacity = 0;
          });
        } else {
          setState(() {
            elevation = 8;
            if (offset > 200) {
              opacity = 1;
            } else {
              opacity = offset / 200;
            }
          });
        }
      }
    });

    scrollController.addListener(() {
      animationController.value = (190 - scrollController.offset) / 190;
    });

    sentenceBloc.getSentencesByKanji(kanjiStr);

    if (widget.kanjiStr != null) {
      KanjiBloc.instance.getKanjiInfoByKanjiStr(widget.kanjiStr);
    }

    if (Random(DateTime.now().millisecondsSinceEpoch).nextBool()) {
      AppReview.isRequestReviewAvailable.then((isAvailable) {
        if (isAvailable) {
          AppReview.requestReview;
        }
      });
    }

    if (widget.kanji != null) KanjiBloc.instance.addSuggestion(widget.kanji);
  }

  @override
  void dispose() {
    scrollController.dispose();
    sentenceBloc.dispose();
    KanjiBloc.instance.reset();
    super.dispose();
  }

  void onWikiPressed() {
    launchURL(kanji.kanji);
  }

  void onAddPressed() {
    showDialog(
        context: context,
        builder: (_) {
          return Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Material(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4))),
                child: StreamBuilder(
                    stream: KanjiListBloc.instance.kanjiLists,
                    builder: (_, snapshot) {
                      if (snapshot.hasData) {
                        final kanjiLists = snapshot.data;

                        if (kanjiLists.isEmpty) {
                          return Container(
                            height: 200,
                            child: const Center(
                              child: Text(
                                "You don't have any list yet.",
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                            shrinkWrap: true,
                            itemBuilder: (_, index) {
                              final kanjiList = kanjiLists[index];
                              final isInList = KanjiListBloc.instance
                                  .isInList(kanjiList, kanjiStr);

                              var subtitle = '';

                              if (kanjiList.kanjiCount > 0) {
                                subtitle += '${kanjiList.kanjiCount} Kanji';
                              }

                              if (kanjiList.wordCount > 0) {
                                subtitle +=
                                    '${subtitle.isEmpty ? '' : ', '}${'${kanjiList.wordCount} Words'}';
                              }

                              if (kanjiList.wordCount == 1) {
                                subtitle =
                                    subtitle.substring(0, subtitle.length - 1);
                              }

                              if (kanjiList.sentenceCount > 0) {
                                subtitle +=
                                    '${subtitle.isEmpty ? '' : ', '}${'${kanjiList.sentenceCount} Sentences'}';
                              }

                              if (kanjiList.sentenceCount == 1) {
                                subtitle =
                                    subtitle.substring(0, subtitle.length - 1);
                              }

                              if (subtitle.isEmpty) {
                                subtitle = 'Empty';
                              }

                              return ListTile(
                                title: Text(kanjiLists[index].name,
                                    style: TextStyle(
                                        color: isInList
                                            ? Colors.black54
                                            : Colors.black)),
                                subtitle: Text(subtitle),
                                onTap: () {
                                  Navigator.pop(context);
                                  if (isInList) {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                        'This kanji is already in ${kanjiList.name}',
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                      backgroundColor:
                                          Theme.of(context).accentColor,
                                      action: SnackBarAction(
                                        label: 'Dismiss',
                                        onPressed: () =>
                                            ScaffoldMessenger.of(context)
                                                .hideCurrentSnackBar(),
                                        textColor: Colors.blueGrey,
                                      ),
                                    ));
                                  } else {
                                    KanjiListBloc.instance
                                        .addKanji(kanjiList, kanjiStr);
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                        '$kanjiStr has been added to ${kanjiList.name}',
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                      backgroundColor:
                                          Theme.of(context).accentColor,
                                      action: SnackBarAction(
                                        label: 'Dismiss',
                                        onPressed: () =>
                                            ScaffoldMessenger.of(context)
                                                .hideCurrentSnackBar(),
                                        textColor: Colors.blueGrey,
                                      ),
                                    ));
                                  }
                                },
                              );
                            },
                            separatorBuilder: (_, index) =>
                                const Divider(height: 0),
                            itemCount: kanjiLists.length);
                      } else {
                        return Container();
                      }
                    }),
              ),
            ),
          );
        });
  }

  String getAppBarInfo() {
    var str = '';
    if (kanji.jlpt != 0) {
      str += "N${kanji.jlpt}";
    }

    if (kanji.grade >= 0) {
      if (kanji.grade > 3) {
        str += ' ${kanji.grade}th Grade';
      } else {
        switch (kanji.grade) {
          case 1:
            str += ' 1st Grade';
            break;
          case 2:
            str += ' 2nd Grade';
            break;
          case 3:
            str += ' 3rd Grade';
            break;
          case 0:
            str += ' Junior High';
            break;
          default:
            throw Exception('Unmatched grade');
        }
      }
    }

    return str.trim();
  }

  @override
  Widget build(BuildContext context) {
    final kanjiBlockHeight = MediaQuery.of(context).size.width / 2 - 24;

    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          elevation: elevation,
          title: Opacity(
            opacity: opacity,
            child: StreamBuilder(
              stream: KanjiBloc.instance.kanji,
              builder: (_, snapshot) {
                if (snapshot.hasData || widget.kanji != null) {
                  final kanji =
                      widget.kanji == null ? snapshot.data : widget.kanji;
                  this.kanji = kanji;
                  return Text(kanji.kanji ?? '');
                } else {
                  return Container();
                }
              },
            ),
          ),
          actions: <Widget>[
            DescribedFeatureOverlay(
              featureId: 'wikitionary',
              // Unique id that identifies this overlay.
              tapTarget: const IconButton(
                  icon: Icon(
                    FontAwesomeIcons.wikipediaW,
                    size: 20,
                  ),
                  onPressed: null),
              // The widget that will be displayed as the tap target.
              title: const Text('More info'),
              description: const Text(
                  'If you want more info on this kanji, Wikitionary is a good place to visit!'),
              backgroundColor: Theme.of(context).primaryColor,
              targetColor: Colors.white,
              textColor: Colors.white,
              child: IconButton(
                icon: const Icon(
                  FontAwesomeIcons.wikipediaW,
                  size: 20,
                ),
                onPressed: onWikiPressed,
              ),
            ),
            DescribedFeatureOverlay(
              featureId: 'add_item',
              // Unique id that identifies this overlay.
              tapTarget: const IconButton(
                  icon: Icon(Icons.playlist_add, size: 28), onPressed: null),
              // The widget that will be displayed as the tap target.
              title: const Text('Add Kanji'),
              description:
                  const Text('You can add kanji into list you created.'),
              backgroundColor: Theme.of(context).primaryColor,
              targetColor: Colors.white,
              textColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.playlist_add, size: 28),
                onPressed: onAddPressed,
              ),
            ),
            FancyIconButton(
              isFaved: isFaved,
              color: Colors.red,
              icon: Icons.favorite,
              iconBorder: Icons.favorite_border,
              onTapped: () {
                setState(() {
                  isFaved = !isFaved;
                });
                if (isFaved) {
                  KanjiBloc.instance.addFav(kanjiStr);
                } else {
                  KanjiBloc.instance.removeFav(kanjiStr);
                }
              },
            ),
            IconButton(
                icon: AnimatedCrossFade(
                    firstChild: const Icon(FontAwesomeIcons.solidBookmark,
                        color: Colors.teal, size: 24),
                    secondChild: const Icon(FontAwesomeIcons.bookmark),
                    crossFadeState: isStared
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(microseconds: 200)),
                onPressed: () {
                  setState(() {
                    isStared = !isStared;
                  });
                  if (isStared) {
                    KanjiBloc.instance.addStar(kanjiStr);
                  } else {
                    KanjiBloc.instance.removeStar(kanjiStr);
                  }
                }),
          ],
        ),
        body: ListView(
          controller: scrollController,
          children: <Widget>[
            AnimatedBuilder(
              animation: animationController,
              child: Container(
                child: Flex(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Container(
                              constraints: const BoxConstraints(
                                  maxWidth: 360, maxHeight: 360),
                              decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black54, blurRadius: 8)
                                  ],
                                  shape: BoxShape.rectangle,
                                  color: Colors.white),
                              height: kanjiBlockHeight,
                              child: Center(
                                  child: KanjiBlock(
                                      kanjiStr:
                                          widget.kanjiStr ?? widget.kanji.kanji,
                                      scaleFactor: computeScaleFactor(
                                          kanjiBlockHeight > 360
                                              ? 360
                                              : kanjiBlockHeight)))),
                        ),
                        flex: 1),
                    Flexible(
                        child: KanjiInfoColumn(
                            key: ObjectKey(widget.kanji ?? widget.kanjiStr),
                            kanji: widget.kanji),
                        flex: 1),
                  ],
                ),
              ),
              builder: (_, child) {
                final scale = 0.5 + 0.5 * animationController.value;
                return Opacity(
                  opacity: animationController.value <= 1
                      ? animationController.value
                      : 1,
                  child: Transform.scale(
                      scale: scale,
                      alignment:
                          scale > 1 ? Alignment.centerLeft : Alignment.center,
                      child: child),
                );
              },
            ),
            StreamBuilder(
              key: ObjectKey(widget.kanji ?? widget.kanjiStr),
              stream: KanjiBloc.instance.kanji,
              builder: (_, snapshot) {
                if (snapshot.hasData || widget.kanji != null) {
                  final kanji =
                      widget.kanji == null ? snapshot.data : widget.kanji;
                  this.kanji = kanji;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            width: MediaQuery.of(context).size.width - 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    LabelDivider(
                                        child: RichText(
                                            textAlign: TextAlign.center,
                                            text: const TextSpan(children: [
                                              TextSpan(
                                                  text: 'いみ\n',
                                                  style: TextStyle(
                                                      fontSize: 9,
                                                      color: Colors.white)),
                                              TextSpan(
                                                  text: '意味',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white))
                                            ]))),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text("${kanji.meaning}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center),
                                    )
                                  ],
                                ),
                                LabelDivider(
                                    child: RichText(
                                        textAlign: TextAlign.center,
                                        text: const TextSpan(children: [
                                          TextSpan(
                                              text: 'よみ      かた\n',
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  color: Colors.white)),
                                          TextSpan(
                                              text: '読み方',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white))
                                        ]))),
                                Wrap(
                                  alignment: WrapAlignment.start,
                                  direction: Axis.horizontal,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: FuriganaText(
                                        text: '音読み',
                                        tokens: [
                                          Token(text: '音読み', furigana: 'おんよみ')
                                        ],
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    for (var onyomi in kanji.onyomi.where(
                                        (s) => s.contains(r'-') == false))
                                      Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: GestureDetector(
                                            onTap: () {
                                              if (!onyomi
                                                  .contains(RegExp(r'\.|-'))) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            KanaDetailPage(
                                                                onyomi,
                                                                Yomikata
                                                                    .onyomi)));
                                              }
                                            },
                                            child: Container(
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  child: Text(
                                                    onyomi,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                              decoration: const BoxDecoration(
                                                //boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(
                                                        5.0) //                 <--- border radius here
                                                    ),
                                              ),
                                            ),
                                          ))
                                  ],
                                ),
                                const Divider(),
                                Wrap(
                                    alignment: WrapAlignment.start,
                                    direction: Axis.horizontal,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: FuriganaText(
                                          text: '訓読み',
                                          tokens: [
                                            Token(text: '訓読み', furigana: 'くんよみ')
                                          ],
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                      for (var kunyomi in kanji.kunyomi.where(
                                          (s) => s.contains(r'-') == false))
                                        Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: GestureDetector(
                                              onTap: () {
                                                if (!kunyomi.contains(
                                                    RegExp(r'\.|-'))) {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) =>
                                                              KanaDetailPage(
                                                                  kunyomi,
                                                                  Yomikata
                                                                      .kunyomi)));
                                                }
                                              },
                                              child: Container(
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: Text(
                                                      kunyomi,
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                                decoration: const BoxDecoration(
                                                  //boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(
                                                          5.0) //                 <--- border radius here
                                                      ),
                                                ),
                                              ),
                                            )),
                                    ]),
                                LabelDivider(
                                    child: RichText(
                                        textAlign: TextAlign.center,
                                        text: const TextSpan(children: [
                                          TextSpan(
                                              text: 'たんご\n',
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  color: Colors.white)),
                                          TextSpan(
                                              text: '単語',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white))
                                        ]))),
                                CompoundWordColumn(
                                    scaffoldContext: scaffoldKey.currentContext,
                                    kanji: kanji),
                                LabelDivider(
                                    child: RichText(
                                        textAlign: TextAlign.center,
                                        text: const TextSpan(children: [
                                          TextSpan(
                                              text: 'れいぶん\n',
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  color: Colors.white)),
                                          TextSpan(
                                              text: '例文',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white))
                                        ]))),
                              ],
                            ),
                          ))
                    ],
                  );
                } else {
                  return Container();
                }
              },
            ),
            StreamBuilder(
              stream: sentenceBloc.sentences,
              builder: (_, snapshot) {
                if (snapshot.hasData) {
                  final sentences = snapshot.data;
                  final children = <Widget>[];
                  if (sentences.isEmpty) {
                    return Container(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: const Center(
                        child: Text(
                          'No example sentences found _(┐「ε:)_',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    );
                  }
                  for (var sentence in sentences) {
                    children.add(ListTile(
                      title: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: FuriganaText(
                            markTarget: true,
                            target: kanji.kanji,
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
                    children.add(const Divider(
                      height: 0,
                      indent: 16,
                      endIndent: 16,
                    ));
                  }
                  children.add(const SizedBox(height: 48));
                  return Column(
                    children: children,
                  );
                } else {
                  return Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: const Center(
                      child: Text(
                        '_(┐「ε:)_',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ));
  }

  void launchURL(String targetKanji) async {
    final url = Uri.encodeFull('https://en.wiktionary.org/wiki/$targetKanji');

    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: true, forceWebView: true);
    } else {
      throw 'Could not launch $url';
    }
  }

  static double computeScaleFactor(double width) {
    return (width / 163.5);
  }
}
