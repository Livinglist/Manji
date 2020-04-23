import 'package:rxdart/rxdart.dart';

class ProgressBloc {
  final _progressFetcher = PublishSubject<List<String>>();
}

final progressBloc = ProgressBloc();
