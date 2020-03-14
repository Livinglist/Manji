import 'package:flutter/material.dart';

import 'package:kanji_dictionary/models/kanji.dart';
import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import 'package:kanji_dictionary/ui/components/kanji_list_view.dart';
import 'package:kanji_dictionary/ui/components/kanji_grid_view.dart';
import 'components/furigana_text.dart';

class EducationKanjiPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EducationKanjiPageState();
}

class EducationKanjiPageState extends State<EducationKanjiPage> {
  //show gridview by default
  bool showGrid = true;

  @override
  void initState() {
    kanjiBloc.fetchKanjisByGrade(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          //title: Text('日本語能力試験漢字'),
          title: FuriganaText(
            text: '教育漢字',
            tokens: [Token(text: '教育', furigana: 'きょういく'),Token(text: '漢字', furigana: 'かんじ')],
            style: TextStyle(fontSize: 20),
          ),
          actions: <Widget>[
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
          bottom: TabBar(
            isScrollable: true,
              tabs: [
                //Tab(child: Container(child: Text('N5'),color: Colors.black),),
                Tab(
                  text: '1',
                ),
                Tab(
                  text: '2',
                ),
                Tab(
                  text: '3',
                ),
                Tab(
                  text: '4',
                ),
                Tab(
                  text: '5',
                ),
                Tab(
                  text: '6',
                ),
                Tab(
                  text: 'Junior High',
                ),
              ]),
        ),
        body: TabBarView(children: [
          buildTabBarViewChildren(1),
          buildTabBarViewChildren(2),
          buildTabBarViewChildren(3),
          buildTabBarViewChildren(4),
          buildTabBarViewChildren(5),
          buildTabBarViewChildren(6),
          buildTabBarViewChildren(0),
        ]),
      ),
    );
  }

  Widget buildTabBarViewChildren(int grade) {
    return StreamBuilder(
      stream: kanjiBloc.allKanjis,
      builder: (_, AsyncSnapshot<List<Kanji>> snapshot) {
        if (snapshot.hasData) {
          var kanjis = snapshot.data.where((kanji) => kanji.grade == grade).toList();
          //kanjis.sort((kanjiLeft, kanjiRight)=>kanjiLeft.strokes.compareTo(kanjiRight.strokes));
          //return KanjiGridView(kanjis: kanjis);
          return AnimatedCrossFade(
              firstChild: KanjiGridView(kanjis: kanjis, fallBackFont: 'ming',),
              secondChild: KanjiListView(kanjis: kanjis, fallBackFont: 'ming',),
              crossFadeState: showGrid ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: Duration(milliseconds: 200));
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
