import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../bloc/kanji_bloc.dart';
import '../../ui/components/kanji_list_tile.dart';

class YearlyActivityPage extends StatefulWidget {
  final Map<DateTime, List<Kanji>> dateToKanjisMap;

  YearlyActivityPage({this.dateToKanjisMap});

  @override
  _YearlyActivityPageState createState() =>
      _YearlyActivityPageState(dateToKanjisMap: dateToKanjisMap);
}

class _YearlyActivityPageState extends State<YearlyActivityPage> {
  final scrollController = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final Map<DateTime, List<Kanji>> dateToKanjisMap;

  _YearlyActivityPageState({this.dateToKanjisMap});

  bool showShadow = false;

  @override
  void initState() {
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
            titleSpacing: 0,
            elevation: showShadow ? 8 : 0,
            centerTitle: true,
            bottom: PreferredSize(
                preferredSize: Size.fromHeight(0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 24,
                  child: GridView.count(
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 13,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      '',
                      'Jan',
                      'Feb',
                      'Mar',
                      'Apr',
                      'May',
                      'Jun',
                      'Jul',
                      'Aug',
                      'Sep',
                      'Oct',
                      'Nov',
                      'Dec'
                    ]
                        .map(
                          (e) => Container(
                              child: Center(
                            child: Text(
                              e,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          )),
                        )
                        .toList(),
                  ),
                ))),
        body: ActivityGridView(
            scrollController: scrollController,
            scaffoldKey: scaffoldKey,
            dateToKanjisMap: dateToKanjisMap));
  }
}

class ActivityGridView extends StatelessWidget {
  final ScrollController scrollController;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Map<DateTime, List<Kanji>> dateToKanjisMap;

  ActivityGridView(
      {this.scrollController, this.dateToKanjisMap, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 13,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      controller: scrollController,
      children: <Widget>[...buildChildren(context), SizedBox(height: 12)],
    );
  }

  List<Widget> buildChildren(BuildContext context) {
    Map<int, List<Kanji>> kanjisByYears = {};
    List<Widget> children = [];

    for (var date in dateToKanjisMap.keys) {
      if (kanjisByYears.containsKey(date.year) == false) {
        kanjisByYears[date.year] = [...dateToKanjisMap[date]];
      } else {
        kanjisByYears[date.year].addAll(dateToKanjisMap[date]);
      }
    }

    for (var i in kanjisByYears.keys.isEmpty
        ? [DateTime.now().year]
        : kanjisByYears.keys.toList()
      ..sort((a, b) => a.compareTo(b))) {
      for (var d in Iterable.generate(31)) {
        children.add(Container(
            height: 12,
            width: 12,
            child: Center(
                child: Text(
              (d + 1).toString(),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ))));
        for (var m in Iterable.generate(12)) {
          var date = DateTime(i, m + 1, d + 1);
          if (dateToKanjisMap.containsKey(date)) {
            children.add(Material(
                elevation: 8,
                child: InkWell(
                  onTap: () => showModalBottomSheet(
                      context, date, dateToKanjisMap[date]),
                  child:
                      Container(height: 12, width: 12, color: Colors.redAccent),
                )));
          } else {
            children.add(Material(
              elevation: 2,
              child: Container(height: 12, width: 12, color: Colors.grey),
            ));
          }
        }
      }
    }

    return children;
  }

  void showModalBottomSheet(
      BuildContext context, DateTime date, List<Kanji> kanjis) {
    var months = [
      'Jan.',
      'Feb.',
      'Mar.',
      'Apr.',
      'May',
      'Jun.',
      'Jul.',
      'Aug.',
      'Sep.',
      'Oct.',
      'Nov.',
      'Dec.'
    ];
    scaffoldKey.currentState.showBottomSheet((context) {
      return Material(
        elevation: 8,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12))),
        color: Theme.of(context).primaryColor,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          height: 500,
          child: Column(
            children: [
              SizedBox(
                  height: 36,
                  child: Center(
                      child: Icon(FontAwesomeIcons.horizontalRule,
                          size: 36, color: Colors.white70))),
              Container(
                height: 464,
                child: SingleChildScrollView(
                    child: Column(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.all(2),
                        child: Center(
                            child: Text(
                                "${months[date.month]} ${toDayString(date.day)} ${date.year}",
                                style: TextStyle(color: Colors.white70)))),
                    ...kanjis
                        .map((kanji) => KanjiListTile(kanji: kanji))
                        .toList(),
                    SizedBox(height: 12)
                  ],
                )),
              )
            ],
          ),
        ),
      );
    },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12))),
        elevation: 8);
  }

  String toDayString(int day) {
    if (day > 3)
      return day.toString() + 'th';
    else {
      if (day == 1) return '1st';
      if (day == 2) return '2nd';
      if (day == 3) return '3rd';
    }
    return '';
  }
}
