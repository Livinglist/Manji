import 'package:flutter/material.dart';

import '../../kanji_detail_page/kanji_detail_page.dart';
import '../../../bloc/settings_bloc.dart';
import '../../../models/kanji.dart';

class KanjiProgressListTile extends StatelessWidget {
  final Kanji kanji;
  final ValueChanged<String> onLongPressed;
  final VoidCallback onTap;

  KanjiProgressListTile({this.kanji, this.onLongPressed, this.onTap}) : assert(kanji != null);

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
                builder: (_, AsyncSnapshot<FontSelection> snapshot) {
                  return Text(kanji.kanji,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontFamily: snapshot.data == FontSelection.handwriting ? Fonts.kazei : Fonts.ming,
                      ));
                },
              ),
            ),
          ),
        ),
      ),
      title: Text('Studied ${kanji.timeStamps.length} ${kanji.timeStamps.length <= 1 ? 'time' : 'times'}',
          style: TextStyle(color: Colors.white)),
      subtitle: Text(
        kanji.meaning,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}
