import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/sentence.dart';
import '../bloc/kanji_bloc.dart';
import '../bloc/kanji_list_bloc.dart';
import '../utils/string_extension.dart';
import 'components/furigana_text.dart';
import 'components/kanji_list_tile.dart';

class SentenceDetailPage extends StatefulWidget {
  final Sentence sentence;

  SentenceDetailPage({this.sentence});

  @override
  State<StatefulWidget> createState() => SentenceDetailPageState();
}

class SentenceDetailPageState extends State<SentenceDetailPage> {
  final scrollController = ScrollController();
  final flutterTts = FlutterTts();
  bool showShadow = false;
  double width;

  @override
  void initState() {
    flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playAndRecord, [
      IosTextToSpeechAudioCategoryOptions.allowBluetooth,
      IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
      IosTextToSpeechAudioCategoryOptions.mixWithOthers
    ]);
    flutterTts.setLanguage("ja");

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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          elevation: showShadow ? 8 : 0,
          actions: [
            IconButton(
              icon: Icon(Icons.volume_up),
              onPressed: () => flutterTts.speak(widget.sentence.text),
            ),
            IconButton(
              icon: Icon(Icons.playlist_add, size: 28),
              onPressed: onAddPressed,
            ),
          ],
        ),
        body: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: FuriganaText(
                  text: widget.sentence.text,
                  tokens: widget.sentence.tokens,
                  style: TextStyle(fontSize: 22),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  widget.sentence.englishText,
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
              for (var kanji
                  in widget.sentence.text.getKanjis().map((e) => KanjiBloc.instance.allKanjisMap[e]).toList()
                    ..removeWhere((e) => e == null))
                KanjiListTile(kanji: kanji),
              SizedBox(
                height: 24,
              )
            ],
          ),
        ));
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

                              var subtitle = '';

                              if (kanjiList.kanjiCount > 0) {
                                subtitle += '${kanjiList.kanjiCount} Kanji';
                              }

                              if (kanjiList.wordCount > 0) {
                                subtitle += (subtitle.isEmpty ? '' : ', ') + '${kanjiList.wordCount} Words';
                              }

                              if (kanjiList.wordCount == 1) subtitle = subtitle.substring(0, subtitle.length - 1);

                              if (kanjiList.sentenceCount > 0) {
                                subtitle += (subtitle.isEmpty ? '' : ', ') + '${kanjiList.sentenceCount} Sentences';
                              }

                              if (kanjiList.sentenceCount == 1) subtitle = subtitle.substring(0, subtitle.length - 1);

                              if (subtitle.isEmpty) {
                                subtitle = 'Empty';
                              }

                              return ListTile(
                                title: Text(kanjiLists[index].name, style: TextStyle(color: Colors.black)),
                                subtitle: Text(
                                  subtitle,
                                  style: TextStyle(color: Theme.of(context).primaryColor == Colors.black ? Colors.white60 : Colors.black54),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  KanjiListBloc.instance.addSentence(kanjiList, widget.sentence);
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                      'This sentence has been added to ${kanjiList.name}',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    backgroundColor: Theme.of(context).accentColor,
                                    action: SnackBarAction(
                                      label: 'Dismiss',
                                      onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                                      textColor: Colors.blueGrey,
                                    ),
                                  ));
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

  List<String> getKanjis(List<Token> tokens) {
    var kanjis = <String>[];
    for (var token in tokens) {
      for (int i = 0; i < token.text.length; i++) {
        if (token.text.codeUnitAt(i) > 12543) {
          if (!kanjis.contains(token.text[i])) kanjis.add(token.text[i]);
        }
      }
    }
    return kanjis;
  }

  List<Kanji> getKanjiInfos(List<Token> tokens) {
    var kanjiStrs = <String>[];
    var kanjis = <Kanji>[];
    for (var token in tokens) {
      for (int i = 0; i < token.text.length; i++) {
        var currentStr = token.text[i];
        if (token.text.codeUnitAt(i) > 12543 && !kanjiStrs.contains(currentStr)) {
          kanjiStrs.add(currentStr);
          var kanjiInfo = KanjiBloc.instance.getKanjiInfo(currentStr);
          if (kanjiInfo != null) kanjis.add(kanjiInfo);
        }
      }
    }
    return kanjis;
  }

  String getSingleKanji(String text) {
    for (int i = 0; i < text.length; i++) {
      if (text.codeUnitAt(i) > 12543) {
        return text[i];
      }
    }
    return null;
  }
}
