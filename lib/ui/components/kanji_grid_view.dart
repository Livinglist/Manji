import 'package:flutter/material.dart';

import 'package:kanji_dictionary/models/kanji.dart';
import 'package:kanji_dictionary/ui/kanji_detail_page.dart';

typedef void StringCallback(String str);

class KanjiGridView extends StatelessWidget{
  final List<Kanji> kanjis;
  final String fallBackFont;
  final StringCallback onLongPressed;
  final bool canRemove;
  final ScrollController scrollController;

  KanjiGridView({this.kanjis, this.fallBackFont, this.onLongPressed, this.canRemove = false, this.scrollController}) : assert(kanjis != null);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      controller: scrollController,
        shrinkWrap: true,
        crossAxisCount: 5,
        children: List.generate(kanjis.length, (index) {
          var kanji = kanjis[index];
          return Center(
              child: InkWell(
            child: Container(
                width: MediaQuery.of(context).size.width / 5,
                height: MediaQuery.of(context).size.width / 5,
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Text(kanji.kanji, style: TextStyle(color: Colors.white, fontSize: 48, fontFamily: fallBackFont ?? 'kazei')),
                    ),
                    Positioned(
                      left: 4,
                      top: 4,
                      child: Text(
                        (index + 1).toString(),
                        style: TextStyle(fontSize: 8, color: Colors.white24),
                      ),
                    )
                  ],
                )),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => KanjiDetailPage(kanji: kanji)));
            },
            onLongPress: () {
              if (onLongPressed != null) {
                onLongPressed(kanjis[index].kanji);
              }
            },
          ));
        }));
  }
}
