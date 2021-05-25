import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/kanji_bloc.dart';
import '../models/kanji.dart';
import '../models/sentence.dart';
import 'db_provider.dart';
import 'jisho_api_provider.dart';

class FirebaseApiProvider {
  final firestore = FirebaseFirestore.instance;

  void uploadKanjis(List<Kanji> kanjis, {bool overwrite = false}) {
    print("Uploading kanjis to Firebase. overwrite is $overwrite");
    for (var kanji in kanjis) {
      print('Uploading ${kanji.kanji} to Firebase.');
      uploadKanji(kanji, overwrite: overwrite);
    }
    print('Uploading completed.');
  }

  Future uploadKanji(Kanji kanji, {bool overwrite = false}) async {
    final docRef = firestore.collection('kanjis').doc(kanji.kanji);
    final snapshot = await docRef.get();
    if (!snapshot.exists || overwrite) {
      docRef.set({
        'grade': kanji.grade,
        'jlpt': kanji.jlpt,
        'kanji': kanji.kanji,
        'frequency': kanji.frequency,
        'onyomi': kanji.onyomi,
        'kunyomi': kanji.kunyomi,
        'strokes': kanji.strokes,
        'parts': kanji.parts,
        'meaning': kanji.meaning,
        'radicals': kanji.radicals,
        'radicalsMeaning': kanji.radicalsMeaning,
        'onyomiWords': kanji.onyomiWords.map((word) => word.toMap()).toList(),
        'kunyomiWords': kanji.kunyomiWords.map((word) => word.toMap()).toList()
      });
    } else {
      docRef.update({
        'parts': kanji.parts,
        'onyomiWords': kanji.onyomiWords.map((word) => word.toMap()).toList(),
        'kunyomiWords': kanji.kunyomiWords.map((word) => word.toMap()).toList()
      });
    }
  }

  @Deprecated('')
  Future completeDatabase() async {
    jishoApiProvider.fetchKanjisByGrade(1).listen((kanji) {
      fetchAllSentencesFromJishoByKanjis([kanji.kanji]);
    });
  }

  ///fetch from jisho.org then upload to firestore
  @Deprecated(
      'Use this only for scripting. Do not use this in the released app.')
  void fetchAllSentencesFromJishoByAllKanjis() async {
    final kanjiStrs = KanjiBloc.instance.allKanjisList
        .expand((element) => [
              ...element.kunyomiWords
                  .where((element) => element.wordText.length > 1)
                  .map((e) => e.wordText),
              ...element.onyomiWords
                  .where((element) => element.wordText.length > 1)
                  .map((e) => e.wordText)
            ])
        .toList();
    // for (var kanji in KanjiBloc.instance.allKanjisList) {
    //   firestore.collection('kanjis').doc(kanji.kanji).update({
    //     'kunyomiWords': kanji.kunyomiWords.map((e) => e.toMap()).toList(),
    //     'onyomiWords': kanji.onyomiWords.map((e) => e.toMap()).toList(),
    //   });
    // }
    //var querySnapshots = await firestore.collection('kanjis').get();
    // for (var snap in querySnapshots.docs) {
    //   var kWords = (snap.data()['kunyomiWords'] as List).map((e) {
    //     print(e);
    //     return Word.fromMap(e as Map);
    //   });
    //   var oWords = (snap.data()['onyomiWords'] as List)
    //       .map((e) => Word.fromMap(e as Map));
    //
    //   //print(kWords.map((e) => e['wordText']));
    //
    //   if (kWords.isNotEmpty)
    //     kanjiStrs.addAll(kWords.map((e) => e.wordText).toList());
    //   if (oWords.isNotEmpty)
    //     kanjiStrs.addAll(oWords.map((e) => e.wordText).toList());
    // }

    JishoApiProvider().fetchAllSentencesByKanjis(kanjiStrs);
  }

  ///fetch from Jisho, save to firestore and local database
  static Map<String, List<Sentence>> sentences = <String, List<Sentence>>{};
  Future fetchAllSentencesFromJishoByKanjis(List<String> kanjiStrs) async {
    for (var kanjiStr in kanjiStrs) {
      JishoApiProvider()
          .fetchAllSentencesByKanji(kanjiStr)
          .listen((sentence) async {
        if (sentence != null) {
          print(sentence.text);
          if (sentences[kanjiStr] == null) {
            sentences[kanjiStr] = <Sentence>[];
            sentences[kanjiStr].add(sentence);
          }
        } else {
          if (sentences[kanjiStr] != null && sentences[kanjiStr].isNotEmpty) {
            for (var sen in sentences[kanjiStr]) {
              await firestore
                  .collection('sentences')
                  .doc(kanjiStr)
                  .set({'dummy': 0});
              await firestore
                  .collection('sentences')
                  .doc(kanjiStr)
                  .collection('sentences')
                  .doc(sen.text)
                  .set({
                'text': sen.text,
                'englishText': sen.englishText,
                'tokens': sen.tokens
                    .map((token) => jsonEncode(token.toMap()))
                    .toList()
              });
            }
            await DBProvider.db.addSentences(sentences[kanjiStr]);
          } else {
            if (sentences[kanjiStr] == null) {}
          }
        }
      });
    }
  }

  Stream<Sentence> fetchAllSentencesFromFirestore() async* {
    final kanjiQuerySnapshot = await firestore.collection('sentences').get();
    for (var kanjiDoc in kanjiQuerySnapshot.docs) {
      final kanjiStr = kanjiDoc.id;
      final sentenceQuerySnapshot =
          await kanjiDoc.reference.collection('sentences').get();
      for (var sentenceDoc in sentenceQuerySnapshot.docs) {
        final map = sentenceDoc.data();
        final sentence = Sentence.fromMap(map);
        sentence.kanji = kanjiStr;
        yield sentence;
      }
    }
    yield null;
  }

  ///fetch from firestore then save to local database
  Future fetchSentencesByKanjis(List<Kanji> kanjis) async {
    JishoApiProvider()
        .fetchAllSentencesByKanjis(kanjis.map((kanji) => kanji.kanji).toList())
        .listen((lis) async {
      final kanjiStr = lis[0];
      final sentence = lis[1];
      //print('I am listening: ${sentence.text}');
      firestore
          .collection('sentences')
          .doc(kanjiStr)
          .collection('sentences')
          .doc(sentence.text)
          .set({
        'text': sentence.text,
        'englishText': sentence.englishText,
        'tokens':
            sentence.tokens.map((token) => jsonEncode(token.toMap())).toList()
      });
      await DBProvider.db.addSentence(sentence);
    });
  }

  ///Used to fetch kanjis that has been loaded to firebase and local db
  Future checkForUpdate(Map<String, Kanji> allLocalKanjis) async {
    final querySnapshot = await firestore.collection('update').get();
    final updateKanjis = <String>[];
    for (var id in querySnapshot.docs.map((doc) => doc.id).toList()) {
      if (!allLocalKanjis.containsKey(id) || id == '伺') {
        updateKanjis.add(id);
      }
    }
    if (updateKanjis.isNotEmpty) {
      fetchAllSentencesFromJishoByKanjis(updateKanjis);
      downloadKanjis(updateKanjis);
    } else {
      print("upload is empty");
    }
  }

  ///fetch from Jisho, load to firestore and local database
  Future downloadKanjis(List<String> kanjiStrs) async {
    for (var kanjiStr in kanjiStrs) {
      final kanji = await jishoApiProvider.fetchKanjiInfo(kanjiStr);
      DBProvider.db.addKanji(kanji);
      await uploadKanji(kanji);
    }
  }

  @Deprecated('Used for scripting')
  Future downloadAllKanjis() async {
    final kanjis = <Kanji>[];
    firestore.collection('kanjis').get().then((querySnapshot) {
      for (var snap in querySnapshot.docs) {
        final kanji = Kanji.fromMap(snap.data());
        print(kanji.kanji);
        kanjis.add(kanji);
      }
      //DBProvider.db.addAllKanjis(kanjis);
    });
  }

  ///TODO: need to test whether the old and new list merge
  Future uploadUserModifiedKanji(Kanji kanji) async {
    final snap =
        await firestore.collection('userUpdates').doc(kanji.kanji).get();

    if (snap.exists) {
      firestore.collection('userUpdates').doc(kanji.kanji).update({
        'kanji': kanji.kanji,
        'onyomi': FieldValue.arrayUnion(kanji.onyomi),
        'kunyomi': FieldValue.arrayUnion(kanji.kunyomi),
        'onyomiWords': FieldValue.arrayUnion(
            kanji.onyomiWords.map((word) => word.toString()).toList()),
        'kunyomiWords': FieldValue.arrayUnion(
            kanji.kunyomiWords.map((word) => word.toString()).toList())
      });
    } else {
      firestore.collection('userUpdates').doc(kanji.kanji).set({
        'kanji': kanji.kanji,
        'onyomi': FieldValue.arrayUnion(kanji.onyomi),
        'kunyomi': FieldValue.arrayUnion(kanji.kunyomi),
        'onyomiWords': FieldValue.arrayUnion(
            kanji.onyomiWords.map((word) => word.toString()).toList()),
        'kunyomiWords': FieldValue.arrayUnion(
            kanji.kunyomiWords.map((word) => word.toString()).toList())
      });
    }
  }

  Future fetchUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    var localVersionNum = prefs.getInt(versionKey);

    if (localVersionNum == null) {
      prefs.setInt(versionKey, 0);
      localVersionNum = 0;
    }

    //To store the kanji that has already been updated
    final updatedKanjiStrs = <String>[];

    var snap = await firestore.collection('updates').doc('version').get();
    final versionNum = snap.data()['versionNum'];
    if (versionNum > localVersionNum) {
      for (var i = localVersionNum + 1; i <= versionNum; i++) {
        snap = await firestore.collection('updates').doc(i.toString()).get();
        final kanjis = snap.data()['kanjis'] as List;
        for (var kanjiStr in kanjis) {
          if (updatedKanjiStrs.contains(kanjiStr)) continue;
          final localKanji = await DBProvider.db.getSingleKanji(kanjiStr);
          final firestoreKanji = Kanji.fromMap(
              (await firestore.collection('kanjis').doc(kanjiStr).get())
                  .data());
          localKanji.kunyomiWords.addAll(firestoreKanji.kunyomiWords);
          localKanji.onyomiWords.addAll(firestoreKanji.onyomiWords);
          DBProvider.db.updateKanji(localKanji);
          updatedKanjiStrs.add(kanjiStr);
        }
      }
    }
    return null; //TODO: should wait for above actions to be finished
  }

  Future<bool> getIsUpdated() async =>
      (await getLocalVersion()) == (await getFirebaseVersion());

  Future<int> getLocalVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final localVersionNum = prefs.getInt(versionKey);
    return localVersionNum ?? 0;
  }

  Future<int> getFirebaseVersion() async =>
      (await firestore.collection('updates').doc('version').get())
          .data()['versionNum'];

  void uploadSentence(Sentence sentence, String key) {
    firestore
        .collection('sentences')
        .doc(key)
        .set({'timeStamp': FieldValue.serverTimestamp()});
    firestore
        .collection('sentences')
        .doc(key)
        .collection('sentences')
        .doc(sentence.text)
        .set({
      'englishText': sentence.englishText,
      'text': sentence.text,
      'tokens':
          sentence.tokens.map((token) => jsonEncode(token.toMap())).toList()
    });
  }
}

const String versionKey = 'version';

///for usage in jisho_api_provider
final firebaseApiProvider = FirebaseApiProvider();
