import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import '../models/sentence.dart';
import '../resource/constants.dart';
import '../resource/repository.dart';

export '../models/kanji.dart';
export '../models/sentence.dart';
export '../models/word.dart';

class SentenceBloc {
  final _sentencesFetcher = BehaviorSubject<List<Sentence>>();
  final _isFetchingFetcher = BehaviorSubject<bool>();

  final _sentences = <Sentence>[];
  var _unloadedSentencesStr = <String>[];

  Stream<List<Sentence>> get sentences => _sentencesFetcher.stream;

  Stream<bool> get isFetching => _isFetchingFetcher.stream;

  bool _isFetching, _allFetched = false;

  ///Used for pagination.
  final int _length;

  ///Used for pagination for fetching sentences from Jisho.org.
  int _currentPage;

  ///Used as a start point for a range of sentences.
  DocumentSnapshot lastDoc;

  ///Kanji for which example sentences are being fetched.
  String _kanjiStr;

  ///Initialize [SentenceBloc] with [length] which defaults to 10 and is used for pagination.
  SentenceBloc({int length = 10})
      : _length = length,
        _currentPage = 0,
        _isFetching = false;

  ///Fetch sentences from Jisho.org by a word.
  void fetchSentencesByWords(String str) {
    _sentences.clear();
    _isFetching = true;
    _isFetchingFetcher.sink.add(_isFetching);

    repo.fetchSentencesByKanji(str).listen((sentence) {
      if (sentence == null) {
        _allFetched = true;
        _isFetching = null;
        _isFetchingFetcher.sink.add(_isFetching);
        _sentencesFetcher.sink.add([]);
      } else if (!_sentencesFetcher.isClosed) {
        _sentences.add(sentence);
        _sentencesFetcher.sink.add(_sentences);
      }
    }).onDone(() {
      _isFetching = false;
      _isFetchingFetcher.sink.add(_isFetching);

      _currentPage++;
    });
  }

  ///Fetch sentences from Jisho.org by a word.
  void fetchMoreSentencesByWordFromJisho(String str) {
    print("Is fetching: $_isFetching");
    print("Is all fetched: $_allFetched");
    if (!_allFetched && !_isFetching) {
      _isFetching = true;
      _isFetchingFetcher.sink.add(_isFetching);
      repo
          .fetchSentencesByKanji(str, currentPage: _currentPage)
          .listen((sentence) {
        if (sentence == null) {
          print('all fetched');
          _allFetched = true;
          _isFetching = null;
          _isFetchingFetcher.sink.add(_isFetching);
        } else if (!_sentencesFetcher.isClosed) {
          _sentences.add(sentence);
          _sentencesFetcher.sink.add(_sentences);
        }
      }).onDone(() {
        if (!_allFetched) {
          print("========Done=======");
          _isFetching = false;
          _isFetchingFetcher.sink.add(_isFetching);

          _currentPage++;
        }
      });
    }
  }

  ///Fetch sentences from Jisho.org by a kanji.
  void fetchSentencesByKanjiFromJisho(String kanjiStr) {
    _sentences.clear();
    repo.fetchSentencesByKanji(kanjiStr).listen((sentence) {
      if (!_sentencesFetcher.isClosed) {
        _sentences.add(sentence);
        _sentencesFetcher.sink.add(_sentences);
      }
    });
  }

  ///Fetch sentences from Firebase.
  void fetchSentencesByKanjiFromFirebase(String kanji,
      {bool shouldClear = true}) {
    if (shouldClear) _sentences.clear();

    Query ref;

    if (lastDoc == null) {
      ref = FirebaseFirestore.instance
          .collection('sentences2')
          .doc(kanji)
          .collection(Keys.sentencesKey)
          .orderBy(Keys.textKey)
          .limit(_length);
    } else {
      ref = FirebaseFirestore.instance
          .collection('sentences2')
          .doc(kanji)
          .collection(Keys.sentencesKey)
          .orderBy(Keys.textKey)
          .startAfterDocument(lastDoc)
          .limit(_length);
    }

    ref.get().then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final sentences =
            snapshot.docs.map((e) => Sentence.fromMap(e.data())).toList();

        //Remove duplicates.
        sentences.removeWhere((e) =>
            _sentences.singleWhere((s) => e.text == s.text,
                orElse: () => null) !=
            null);

        _sentences.addAll(sentences);
        _sentencesFetcher.sink.add(_sentences);
        lastDoc = snapshot.docs.last;
      }
    });
  }

  ///Fetch more sentences from Firebase.
  void fetchMoreSentencesByKanji(String kanji) {
    final ref = FirebaseFirestore.instance
        .collection('sentences2')
        .doc(kanji)
        .collection(Keys.sentencesKey)
        .orderBy(Keys.textKey)
        .startAfterDocument(lastDoc)
        .limit(_length);

    ref.get().then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final sentences =
            snapshot.docs.map((e) => Sentence.fromMap(e.data())).toList();
        _sentences.addAll(sentences);
        _sentencesFetcher.sink.add(_sentences);
        lastDoc = snapshot.docs.last;
      }
    });
  }

  ///Fetch sentences from Firebase.
  void fetchSentencesByWordFromFirebase(String word) {
    _sentences.clear();
    if (word.length > 1) {
      final ref = FirebaseFirestore.instance
          .collection('wordSentences')
          .doc(word)
          .collection(Keys.sentencesKey)
          .orderBy(Keys.textKey)
          .limit(_length);
      ref.get().then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final sentences =
              snapshot.docs.map((e) => Sentence.fromMap(e.data())).toList();
          _sentences.addAll(sentences);
          _sentencesFetcher.sink.add(_sentences);
          lastDoc = snapshot.docs.last;
        }
      });
    } else {
      fetchSentencesByKanjiFromFirebase(word);
    }
  }

  ///Fetch more sentences from Firebase.
  void fetchMoreSentencesByWord(String word) {
    if (word.length > 1) {
      final ref = FirebaseFirestore.instance
          .collection('wordSentences')
          .doc(word)
          .collection(Keys.sentencesKey)
          .orderBy(Keys.textKey)
          .startAfterDocument(lastDoc)
          .limit(_length);

      ref.get().then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final sentences =
              snapshot.docs.map((e) => Sentence.fromMap(e.data())).toList();
          _sentences.addAll(sentences);
          _sentencesFetcher.sink.add(_sentences);
          lastDoc = snapshot.docs.last;
        }
      });
    } else {
      fetchMoreSentencesByKanji(word);
    }
  }

  ///Get a single sentence from the local database.
  void getRandomSentenceByKanji(String kanjiStr) async {
    final jsonStr = await repo.getSentencesJsonStringByKanji(kanjiStr);
    if (jsonStr != null) {
      final list = (jsonDecode(jsonStr) as List).cast<String>();
      final randomIndex = Random().nextInt(list.length);
      final sentence =
          Sentence.fromMap(jsonDecode(list.elementAt(randomIndex)));

      _unloadedSentencesStr = list;

      _sentences.add(sentence);

      if (sentence != null && !_sentencesFetcher.isClosed) {
        _sentencesFetcher.sink.add(_sentences);
      }
    }
  }

  ///Get sentences from the local database.
  void getSentencesByKanji(String kanjiStr) async {
    _kanjiStr = kanjiStr;
    final jsonStr = await repo.getSentencesJsonStringByKanji(kanjiStr);
    if (jsonStr != null) {
      final list = (jsonDecode(jsonStr) as List).cast<String>();
      final sentences = await jsonToSentences(
          list.sublist(0, list.length < 5 ? list.length : 5));

      list.removeRange(0, list.length < 5 ? list.length : 5);

      _unloadedSentencesStr = list;

      if (sentences != null && !_sentencesFetcher.isClosed) {
        _sentences.addAll(sentences);
        _sentencesFetcher.sink.add(_sentences);
      }
    }
  }

  ///Get more sentences from the local database.
  void getMoreSentencesByKanji() async {
    final sentences = await jsonToSentences(_unloadedSentencesStr.sublist(0,
        _unloadedSentencesStr.length < 10 ? _unloadedSentencesStr.length : 10));

    if (sentences.isEmpty) {
      fetchSentencesByKanjiFromFirebase(_kanjiStr, shouldClear: false);
      return;
    }

    _unloadedSentencesStr.removeRange(0,
        _unloadedSentencesStr.length < 10 ? _unloadedSentencesStr.length : 10);

    _sentences.addAll(sentences);

    if (sentences != null && !_sentencesFetcher.isClosed) {
      _sentencesFetcher.sink.add(_sentences);
    }
  }

  void resetSentencesFetcher() {
    _sentencesFetcher.drain();
    _sentences.clear();
    _unloadedSentencesStr.clear();
  }

  void dispose() {
    _sentencesFetcher.close();
    _isFetchingFetcher.close();
  }
}
