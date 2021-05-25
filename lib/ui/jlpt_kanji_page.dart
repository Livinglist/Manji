import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../bloc/kanji_bloc.dart';
import '../models/kanji.dart';
import '../ui/components/kanji_grid_view.dart';
import '../ui/components/kanji_list_view.dart';
import 'components/furigana_text.dart';
import 'kanji_study_pages/kanji_study_page.dart';

class JLPTKanjiPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => JLPTKanjiPageState();
}

class JLPTKanjiPageState extends State<JLPTKanjiPage> {
  static const actionTextStyle = TextStyle(color: Colors.blue);

  //show gridview by default
  JLPTLevel currentLevel = JLPTLevel.n5;
  bool showGrid = true;
  bool sorted = true;
  bool altSorted = false;
  Map<JLPTLevel, List<Kanji>> jlptToKanjisMap = {
    JLPTLevel.n1: [],
    JLPTLevel.n2: [],
    JLPTLevel.n3: [],
    JLPTLevel.n4: [],
    JLPTLevel.n5: [],
  };

  @override
  void initState() {
    super.initState();

    for (var kanji in KanjiBloc.instance.allKanjisList) {
      if (kanji.jlpt == 0) continue;
      jlptToKanjisMap[kanji.jlptLevel].add(kanji);
    }
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
            text: '日能試漢字',
            tokens: [
              Token(text: '日能試', furigana: 'にのうし'),
              Token(text: '漢字', furigana: 'かんじ')
            ],
            style: const TextStyle(fontSize: 20),
          ),
          actions: <Widget>[
            IconButton(
                icon: const Icon(FontAwesomeIcons.bookOpen, size: 16),
                onPressed: () => showAmountDialog(jlptToKanjisMap[currentLevel],
                    'Study N${currentLevel.index + 1}')),
            IconButton(
                icon: AnimatedCrossFade(
                  firstChild: const Icon(
                    FontAwesomeIcons.sortNumericDown,
                    color: Colors.white,
                  ),
                  secondChild: const Icon(
                    FontAwesomeIcons.sortNumericDownAlt,
                    color: Colors.white,
                  ),
                  crossFadeState: altSorted
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 200),
                ),
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    altSorted = !altSorted;
                  });
                }),
            IconButton(
              icon: AnimatedCrossFade(
                firstChild: const Icon(
                  Icons.view_headline,
                  color: Colors.white,
                ),
                secondChild: const Icon(
                  Icons.view_comfy,
                  color: Colors.white,
                ),
                crossFadeState: showGrid
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 200),
              ),
              onPressed: () {
                setState(() {
                  showGrid = !showGrid;
                });
              },
            ),
          ],
          //elevation: 0,
          bottom: TabBar(
              tabs: const [
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
              ],
              onTap: (index) {
                switch (index) {
                  case 0:
                    currentLevel = JLPTLevel.n5;
                    break;
                  case 1:
                    currentLevel = JLPTLevel.n4;
                    break;
                  case 2:
                    currentLevel = JLPTLevel.n3;
                    break;
                  case 3:
                    currentLevel = JLPTLevel.n2;
                    break;
                  case 4:
                    currentLevel = JLPTLevel.n1;
                    break;
                  default:
                }
              }),
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
    if (sorted) {
      if (altSorted) {
        jlptToKanjisMap[jlptLevel]
            .sort((l, r) => r.strokes.compareTo(l.strokes));
      } else {
        jlptToKanjisMap[jlptLevel]
            .sort((l, r) => l.strokes.compareTo(r.strokes));
      }
    }

    if (showGrid) return KanjiGridView(kanjis: jlptToKanjisMap[jlptLevel]);

    return KanjiListView(kanjis: jlptToKanjisMap[jlptLevel]);
  }

  void showAmountDialog(List<Kanji> kanjis, String title) {
    if (kanjis.length <= 20) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => KanjiStudyPage(kanjis: kanjis)));
      return;
    }

    showCupertinoModalPopup(
        context: context,
        builder: (_) {
          return CupertinoActionSheet(
            title: Text(title),
            actions: <Widget>[
              CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => KanjiStudyPage(kanjis: kanjis)));
                  },
                  child: Text("All of ${kanjis.length} kanji",
                      style: actionTextStyle)),
              if (kanjis.length >= 100)
                CupertinoActionSheetAction(
                    onPressed: () => onAmountPressed(100, kanjis),
                    child: const Text("100 kanji", style: actionTextStyle)),
              if (kanjis.length >= 50)
                CupertinoActionSheetAction(
                    onPressed: () => onAmountPressed(50, kanjis),
                    child: const Text("50 kanji", style: actionTextStyle)),
              CupertinoActionSheetAction(
                  onPressed: () => onAmountPressed(20, kanjis),
                  child: const Text("20 kanji", style: actionTextStyle)),
              CupertinoActionSheetAction(
                  onPressed: () => onAmountPressed(10, kanjis),
                  child: const Text("10 kanji", style: actionTextStyle)),
            ],
            cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel", style: actionTextStyle)),
          );
        });
  }

  void onAmountPressed(int amount, List<Kanji> kanjis) {
    Navigator.pop(context);
    final start = Random(DateTime.now().millisecondsSinceEpoch)
        .nextInt(kanjis.length - amount);
    final temp = kanjis.sublist(start, start + amount);
    Navigator.push(context,
        MaterialPageRoute(builder: (_) => KanjiStudyPage(kanjis: temp)));
  }
}
