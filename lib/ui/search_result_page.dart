import 'package:flutter/material.dart';

import 'package:kanji_dictionary/models/kanji.dart';
import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import 'package:kanji_dictionary/ui/components/kanji_list_view.dart';

class SearchResultPage extends StatefulWidget {
  final String text;

  SearchResultPage({this.text}) : assert(text != null);

  @override
  State<StatefulWidget> createState() => SearchResultPageState();
}

class SearchResultPageState extends State<SearchResultPage> {
  final scrollController = ScrollController();
  bool showShadow = false;
  List<Kanji> kanjis = <Kanji>[];
  Map<int, bool> jlptMap = {1: false, 2: false, 3: false, 4: false, 5: false};

  Map<int, bool> gradeMap = {
    0: false, //Junior High
    1: false,
    2: false,
    3: false,
    4: false,
    5: false,
    6: false
  };

  @override
  void initState() {
    scrollController.addListener(() {
      if (this.mounted) {
        if (scrollController.offset <= 0) {
          setState(() {
            showShadow = false;
          });
        } else if (showShadow == false) {
          setState(() {
            showShadow = true;
          });
        }
      }
    });

    super.initState();
    kanjiBloc.searchKanjiInfosByStr(widget.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          elevation: showShadow ? 8 : 0,
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.all(12),
              child: StreamBuilder(
                stream: kanjiBloc.searchResults,
                builder: (_, AsyncSnapshot<List<Kanji>> snapshot) {
                  if (snapshot.hasData) {
                    var kanjis = snapshot.data;

                    return Center(child: Text('${kanjis.length} kanji found'));
                  }
                  return Container();
                },
              ),
            )
          ],
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(80),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        runSpacing: 12,
                        spacing: 12,
                        children: <Widget>[
                          SizedBox(width: 12),
                          for (var n in jlptMap.keys)
                            FilterChip(
                                selected: jlptMap[n],
                                elevation: 4,
                                label: Text("N$n"),
                                onSelected: (val) {
                                  setState(() {
                                    jlptMap[n] = !jlptMap[n];
                                  });
                                  kanjiBloc.filterKanji(jlptMap, gradeMap);
                                })
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 8,
                        children: <Widget>[
                          SizedBox(width: 12),
                          for (var g in gradeMap.keys)
                            FilterChip(
                                selected: gradeMap[g],
                                elevation: 4,
                                label: Text(getGradeStr(g)),
                                onSelected: (val) {
                                  setState(() {
                                    gradeMap[g] = !gradeMap[g];
                                  });
                                  kanjiBloc.filterKanji(jlptMap, gradeMap);
                                })
                        ],
                      ),
                    )
                  ],
                ),
              )),
        ),
        body: StreamBuilder(
          stream: kanjiBloc.searchResults,
          builder: (_, AsyncSnapshot<List<Kanji>> snapshot) {
            if (snapshot.hasData) {
              var kanjis = snapshot.data;

              return kanjis.isNotEmpty
                  ? KanjiListView(kanjis: kanjis, scrollController: scrollController)
                  : Center(
                      child: Text(
                        'No results found _(┐「ε:)_',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
            }
            return Center(child: CircularProgressIndicator());
          },
        ));
  }

  static String getGradeStr(int grade) {
    if (grade > 3) {
      return '${grade}th';
    } else {
      switch (grade) {
        case 1:
          return '1st';
        case 2:
          return '2nd';
        case 3:
          return '3rd';
        case 0:
          return 'Junior High';
        default:
          throw Exception('Unmatched grade');
      }
    }
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
