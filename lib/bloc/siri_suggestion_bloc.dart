import 'package:rxdart/rxdart.dart';

class SiriSuggestionBloc {
  final _siriSuggestionFetcher = BehaviorSubject<String>();

  SiriSuggestionBloc._();

  static final instance = SiriSuggestionBloc._();

  Stream<String> get siriSuggestion => _siriSuggestionFetcher.stream;

  void suggest(String kanjiStr) {
    _siriSuggestionFetcher.sink.add(kanjiStr);
  }

  void dispose() {
    _siriSuggestionFetcher.close();
  }
}
