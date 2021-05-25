import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../bloc/kanji_bloc.dart';
import 'components/kanji_grid_view.dart';
import 'components/kanji_list_view.dart';

class KanaDetailPage extends StatefulWidget {
  final String kana;
  final Yomikata yomikata;

  KanaDetailPage(this.kana, this.yomikata);

  @override
  State<StatefulWidget> createState() => KanaDetailPageState();
}

class KanaDetailPageState extends State<KanaDetailPage> {
  final flutterTts = FlutterTts();
  List<Kanji> kanjis = [];
  bool showGrid = false;
  bool showShadow = false;
  ScrollController gridScrollController = ScrollController();
  ScrollController listScrollController = ScrollController();

  @override
  void initState() {
    flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playAndRecord, [
      IosTextToSpeechAudioCategoryOptions.allowBluetooth,
      IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
      IosTextToSpeechAudioCategoryOptions.mixWithOthers
    ]);
    flutterTts.setLanguage("ja");

    KanjiBloc.instance
        .findKanjiByKana(widget.kana, widget.yomikata)
        .listen((kanji) {
      setState(() {
        kanjis.add(kanji);
      });
    });

    gridScrollController.addListener(() {
      if (mounted) {
        if (gridScrollController.offset <= 0) {
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

    listScrollController.addListener(() {
      if (mounted) {
        if (listScrollController.offset <= 0) {
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
  void dispose() {
    listScrollController.dispose();
    gridScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          elevation: 0,
          title: Container(),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: () => flutterTts.speak(widget.kana),
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
                  duration: const Duration(milliseconds: 200)),
              onPressed: () {
                setState(() {
                  showGrid = !showGrid;
                });
              },
            ),
          ],
        ),
        body: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Align(
                alignment: Alignment.topCenter,
                child: Material(
                  color: Theme.of(context).primaryColor,
                  elevation: showShadow ? 8 : 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 100,
                    child: Center(
                      child: Text(
                        widget.kana,
                        style: const TextStyle(
                          fontSize: 48,
                          color: Colors.white,
                          //fontFamily: 'Ai'
                        ),
                      ),
                    ),
                  ),
                )),
            Expanded(
              child: showGrid
                  ? KanjiGridView(
                      kanjis: kanjis,
                      scrollController: gridScrollController,
                    )
                  : KanjiListView(
                      kanjis: kanjis,
                      scrollController: listScrollController,
                    ),
            )
          ],
        ));
  }
}
