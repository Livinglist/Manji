import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../bloc/settings_bloc.dart';
import '../../../models/question.dart';
import '../../../ui/components/chip_collections.dart';
import '../../kanji_detail_page/kanji_detail_page.dart';

class IncorrectQuestionListTile extends StatelessWidget {
  final Question question;
  final double fontSize;

  IncorrectQuestionListTile({this.question})
      : assert(question != null),
        fontSize = typeToFontSize(question.questionType);

  @override
  Widget build(BuildContext context) {
    final kanji = question.targetedKanji;
    final wrongKana = question.choices[question.selected];
    final rightKana = question.rightAnswer;
    final tag = UniqueKey().toString() +
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
                builder: (_, snapshot) {
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
          const SizedBox(height: 8),
          Wrap(
            children: <Widget>[
              kanji.jlpt != 0
                  ? Padding(
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              'N${kanji.jlpt}',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            )),
                        decoration: const BoxDecoration(
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
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          Wrap(
            alignment: WrapAlignment.start,
            direction: Axis.horizontal,
            children: <Widget>[
              for (var kunyomi in kanji.kunyomi)
                Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            kunyomi,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          )),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(
                                5.0) //                 <--- border radius here
                            ),
                      ),
                    )),
              for (var onyomi in kanji.onyomi)
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          onyomi,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        )),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(
                              5.0) //                 <--- border radius here
                          ),
                    ),
                  ),
                )
            ],
          ),
          const Divider(),
          if (question.questionType == QuestionType.kanjiToKatakana)
            Row(children: <Widget>[
              const Icon(FontAwesomeIcons.checkCircle,
                  color: Colors.greenAccent),
              const Spacer(),
              Text(rightKana,
                  style:
                      TextStyle(color: Colors.greenAccent, fontSize: fontSize))
            ]),
          if (question.questionType == QuestionType.kanjiToMeaning ||
              question.questionType == QuestionType.kanjiToHiragana)
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Icon(FontAwesomeIcons.checkCircle,
                      color: Colors.greenAccent),
                  const Spacer(),
                  Flexible(
                    child: Text(rightKana,
                        style: TextStyle(
                            color: Colors.greenAccent, fontSize: fontSize),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  )
                ]),
          const Divider(),
          if (question.questionType == QuestionType.kanjiToKatakana)
            Row(children: <Widget>[
              const Icon(FontAwesomeIcons.timesCircle, color: Colors.redAccent),
              const Spacer(),
              Text(wrongKana,
                  style: TextStyle(color: Colors.redAccent, fontSize: fontSize))
            ]),
          if (question.questionType == QuestionType.kanjiToMeaning ||
              question.questionType == QuestionType.kanjiToHiragana)
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Icon(FontAwesomeIcons.timesCircle,
                      color: Colors.redAccent),
                  const Spacer(),
                  Flexible(
                      child: Text(wrongKana,
                          style: TextStyle(
                              color: Colors.redAccent, fontSize: fontSize),
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis))
                ]),
          const Divider(),
          Text(
            question.targetedKanji.meaning,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  static double typeToFontSize(QuestionType type) {
    switch (type) {
      case QuestionType.kanjiToKatakana:
        return 22;
      case QuestionType.kanjiToMeaning:
        return 16;
      default:
        return 16;
    }
  }
}
