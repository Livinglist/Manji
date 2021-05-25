import 'package:flutter/material.dart';

import '../../bloc/settings_bloc.dart';
import '../../models/kanji.dart';
import '../kanji_detail_page/kanji_detail_page.dart';
import 'chip_collections.dart';

class CompactKanjiListTile extends StatelessWidget {
  final Kanji kanji;
  final ValueChanged<String> onLongPressed;
  final VoidCallback onTap;

  CompactKanjiListTile({this.kanji, this.onLongPressed, this.onTap})
      : assert(kanji != null);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        if (onTap != null)
          this.onTap();
        else {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => KanjiDetailPage(kanji: kanji)));
        }
      },
      onLongPress: () {
        if (onLongPressed != null) {
          onLongPressed(kanji.kanji);
        }
      },
      leading: Container(
        width: 28,
        height: 28,
        child: Center(
          child: Hero(
            tag: kanji.kanji,
            child: Material(
              color: Colors.transparent,
              child: StreamBuilder(
                key: ObjectKey(kanji.kanji),
                stream: SettingsBloc.instance.fontSelection,
                initialData: SettingsBloc.instance.tempFontSelection,
                builder: (_, AsyncSnapshot<FontSelection> snapshot) {
                  if (snapshot.hasData) {
                    return Text(kanji.kanji,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontFamily: snapshot.data == FontSelection.handwriting
                              ? Fonts.kazei
                              : Fonts.ming,
                        ));
                  }
                  return Container();
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
              JLPTChip.compact(jlpt: kanji.jlpt),
              GradeChip(
                grade: kanji.grade,
                textStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              StrokeChip.compact(stokeCount: kanji.strokes)
            ],
          ),
          const Divider(height: 0),
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
                                fontSize: 12, fontWeight: FontWeight.bold),
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
                              fontSize: 12, fontWeight: FontWeight.bold),
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
        ],
      ),
      subtitle: Text(
        kanji.meaning,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
