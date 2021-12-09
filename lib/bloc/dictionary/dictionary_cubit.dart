import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import '../../config/locator.dart';
import '../../models/kanji.dart';
import '../../resource/db_provider.dart';
import '../../resource/shared_preferences_provider.dart';

part 'dictionary_state.dart';

class DictionaryCubit extends Cubit<DictionaryState> {
  DictionaryCubit(
      {DBProvider? dbProvider, SharedPreferencesProvider? preferencesProvider})
      : _dbProvider = dbProvider ?? locator.get<DBProvider>(),
        _preferencesProvider =
            preferencesProvider ?? locator.get<SharedPreferencesProvider>(),
        super(DictionaryState.init());

  final DBProvider _dbProvider;
  final SharedPreferencesProvider _preferencesProvider;

  void init() {
    _dbProvider.getAllKanjis().then((kanjis) {
      if (kanjis.isNotEmpty) {
        final mappedKanjis = Map.fromEntries(
          kanjis.map(
            (kanji) => MapEntry(kanji.kanji, kanji),
          ),
        );

        //TODO: getRandomKanji
        //getRandomKanji();

        final favKanjiStrings = _preferencesProvider.getAllFavKanjiStrs();

        final starredKanjiStrings = _preferencesProvider.getAllStarKanjiStrs();

        emit(
          state.copyWith(
            kanjis: kanjis,
            mappedKanjis: mappedKanjis,
            favKanjiStrings: favKanjiStrings,
            starredKanjiStrings: starredKanjiStrings,
          ),
        );
      }
    });
  }
}
