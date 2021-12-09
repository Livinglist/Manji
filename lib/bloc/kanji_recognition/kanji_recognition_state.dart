part of 'kanji_recognition_cubit.dart';

class KanjiRecognitionState extends Equatable {
  final List<Kanji> kanjis;

  KanjiRecognitionState({required this.kanjis});

  KanjiRecognitionState.init() : kanjis = [];

  KanjiRecognitionState copyWith({List<Kanji>? kanjis}) {
    return KanjiRecognitionState(
      kanjis: kanjis ?? this.kanjis,
    );
  }

  @override
  List<Object?> get props => [kanjis];
}
