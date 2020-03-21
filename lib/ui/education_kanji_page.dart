import 'package:flutter/material.dart';

import 'package:kanji_dictionary/models/kanji.dart';
import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import 'package:kanji_dictionary/ui/components/kanji_list_view.dart';
import 'package:kanji_dictionary/ui/components/kanji_grid_view.dart';
import 'components/furigana_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EducationKanjiPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EducationKanjiPageState();
}

class EducationKanjiPageState extends State<EducationKanjiPage> {
  //show gridview by default
  bool showGrid = true;
  bool altSorted = false;
  Map<int, List<Kanji>> gradeToKanjisMap = {
    0: [],
    1: [],
    2: [],
    3: [],
    4: [],
    5: [],
    6: [],
  };

  @override
  void initState() {
    super.initState();

    for (var kanji in kanjiBloc.allKanjisList) {
      gradeToKanjisMap[kanji.grade].add(kanji);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: kanjiBloc.allKanjis,
      builder: (_, AsyncSnapshot<List<Kanji>> snapshot) {
        return DefaultTabController(
          length: 7,
          child: Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            appBar: AppBar(
              //title: Text('日本語能力試験漢字'),
              title: FuriganaText(
                text: '教育漢字',
                tokens: [Token(text: '教育', furigana: 'きょういく'), Token(text: '漢字', furigana: 'かんじ')],
                style: TextStyle(fontSize: 20),
              ),
              actions: <Widget>[
                IconButton(
                    icon: AnimatedCrossFade(
                      firstChild: Icon(
                        FontAwesomeIcons.sortNumericDown,
                        color: Colors.white,
                      ),
                      secondChild: Icon(
                        FontAwesomeIcons.sortNumericDownAlt,
                        color: Colors.white,
                      ),
                      crossFadeState: altSorted ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                      duration: Duration(milliseconds: 200),
                    ),
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        altSorted = !altSorted;
                      });
                    }),
                IconButton(
                  icon: AnimatedCrossFade(
                    firstChild: Icon(
                      Icons.view_headline,
                      color: Colors.white,
                    ),
                    secondChild: Icon(
                      Icons.view_comfy,
                      color: Colors.white,
                    ),
                    crossFadeState: showGrid ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    duration: Duration(milliseconds: 200),
                  ),
                  onPressed: () {
                    setState(() {
                      showGrid = !showGrid;
                    });
                  },
                ),
              ],
              bottom: TabBar(isScrollable: true, tabs: [
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
      },
    );
  }

  Widget buildTabBarViewChildren(int grade) {
    if (altSorted) {
      gradeToKanjisMap[grade].sort((l, r) => r.strokes.compareTo(l.strokes));
    } else {
      gradeToKanjisMap[grade].sort((l, r) => l.strokes.compareTo(r.strokes));
    }

    return AnimatedCrossFade(
        firstChild: KanjiGridView(
          kanjis: gradeToKanjisMap[grade],
          fallBackFont: 'ming',
        ),
        secondChild: KanjiListView(
          kanjis: gradeToKanjisMap[grade],
          fallBackFont: 'ming',
        ),
        crossFadeState: showGrid ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        duration: Duration(milliseconds: 200));
  }
}
