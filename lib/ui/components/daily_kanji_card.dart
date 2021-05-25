import 'package:flutter/material.dart';

import '../../bloc/kanji_bloc.dart';
import '../../ui/components/chip_collections.dart';
import '../kanji_detail_page/kanji_detail_page.dart';

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
      duration: const Duration(milliseconds: 300),
      child: StreamBuilder(
        stream: KanjiBloc.instance.randomKanji,
        builder: (_, snapshot) {
          if (snapshot.hasData) {
            final kanji = snapshot.data;
            return Container(
              decoration: const BoxDecoration(
                boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                color: Colors.white,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: Padding(
                        padding: const EdgeInsets.all(8),
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
                                                  style: const TextStyle(
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
                                                padding:
                                                    const EdgeInsets.all(4),
                                                child: Container(
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      child: Text(
                                                        'N${kanji.jlpt}',
                                                        style: const TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      )),
                                                  decoration:
                                                      const BoxDecoration(
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
                                        const TextSpan(
                                            text: '意味 ',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w600)),
                                        TextSpan(
                                            text: kanji.meaning,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600))
                                      ]),
                                    ),
                                    RichText(
                                      text: TextSpan(children: [
                                        const TextSpan(
                                            text: '使用頻度 ',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w600)),
                                        TextSpan(
                                            text: kanji.frequency.toString(),
                                            style: const TextStyle(
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
