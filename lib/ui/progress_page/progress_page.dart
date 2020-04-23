import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kanji_dictionary/bloc/kanji_bloc.dart';

import 'package:kanji_dictionary/ui/components/furigana_text.dart';
import 'package:kanji_dictionary/bloc/kanji_list_bloc.dart';
import 'package:kanji_dictionary/ui/custom_list_detail_page.dart';

import 'components/progress_list_tile.dart';
import 'progress_detail_page.dart';

///This is the page that displays lists created by users
class ProgressPage extends StatefulWidget {
  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> with TickerProviderStateMixin {
  final List<AnimationController> controllers = List<AnimationController>(5);
  final scrollController = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final textEditingController = TextEditingController();
  final Map<int, List<Kanji>> jlptToKanjisMap = {};
  final Map<int, Map<int, double>> jlptToValuesMap = {1: {}, 2: {}, 3: {}, 4: {}, 5: {}};

  bool showShadow = false;

  @override
  void initState() {
    for (var index in [0, 1, 2, 3, 4]) {
      controllers[index] = AnimationController(vsync: this, duration: Duration(milliseconds: 600));

      computeJLPTProgress(5 - index).listen((progress) {
        controllers[index].animateTo(progress);
      });
    }

    super.initState();

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: showShadow ? 8 : 0,
        title: FuriganaText(
          text: '進度',
          tokens: [Token(text: '進度', furigana: 'しんど')],
          style: TextStyle(fontSize: 20),
        ),
        actions: <Widget>[],
      ),
      body: StreamBuilder(
          stream: KanjiListBloc.instance.kanjiLists,
          builder: (_, AsyncSnapshot<List<KanjiList>> snapshot) {
            if (snapshot.hasData) {
              var kanjiLists = snapshot.data;
              return ListView.separated(
                  controller: scrollController,
                  itemBuilder: (_, index) {
                    if (index < 5) {
                      int jlpt = 5 - index;

                      return AnimatedBuilder(
                        animation: controllers[index],
                        builder: (_, __) {
                          return ProgressListTile(
                              title: 'N$jlpt',
                              progress: controllers[index].value,
                              studiedTimes: jlptToValuesMap[jlpt],
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ProgressDetailPage(
                                            kanjis: jlptToKanjisMap[jlpt],
                                            title: 'N$jlpt',
                                            totalStudied: (jlptToValuesMap[jlpt][1] ?? 0 * jlptToKanjisMap[jlpt].length).toInt())));
                              });
                        },
                      );
                    }
                    var kanjiList = kanjiLists[index - 5];
                    var kanjis = kanjiList.kanjiStrs.map((str) => kanjiBloc.allKanjisMap[str]).toList();
                    return ProgressListTile(
                        title: kanjiList.name,
                        progress: computeListProgress(kanjis),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ProgressDetailPage(kanjis: kanjis, title: kanjiList.name)));
                        });
                  },
                  separatorBuilder: (_, index) => Divider(height: 0),
                  itemCount: 5 + kanjiLists.length);
            } else {
              return Container();
            }
          }),
    );
  }

  double computeListProgress(List<Kanji> kanjis) {
    var total = kanjis.length;
    if (total == 0) return 0;
    var studied = 0;
    for (var kanji in kanjis) {
      if (kanji.timeStamps.isNotEmpty) {
        studied += 1;
      }
    }
    return studied / total;
  }

  Stream<double> computeJLPTProgress(int jlpt) async* {
    double progress = 1.0;
    int total = 0;
    int studied = 0;
    var kanjis = await compute<List<dynamic>, List<Kanji>>(getTargetedKanjis, [jlpt, kanjiBloc.allKanjisList]);
    jlptToKanjisMap[jlpt] = kanjis;
    total = kanjis.length;
    for (var kanji in kanjis) {
      if (kanji.timeStamps.isNotEmpty) {
        for (var timeCount in Iterable.generate(kanji.timeStamps.length)) {
          if (jlptToValuesMap[jlpt].containsKey(timeCount + 1) == false) {
            jlptToValuesMap[jlpt][timeCount + 1] = 1 / total;
          } else {
            jlptToValuesMap[jlpt][timeCount + 1] = (jlptToValuesMap[jlpt][timeCount + 1] * total + 1) / total;
          }
        }

        studied += 1;
        progress = studied / total;
        yield progress;
      } else {
        progress = studied / total;
        yield progress;
      }
    }
  }
}

List<Kanji> getTargetedKanjis(List<dynamic> params) {
  var kanjis = params[1];
  var jlpt = params[0];
  return kanjis.where((kanji) {
    return kanji.jlpt == jlpt;
  }).toList();
}
