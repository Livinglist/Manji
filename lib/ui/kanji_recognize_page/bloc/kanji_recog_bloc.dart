import 'package:rxdart/rxdart.dart';

import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import '../resource/brain.dart';

class KanjiRecogBloc {
  final _predictedKanjiFetcher = PublishSubject<List<Kanji>>();
  final brain = AppBrain();

  Stream<List<Kanji>> get predictedKanji => _predictedKanjiFetcher.stream;

  KanjiRecogBloc() {
    brain.loadModel();
  }

  void predict(List<Offset> points, double canvasSize) {
    brain.processCanvasPoints(points, canvasSize).then((predicts) {
      var temp = <Kanji>[];
      for (var p in predicts) {
        if (kanjiBloc.allKanjisMap.containsKey(p['label'])) {
          temp.add(kanjiBloc.allKanjisMap[p['label']]);
        }
      }
      _predictedKanjiFetcher.sink.add(temp);
    });
  }

  dispose() {
    _predictedKanjiFetcher.close();
  }
}

final kanjiRecogBloc = KanjiRecogBloc();
