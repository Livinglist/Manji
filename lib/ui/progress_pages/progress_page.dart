import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../bloc/kanji_bloc.dart';
import '../../ui/components/furigana_text.dart';
import '../../bloc/kanji_list_bloc.dart';
import 'components/progress_list_tile.dart';
import 'components/activity_panel.dart';
import 'progress_detail_page.dart';

///This is the page that displays lists created by users
class ProgressPage extends StatefulWidget {
  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with TickerProviderStateMixin {
  final List<AnimationController> controllers = <AnimationController>[];
  AnimationController panelAnimationController;
  final scrollController = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final textEditingController = TextEditingController();
  final Map<int, List<Kanji>> jlptToKanjisMap = {};
  final Map<int, Map<int, double>> jlptToValuesMap = {
    1: {},
    2: {},
    3: {},
    4: {},
    5: {}
  };

  bool showPanel = false;

  bool showShadow = false;

  double screenWidth, panelHeight = 120;

  @override
  void initState() {
    super.initState();

    panelAnimationController =
        AnimationController(vsync: this, lowerBound: 0, upperBound: 3)
          ..value = 1;

    for (var index in [0, 1, 2, 3, 4]) {
      controllers.add(AnimationController(
          vsync: this, duration: Duration(milliseconds: 600)));

      computeJLPTProgress(5 - index).listen((progress) {
        controllers[index].animateTo(progress);
      });
    }

    scrollController.addListener(() {
      panelAnimationController.value = (120 - scrollController.offset) / 120;
    });

    Future.delayed(Duration(milliseconds: 600), () {
      setState(() {
        showPanel = true;
      });
    });
  }

  @override
  void dispose() {
    controllers.forEach((c) => c.dispose());
    panelAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 8,
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
                  addAutomaticKeepAlives: true,
                  controller: scrollController,
                  itemBuilder: (_, index) {
                    if (index == 0) {
                      return AnimatedOpacity(
                        duration: Duration(milliseconds: 300),
                        opacity: showPanel ? 1 : 0,
                        child: AnimatedBuilder(
                          animation: panelAnimationController,
                          child: ActivityPanel(),
                          builder: (_, child) {
                            return Transform.scale(
                                origin: Offset(0, 60),
                                scale: panelAnimationController.value,
                                child: Container(
                                  height: panelHeight,
                                  child: child,
                                ));
                          },
                        ),
                      );
                    }

                    index--;
                    if (index < 5) {
                      int jlpt = 5 - index;

                      return AnimatedBuilder(
                        animation: controllers[index],
                        builder: (_, __) {
                          return ProgressListTile(
                              title: 'N$jlpt',
                              progress: controllers[index].value,
                              studiedTimes: jlptToValuesMap[jlpt],
                              totalStudiedPercentage:
                                  jlptToKanjisMap[jlpt] == null
                                      ? 0
                                      : jlptToKanjisMap[jlpt]
                                              .where((kanji) =>
                                                  kanji.timeStamps.isNotEmpty)
                                              .length /
                                          jlptToKanjisMap[jlpt].length *
                                          100,
                              onTap: () {
                                var totalStudied = jlptToKanjisMap[jlpt]
                                    .where(
                                        (kanji) => kanji.timeStamps.isNotEmpty)
                                    .length;
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ProgressDetailPage(
                                            kanjis: jlptToKanjisMap[jlpt],
                                            title: 'N$jlpt',
                                            totalStudied: totalStudied)));
                              });
                        },
                      );
                    }
                    var kanjiList = kanjiLists[index - 5];
                    var kanjis = kanjiList.kanjiStrs
                        .where((e) => e.length == 1)
                        .map((str) => KanjiBloc.instance.allKanjisMap[str])
                        .toList();

                    return ProgressListTile(
                        title: kanjiList.name,
                        progress: computeListProgress(kanjis),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => ProgressDetailPage(
                                      kanjis: kanjis, title: kanjiList.name)));
                        });
                  },
                  separatorBuilder: (_, index) => Divider(height: 0),
                  itemCount: 1 + 5 + kanjiLists.length);
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
    double progress = 0.0;
    int total = 0;
    int iterated = 0;
    var kanjis = await compute<List<dynamic>, List<Kanji>>(
        getTargetedKanjis, [jlpt, KanjiBloc.instance.allKanjisList]);
    jlptToKanjisMap[jlpt] = kanjis;
    total = kanjis.length;
    for (var kanji in kanjis) {
      progress = (++iterated) / total;
      yield progress;

      if (kanji.timeStamps.isNotEmpty) {
        for (var timeCount in Iterable.generate(kanji.timeStamps.length)) {
          if (jlptToValuesMap[jlpt].containsKey(timeCount + 1) == false) {
            jlptToValuesMap[jlpt][timeCount + 1] = 1 / total;
          } else {
            jlptToValuesMap[jlpt][timeCount + 1] =
                (jlptToValuesMap[jlpt][timeCount + 1] * total + 1) / total;
          }
        }
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
