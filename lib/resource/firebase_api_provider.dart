import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kanji_dictionary/models/kanji.dart';
import 'package:kanji_dictionary/models/sentence.dart';
import 'db_provider.dart';
import 'jisho_api_provider.dart';

class FirebaseApiProvider {
  final firestore = Firestore.instance;

  void uploadKanjis(List<Kanji> kanjis) {
    for (var kanji in kanjis) {
      uploadKanji(kanji);
    }
  }

  Future uploadKanji(Kanji kanji) async {
    var docRef = firestore.collection('kanjis').document(kanji.kanji);
    var snapshot = await docRef.get();
    if (!snapshot.exists) {
      docRef.setData({
        'grade': kanji.grade,
        'jlpt': kanji.jlpt,
        'kanji': kanji.kanji,
        'kunyomi': kanji.kunyomi,
        'frequency': kanji.frequency,
        'onyomi': kanji.onyomi,
        'kunyomi': kanji.kunyomi,
        'strokes': kanji.strokes,
        'parts': kanji.parts,
        'meaning': kanji.meaning,
        'onyomiWords': kanji.onyomiWords.map((word) => word.toString()).toList(),
        'kunyomiWords': kanji.kunyomiWords.map((word) => word.toString()).toList()
      });
    } else {
      docRef.updateData({
        'parts': kanji.parts,
        'onyomiWords': kanji.onyomiWords.map((word) => word.toString()).toList(),
        'kunyomiWords': kanji.kunyomiWords.map((word) => word.toString()).toList()
      });
    }
  }

  @Deprecated('')
  Future completeDatabase() async {
    jishoApiProvider.fetchKanjisByGrade(1).listen((kanji) {
      fetchAllSentencesFromJishoByKanjis([kanji.kanji]);
    });
  }

  ///fetch from jisho.org then upload to firestrore
  Future fetchAllSentencesFromJishoByAllKanjis() async {
    List<String> kanjiStrs = <String>[];
    var querySnapshots = await firestore.collection('kanjis').getDocuments();
    for (var snap in querySnapshots.documents) {
      kanjiStrs.add(snap.documentID);
    }

    JishoApiProvider().fetchAllSentencesByKanjis(kanjiStrs).listen((lis) async {
      var kanjiStr = lis[0];
      Sentence sentence = lis[1];
      //print('I am listening: ${sentence.text}');
      var docRef = firestore.collection('sentences').document(kanjiStr).collection('sentences').document(sentence.text).setData(
          {'text': sentence.text, 'englishText': sentence.englishText, 'tokens': sentence.tokens.map((token) => jsonEncode(token.toMap())).toList()});
    });
  }

  ///fetch from Jisho, save to firestore and local database
  static Map<String, List<Sentence>> sentences = <String, List<Sentence>>{};
  Future fetchAllSentencesFromJishoByKanjis(List<String> kanjiStrs) async {
    for (var kanjiStr in kanjiStrs) {
      JishoApiProvider().fetchAllSentencesByKanji(kanjiStr).listen((sentence) async {
        if (sentence != null) {
          print(sentence.text);
          if (sentences[kanjiStr] == null) {
            sentences[kanjiStr] = <Sentence>[];
            sentences[kanjiStr].add(sentence);
          }
        } else {
          if (sentences[kanjiStr] != null && sentences[kanjiStr].isNotEmpty) {
            for (var sen in sentences[kanjiStr]) {
              await firestore.collection('sentences').document(kanjiStr).setData({'dummy': 0});
              await firestore.collection('sentences').document(kanjiStr).collection('sentences').document(sen.text).setData(
                  {'text': sen.text, 'englishText': sen.englishText, 'tokens': sen.tokens.map((token) => jsonEncode(token.toMap())).toList()});
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
    var kanjiQuerySnapshot = await firestore.collection('sentences').getDocuments();
    for (var kanjiDoc in kanjiQuerySnapshot.documents) {
      String kanjiStr = kanjiDoc.documentID;
      print("the kanji is $kanjiStr");
      var sentenceQuerySnapshot = await kanjiDoc.reference.collection('sentences').getDocuments();
      for (var sentenceDoc in sentenceQuerySnapshot.documents) {
        var map = sentenceDoc.data;
        Sentence sentence = Sentence.fromMap(map);
        sentence.kanji = kanjiStr;
        yield sentence;
      }
    }
    yield null;
  }

  ///fetch from firestore then save to local database
  Future fetchSentencesByKanjis(List<Kanji> kanjis) async {
    JishoApiProvider().fetchAllSentencesByKanjis(kanjis.map((kanji) => kanji.kanji).toList()).listen((lis) async {
      var kanjiStr = lis[0];
      var sentence = lis[1];
      //print('I am listening: ${sentence.text}');
      var docRef = firestore.collection('sentences').document(kanjiStr).collection('sentences').document(sentence.text).setData(
          {'text': sentence.text, 'englishText': sentence.englishText, 'tokens': sentence.tokens.map((token) => jsonEncode(token.toMap())).toList()});
      await DBProvider.db.addSentence(sentence);
    });
  }

  ///Used to fetch kanjis that has been loaded to firebase and local db
  Future checkForUpdate(Map<String, Kanji> allLocalKanjis) async {
    var querySnapshot = await firestore.collection('update').getDocuments();
    var updateKanjis = <String>[];
    for (var id in querySnapshot.documents.map((doc) => doc.documentID).toList()) {
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
      var kanji = await jishoApiProvider.fetchKanjiInfo(kanjiStr);
      DBProvider.db.addKanji(kanji);
      await uploadKanji(kanji);
    }
  }

  @Deprecated('Used for scripting')
  Future downloadAllKanjis() async {
    var kanjis = <Kanji>[];
    firestore.collection('kanjis').getDocuments().then((querySnapshot) {
      for (var snap in querySnapshot.documents) {
        var kanji = Kanji.fromMap(snap.data);
        print(kanji.kanji);
        kanjis.add(kanji);
      }
      //DBProvider.db.addAllKanjis(kanjis);
    });
  }

  ///TODO: need to test whether the old and new list merge
  Future uploadUserModifiedKanji(Kanji kanji) async {
    var snap = await firestore.collection('userUpdates').document(kanji.kanji).get();

    if(snap.exists) {
      firestore.collection('userUpdates').document(kanji.kanji).updateData({
        'kanji': kanji.kanji,
        'onyomi': FieldValue.arrayUnion(kanji.onyomi),
        'kunyomi': FieldValue.arrayUnion(kanji.kunyomi),
        'onyomiWords': FieldValue.arrayUnion(kanji.onyomiWords.map((word) => word.toString()).toList()),
        'kunyomiWords': FieldValue.arrayUnion(kanji.kunyomiWords.map((word) => word.toString()).toList())
      });
    }else{
      firestore.collection('userUpdates').document(kanji.kanji).setData({
        'kanji': kanji.kanji,
        'onyomi': FieldValue.arrayUnion(kanji.onyomi),
        'kunyomi': FieldValue.arrayUnion(kanji.kunyomi),
        'onyomiWords': FieldValue.arrayUnion(kanji.onyomiWords.map((word) => word.toString()).toList()),
        'kunyomiWords': FieldValue.arrayUnion(kanji.kunyomiWords.map((word) => word.toString()).toList())
      });
    }
//    int i = 0;
//    var snap = await firestore.collection('userUpdates').document(kanji.kanji).get();
//    if(snap.exists) {
//      while (snap.exists) {
//        i++;
//        snap = await firestore.collection('userUpdates').document(kanji.kanji + i.toString()).get();
//      }
//      firestore.collection('userUpdates').document(kanji.kanji+i.toString()).setData({
//        'kanji': kanji.kanji,
//        'onyomi': FieldValue.arrayUnion(kanji.onyomi),
//        'kunyomi': FieldValue.arrayUnion(kanji.kunyomi),
//        'onyomiWords': FieldValue.arrayUnion(kanji.onyomiWords.map((word) => word.toString()).toList()),
//        'kunyomiWords': FieldValue.arrayUnion(kanji.kunyomiWords.map((word) => word.toString()).toList())
//      });
//    }else{
//      firestore.collection('userUpdates').document(kanji.kanji).setData({
//        'kanji': kanji.kanji,
//        'onyomi': FieldValue.arrayUnion(kanji.onyomi),
//        'kunyomi': FieldValue.arrayUnion(kanji.kunyomi),
//        'onyomiWords': FieldValue.arrayUnion(kanji.onyomiWords.map((word) => word.toString()).toList()),
//        'kunyomiWords': FieldValue.arrayUnion(kanji.kunyomiWords.map((word) => word.toString()).toList())
//      });
//    }
  }

  Future fetchUpdates() async {
    var prefs = await SharedPreferences.getInstance();
    var localVersionNum = prefs.getInt(versionKey);

    if (localVersionNum == null) {
      prefs.setInt(versionKey, 0);
      localVersionNum = 0;
    }

    //To store the kanji that has already been updated
    List<String> updatedKanjiStrs = <String>[];

    var snap = await firestore.collection('updates').document('version').get();
    var versionNum = snap.data['versionNum'];
    if (versionNum > localVersionNum) {
      for (int i = localVersionNum + 1; i <= versionNum; i++) {
        snap = await firestore.collection('updates').document(i.toString()).get();
        var kanjis = snap.data['kanjis'] as List;
        for (var kanjiStr in kanjis) {
          if (updatedKanjiStrs.contains(kanjiStr)) continue;
          var localKanji = await DBProvider.db.getSingleKanji(kanjiStr);
          var firestoreKanji = Kanji.fromMap((await firestore.collection('kanjis').document(kanjiStr).get()).data);
          localKanji.kunyomiWords.addAll(firestoreKanji.kunyomiWords);
          localKanji.onyomiWords.addAll(firestoreKanji.onyomiWords);
          DBProvider.db.updateKanji(localKanji);
          updatedKanjiStrs.add(kanjiStr);
        }
      }
    }
    return null; //TODO: should wait for above actions to be finished
  }

  Future<bool> getIsUpdated() async => (await getLocalVersion()) == (await getFirebaseVersion());

  Future<int> getLocalVersion() async {
    var prefs = await SharedPreferences.getInstance();
    var localVersionNum = prefs.getInt(versionKey);
    return localVersionNum ?? 0;
  }

  Future<int> getFirebaseVersion() async => (await firestore.collection('updates').document('version').get()).data['versionNum'];
}

const String versionKey = 'version';

///for usage in jisho_api_provider
final firebaseApiProvider = FirebaseApiProvider();
