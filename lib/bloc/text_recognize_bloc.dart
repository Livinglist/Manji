import 'package:rxdart/rxdart.dart';

import '../resource/google_api_provider.dart';

class TextRecognizeBloc {
  final _textFetcher = PublishSubject<String>();

  Stream<String> get text => _textFetcher.stream;

  void extractTextFromImage(String imgStr) {
    _textFetcher.sink.add(null);
    GoogleApiProvider.extractTextFromImage(imgStr)
        .then((text) => _textFetcher.sink.add(text));
  }

  void reset() => _textFetcher.drain();

  void dispose() {
    _textFetcher.close();
  }
}

final textRecognizeBloc = TextRecognizeBloc();
