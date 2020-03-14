import 'package:flutter/material.dart';

import 'package:kanji_dictionary/models/sentence.dart';
import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import 'components/furigana_text.dart';
import 'kanji_detail_page.dart';

class SentenceDetailPage extends StatefulWidget {
  final Sentence sentence;

  SentenceDetailPage({this.sentence});

  @override
  State<StatefulWidget> createState() => SentenceDetailPageState();
}

class SentenceDetailPageState extends State<SentenceDetailPage> {
  final scrollController = ScrollController();
  double elevation = 0;
  double width;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (this.mounted) {
        if (scrollController.offset <= 0) {
          setState(() {
            elevation = 0;
          });
        } else {
          setState(() {
            elevation = 8;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(elevation: elevation),
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
//                child: Text(
//                  widget.sentence.text,
//                  style: TextStyle(fontSize: 18, color: Colors.white),
//                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  widget.sentence.englishText,
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ),
              for (var kanji in getKanjiInfos(widget.sentence.tokens))
                ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => KanjiDetailPage(kanji: kanji)));
                  },
                  leading: Container(
                    width: 28,
                    height: 28,
                    child: Center(
                      child: Text(kanji.kanji, style: TextStyle(color: Colors.white, fontSize: 28, fontFamily: 'kazei')),
                    ),
                  ),
                  title: Column(
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
                          kanji.grade != 0
                              ? Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Container(
                                    child: Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Text(
                                          'Grade ${kanji.grade}',
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
                        ],
                      ),
                      Divider(height: 0),
                      Wrap(
                        alignment: WrapAlignment.start,
                        direction: Axis.horizontal,
                        children: <Widget>[
                          for (var kunyomi in kanji.kunyomi)
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
                                )),
                          for (var onyomi in kanji.onyomi)
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
                      ),
                    ],
                  ),
                  subtitle: Text(
                    kanji.meaning,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
//              Container(
//                  width: width,
//                  child: SingleChildScrollView(
//                    scrollDirection: Axis.horizontal,
//                    child: Row(
//                      children: <Widget>[
//                        //for (var token in widget.sentence.tokens.where((token) => token.isKanji))
//                        for (var kanji in getKanjis(widget.sentence.tokens))
//                          Padding(
//                            padding: EdgeInsets.all(8),
//                            child: ClipRRect(
//                              child: Container(
//                                color: Colors.teal,
//                                child: Material(
//                                  color: Colors.transparent,
//                                  child: InkWell(
//                                    splashColor: Colors.tealAccent,
//                                    onTap: (){
//                                      Navigator.push(context, MaterialPageRoute(builder: (_)=>KanjiDetailPage(kanjiStr: kanji)));
//                                    },
//                                    child: Container(
//                                      width: 60,
//                                      height: 60,
//                                      color: Colors.transparent,
//                                      child: Center(
//                                          child: Text(
//                                            getSingleKanji(kanji) ?? "",
//                                            style: TextStyle(fontSize: 24, color: Colors.white, fontFamily: 'kazei'),
//                                          )),
//                                    ),
//                                  ),
//                                ),
//                              ),
//                              borderRadius: BorderRadius.all(Radius.circular(30)),
//                            ),
//                          )
//                      ],
//                    ),
//                  )),
//              Container(
//                width: width,
//                child: Column(
//                  children: <Widget>[
//                    for (var token in widget.sentence.tokens.where((token) => token.isKanji))
//                      Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: WordCard(wordFurigana: token.furigana, wordText: token.text))
////                      ClipRRect(
////                        child: Container(
////                          decoration: BoxDecoration(color: Colors.teal,shape: BoxShape.rectangle, borderRadius: BorderRadius.all(Radius.circular(6))),
////                          child: Center(child: Text(token.text)),
////                        ),
////                        borderRadius: BorderRadius.all(Radius.circular(15)),
////                      )
//                  ],
//                ),
//              ),
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
          var kanjiInfo = kanjiBloc.getKanjiInfo(currentStr);
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
