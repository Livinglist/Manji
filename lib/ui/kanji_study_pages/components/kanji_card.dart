import 'package:flutter/material.dart';

import 'package:flutter_device_type/flutter_device_type.dart';

import 'package:kanji_dictionary/bloc/sentence_bloc.dart';
import 'package:kanji_dictionary/ui/components/furigana_text.dart';
import 'package:kanji_dictionary/ui/kanji_detail_page.dart';

import '../../../models/kanji_card_content.dart';

export '../../../models/kanji_card_content.dart';

class KanjiCard extends StatefulWidget {
  final KanjiCardContent kanjiCardContent;
  final Color color;

  KanjiCard({this.kanjiCardContent, Color color, Key key})
      : this.color = color ?? Colors.grey[700],
        super(key: key ?? UniqueKey());

  @override
  KanjiCardState createState() => KanjiCardState();
}

class KanjiCardState extends State<KanjiCard> {
  final sentenceBloc = SentenceBloc();
  ContentType type;
  Kanji kanji;
  bool kanjiDetailsDisplayed = false;

  @override
  void initState() {
    type = widget.kanjiCardContent.contentType;
    kanji = widget.kanjiCardContent.kanji;
    sentenceBloc.getSingleSentenceByKanji(kanji.kanji);

    super.initState();

    //_color = Colors.grey[700].withBlue(100 + Random(DateTime.now().millisecondsSinceEpoch).nextInt(155));
  }

  @override
  void dispose() {
    sentenceBloc.dispose();
    super.dispose();
  }

  void switchContent() {
    setState(() {
      kanjiDetailsDisplayed = !kanjiDetailsDisplayed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      color: widget.color,
      borderRadius: BorderRadius.all(Radius.circular(12)),
      child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          splashColor: Colors.grey[600],
          onTap: switchContent,
          onDoubleTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => KanjiDetailPage(kanji: kanji))),
          child: AnimatedContainer(
            duration: Duration(microseconds: 600),
            child: kanjiDetailsDisplayed
                ? Container(
                    color: Colors.transparent,
                    height: MediaQuery.of(context).size.height * 0.6,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Center(
                      child: Flex(
                        //mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        direction: Axis.vertical,
                        children: <Widget>[
                          SizedBox(height: 48),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Text(kanji.meaning, textAlign: TextAlign.center, style: TextStyle(color: Colors.white70))),
                          Text(kanji.kanji, style: TextStyle(color: Colors.white, fontSize: 64)),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Text([...kanji.onyomi, ...kanji.kunyomi].where((s) => s.contains('\.|-') == false).join(','),
                                  textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18))),
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 0),
                            child: StreamBuilder(
                              stream: sentenceBloc.sentences,
                              builder: (_, AsyncSnapshot<List<Sentence>> snapshot) {
                                if (snapshot.hasData) {
                                  var sentence = snapshot.data.isEmpty ? null : snapshot.data.first;
                                  if (sentence == null) {
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
                                  return Padding(
                                      padding: EdgeInsets.only(
                                          left: sentence.text.length > 45 ? 4 : 8,
                                          right: sentence.text.length > 45 ? 4 : 8,
                                          bottom: sentence.englishText.length > 140 ? 0 : 48),
                                      child: Device.get().isTablet
                                          ? Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 4),
                                                    child: FuriganaText(
                                                      markTarget: true,
                                                      target: kanji.kanji,
                                                      text: sentence.text,
                                                      tokens: sentence.tokens,
                                                      style: TextStyle(fontSize: sentence.text.length > 50 ? 18 : 22),
                                                    )),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 48),
                                                  child: Text(
                                                    sentence.englishText,
                                                    style: TextStyle(color: Colors.white54),
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : ListTile(
                                              title: Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 4),
                                                  child: FuriganaText(
                                                    markTarget: true,
                                                    target: kanji.kanji,
                                                    text: sentence.text,
                                                    tokens: sentence.tokens,
                                                    style: TextStyle(fontSize: sentence.text.length > 50 ? 14 : 16),
                                                  )),
                                              subtitle: Padding(
                                                padding: EdgeInsets.symmetric(vertical: 4),
                                                child: Text(
                                                  sentence.englishText,
                                                  style: TextStyle(color: Colors.white54),
                                                  maxLines: 4,
                                                  overflow: TextOverflow.fade,
                                                ),
                                              )));
                                } else {
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
                              },
                            ),
                          ),
                          SizedBox(height: 24)
                        ],
                      ),
                    ),
                  )
                : Container(
                    color: Colors.transparent,
                    height: MediaQuery.of(context).size.height * 0.6,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Center(
                      child: Flex(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        direction: Axis.vertical,
                        children: <Widget>[
                          if (type == ContentType.kanji)
                            Text(kanji.kanji, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 64)),
                          if (type == ContentType.meaning)
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24),
                                child: Text(kanji.meaning, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24))),
                          if (type == ContentType.yomi)
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24),
                                child: Text([...kanji.onyomi, ...kanji.kunyomi].where((s) => s.contains('\.|-') == false).join(','),
                                    textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24)))
                          //Text(widget.kanji.meaning, style: TextStyle(color: Colors.white70))
                        ],
                      ),
                    ),
                  ),
          )),
    );
  }
}
