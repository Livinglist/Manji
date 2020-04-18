import 'package:flutter/material.dart';

import 'package:kanji_dictionary/ui/kanji_detail_page.dart';
import 'package:kanji_dictionary/models/kanji.dart';
import 'chip_collections.dart';

typedef void StringCallback(String str);

class KanjiListView extends StatelessWidget {
  final List<Kanji> kanjis;
  final String fallBackFont;
  final StringCallback onLongPressed;
  final bool canRemove;
  final ScrollController scrollController;
  final ScrollPhysics scrollPhysics;

  KanjiListView(
      {this.kanjis,
      this.fallBackFont,
      this.onLongPressed,
      this.canRemove = false,
      this.scrollController,
      this.scrollPhysics = const AlwaysScrollableScrollPhysics()})
      : assert(kanjis != null);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        physics: scrollPhysics,
        shrinkWrap: true,
        controller: scrollController,
        itemBuilder: (_, index) {
          return ListTile(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => KanjiDetailPage(kanji: kanjis[index])));
            },
            onLongPress: () {
              if (onLongPressed != null) {
                onLongPressed(kanjis[index].kanji);
              }
            },
            leading: Container(
              width: 28,
              height: 28,
              child: Center(
                child: Hero(
                  tag: kanjis[index].kanji,
                  child: Material(
                    color: Colors.transparent,
                    child: Text(kanjis[index].kanji, style: TextStyle(color: Colors.white, fontSize: 28, fontFamily: fallBackFont ?? 'kazei')),
                  ),
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 8),
                Wrap(
                  children: <Widget>[
                    kanjis[index].jlpt != 0
                        ? Padding(
                            padding: EdgeInsets.all(4),
                            child: Container(
                              child: Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Text(
                                    'N${kanjis[index].jlpt}',
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
                    kanjis[index].grade != 0
                        ? GradeChip(
                            grade: kanjis[index].grade,
                          )
                        : Container(),
                    StrokeChip(stokeCount: kanjis[index].strokes)
                  ],
                ),
                Divider(height: 0),
                Wrap(
                  alignment: WrapAlignment.start,
                  direction: Axis.horizontal,
                  children: <Widget>[
                    for (var kunyomi in kanjis[index].kunyomi)
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
                    for (var onyomi in kanjis[index].onyomi)
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
              kanjis[index].meaning,
              style: TextStyle(color: Colors.grey),
            ),
          );
        },
        separatorBuilder: (_, __) => Divider(height: 0),
        itemCount: kanjis.length);
  }
}
