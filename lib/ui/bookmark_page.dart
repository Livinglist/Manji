import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../bloc/kanji_bloc.dart';
import 'components/kanji_grid_view.dart';
import 'components/kanji_list_view.dart';
import 'components/furigana_text.dart';

class MyKanjiPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyKanjiPageState();
}

class MyKanjiPageState extends State<MyKanjiPage> {
  //show gridview by default
  bool showGrid = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          //title: Text('収蔵した漢字'),
          title: FuriganaText(
            text: '収蔵した漢字',
            tokens: [
              Token(text: '収蔵', furigana: 'しゅうぞう'),
              Token(text: '漢字', furigana: 'かんじ')
            ],
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
              crossFadeState: showGrid
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: Duration(milliseconds: 200),
            )
          ],
          bottom: TabBar(tabs: [
            //Tab(child: Container(child: Text('N5'),color: Colors.black),),
            Tab(
              icon: Icon(FontAwesomeIcons.solidBookmark, color: Colors.teal),
            ),
            Tab(
              icon: Icon(FontAwesomeIcons.bookHeart, color: Colors.red),
            )
          ]),
        ),
        body: TabBarView(children: [
          StreamBuilder(
            stream: KanjiBloc.instance.allStarKanjis,
            builder: (_, AsyncSnapshot<List<Kanji>> snapshot) {
              if (snapshot.hasData) {
                var kanjis = snapshot.data;
                //kanjis.sort((kanjiLeft, kanjiRight)=>kanjiLeft.strokes.compareTo(kanjiRight.strokes));
                //return showGrid ? KanjiGridView(kanjis: kanjis) : KanjiListView(kanjis: kanjis);

                if (kanjis.isEmpty) {
                  return Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text(
                        'Go and explore more kanji！ (╯°Д°）╯',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                }

                if (showGrid) return KanjiGridView(kanjis: kanjis);
                return KanjiListView(kanjis: kanjis);
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          StreamBuilder(
            stream: KanjiBloc.instance.allFavKanjis,
            builder: (_, AsyncSnapshot<List<Kanji>> snapshot) {
              if (snapshot.hasData) {
                var kanjis = snapshot.data;

                //kanjis.sort((kanjiLeft, kanjiRight)=>kanjiLeft.strokes.compareTo(kanjiRight.strokes));
                //return showGrid ? KanjiGridView(kanjis: kanjis) : KanjiListView(kanjis: kanjis);

                if (kanjis.isEmpty) {
                  return Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text(
                        'Go and explore more kanji！ (╯°Д°）╯',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                }

                if (showGrid) return KanjiGridView(kanjis: kanjis);
                return KanjiListView(kanjis: kanjis);
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          )
        ]),
      ),
    );
  }
}
