import 'package:rxdart/rxdart.dart';

import '../bloc/kanji_bloc.dart';
import '../ui/kanji_recognize_page/resource/brain.dart';

class KanjiRecognitionBloc {
  final _predictedKanjiFetcher = PublishSubject<List<Kanji>>();
  final _brain = AppBrain();

  Stream<List<Kanji>> get predictedKanji => _predictedKanjiFetcher.stream;

  KanjiRecognitionBloc() {
    _brain.loadModel();
  }

  void predict(List<Offset> points, double canvasSize) {
    _brain.processCanvasPoints(points, canvasSize).then((predicts) {
      final temp = <Kanji>[];
      for (var p in predicts) {
        if (KanjiBloc.instance.allKanjisMap.containsKey(p['label'])) {
          temp.add(KanjiBloc.instance.allKanjisMap[p['label']]);
        }
      }
      _predictedKanjiFetcher.sink.add(temp);
    });
  }

  void dispose() {
    _predictedKanjiFetcher.close();
  }
}

final kanjiRecognizeBloc = KanjiRecognitionBloc();
