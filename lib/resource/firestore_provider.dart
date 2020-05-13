import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import 'package:kanji_dictionary/bloc/kanji_list_bloc.dart';
import 'package:kanji_dictionary/resource/shared_preferences_provider.dart';

class FirestoreProvider {
  FirestoreProvider._();

  static final instance = FirestoreProvider._();

  static String _uid;

  Future removeFavKanji(String kanji) async {
    _uid = _uid ?? await FirebaseAuth.instance.currentUser().then((value) => value.uid);

    return Firestore.instance.collection(usersKey).document(_uid).updateData({
      favKanjisKey: FieldValue.arrayRemove([kanji])
    }).whenComplete(_updateTimestamp);
  }

  Future removeMarkedKanji(String kanji) async {
    _uid = _uid ?? await FirebaseAuth.instance.currentUser().then((value) => value.uid);

    return Firestore.instance.collection(usersKey).document(_uid).updateData({
      markedKanjisKey: FieldValue.arrayRemove([kanji])
    }).whenComplete(_updateTimestamp);
  }

  Future uploadFavKanjis(List<String> kanjis) async {
    _uid = _uid ?? await FirebaseAuth.instance.currentUser().then((value) => value.uid);

    return Firestore.instance
        .collection(usersKey)
        .document(_uid)
        .updateData({favKanjisKey: FieldValue.arrayUnion(kanjis)}).whenComplete(_updateTimestamp);
  }

  Future uploadMarkedKanjis(List<String> kanjis) async {
    _uid = _uid ?? await FirebaseAuth.instance.currentUser().then((value) => value.uid);

    return Firestore.instance
        .collection(usersKey)
        .document(_uid)
        .updateData({markedKanjisKey: FieldValue.arrayUnion(kanjis)}).whenComplete(_updateTimestamp);
  }

  Future uploadKanjiList(KanjiList kanjiList) async {
    _uid = _uid ?? await FirebaseAuth.instance.currentUser().then((value) => value.uid);

    var snapshot = await Firestore.instance.collection(usersKey).document(_uid).collection(kanjiListsKey).document(kanjiList.uid).get();
    if (snapshot.exists) {
      return Firestore.instance.collection(usersKey).document(_uid).collection(kanjiListsKey).document(kanjiList.uid).updateData({
        kanjiListUidKey: kanjiList.uid,
        kanjiListNameKey: kanjiList.name,
        kanjiListKanjisKey: kanjiList.kanjiStrs,
      }).whenComplete(_updateTimestamp);
    }
    return Firestore.instance.collection(usersKey).document(_uid).collection(kanjiListsKey).document(kanjiList.uid).setData({
      kanjiListUidKey: kanjiList.uid,
      kanjiListNameKey: kanjiList.name,
      kanjiListKanjisKey: kanjiList.kanjiStrs,
    }).whenComplete(_updateTimestamp);
  }

  Future<List<String>> fetchFavKanjis() async {
    _uid = _uid ?? await FirebaseAuth.instance.currentUser().then((value) => value.uid);

    var snapshot = await Firestore.instance.collection(usersKey).document(_uid).get();
    return (snapshot.data[favKanjisKey] as List).cast<String>();
  }

  Future<List<String>> fetchMarkedKanjis() async {
    _uid = _uid ?? await FirebaseAuth.instance.currentUser().then((value) => value.uid);

    var snapshot = await Firestore.instance.collection(usersKey).document(_uid).get();
    return (snapshot.data[markedKanjisKey] as List).cast<String>();
  }

  Stream<KanjiList> fetchKanjiLists() async* {
    _uid = _uid ?? await FirebaseAuth.instance.currentUser().then((value) => value.uid);

    var snapshots = await Firestore.instance.collection(usersKey).document(_uid).collection(kanjiListsKey).getDocuments();
    for (var snapshot in snapshots.documents) {
      var kanjiList = KanjiList.fromMap(snapshot.data);
      yield kanjiList;
    }
  }

  Future deleteKanjiList(KanjiList kanjiList) async {
    _uid = _uid ?? await FirebaseAuth.instance.currentUser().then((value) => value.uid);
    return Firestore.instance
        .collection(usersKey)
        .document(_uid)
        .collection(kanjiListsKey)
        .document(kanjiList.uid)
        .delete()
        .whenComplete(_updateTimestamp);
  }

  Future _updateTimestamp() async {
    _uid = _uid ?? await FirebaseAuth.instance.currentUser().then((value) => value.uid);

    return Firestore.instance.collection(usersKey).document(_uid).setData({lastUpdatedAtKey: DateTime.now().millisecondsSinceEpoch}, merge: true);
  }

  Future<bool> isUpgradable() async {
    _uid = _uid ?? await FirebaseAuth.instance.currentUser().then((value) => value.uid);

    var lastFetchedAt = SharedPreferencesProvider.instance.lastFetchedAt;
    var lastUpdatedAt = await Firestore.instance.collection(usersKey).document(_uid).get().then((snapshot) => snapshot.data[lastUpdatedAtKey]);

    return lastFetchedAt == null || lastFetchedAt < lastUpdatedAt;
  }

  ///Upload all local data to Firestore if user is the first time user.
  void uploadAll() {
    var allFav = kanjiBloc.getAllFavKanjis;
    var allMarked = kanjiBloc.getAllMarkedKanjis;
    var allLists = KanjiListBloc.instance.allKanjiLists;

    uploadFavKanjis(allFav);
    uploadMarkedKanjis(allMarked);
    for (var list in allLists) {
      uploadKanjiList(list);
    }
  }

  ///Fetch all remote data from Firestore if is upgradable.
  void fetchAll() async {
    var allFav = await fetchFavKanjis();
    var allMarked = await fetchMarkedKanjis();
    var allLists = await fetchKanjiLists().toList();

    for (var kanji in allFav) {
      kanjiBloc.addFav(kanji);
    }

    for (var kanji in allMarked) {
      kanjiBloc.addStar(kanji);
    }

    KanjiListBloc.instance.clearThenAddKanjiLists(allLists);

    SharedPreferencesProvider.instance.lastFetchedAt = DateTime.now().millisecondsSinceEpoch;
  }
}

const String usersKey = 'users';
const String favKanjisKey = 'favKanjis';
const String markedKanjisKey = 'markedKanjis';
const String kanjiListsKey = 'kanjiLists';
const String kanjiListUidKey = 'uid';
const String kanjiListNameKey = 'name';
const String kanjiListKanjisKey = 'kanjiStrs';
const String lastUpdatedAtKey = 'lastUpdatedAt';
