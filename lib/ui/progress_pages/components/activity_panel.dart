import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:kanji_dictionary/bloc/kanji_bloc.dart';

class ActivityPanel extends StatelessWidget {
  double height, width;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.width / 40;
    width = MediaQuery.of(context).size.width / 40;
    return AnimatedContainer(
      duration: Duration(milliseconds: 400),
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: buildView(),
    );
  }

  Widget buildView() {
    return FutureBuilder(
      future: compute<List<Kanji>, Map<DateTime, List<Kanji>>>(convertTimeStampsToDateTimeMap, kanjiBloc.allKanjisList),
      builder: (_, AsyncSnapshot<Map<DateTime, List<Kanji>>> snapshot) {
        if (snapshot.hasData) {
          var map = snapshot.data;
          print(map);
          return Container(
            height: 120,
            child: GridView.count(
                padding: EdgeInsets.all(2),
                childAspectRatio: 1,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                scrollDirection: Axis.horizontal,
                crossAxisCount: 10,
                children: Iterable.generate(366, (index) {
                  var d = DateTime.now().subtract(Duration(days: 365 - index));
                  var date = DateTime(d.year, d.month, d.day);
                  print(date);
                  if (map.containsKey(date)) {
                    return Material(
                      elevation: 2,
                      child: Container(
                        height: width - 2,
                        width: width - 2,
                        color: Colors.redAccent,
                      ),
                    );
                  } else {
                    return Container(
                      height: width - 2,
                      width: width - 2,
                      color: Colors.grey,
                    );
                  }
                }).toList()),
          );
        }
        return Container();
      },
    );
  }
}

Map<DateTime, List<Kanji>> convertTimeStampsToDateTimeMap(List<Kanji> kanjis) {
  var map = Map<DateTime, List<Kanji>>();
  for (var kanji in kanjis) {
    for (var timeStamp in kanji.timeStamps) {
      var dateTime = DateTime.fromMillisecondsSinceEpoch(timeStamp).toLocal();
      dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day);
      if (map.containsKey(dateTime) == false) map[dateTime] = [];
      map[dateTime].add(kanji);
    }
  }
  return map;
}
