import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../bloc/kanji_list_bloc.dart';
import '../bloc/sentence_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../models/sentence.dart';
import '../models/word.dart';
import '../ui/sentence_detail_page.dart';
import 'components/furigana_text.dart';
import 'kanji_detail_page/kanji_detail_page.dart';

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
      if (mounted) {
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
      if (mounted) {
        if (scrollController.offset >=
            scrollController.position.maxScrollExtent) {
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
              icon: const Icon(Icons.volume_up),
              onPressed: () => flutterTts.speak(widget.word.wordText),
            ),
            IconButton(
              icon: const Icon(Icons.playlist_add, size: 28),
              onPressed: onAddPressed,
            ),
          ],
        ),
        body: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: FuriganaText(
                  text: widget.word.wordText,
                  tokens: [
                    Token(
                        text: widget.word.wordText,
                        furigana: widget.word.wordFurigana)
                  ],
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  widget.word.meanings,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
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
                          for (var kanjiStr in getKanjis(widget.word.wordText))
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: ClipRRect(
                                child: Container(
                                  color: Colors.teal,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      splashColor: Colors.tealAccent,
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => KanjiDetailPage(
                                                    kanjiStr: kanjiStr)));
                                      },
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.transparent,
                                        child: Center(
                                          child: StreamBuilder(
                                            key: ObjectKey(kanjiStr),
                                            stream: SettingsBloc
                                                .instance.fontSelection,
                                            initialData: SettingsBloc
                                                .instance.tempFontSelection,
                                            builder: (_, snapshot) {
                                              final kanji =
                                                  getSingleKanji(kanjiStr) ??
                                                      "";
                                              if (snapshot.hasData) {
                                                return Text(kanji,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontFamily: snapshot
                                                                  .data ==
                                                              FontSelection
                                                                  .handwriting
                                                          ? Fonts.kazei
                                                          : Fonts.ming,
                                                    ));
                                              }
                                              return Container();
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(30)),
                              ),
                            )
                        ],
                      ),
                    )),
              StreamBuilder(
                stream: sentenceBloc.sentences,
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    final sentences = snapshot.data;
                    final children = <Widget>[];
                    if (sentences.isEmpty) {
                      return Container(
                        height: 360,
                        child: const Center(
                          child: Text(
                            'No example sentences found _(┐「ε:)_',
                            style: TextStyle(color: Colors.white38),
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
                              target: widget.word.wordText,
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
                    return Column(
                      children: [
                        ...children,
                        StreamBuilder(
                          stream: sentenceBloc.isFetching,
                          initialData: false,
                          builder: (_, isFetchingSnapshot) {
                            if (isFetchingSnapshot.data == null) {
                              return Container(
                                height: 48,
                              );
                            } else if (isFetchingSnapshot.data) {
                              return Container(
                                key: const Key('ProgressIndicator'),
                                height: 96,
                                child: const Center(
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
                    return Container(
                      height: 360,
                      child: const Center(
                          child: Text(
                        '( ͡• ͜ʖ ͡•)',
                        style: TextStyle(color: Colors.white38),
                      )),
                    );
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
                                    style:
                                        const TextStyle(color: Colors.black)),
                                subtitle: Text(subtitle),
                                onTap: () {
                                  Navigator.pop(context);
                                  KanjiListBloc.instance
                                      .addWord(kanjiList, widget.word);
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                      '${widget.word.wordText} has been added to ${kanjiList.name}',
                                      style:
                                          const TextStyle(color: Colors.black),
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

  List<String> getKanjis(String str) {
    final kanjis = <String>[];
    for (var i = 0; i < str.length; i++) {
      if (str.codeUnitAt(i) > 12543 && !kanjis.contains(str[i])) {
        kanjis.add(str[i]);
      }
    }

    return kanjis;
  }

  String getSingleKanji(String text) {
    for (var i = 0; i < text.length; i++) {
      if (text.codeUnitAt(i) > 12543) {
        return text[i];
      }
    }
    return null;
  }
}
