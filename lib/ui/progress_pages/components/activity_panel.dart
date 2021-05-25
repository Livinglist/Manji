import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../bloc/kanji_bloc.dart';
import '../yearly_activity_page.dart';

class ActivityPanel extends StatelessWidget {
  static Map<DateTime, List<Kanji>> data;
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return buildView(context);
  }

  Widget buildView(BuildContext context) {
    final width = MediaQuery.of(context).size.width / 40;
    return FutureBuilder(
      future: compute<List<Kanji>, Map<DateTime, List<Kanji>>>(
          convertTimeStampsToDateTimeMap, KanjiBloc.instance.allKanjisList),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          final map = snapshot.data;
          ActivityPanel.data = map;
          return Material(
              child: InkWell(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => YearlyActivityPage(dateToKanjisMap: map))),
            child: Container(
              height: 120,
              child: GridView.count(
                  controller: scrollController,
                  padding: const EdgeInsets.all(2),
                  childAspectRatio: 1,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  scrollDirection: Axis.horizontal,
                  crossAxisCount: 10,
                  children: Iterable.generate(316, (index) {
                    final d =
                        DateTime.now().subtract(Duration(days: 315 - index));
                    final date = DateTime(d.year, d.month, d.day);
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
                      return Material(
                        elevation: 1,
                        child: Container(
                          height: width - 2,
                          width: width - 2,
                          color: Colors.grey,
                        ),
                      );
                    }
                  }).toList()),
            ),
          ));
        }
        return Container();
      },
    );
  }
}

Map<DateTime, List<Kanji>> convertTimeStampsToDateTimeMap(List<Kanji> kanjis) {
  final map = <DateTime, List<Kanji>>{};
  for (var kanji in kanjis) {
    for (var timeStamp in kanji.timeStamps) {
      var dateTime = DateTime.fromMillisecondsSinceEpoch(timeStamp).toLocal();
      dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day);
      if (map.containsKey(dateTime) == false) map[dateTime] = [];
      if (map[dateTime].contains(kanji) == false) map[dateTime].add(kanji);
    }
  }
  return map;
}
