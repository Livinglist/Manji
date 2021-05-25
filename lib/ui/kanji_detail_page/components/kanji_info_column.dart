import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';

import '../../../bloc/kanji_bloc.dart';
import '../../../bloc/kanji_list_bloc.dart';
import '../../../bloc/sentence_bloc.dart';
import '../../components/chip_collections.dart';
import '../../components/label_divider.dart';
import '../../search_result_page.dart';

class KanjiInfoColumn extends StatelessWidget {
  final Kanji kanji;

  KanjiInfoColumn({Key key, this.kanji}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: KanjiBloc.instance.kanji,
      builder: (_, snapshot) {
        if (snapshot.hasData || kanji != null) {
          final kanji = this.kanji == null ? snapshot.data : this.kanji;

          Widget radicalPanel;

          if (kanji.radicals != null && kanji.radicals.isNotEmpty) {
            radicalPanel = InkWell(
              splashColor: Theme.of(context).primaryColor,
              highlightColor: Theme.of(context).primaryColor,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            SearchResultPage(radicals: kanji.radicals)));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  LabelDivider(
                      child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(children: [
                            TextSpan(
                                text: 'ぶしゅ\n',
                                style: TextStyle(
                                    fontSize: 9, color: Colors.white)),
                            TextSpan(
                                text: '部首',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white))
                          ]))),
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: Text("${kanji.radicals}",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: Text("${kanji.radicalsMeaning}",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                children: <Widget>[
                  kanji.jlpt != 0
                      ? Padding(
                          padding: const EdgeInsets.all(4),
                          child: Container(
                            child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  'N${kanji.jlpt}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                )),
                            decoration: const BoxDecoration(
                              //boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(
                                      5.0) //                 <--- border radius here
                                  ),
                            ),
                          ),
                        )
                      : Container(),
                  GradeChip(
                    grade: kanji.grade,
                  )
                ],
              ),
              Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  child: Text(
                    "${kanji.strokes} strokes",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  )),
              if (kanji.radicals != null && kanji.radicals.isNotEmpty)
                DescribedFeatureOverlay(
                    featureId: 'more_radicals',
                    // Unique id that identifies this overlay.
                    tapTarget: const Text('部首', style: TextStyle(fontSize: 18)),
                    // The widget that will be displayed as the tap target.
                    title: const Text('Radicals'),
                    description: const Text(
                        'Tap here if you want to see more kanji with this radical.'),
                    backgroundColor: Theme.of(context).primaryColor,
                    targetColor: Colors.white,
                    textColor: Colors.white,
                    child: radicalPanel),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }
}
