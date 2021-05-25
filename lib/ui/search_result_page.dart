import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../bloc/kanji_bloc.dart';
import '../bloc/search_bloc.dart';
import '../ui/radicals_page.dart';
import 'components/kanji_list_tile.dart';
import 'kanji_detail_page/kanji_detail_page.dart';

double _filterPanelHeight = 140;

class SearchResultPage extends StatefulWidget {
  final String text;
  final String radicals;

  SearchResultPage({this.text, this.radicals})
      : assert(text != null || radicals != null);

  @override
  State<StatefulWidget> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage>
    with SingleTickerProviderStateMixin {
  final scrollController = ScrollController();
  final searchBloc = SearchBloc();
  final Map<int, bool> jlptMap = {
    1: false,
    2: false,
    3: false,
    4: false,
    5: false
  };
  final Map<int, bool> gradeMap = {
    0: false, //Junior High
    1: false,
    2: false,
    3: false,
    4: false,
    5: false,
    6: false
  };
  AnimationController animationController;
  Map<String, bool> radicalsMap = {};
  bool showShadow = false, shouldVibrate = false;

  @override
  void initState() {
    scrollController.addListener(() {
      if (mounted) {
        if (scrollController.offset <= _filterPanelHeight) {
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

    scrollController.addListener(() {
      if (mounted) {
        animationController.value =
            scrollController.offset >= _filterPanelHeight
                ? 0
                : 1 - scrollController.offset / _filterPanelHeight;
      }
    });

    animationController = AnimationController(vsync: this, value: 1);

    radicalsMap = radicalsToMeaning.map((key, value) => MapEntry(key, false));

    if (widget.text != null) searchBloc.search(widget.text);

    if (widget.radicals != null) {
      radicalsMap[widget.radicals] = true;
      searchBloc.filter(jlptMap, gradeMap, radicalsMap);
    }

    Vibration.hasCustomVibrationsSupport().then((hasCoreHaptics) {
      setState(() {
        shouldVibrate = hasCoreHaptics;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          elevation: showShadow ? 8 : 0,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12),
              child: StreamBuilder(
                stream: searchBloc.results,
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    final kanjis = snapshot.data;

                    return Center(child: Text('${kanjis.length} kanji found'));
                  }
                  return Container();
                },
              ),
            )
          ],
        ),
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: StreamBuilder(
                stream: searchBloc.results,
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    final kanjis = snapshot.data;

                    return kanjis.isNotEmpty
                        ? _KanjiListView(
                            kanjis: kanjis, scrollController: scrollController)
                        : const Center(
                            child: Text(
                              'No results found _(┐「ε:)_',
                              style: TextStyle(color: Colors.white70),
                            ),
                          );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            Align(
                alignment: Alignment.topCenter,
                child: AnimatedBuilder(
                  animation: animationController,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 8,
                            children: <Widget>[
                              const SizedBox(width: 4),
                              for (var n in jlptMap.keys)
                                FilterChip(
                                    selected: jlptMap[n],
                                    elevation: 4,
                                    label: Text("N$n"),
                                    onSelected: (val) {
                                      if (shouldVibrate) {
                                        Vibration.cancel().then((_) {
                                          Vibration.vibrate(
                                              pattern: [0, 5],
                                              intensities: [200]);
                                        });
                                      }

                                      setState(() {
                                        jlptMap[n] = !jlptMap[n];
                                      });

                                      searchBloc.filter(
                                          jlptMap, gradeMap, radicalsMap);
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
                              const SizedBox(width: 4),
                              for (var g in gradeMap.keys)
                                FilterChip(
                                    selected: gradeMap[g],
                                    elevation: 4,
                                    label: Text(getGradeStr(g)),
                                    onSelected: (val) {
                                      if (shouldVibrate) {
                                        Vibration.cancel().then((_) {
                                          Vibration.vibrate(
                                              pattern: [0, 5],
                                              intensities: [200]);
                                        });
                                      }

                                      setState(() {
                                        gradeMap[g] = !gradeMap[g];
                                      });

                                      searchBloc.filter(
                                          jlptMap, gradeMap, radicalsMap);
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
                              const SizedBox(width: 4),
                              for (var r
                                  in radicalsMap.keys.toList().sublist(0, 4))
                                FilterChip(
                                    selected: radicalsMap[r],
                                    elevation: 4,
                                    label: Text(r),
                                    onSelected: (val) {
                                      if (shouldVibrate) {
                                        Vibration.cancel().then((_) {
                                          Vibration.vibrate(
                                              pattern: [0, 5],
                                              intensities: [200]);
                                        });
                                      }

                                      setState(() {
                                        radicalsMap[r] = !radicalsMap[r];
                                      });

                                      searchBloc.filter(
                                          jlptMap, gradeMap, radicalsMap);
                                    }),
                              for (var r in radicalsMap.keys
                                  .toList()
                                  .sublist(4)
                                  .where((element) => radicalsMap[element]))
                                FilterChip(
                                    selected: true,
                                    elevation: 4,
                                    label: Text(r),
                                    onSelected: (val) {
                                      if (shouldVibrate) {
                                        Vibration.cancel().then((_) {
                                          Vibration.vibrate(
                                              pattern: [0, 5],
                                              intensities: [200]);
                                        });
                                      }

                                      setState(() {
                                        radicalsMap[r] = !radicalsMap[r];
                                      });

                                      searchBloc.filter(
                                          jlptMap, gradeMap, radicalsMap);
                                    }),
                              Hero(
                                tag: 'hero',
                                child: MaterialButton(
                                  onPressed: showRadicalsDialog,
                                  child: const Text('More Radicals'),
                                  shape: const StadiumBorder(),
                                  color: Colors.grey,
                                  height: 32,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  builder: (_, child) {
                    return Opacity(
                      opacity: animationController.value,
                      child:
                          animationController.value <= 0 ? Container() : child,
                    );
                  },
                )),
          ],
        ));
  }

  void showRadicalsDialog() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => RadicalsPage(
                selectedRadicals: radicalsMap.keys
                    .where((element) => radicalsMap[element])
                    .toList()))).then((value) {
      if (value != null) {
        setState(() {
          radicalsMap = value;
        });
        searchBloc.filter(jlptMap, gradeMap, radicalsMap);
      }
    });
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

class _KanjiListView extends StatelessWidget {
  final List<Kanji> kanjis;
  final String fallBackFont;
  final ValueChanged<String> onLongPressed;
  final bool canRemove;
  final ScrollController scrollController;
  final ScrollPhysics scrollPhysics;

  _KanjiListView(
      {this.kanjis,
      this.fallBackFont,
      this.onLongPressed,
      this.canRemove = false,
      this.scrollController,
      this.scrollPhysics = const AlwaysScrollableScrollPhysics()})
      : assert(kanjis != null);

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    children.add(Container(
      height: _filterPanelHeight,
    ));
    for (final kanji in kanjis) {
      children.add(Material(
        color: Theme.of(context).primaryColor,
        child: KanjiListTile(
          kanji: kanji,
          onLongPressed: onLongPressed,
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => KanjiDetailPage(kanji: kanji))),
        ),
      ));
      children.add(const Divider(height: 0));
    }
    children.removeLast();
    children.add(Container(
      height: _filterPanelHeight,
    ));

    return ListView(
      physics: scrollPhysics,
      shrinkWrap: true,
      controller: scrollController,
      children: children,
    );
  }
}
