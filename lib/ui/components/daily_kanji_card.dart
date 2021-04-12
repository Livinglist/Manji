import 'package:flutter/material.dart';

import '../../models/kanji.dart';
import '../../bloc/kanji_bloc.dart';
import '../kanji_detail_page/kanji_detail_page.dart';
import '../../ui/components/chip_collections.dart';

class DailyKanjiCard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DailyKanjiCardState();
}

class DailyKanjiCardState extends State<DailyKanjiCard>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      vsync: this,
      duration: Duration(milliseconds: 300),
      child: StreamBuilder(
        stream: KanjiBloc.instance.randomKanji,
        builder: (_, AsyncSnapshot<Kanji> snapshot) {
          if (snapshot.hasData) {
            var kanji = snapshot.data;
            return Container(
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                color: Colors.white,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Flex(
                          direction: Axis.horizontal,
                          children: <Widget>[
                            Flexible(
                              child: Container(
                                child: Center(
                                  child: Stack(
                                    children: <Widget>[
                                      Positioned.fill(
                                          child: Image.asset(
                                        'data/matts.png',
                                      )),
                                      Align(
                                        alignment: Alignment.center,
                                        child: Center(
                                            child: Hero(
                                                tag: '',
                                                child: Text(
                                                  kanji.kanji,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          'strokeOrders',
                                                      fontSize: 128),
                                                  textAlign: TextAlign.center,
                                                ))),
                                      )
                                    ],
                                  ),
                                  //child: Text(widget.kanjiStr ?? widget.kanji.kanji, style: TextStyle(fontFamily: 'strokeOrders', fontSize: 148))
                                ),
                              ),
                              flex: 1,
                            ),
                            Flexible(
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Wrap(
                                      children: <Widget>[
                                        kanji.jlpt != 0
                                            ? Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Container(
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.all(4),
                                                      child: Text(
                                                        'N${kanji.jlpt}',
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )),
                                                  decoration: BoxDecoration(
                                                    //boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                                                    color: Colors.grey,
                                                    borderRadius: BorderRadius.all(
                                                        Radius.circular(
                                                            5.0) //                 <--- border radius here
                                                        ),
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        GradeChip(
                                          grade: kanji.grade,
                                          color: Colors.grey,
                                        )
                                      ],
                                    ),
                                    RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                            text: '意味 ',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w600)),
                                        TextSpan(
                                            text: kanji.meaning,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600))
                                      ]),
                                    ),
                                    RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                            text: '使用頻度 ',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w600)),
                                        TextSpan(
                                            text: kanji.frequency.toString(),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600))
                                      ]),
                                    ),
                                  ],
                                ),
                                flex: 1)
                          ],
                        )),
                  ),
                  splashColor: Colors.grey,
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => KanjiDetailPage(kanji: kanji)));
                  },
                ),
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
