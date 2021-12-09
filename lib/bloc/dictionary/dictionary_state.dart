part of 'dictionary_cubit.dart';

class DictionaryState extends Equatable {
  final List<Kanji> kanjis;
  final Map<String, Kanji> mappedKanjis;
  final List<String> favKanjiStrings;
  final List<String> starredKanjiStrings;

  List<Kanji> get favKanjis =>
      favKanjiStrings.map((e) => mappedKanjis[e]).whereNotNull().toList();

  List<Kanji> get starredKanjis =>
      favKanjiStrings.map((e) => mappedKanjis[e]).whereNotNull().toList();

  DictionaryState({
    required this.kanjis,
    required this.mappedKanjis,
    required this.favKanjiStrings,
    required this.starredKanjiStrings,
  });

  DictionaryState.init()
      : kanjis = [],
        mappedKanjis = {},
        favKanjiStrings = [],
        starredKanjiStrings = [];

  DictionaryState copyWith({
    List<Kanji>? kanjis,
    Map<String, Kanji>? mappedKanjis,
    List<String>? favKanjiStrings,
    List<String>? starredKanjiStrings,
  }) {
    return DictionaryState(
      kanjis: kanjis ?? this.kanjis,
      mappedKanjis: mappedKanjis ?? this.mappedKanjis,
      favKanjiStrings: favKanjiStrings ?? this.favKanjiStrings,
      starredKanjiStrings: starredKanjiStrings ?? this.starredKanjiStrings,
    );
  }

  @override
  List<Object?> get props => [
        kanjis,
        mappedKanjis,
        favKanjiStrings,
        starredKanjiStrings,
      ];
}
