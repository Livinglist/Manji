import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../bloc/kana_bloc.dart';
import 'components/furigana_text.dart';

class KanaPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => KanaPageState();
}

class KanaPageState extends State<KanaPage> {
  final flutterTts = FlutterTts();
  bool showHandwritten = true;

  @override
  void initState() {
    flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playAndRecord, [
      IosTextToSpeechAudioCategoryOptions.allowBluetooth,
      IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
      IosTextToSpeechAudioCategoryOptions.mixWithOthers
    ]);
    flutterTts.setLanguage("ja");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: FuriganaText(
            text: '仮名',
            tokens: [Token(text: '仮名', furigana: 'かな')],
            style: const TextStyle(fontSize: 20),
          ),
          bottom: const TabBar(tabs: [
            Tab(
              text: 'ひらがな',
            ),
            Tab(
              text: 'カタカナ',
            )
          ]),
          actions: [
            IconButton(
              icon: Icon(showHandwritten
                  ? FontAwesomeIcons.book
                  : FontAwesomeIcons.signature),
              onPressed: () =>
                  setState(() => showHandwritten = !showHandwritten),
            )
          ],
        ),
        body: TabBarView(children: [
          StreamBuilder(
            stream: kanaBloc.hiragana,
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                final hiraganas = snapshot.data;
                return KanaGridView(
                  kanas: hiraganas,
                  showHandwritten: showHandwritten,
                  onTap: flutterTts.speak,
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          StreamBuilder(
            stream: kanaBloc.katakana,
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                final katakana = snapshot.data;
                return KanaGridView(
                  kanas: katakana,
                  showHandwritten: showHandwritten,
                  onTap: flutterTts.speak,
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          )
        ]),
      ),
    );
  }
}

class KanaGridView extends StatelessWidget {
  final List<Kana> kanas;
  final bool showHandwritten;
  final ValueChanged<String> onTap;

  KanaGridView({this.kanas, this.showHandwritten, this.onTap})
      : assert(kanas != null);

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);
    return Container(
      height: MediaQuery.of(context).size.height,
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 5,
        children: List.generate(kanas.length, (index) {
          return Center(
              child: InkWell(
            onTap: () => onTap(kanas[index].kana),
            child: showHandwritten
                ? Container(
                    width: MediaQuery.of(context).size.width / 5,
                    height: MediaQuery.of(context).size.width / 5,
                    child: Center(
                      child: Stack(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              kanas[index].kana ?? '',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontFamily: 'Ai'),
                              textScaleFactor:
                                  MediaQuery.of(context).size.width / 375,
                            ),
                          ),
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: Text(kanas[index].pron ?? '',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                  textScaleFactor:
                                      MediaQuery.of(context).size.width / 375))
                        ],
                      ),
                    ))
                : Container(
                    width: MediaQuery.of(context).size.width / 5,
                    height: MediaQuery.of(context).size.width / 5,
                    child: Center(
                      child: Stack(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Text(kanas[index].kana ?? '',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 36),
                                textScaleFactor:
                                    MediaQuery.of(context).size.width / 375),
                          ),
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: Text(kanas[index].pron ?? '',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                  textScaleFactor:
                                      MediaQuery.of(context).size.width / 375))
                        ],
                      ),
                    )),
          ));
        }),
      ),
    );
  }
}
