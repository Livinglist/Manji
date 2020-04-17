import 'package:flutter/material.dart';

import 'package:kanji_dictionary/ui/kanji_detail_page.dart';
import 'package:kanji_dictionary/ui/components/chip_collections.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:kanji_dictionary/models/question.dart';

class IncorrectQuestionListTile extends StatelessWidget {
  final Question question;

  IncorrectQuestionListTile({this.question}) : assert(question != null);

  @override
  Widget build(BuildContext context) {
    var kanji = question.targetedKanji;
    var wrongKana = question.choices[question.selected];
    var rightKana = question.rightAnswer;
    return ListTile(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => KanjiDetailPage(kanji: kanji)));
      },
      leading: Container(
        width: 28,
        height: 28,
        child: Center(
          child: Hero(
            tag: kanji,
            child: Material(
              color: Colors.transparent,
              child: Text(kanji.kanji, style: TextStyle(color: Colors.white, fontSize: 28, fontFamily: 'kazei')),
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
              GradeChip(grade: kanji.grade),
            ],
          ),
          Divider(),
          Row(children: <Widget>[
            Icon(FontAwesomeIcons.checkCircle, color: Colors.greenAccent),
            Spacer(),
            Text(rightKana, style: TextStyle(color: Colors.greenAccent))
          ]),
          Divider(),
          Row(children: <Widget>[
            Icon(FontAwesomeIcons.timesCircle, color: Colors.redAccent),
            Spacer(),
            Text(wrongKana, style: TextStyle(color: Colors.redAccent))
          ]),
          Divider(),
          Text(
            question.targetedKanji.meaning,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
    ;
  }
}
