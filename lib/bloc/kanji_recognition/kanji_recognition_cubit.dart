import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/kanji.dart';
import '../../ui/kanji_recognize_page/resource/brain.dart';
import '../dictionary/dictionary_cubit.dart';

part 'kanji_recognition_state.dart';

class KanjiRecognitionCubit extends Cubit<KanjiRecognitionState> {
  KanjiRecognitionCubit({
    required DictionaryCubit dictionaryCubit,
    required AppBrain brain,
  })  : _dictionaryCubit = dictionaryCubit,
        _brain = brain,
        super(KanjiRecognitionState.init()) {
    _brain.loadModel();
  }

  final DictionaryCubit _dictionaryCubit;
  final AppBrain _brain;

  void predict(List<Offset> points, double canvasSize) {
    _brain.processCanvasPoints(points, canvasSize).then((predicts) {
      final kanjis = <Kanji>[];
      for (var p in predicts) {
        if (_dictionaryCubit.state.mappedKanjis.containsKey(p['label'])) {
          kanjis.add(_dictionaryCubit.state.mappedKanjis[p['label']]!);
        }
      }
      emit(state.copyWith(kanjis: kanjis));
    });
  }
}
