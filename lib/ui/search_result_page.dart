import 'package:flutter/material.dart';

import 'package:kanji_dictionary/models/kanji.dart';
import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import 'package:kanji_dictionary/ui/components/kanji_list_view.dart';
import 'package:kanji_dictionary/ui/components/kanji_grid_view.dart';
import 'components/furigana_text.dart';

class SearchResultPage extends StatefulWidget {
  final String text;

  SearchResultPage({this.text}) : assert(text != null);

  @override
  State<StatefulWidget> createState() => SearchResultPageState();
}

class SearchResultPageState extends State<SearchResultPage> {
  String text;
  List<Kanji> kanjis = <Kanji>[];

  @override
  void initState() {
    text = widget.text;
    for (int i = 0; i < text.length; i++) {
      if (text.codeUnitAt(i) > 12543) {
        kanjis.add(kanjiBloc.getKanjiInfo(text[i]));
      }
    }
    kanjis.addAll(kanjiBloc.searchKanjiInfosByStr(text));
    kanjis.removeWhere((kanji) => kanji == null);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(),
        body: kanjis.isNotEmpty
            ? KanjiListView(kanjis: kanjis)
            : Center(
                child: Text(
                  'No results found _(┐「ε:)_',
                  style: TextStyle(color: Colors.white70),
                ),
              ));
  }
}

//class KanjiGridView extends StatelessWidget {
//  final List<Kanji> kanjis;
//
//  KanjiGridView({this.kanjis}) : assert(kanjis != null);
//
//  @override
//  Widget build(BuildContext context) {
//    return GridView.count(
//      crossAxisCount: 6,
//      children: kanjis.map((kanji) {
//        return Center(
//          child: InkWell(
//            child:Container(
//              width: double.infinity,
//              height: double.infinity,
//              child: Center(
//                child: Text(kanji.kanji, style: TextStyle(color: Colors.white, fontSize: 28, fontFamily: 'kazei')),
//              )
//            ),
//            onTap: (){
//              Navigator.push(context, MaterialPageRoute(builder: (_)=>KanjiDetailPage(kanji: kanji)));
//            },
//          )
//        );
//      }).toList(),
//    );
//  }
//}
