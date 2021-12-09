import 'package:get_it/get_it.dart';
import 'package:kanji_dictionary/resource/db_provider.dart';
import 'package:kanji_dictionary/resource/shared_preferences_provider.dart';

/// Global [GetIt.instance].
final locator = GetIt.instance;

/// Set up [GetIt] locator.
Future<void> setUpLocator() async {
  locator
    ..registerSingleton<DBProvider>(DBProvider.db)
    ..registerSingleton<SharedPreferencesProvider>(
      SharedPreferencesProvider.instance,
    );
}
