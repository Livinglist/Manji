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

class EducationKanjiPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EducationKanjiPageState();
}

class EducationKanjiPageState extends State<EducationKanjiPage> {
  static const actionTextStyle = TextStyle(color: Colors.blue);
  //show gridview by default
  int currentGrade = 1;
  bool showGrid = true;
  bool altSorted = false;
  Map<int, List<Kanji>> gradeToKanjisMap = {
    0: [], //Junior High
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

    for (var kanji in KanjiBloc.instance.allKanjisList) {
      gradeToKanjisMap[kanji.grade].add(kanji);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: KanjiBloc.instance.allKanjis,
      builder: (_, snapshot) {
        return DefaultTabController(
          length: 7,
          child: Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            appBar: AppBar(
              //title: Text('日本語能力試験漢字'),
              title: FuriganaText(
                text: '教育漢字',
                tokens: [
                  Token(text: '教育', furigana: 'きょういく'),
                  Token(text: '漢字', furigana: 'かんじ')
                ],
                style: const TextStyle(fontSize: 20),
              ),
              actions: <Widget>[
                IconButton(
                    icon: const Icon(FontAwesomeIcons.bookOpen, size: 16),
                    onPressed: () => showAmountDialog(
                        gradeToKanjisMap[currentGrade],
                        'Study ${toGradeString(currentGrade)}')),
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
              bottom: TabBar(
                isScrollable: true,
                tabs: const [
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
                ],
                onTap: (index) {
                  if (index <= 5) {
                    currentGrade = index + 1;
                  } else {
                    currentGrade = 0;
                  }
                },
              ),
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

    if (showGrid) {
      return KanjiGridView(
        kanjis: gradeToKanjisMap[grade],
        fallBackFont: 'ming',
      );
    }
    return KanjiListView(
      kanjis: gradeToKanjisMap[grade],
      fallBackFont: 'ming',
    );
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

  String toGradeString(int grade) {
    if (grade > 3) {
      return '${grade}th Grade';
    } else {
      switch (grade) {
        case 1:
          return '1st Grade';
        case 2:
          return '2nd Grade';
        case 3:
          return '3rd Grade';
        case 0:
          return 'Junior High';
        default:
          throw Exception('Unmatched grade');
      }
    }
  }
}
