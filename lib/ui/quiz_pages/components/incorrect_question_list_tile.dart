import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../kanji_detail_page/kanji_detail_page.dart';
import '../../../ui/components/chip_collections.dart';
import '../../../models/question.dart';
import '../../../bloc/settings_bloc.dart';

class IncorrectQuestionListTile extends StatelessWidget {
  final Question question;
  final double fontSize;

  IncorrectQuestionListTile({this.question})
      : assert(question != null),
        fontSize = typeToFontSize(question.questionType);

  @override
  Widget build(BuildContext context) {
    var kanji = question.targetedKanji;
    var wrongKana = question.choices[question.selected];
    var rightKana = question.rightAnswer;
    var tag = UniqueKey().toString() +
        kanji.kanji +
        question.questionType.index.toString();
    return ListTile(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => KanjiDetailPage(kanji: kanji, tag: tag)));
      },
      leading: Container(
        width: 36,
        height: 36,
        child: Center(
          child: Hero(
            tag: tag,
            child: Material(
              color: Colors.transparent,
              child: StreamBuilder(
                key: ObjectKey(kanji.kanji),
                stream: SettingsBloc.instance.fontSelection,
                builder: (_, AsyncSnapshot<FontSelection> snapshot) {
                  return Text(kanji.kanji,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontFamily: snapshot.data == FontSelection.handwriting
                            ? Fonts.kazei
                            : Fonts.ming,
                      ));
                },
              ),
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
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            )),
                        decoration: BoxDecoration(
                          //boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(
                                  5.0) //                 <--- border radius here
                              ),
                        ),
                      ),
                    )
                  : Container(),
              GradeChip(
                  grade: kanji.grade,
                  textStyle:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
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
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          )),
                      decoration: BoxDecoration(
                        //boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(
                                5.0) //                 <--- border radius here
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
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        )),
                    decoration: BoxDecoration(
                      //boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(
                              5.0) //                 <--- border radius here
                          ),
                    ),
                  ),
                )
            ],
          ),
          Divider(),
          if (question.questionType == QuestionType.KanjiToKatakana)
            Row(children: <Widget>[
              Icon(FontAwesomeIcons.checkCircle, color: Colors.greenAccent),
              Spacer(),
              Text(rightKana,
                  style:
                      TextStyle(color: Colors.greenAccent, fontSize: fontSize))
            ]),
          if (question.questionType == QuestionType.KanjiToMeaning ||
              question.questionType == QuestionType.KanjiToHiragana)
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(FontAwesomeIcons.checkCircle, color: Colors.greenAccent),
                  Spacer(),
                  Flexible(
                    child: Text(rightKana,
                        style: TextStyle(
                            color: Colors.greenAccent, fontSize: fontSize),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  )
                ]),
          Divider(),
          if (question.questionType == QuestionType.KanjiToKatakana)
            Row(children: <Widget>[
              Icon(FontAwesomeIcons.timesCircle, color: Colors.redAccent),
              Spacer(),
              Text(wrongKana,
                  style: TextStyle(color: Colors.redAccent, fontSize: fontSize))
            ]),
          if (question.questionType == QuestionType.KanjiToMeaning ||
              question.questionType == QuestionType.KanjiToHiragana)
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(FontAwesomeIcons.timesCircle, color: Colors.redAccent),
                  Spacer(),
                  Flexible(
                      child: Text(wrongKana,
                          style: TextStyle(
                              color: Colors.redAccent, fontSize: fontSize),
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis))
                ]),
          Divider(),
          Text(
            question.targetedKanji.meaning,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  static double typeToFontSize(QuestionType type) {
    switch (type) {
      case QuestionType.KanjiToKatakana:
        return 22;
      case QuestionType.KanjiToMeaning:
        return 16;
      default:
        return 16;
    }
  }
}
