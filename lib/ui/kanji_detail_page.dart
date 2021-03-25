import 'dart:math';

import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kanji_dictionary/ui/search_result_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_review/app_review.dart';
import 'package:video_player/video_player.dart';

import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import 'package:kanji_dictionary/bloc/sentence_bloc.dart';
import 'package:kanji_dictionary/bloc/kanji_list_bloc.dart';
import 'package:kanji_dictionary/ui/components/fancy_icon_button.dart';
import 'components/spring_curve.dart';
import 'kana_detail_page.dart';
import 'sentence_detail_page.dart';
import 'word_detail_page.dart';
import 'components/furigana_text.dart';
import 'components/custom_bottom_sheet.dart' as CustomBottomSheet;
import 'components/chip_collections.dart';
import 'components/label_divider.dart';
import 'package:kanji_dictionary/resource/constants.dart';

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

class _KanjiDetailPageState extends State<KanjiDetailPage> with SingleTickerProviderStateMixin {
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
    animationController = AnimationController(vsync: this, lowerBound: 0, upperBound: 1.1)..value = 1;
    kanjiStr = widget.kanjiStr ?? widget.kanji.kanji;
    isFaved = KanjiBloc.instance.getIsFaved(kanjiStr);
    isStared = KanjiBloc.instance.getIsStared(kanjiStr);

    //FeatureDiscovery.clearPreferences(context, <String>{ 'wikitionary', 'add_item', 'more_radicals'});
    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      FeatureDiscovery.discoverFeatures(
        context,
        const <String>{'wikitionary', 'add_item', 'more_radicals'},
      );
    });

    super.initState();

    scrollController.addListener(() {
      if (this.mounted && scrollController.offset == scrollController.position.maxScrollExtent) {
        sentenceBloc.getMoreSentencesByKanji();
      }
    });

    scrollController.addListener(() {
      double offset = scrollController.offset;
      if (this.mounted) {
        if (offset <= 0) {
          setState(() {
            elevation = 0;
            opacity = 0;
          });
        } else {
          setState(() {
            elevation = 8;
            if (offset > 200)
              opacity = 1;
            else
              opacity = offset / 200;
          });
        }
      }
    });

    scrollController.addListener(() {
      animationController.value = (190 - scrollController.offset) / 190;
    });

    sentenceBloc.getSentencesByKanji(kanjiStr);
    // KanjiBloc.instance.getSentencesByKanji(widget.kanjiStr ?? widget.kanji.kanji);
    //KanjiBloc.instance.fetchWordsByKanji(widget.kanjiStr ?? widget.kanji.kanji);
    if (widget.kanjiStr != null) KanjiBloc.instance.getKanjiInfoByKanjiStr(widget.kanjiStr);

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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                child: StreamBuilder(
                    stream: KanjiListBloc.instance.kanjiLists,
                    builder: (_, AsyncSnapshot<List<KanjiList>> snapshot) {
                      if (snapshot.hasData) {
                        var kanjiLists = snapshot.data;

                        if (kanjiLists.isEmpty) {
                          return Container(
                            height: 200,
                            child: Center(
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
                              var kanjiList = kanjiLists[index];
                              var isInList = KanjiListBloc.instance.isInList(kanjiList, kanjiStr);

                              var subtitle = '';

                              if (kanjiList.kanjiCount > 0) {
                                subtitle += '${kanjiList.kanjiCount} Kanji';
                              }

                              if (kanjiList.wordCount > 0) {
                                subtitle += (subtitle.isEmpty ? '' : ', ') + '${kanjiList.wordCount} Words';
                              }

                              if (kanjiList.sentenceCount > 0) {
                                subtitle += (subtitle.isEmpty ? '' : ', ') + '${kanjiList.sentenceCount} Sentences';
                              }

                              if (subtitle.isEmpty) {
                                subtitle = 'Empty';
                              }

                              return ListTile(
                                title: Text(kanjiLists[index].name, style: TextStyle(color: isInList ? Colors.black54 : Colors.black)),
                                subtitle: Text(subtitle),
                                onTap: () {
                                  Navigator.pop(context);
                                  if (isInList) {
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(
                                        'This kanji is already in ${kanjiList.name}',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      backgroundColor: Theme.of(context).accentColor,
                                      action: SnackBarAction(
                                        label: 'Dismiss',
                                        onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                                        textColor: Colors.blueGrey,
                                      ),
                                    ));
                                  } else {
                                    KanjiListBloc.instance.addKanji(kanjiList, kanjiStr);
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(
                                        '$kanjiStr has been added to ${kanjiList.name}',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      backgroundColor: Theme.of(context).accentColor,
                                      action: SnackBarAction(
                                        label: 'Dismiss',
                                        onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                                        textColor: Colors.blueGrey,
                                      ),
                                    ));
                                  }
                                },
                              );
                            },
                            separatorBuilder: (_, index) => Divider(height: 0),
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
    String str = '';
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
    double kanjiBlockHeight = MediaQuery.of(context).size.width / 2 - 24;
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          elevation: elevation,
          title: Opacity(
            opacity: opacity,
            child: StreamBuilder(
              stream: KanjiBloc.instance.kanji,
              builder: (_, AsyncSnapshot<Kanji> snapshot) {
                if (snapshot.hasData || widget.kanji != null) {
                  var kanji = widget.kanji == null ? snapshot.data : widget.kanji;
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
              tapTarget: IconButton(
                  icon: Icon(
                    FontAwesomeIcons.wikipediaW,
                    size: 20,
                  ),
                  onPressed: null),
              // The widget that will be displayed as the tap target.
              title: Text('More info'),
              description: Text('If you want more info on this kanji, Wikitionary is a good place to visit!'),
              backgroundColor: Theme.of(context).primaryColor,
              targetColor: Colors.white,
              textColor: Colors.white,
              child: IconButton(
                icon: Icon(
                  FontAwesomeIcons.wikipediaW,
                  size: 20,
                ),
                onPressed: onWikiPressed,
              ),
            ),
            DescribedFeatureOverlay(
              featureId: 'add_item',
              // Unique id that identifies this overlay.
              tapTarget: IconButton(icon: Icon(Icons.playlist_add, size: 28), onPressed: null),
              // The widget that will be displayed as the tap target.
              title: Text('Add Kanji'),
              description: Text('You can add kanji into list you created.'),
              backgroundColor: Theme.of(context).primaryColor,
              targetColor: Colors.white,
              textColor: Colors.white,
              child: IconButton(
                icon: Icon(Icons.playlist_add, size: 28),
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
                    firstChild: Icon(FontAwesomeIcons.solidBookmark, color: Colors.teal, size: 24),
                    secondChild: Icon(FontAwesomeIcons.bookmark),
                    crossFadeState: isStared ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    duration: Duration(microseconds: 200)),
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
        body: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: <Widget>[
              AnimatedBuilder(
                animation: animationController,
                child: Container(
                  child: Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      Flexible(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Container(
                                constraints: BoxConstraints(maxWidth: 360, maxHeight: 360),
                                decoration: BoxDecoration(
                                    boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                                    shape: BoxShape.rectangle,
                                    color: Colors.white),
                                height: kanjiBlockHeight,
                                child: Center(
                                    child: KanjiBlock(
                                        kanjiStr: widget.kanjiStr ?? widget.kanji.kanji,
                                        scaleFactor: computeScaleFactor(kanjiBlockHeight > 360 ? 360 : kanjiBlockHeight)))),
                          ),
                          flex: 1),
                      Flexible(child: buildKanjiInfoColumn(), flex: 1),
                    ],
                  ),
                ),
                builder: (_, child) {
                  var scale = 0.5 + 0.5 * animationController.value;
                  return Opacity(
                    opacity: animationController.value <= 1 ? animationController.value : 1,
                    child: Transform.scale(scale: scale, alignment: scale > 1 ? Alignment.centerLeft : Alignment.center, child: child),
                  );
                },
              ),
              StreamBuilder(
                stream: KanjiBloc.instance.kanji,
                builder: (_, AsyncSnapshot<Kanji> snapshot) {
                  if (snapshot.hasData || widget.kanji != null) {
                    var kanji = widget.kanji == null ? snapshot.data : widget.kanji;
                    this.kanji = kanji;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
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
                                              text: TextSpan(children: [
                                                TextSpan(text: 'いみ' + '\n', style: TextStyle(fontSize: 9, color: Colors.white)),
                                                TextSpan(text: '意味', style: TextStyle(fontSize: 18, color: Colors.white))
                                              ]))),
                                      Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Text("${kanji.meaning}",
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center),
                                      )
                                    ],
                                  ),
                                  LabelDivider(
                                      child: RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(children: [
                                            TextSpan(text: 'よみ      かた' + '\n', style: TextStyle(fontSize: 9, color: Colors.white)),
                                            TextSpan(text: '読み方', style: TextStyle(fontSize: 18, color: Colors.white))
                                          ]))),
                                  Wrap(
                                    alignment: WrapAlignment.start,
                                    direction: Axis.horizontal,
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.all(4),
                                        child: FuriganaText(
                                          text: '音読み',
                                          tokens: [Token(text: '音読み', furigana: 'おんよみ')],
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ),
                                      for (var onyomi in kanji.onyomi.where((s) => s.contains(r'-') == false))
                                        Padding(
                                            padding: EdgeInsets.all(4),
                                            child: GestureDetector(
                                              onTap: () {
                                                if (!onyomi.contains(RegExp(r'\.|-'))) {
                                                  Navigator.push(
                                                      context, MaterialPageRoute(builder: (_) => KanaDetailPage(onyomi, Yomikata.onyomi)));
                                                }
                                              },
                                              child: Container(
                                                child: Padding(
                                                    padding: EdgeInsets.all(4),
                                                    child: Text(
                                                      onyomi,
                                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                    )),
                                                decoration: BoxDecoration(
                                                  //boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                                                          ),
                                                ),
                                              ),
                                            ))
                                    ],
                                  ),
                                  Divider(),
                                  Wrap(alignment: WrapAlignment.start, direction: Axis.horizontal, children: [
                                    Padding(
                                      padding: EdgeInsets.all(4),
                                      child: FuriganaText(
                                        text: '訓読み',
                                        tokens: [Token(text: '訓読み', furigana: 'くんよみ')],
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    for (var kunyomi in kanji.kunyomi.where((s) => s.contains(r'-') == false))
                                      Padding(
                                          padding: EdgeInsets.all(4),
                                          child: GestureDetector(
                                            onTap: () {
                                              if (!kunyomi.contains(RegExp(r'\.|-'))) {
                                                Navigator.push(
                                                    context, MaterialPageRoute(builder: (_) => KanaDetailPage(kunyomi, Yomikata.kunyomi)));
                                              }
                                            },
                                            child: Container(
                                              child: Padding(
                                                  padding: EdgeInsets.all(4),
                                                  child: Text(
                                                    kunyomi,
                                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                  )),
                                              decoration: BoxDecoration(
                                                //boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                                                        ),
                                              ),
                                            ),
                                          )),
                                  ]),
                                  LabelDivider(
                                      child: RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(children: [
                                            TextSpan(text: 'たんご' + '\n', style: TextStyle(fontSize: 9, color: Colors.white)),
                                            TextSpan(text: '単語', style: TextStyle(fontSize: 18, color: Colors.white))
                                          ]))),
                                  buildCompoundWordColumn(kanji),
                                  LabelDivider(
                                      child: RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(children: [
                                            TextSpan(text: 'れいぶん' + '\n', style: TextStyle(fontSize: 9, color: Colors.white)),
                                            TextSpan(text: '例文', style: TextStyle(fontSize: 18, color: Colors.white))
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
                builder: (_, AsyncSnapshot<List<Sentence>> snapshot) {
                  if (snapshot.hasData) {
                    var sentences = snapshot.data;
                    var children = <Widget>[];
                    if (sentences.isEmpty) {
                      return Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
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
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: FuriganaText(
                              markTarget: true,
                              target: kanji.kanji,
                              text: sentence.text,
                              tokens: sentence.tokens,
                              style: TextStyle(fontSize: 20),
                            )),
                        subtitle: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            sentence.englishText,
                            style: TextStyle(color: Colors.white54),
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
                      children.add(Divider(
                        height: 0,
                        indent: 16,
                        endIndent: 16,
                      ));
                    }
                    children.add(SizedBox(height: 48));
                    return Column(
                      children: children,
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ],
          ),
        ));
  }

  Widget buildCompoundWordColumn(Kanji kanji) {
    var onyomiGroup = <Widget>[];
    var kunyomiGroup = <Widget>[];
    var onyomiVerbGroup = <Widget>[];
    var kunyomiVerbGroup = <Widget>[];

    var onyomis = kanji.onyomi.where((s) => s.contains(r'-') == false).toList();
    var kunyomis = kanji.kunyomi.where((s) => s.contains(r'-') == false).toList();

//

    List<Word> onyomiWords =
        Set<Word>.from(kanji.onyomiWords).toList(); //..sort((a, b) => a.wordFurigana.length.compareTo(b.wordFurigana.length));
    onyomis.sort((a, b) => b.length.compareTo(a.length));
    for (var onyomi in onyomis) {
      var words =
          List.from(onyomiWords.where((onyomiWord) => onyomiWord.wordFurigana.contains(onyomi.replaceAll('.', '').replaceAll('-', ''))));

      onyomiWords.removeWhere((word) => words.contains(word));
      var tileTitle = Stack(
        children: <Widget>[
          Positioned.fill(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(4),
                child: Container(
                  child: Padding(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        onyomi,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      )),
                  decoration: BoxDecoration(
                    //boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                        ),
                  ),
                ),
              )
            ],
          )),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.add_circle_outline, color: Colors.white),
              onPressed: () => showCustomBottomSheet(yomi: onyomi, isOnyomi: true),
            ),
          )
        ],
      );

      var tileChildren = <Widget>[];

      for (var word in words) {
        tileChildren.add(ListTile(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => WordDetailPage(word: word)));
          },
          onLongPress: () {
            showModalBottomSheet(
                context: context,
                builder: (_) => ListTile(
                      title: Text('Delete from $onyomi'),
                      onTap: () {
                        kanji.onyomiWords.remove(word);
                        KanjiBloc.instance.updateKanji(kanji, isDeleted: true);
                        Navigator.pop(context);
                      },
                    ));
          },
          title: FuriganaText(
            text: word.wordText,
            tokens: [Token(text: word.wordText, furigana: word.wordFurigana)],
            style: TextStyle(fontSize: 24),
          ),
          subtitle: Text(word.meanings, style: TextStyle(color: Colors.white54)),
        ));
        tileChildren.add(Divider(
          height: 0,
          indent: 8,
          endIndent: 8,
        ));
      }

      if (words.isEmpty) {
        // tileChildren.add(Container(
        //   height: 100,
        //   child: Center(
        //     child: Text(
        //       'No compound words found _(┐「ε:)_',
        //       style: TextStyle(color: Colors.white54),
        //     ),
        //   ),
        // ));
      } else {
        tileChildren.removeLast();
      }

      if (onyomi.contains(RegExp(r'[.-]'))) {
        if (onyomiVerbGroup.isNotEmpty) {
          onyomiVerbGroup.add(Padding(
            padding: EdgeInsets.only(top: 12),
            child: tileTitle,
          ));
        } else {
          onyomiVerbGroup.add(tileTitle);
        }
        onyomiVerbGroup.addAll(tileChildren);
      } else {
        if (onyomiGroup.isNotEmpty) {
          onyomiGroup.add(Padding(
            padding: EdgeInsets.only(top: 12),
            child: tileTitle,
          ));
        } else {
          onyomiGroup.add(tileTitle);
        }
        onyomiGroup.addAll(tileChildren);
      }
    }

    var kunyomiWords = Set<Word>.from(kanji.kunyomiWords).toList();

    kunyomis.sort((a, b) => b.length.compareTo(a.length));

    for (var kunyomi in kunyomis) {
      var words = List.from(
          kunyomiWords.where((kunyomiWord) => kunyomiWord.wordFurigana.contains(kunyomi.replaceAll('.', '').replaceAll('-', ''))));

      kunyomiWords.removeWhere((word) => words.contains(word));

      var tileTitle = Stack(
        children: <Widget>[
          Positioned.fill(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(4),
                child: Container(
                  child: Padding(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        kunyomi,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      )),
                  decoration: BoxDecoration(
                    //boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                        ),
                  ),
                ),
              )
            ],
          )),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.add_circle_outline, color: Colors.white),
              onPressed: () => showCustomBottomSheet(yomi: kunyomi, isOnyomi: false),
            ),
          )
        ],
      );

      var tileChildren = <Widget>[];

      for (var word in words) {
        tileChildren.add(ListTile(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => WordDetailPage(word: word)));
          },
          onLongPress: () {
            showModalBottomSheet(
                context: context,
                builder: (_) => ListTile(
                      title: Text('Delete from $kunyomi'),
                      onTap: () {
                        kanji.kunyomiWords.remove(word);
                        KanjiBloc.instance.updateKanji(kanji, isDeleted: true);
                        Navigator.pop(context);
                      },
                    ));
          },
          title: FuriganaText(
            text: word.wordText,
            tokens: [Token(text: word.wordText, furigana: word.wordFurigana)],
            style: TextStyle(fontSize: 24),
          ),
          subtitle: Text(word.meanings, style: TextStyle(color: Colors.white54)),
        ));
        tileChildren.add(Divider(height: 0, indent: 8, endIndent: 8));
      }

      if (words.isEmpty) {
        // tileChildren.add(Container(
        //   height: 100,
        //   child: Center(
        //     child: Text(
        //       'No compound words found _(┐「ε:)_',
        //       style: TextStyle(color: Colors.white54),
        //     ),
        //   ),
        // ));
      } else {
        tileChildren.removeLast();
      }

      if (kunyomi.contains(RegExp(r'[.-]'))) {
        if (kunyomiVerbGroup.isNotEmpty) {
          kunyomiVerbGroup.add(Padding(
            padding: EdgeInsets.only(top: 12),
            child: tileTitle,
          ));
        } else {
          kunyomiVerbGroup.add(tileTitle);
        }
        kunyomiVerbGroup.addAll(tileChildren);
      } else {
        if (kunyomiGroup.isNotEmpty) {
          kunyomiGroup.add(Padding(
            padding: EdgeInsets.only(top: 12),
            child: tileTitle,
          ));
        } else {
          kunyomiGroup.add(tileTitle);
        }
        kunyomiGroup.addAll(tileChildren);
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ...onyomiGroup,
      ...kunyomiGroup,
      Padding(
          padding: EdgeInsets.all(12),
          child: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Flexible(
                flex: 4,
                child: Divider(color: Colors.white60),
              ),
              Flexible(
                  flex: 5,
                  child: Container(
                    child: Center(
                        child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              TextSpan(text: 'どうし　　　　けいようし' + '\n', style: TextStyle(fontSize: 9, color: Colors.white)),
                              TextSpan(text: '動詞 と 形容詞', style: TextStyle(fontSize: 18, color: Colors.white)),
                            ]))),
                  )),
              Flexible(
                flex: 4,
                child: Divider(color: Colors.white60),
              ),
            ],
          )),
      if (onyomiVerbGroup.isEmpty && kunyomiVerbGroup.isEmpty)
        Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Text(
              'No related verbs found _(┐「ε:)_',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ...onyomiVerbGroup,
      ...kunyomiVerbGroup,
    ]);
  }

  Widget buildKanjiInfoColumn() {
    return StreamBuilder(
      stream: KanjiBloc.instance.kanji,
      builder: (_, AsyncSnapshot<Kanji> snapshot) {
        if (snapshot.hasData || widget.kanji != null) {
          var kanji = widget.kanji == null ? snapshot.data : widget.kanji;

          Widget radicalPanel;

          if (kanji.radicals != null && kanji.radicals.isNotEmpty) {
            radicalPanel = InkWell(
              splashColor: Theme.of(context).primaryColor,
              highlightColor: Theme.of(context).primaryColor,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => SearchResultPage(radicals: kanji.radicals)));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  LabelDivider(
                      child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(children: [
                            TextSpan(text: 'ぶしゅ' + '\n', style: TextStyle(fontSize: 9, color: Colors.white)),
                            TextSpan(text: '部首', style: TextStyle(fontSize: 18, color: Colors.white))
                          ]))),
                  Padding(
                    padding: EdgeInsets.all(0),
                    child: Text("${kanji.radicals}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(0),
                    child: Text("${kanji.radicalsMeaning}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                children: <Widget>[
                  kanji.jlpt != 0
                      ? Padding(
                          padding: EdgeInsets.all(4),
                          child: Container(
                            child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Text(
                                  'N${kanji.jlpt}',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                )),
                            decoration: BoxDecoration(
                              //boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                                  ),
                            ),
                          ),
                        )
                      : Container(),
                  GradeChip(
                    grade: kanji.grade,
                  )
                ],
              ),
              Padding(
                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  child: Text(
                    "${kanji.strokes} strokes",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  )),
              if (kanji.radicals != null && kanji.radicals.isNotEmpty)
                DescribedFeatureOverlay(
                    featureId: 'more_radicals',
                    // Unique id that identifies this overlay.
                    tapTarget: Text('部首', style: TextStyle(fontSize: 18)),
                    // The widget that will be displayed as the tap target.
                    title: Text('Radicals'),
                    description: Text('Tap here if you want to see more kanji with this radical.'),
                    backgroundColor: Theme.of(context).primaryColor,
                    targetColor: Colors.white,
                    textColor: Colors.white,
                    child: radicalPanel),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }

  ///show modal bottom sheet where user can add words to onyomi or kunyomi
  void showCustomBottomSheet({String yomi, bool isOnyomi}) {
    var yomiTextEditingController = TextEditingController();
    var wordTextEditingController = TextEditingController();
    var meaningTextEditingController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    yomiTextEditingController.text = yomi.replaceFirst('.', '');

    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 300),
      context: context,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: 360,
              margin: EdgeInsets.only(top: 48, left: 12, right: 12),
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8)), color: Theme.of(context).primaryColor),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Add a word to',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          SizedBox(width: 12),
                          Container(
                            child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Text(
                                  yomi,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                )),
                            decoration: BoxDecoration(
                              //boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(5.0) //                 <--- border radius here
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: TextFormField(
                          validator: (str) {
                            if (str == null || str.isEmpty) {
                              return "Can't be empty";
                            }
                            return null;
                          },
                          controller: yomiTextEditingController,
                          decoration: InputDecoration(
                            focusColor: Colors.white,
                            labelText: isOnyomi ? 'Onyomi' : 'Kunyomi',
                            labelStyle: TextStyle(color: Colors.white70),
                            border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                          ),
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          minLines: 1,
                          maxLines: 1,
                        )),
                    SizedBox(height: 12),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: TextFormField(
                        validator: (str) {
                          if (str == null || str.isEmpty) {
                            return "Can't be empty";
                          }
                          return null;
                        },
                        controller: wordTextEditingController,
                        decoration: InputDecoration(
                          focusColor: Colors.white,
                          labelText: 'Word',
                          labelStyle: TextStyle(color: Colors.white70),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                        ),
                        style: TextStyle(color: Colors.white),
                        minLines: 1,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(height: 12),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: TextFormField(
                        validator: (str) {
                          if (str == null || str.isEmpty) {
                            return "Can't be empty";
                          }
                          return null;
                        },
                        controller: meaningTextEditingController,
                        decoration: InputDecoration(
                          focusColor: Colors.white,
                          labelText: 'Meaning',
                          labelStyle: TextStyle(color: Colors.white70),
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                        ),
                        style: TextStyle(color: Colors.white),
                        minLines: 1,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                          width: MediaQuery.of(context).size.width - 24,
                          height: 42,
                          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8))),
                          child: ElevatedButton(
                              child: Text(
                                'Add',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                if (formKey.currentState.validate()) {
                                  if (isOnyomi) {
                                    kanji.onyomiWords.add(Word(
                                        wordText: wordTextEditingController.text,
                                        wordFurigana: yomiTextEditingController.text,
                                        meanings: meaningTextEditingController.text));
                                  } else {
                                    kanji.kunyomiWords.add(Word(
                                        wordText: wordTextEditingController.text,
                                        wordFurigana: yomiTextEditingController.text,
                                        meanings: meaningTextEditingController.text));
                                  }
                                }
                                KanjiBloc.instance.updateKanji(kanji);
                                Navigator.pop(context);
                                setState(() {});
                              })),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(CurvedAnimation(parent: anim, curve: SpringCurve.underDamped)),
          child: child,
        );
      },
    );
  }

  launchURL(String targetKanji) async {
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

class KanjiBlock extends StatefulWidget {
  final String kanjiStr;
  final double scaleFactor;

  KanjiBlock({this.kanjiStr, this.scaleFactor = 1}) : assert(kanjiStr != null && kanjiStr.length == 1);

  @override
  _KanjiBlockState createState() => _KanjiBlockState();
}

class _KanjiBlockState extends State<KanjiBlock> {
  VideoPlayerController videoController;
  bool isPlaying = false;

  @override
  void initState() {
    loadVideo();

    super.initState();
  }

  loadVideo() async {
    if (allVideoFiles.contains(widget.kanjiStr)) {
      setState(() {
        videoController = VideoPlayerController.asset(Uri.encodeFull('video/${widget.kanjiStr}.mp4'))
          ..initialize().whenComplete(() {
            setState(() {});
          })
          ..addListener(() async {
            if (videoController != null && this.mounted) {
              if (await videoController.position >= videoController.value.duration + Duration(seconds: 1) && isPlaying) {
                videoController.pause();
                videoController.seekTo(Duration(seconds: 0));

                print("paused vc is $videoController");

                setState(() {
                  isPlaying = false;
                  //loadVideo();
                });
              }
            }
          });
      });
    }
  }

  @override
  void dispose() {
    print("${widget.kanjiStr}.mp4 disposed");
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("isPlaying now is $isPlaying and vc is $videoController");
    return Stack(
      children: <Widget>[
        Positioned.fill(
            child: Image.asset(
          'data/matts.png',
        )),
        if (isPlaying == false)
          Align(
            alignment: Alignment.center,
            child: Center(
                child: Hero(
                    tag: widget.kanjiStr,
                    child: Material(
                      //wrap the text in Material so that Hero transition doesn't glitch
                      color: Colors.transparent,
                      child: Text(
                        widget.kanjiStr,
                        style: TextStyle(fontFamily: 'strokeOrders', fontSize: 128),
                        textScaleFactor: widget.scaleFactor,
                        textAlign: TextAlign.center,
                      ),
                    ))),
          ),
        if (videoController != null && videoController.value.initialized && isPlaying == true)
          Positioned.fill(
              child: Center(
                  child: Padding(
            padding: EdgeInsets.all(24),
            child: StrokeAnimationPlayer(kanjiStr: widget.kanjiStr, videoController: videoController),
          ))),
        if (isPlaying)
          Positioned.fill(
              child: Image.asset(
            'data/matts.png',
          )),
        if (videoController != null && videoController.value.initialized && isPlaying == false)
          Positioned.fill(
              child: Center(
                  child: Opacity(
                      opacity: 0.7,
                      child: Material(
                        child: InkWell(
                            onTap: () {
                              setState(() {
                                isPlaying = true;
                                videoController.play();
                              });
                            },
                            child: Icon(Icons.play_arrow)),
                      ))))
      ],
    );
  }
}

class StrokeAnimationPlayer extends StatefulWidget {
  final String kanjiStr;
  final VideoPlayerController videoController;

  StrokeAnimationPlayer({this.kanjiStr, this.videoController}) : assert(kanjiStr != null && kanjiStr.length == 1);

  @override
  _StrokeAnimationPlayerState createState() => _StrokeAnimationPlayerState();
}

class _StrokeAnimationPlayerState extends State<StrokeAnimationPlayer> {
  VideoPlayerController videoController;

  @override
  void initState() {
    videoController = widget.videoController;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (videoController == null) return Container();
//    return AspectRatio(
//      aspectRatio: videoController.value.aspectRatio,
//      // Use the VideoPlayer widget to display the video.
//      child: VideoPlayer(videoController),
//    );
    return FutureBuilder(
      future: videoController.initialize(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: videoController.value.aspectRatio,
            // Use the VideoPlayer widget to display the video.
            child: VideoPlayer(videoController),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
