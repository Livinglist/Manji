import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:kanji_dictionary/models/sentence.dart';
import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import 'components/furigana_text.dart';
import 'components/kanji_list_tile.dart';
import 'package:kanji_dictionary/utils/string_extension.dart';

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
            )
          ],
        ),
        body: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: FuriganaText(
                  text: widget.sentence.text,
                  tokens: widget.sentence.tokens,
                  style: TextStyle(fontSize: 24),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  widget.sentence.englishText,
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
              for (var kanji in widget.sentence.text.getKanjis().map((e) => KanjiBloc.instance.allKanjisMap[e]).toList()) KanjiListTile(kanji: kanji),
              SizedBox(
                height: 24,
              )
            ],
          ),
        ));
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
