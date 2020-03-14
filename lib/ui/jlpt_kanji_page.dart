import 'package:flutter/material.dart';

import 'package:kanji_dictionary/models/kanji.dart';
import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import 'package:kanji_dictionary/ui/components/kanji_list_view.dart';
import 'package:kanji_dictionary/ui/components/kanji_grid_view.dart';
import 'components/furigana_text.dart';

class JLPTKanjiPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => JLPTKanjiPageState();
}

class JLPTKanjiPageState extends State<JLPTKanjiPage> {
  //show gridview by default
  bool showGrid = true;

  @override
  void initState() {
    //kanjiBloc.fetchKanjisByJLPTLevel(JLPTLevel.n5);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          //title: Text('日本語能力試験漢字'),
          title: FuriganaText(
            text: '日本語能力試験漢字',
            tokens: [Token(text: '日本語', furigana: 'にほんご'),Token(text: '能力', furigana: 'のうりょく'),Token(text: '試験', furigana: 'しけん'),Token(text: '漢字', furigana: 'かんじ')],
            style: TextStyle(fontSize: 20),
          ),
          actions: <Widget>[
//            IconButton(
//              icon: Icon(Icons.sort),
//              onPressed: (){
//
//              },
//            ),
            AnimatedCrossFade(
              firstChild: IconButton(
                icon: Icon(
                  Icons.view_headline,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    showGrid = !showGrid;
                  });
                },
              ),
              secondChild: IconButton(
                icon: Icon(
                  Icons.view_comfy,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    showGrid = !showGrid;
                  });
                },
              ),
              crossFadeState: showGrid ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: Duration(milliseconds: 200),
            )
          ],
          //elevation: 0,
          bottom: TabBar(
              onTap: (index) {
//                switch (index) {
//                  case 0:
//                    kanjiBloc.fetchKanjisByJLPTLevel(JLPTLevel.n5);
//                    break;
//                  case 1:
//                    kanjiBloc.fetchKanjisByJLPTLevel(JLPTLevel.n4);
//                    break;
//                  case 2:
//                    kanjiBloc.fetchKanjisByJLPTLevel(JLPTLevel.n3);
//                    break;
//                  case 3:
//                    kanjiBloc.fetchKanjisByJLPTLevel(JLPTLevel.n2);
//                    break;
//                  case 4:
//                    kanjiBloc.fetchKanjisByJLPTLevel(JLPTLevel.n1);
//                    break;
//                }
              },
              tabs: [
                Tab(
                  text: 'N5',
                ),
                Tab(
                  text: 'N4',
                ),
                Tab(
                  text: 'N3',
                ),
                Tab(
                  text: 'N2',
                ),
                Tab(
                  text: 'N1',
                ),
              ]),
        ),
        body: TabBarView(children: [
          buildTabBarViewChildren(JLPTLevel.n5),
          buildTabBarViewChildren(JLPTLevel.n4),
          buildTabBarViewChildren(JLPTLevel.n3),
          buildTabBarViewChildren(JLPTLevel.n2),
          buildTabBarViewChildren(JLPTLevel.n1),
        ]),
      ),
    );
  }

  Widget buildTabBarViewChildren(JLPTLevel jlptLevel) {
    return StreamBuilder(
      stream: kanjiBloc.allKanjis,
      builder: (_, AsyncSnapshot<List<Kanji>> snapshot) {
        if (snapshot.hasData) {
          var kanjis = snapshot.data.where((kanji) => kanji.jlptLevel == jlptLevel).toList();
          //kanjis.sort((kanjiLeft, kanjiRight)=>kanjiLeft.strokes.compareTo(kanjiRight.strokes));
          //return KanjiGridView(kanjis: kanjis);
          return AnimatedCrossFade(
              firstChild: KanjiGridView(kanjis: kanjis),
              secondChild: KanjiListView(kanjis: kanjis),
              crossFadeState: showGrid ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: Duration(milliseconds: 200));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
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
