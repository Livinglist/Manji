import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kanji_dictionary/bloc/kanji_list_bloc.dart';

import 'package:kanji_dictionary/models/sentence.dart';
import 'package:kanji_dictionary/models/word.dart';
import 'package:kanji_dictionary/bloc/sentence_bloc.dart';
import 'package:kanji_dictionary/ui/sentence_detail_page.dart';
import 'components/furigana_text.dart';
import 'kanji_detail_page.dart';

class WordDetailPage extends StatefulWidget {
  final Word word;

  WordDetailPage({this.word});

  @override
  State<StatefulWidget> createState() => WordDetailPageState();
}

class WordDetailPageState extends State<WordDetailPage> {
  final sentenceBloc = SentenceBloc();
  final scrollController = ScrollController();
  final flutterTts = FlutterTts();
  double width, elevation = 0;
  bool showShadow = false;

  @override
  void initState() {
    flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playAndRecord, [
      IosTextToSpeechAudioCategoryOptions.allowBluetooth,
      IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
      IosTextToSpeechAudioCategoryOptions.mixWithOthers
    ]);
    flutterTts.setLanguage("ja");

    sentenceBloc.fetchSentencesByWords(widget.word.wordText);

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

    scrollController.addListener(() {
      if (this.mounted) {
        if (scrollController.offset >= scrollController.position.maxScrollExtent) {
          sentenceBloc.fetchMoreSentencesByWordFromJisho(widget.word.wordText);
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
              onPressed: () => flutterTts.speak(widget.word.wordText),
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
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: FuriganaText(
                  text: widget.word.wordText,
                  tokens: [Token(text: widget.word.wordText, furigana: widget.word.wordFurigana)],
                  style: TextStyle(fontSize: 24),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  widget.word.meanings,
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              if (widget.word.wordText.length > 1)
                Container(
                    width: width,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          //for (var token in widget.sentence.tokens.where((token) => token.isKanji))
                          for (var kanji in getKanjis(widget.word.wordText))
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: ClipRRect(
                                child: Container(
                                  color: Colors.teal,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      splashColor: Colors.tealAccent,
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => KanjiDetailPage(kanjiStr: kanji)));
                                      },
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.transparent,
                                        child: Center(
                                            child: Text(
                                          getSingleKanji(kanji) ?? "",
                                          style: TextStyle(fontSize: 24, color: Colors.white, fontFamily: 'kazei'),
                                        )),
                                      ),
                                    ),
                                  ),
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(30)),
                              ),
                            )
                        ],
                      ),
                    )),
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
                              target: widget.word.wordText,
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
                    return Column(
                      children: [
                        ...children,
                        StreamBuilder(
                          stream: sentenceBloc.isFetching,
                          initialData: false,
                          builder: (_, AsyncSnapshot<bool> isFetchingSnapshot) {
                            if (isFetchingSnapshot.data == null) {
                              return Container(
                                height: 48,
                              );
                            } else if (isFetchingSnapshot.data) {
                              return Container(
                                key: Key('ProgressIndicator'),
                                height: 96,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            return Container(
                              height: 48,
                            );
                          },
                        ),
                      ],
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
                              //var isInList = KanjiListBloc.instance.isInList(kanjiList);

                              var subtitle = '';

                              if(kanjiList.kanjiCount > 0){
                                subtitle += '${kanjiList.kanjiCount} Kanji';
                              }

                              if(kanjiList.wordCount > 0){
                                subtitle += (subtitle.isEmpty ? '' : ', ') + '${kanjiList.wordCount} Words';
                              }

                              if(kanjiList.wordCount <= 1) subtitle = subtitle.substring(0, subtitle.length - 1);

                              if(kanjiList.sentenceCount > 0){
                                subtitle += (subtitle.isEmpty ? '' : ', ') + '${kanjiList.sentenceCount} Sentences';
                              }

                              if(kanjiList.sentenceCount <= 1) subtitle = subtitle.substring(0, subtitle.length - 1);

                              if(subtitle.isEmpty){
                                subtitle = 'Empty';
                              }

                              return ListTile(
                                title: Text(kanjiLists[index].name, style: TextStyle(color: Colors.black)),
                                subtitle: Text(subtitle),
                                onTap: () {
                                  Navigator.pop(context);
                                  KanjiListBloc.instance.addWord(kanjiList, widget.word);
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                      '${widget.word.wordText} has been added to ${kanjiList.name}',
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

  List<String> getKanjis(String str) {
    var kanjis = <String>[];
    for (int i = 0; i < str.length; i++) {
      if (str.codeUnitAt(i) > 12543 && !kanjis.contains(str[i])) {
        kanjis.add(str[i]);
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
