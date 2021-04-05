import 'package:flutter/material.dart';

import '../kanji_detail_page/kanji_detail_page.dart';
import '../../models/kanji.dart';
import 'chip_collections.dart';

class KanjiListTile extends StatelessWidget {
  final Kanji kanji;
  final ValueChanged<String> onLongPressed;
  final VoidCallback onTap;

  KanjiListTile({this.kanji, this.onLongPressed, this.onTap}) : assert(kanji != null);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        if (onTap != null)
          this.onTap();
        else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => KanjiDetailPage(kanji: kanji)));
        }
      },
      onLongPress: () {
        if (onLongPressed != null) {
          onLongPressed(kanji.kanji);
        }
      },
      leading: Container(
        width: 36,
        height: 36,
        child: Center(
          child: Hero(
            tag: kanji.kanji,
            child: Material(
              color: Colors.transparent,
              child:
                  Text(kanji.kanji, style: TextStyle(color: Colors.white, fontSize: 36, fontFamily: 'kazei', fontFamilyFallback: ['Ai'])),
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
              JLPTChip(jlpt: kanji.jlpt),
              GradeChip(
                grade: kanji.grade,
              ),
              StrokeChip(stokeCount: kanji.strokes)
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
    );
  }
}
