import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../kanji_bloc.dart';

class KanjiDetailsBloc extends Bloc<KanjiDetailsEvent, KanjiDetailsState> {
  KanjiDetailsBloc(KanjiDetailsState initialState) : super(initialState) {
    on<KanjiDetailsInitialize>(onKanjiDetailsInitialize);
  }

  void onKanjiDetailsInitialize(
    KanjiDetailsInitialize event,
    Emitter<KanjiDetailsState> emitter,
  ) {
  }
}

class KanjiDetailsState extends Equatable {
  final Kanji kanji;
  final List<Sentence> sentences;
  final List<Word> words;

  KanjiDetailsState(
      {required this.kanji, required this.sentences, required this.words});

  KanjiDetailsState copyWith(
    Kanji? kanji,
    List<Sentence>? sentences,
    List<Word>? words,
  ) {
    return KanjiDetailsState(
      kanji: kanji ?? this.kanji,
      sentences: sentences ?? this.sentences,
      words: words ?? this.words,
    );
  }

  @override
  List<Object> get props => throw UnimplementedError();
}

abstract class KanjiDetailsEvent extends Equatable {}

class KanjiDetailsInitialize extends KanjiDetailsEvent {
  @override
  List<Object> get props => [];
}
