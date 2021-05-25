import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../bloc/kanji_bloc.dart';
import '../bloc/kanji_list_bloc.dart';
import '../resource/shared_preferences_provider.dart';

class FirestoreProvider {
  FirestoreProvider._();

  static final instance = FirestoreProvider._();

  static String _uid;

  Future removeFavKanji(String kanji) async {
    _uid = _uid ?? FirebaseAuth.instance.currentUser.uid;

    return FirebaseFirestore.instance.collection(usersKey).doc(_uid).update({
      favKanjisKey: FieldValue.arrayRemove([kanji])
    }).whenComplete(_updateTimestamp);
  }

  Future removeMarkedKanji(String kanji) async {
    _uid = _uid ?? FirebaseAuth.instance.currentUser.uid;

    return FirebaseFirestore.instance.collection(usersKey).doc(_uid).update({
      markedKanjisKey: FieldValue.arrayRemove([kanji])
    }).whenComplete(_updateTimestamp);
  }

  Future uploadFavKanjis(List<String> kanjis) async {
    _uid = _uid ?? FirebaseAuth.instance.currentUser.uid;

    return FirebaseFirestore.instance
        .collection(usersKey)
        .doc(_uid)
        .update({favKanjisKey: FieldValue.arrayUnion(kanjis)}).whenComplete(
            _updateTimestamp);
  }

  Future uploadMarkedKanjis(List<String> kanjis) async {
    _uid = _uid ?? FirebaseAuth.instance.currentUser.uid;

    return FirebaseFirestore.instance
        .collection(usersKey)
        .doc(_uid)
        .update({markedKanjisKey: FieldValue.arrayUnion(kanjis)}).whenComplete(
            _updateTimestamp);
  }

  Future uploadKanjiList(KanjiList kanjiList) async {
    if (FirebaseAuth.instance.currentUser != null) {
      _uid = _uid ?? FirebaseAuth.instance.currentUser.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection(usersKey)
          .doc(_uid)
          .collection(kanjiListsKey)
          .doc(kanjiList.uid)
          .get();
      if (snapshot.exists) {
        return FirebaseFirestore.instance
            .collection(usersKey)
            .doc(_uid)
            .collection(kanjiListsKey)
            .doc(kanjiList.uid)
            .update({
          kanjiListUidKey: kanjiList.uid,
          kanjiListNameKey: kanjiList.name,
          kanjiListKanjisKey: kanjiList.kanjiStrs,
        }).whenComplete(_updateTimestamp);
      }
      return FirebaseFirestore.instance
          .collection(usersKey)
          .doc(_uid)
          .collection(kanjiListsKey)
          .doc(kanjiList.uid)
          .set({
        kanjiListUidKey: kanjiList.uid,
        kanjiListNameKey: kanjiList.name,
        kanjiListKanjisKey: kanjiList.kanjiStrs,
      }).whenComplete(_updateTimestamp);
    }
  }

  Future<List<String>> fetchFavKanjis() async {
    _uid = _uid ?? FirebaseAuth.instance.currentUser.uid;

    final snapshot =
        await FirebaseFirestore.instance.collection(usersKey).doc(_uid).get();
    return (snapshot.data()[favKanjisKey] as List).cast<String>();
  }

  Future<List<String>> fetchMarkedKanjis() async {
    _uid = _uid ?? FirebaseAuth.instance.currentUser.uid;

    final snapshot =
        await FirebaseFirestore.instance.collection(usersKey).doc(_uid).get();
    return (snapshot.data()[markedKanjisKey] as List).cast<String>();
  }

  Stream<KanjiList> fetchKanjiLists() async* {
    _uid = _uid ?? FirebaseAuth.instance.currentUser.uid;

    final snapshots = await FirebaseFirestore.instance
        .collection(usersKey)
        .doc(_uid)
        .collection(kanjiListsKey)
        .get();
    for (var snapshot in snapshots.docs) {
      final kanjiList = KanjiList.fromMap(snapshot.data());
      yield kanjiList;
    }
  }

  Future deleteKanjiList(KanjiList kanjiList) async {
    if (FirebaseAuth.instance.currentUser != null) {
      _uid = _uid ?? FirebaseAuth.instance.currentUser.uid;
      return FirebaseFirestore.instance
          .collection(usersKey)
          .doc(_uid)
          .collection(kanjiListsKey)
          .doc(kanjiList.uid)
          .delete()
          .whenComplete(_updateTimestamp);
    }
  }

  Future _updateTimestamp() async {
    _uid = _uid ?? FirebaseAuth.instance.currentUser.uid;

    return FirebaseFirestore.instance.collection(usersKey).doc(_uid).set(
        {lastUpdatedAtKey: DateTime.now().millisecondsSinceEpoch},
        SetOptions(merge: true));
  }

  Future<bool> isUpgradable() async {
    _uid = _uid ?? FirebaseAuth.instance.currentUser.uid;

    final lastFetchedAt = SharedPreferencesProvider.instance.lastFetchedAt;
    final lastUpdatedAt = await FirebaseFirestore.instance
        .collection(usersKey)
        .doc(_uid)
        .get()
        .then((snapshot) => snapshot.data()[lastUpdatedAtKey]);

    if (lastUpdatedAt == null) {
      FirebaseFirestore.instance
          .collection(usersKey)
          .doc(_uid)
          .update({lastUpdatedAtKey: DateTime.now().millisecondsSinceEpoch});
      return false;
    }

    return lastFetchedAt == null || lastFetchedAt < lastUpdatedAt;
  }

  ///Upload all local data to FirebaseFirestore if user is the first time user.
  void uploadAll() {
    final allFav = KanjiBloc.instance.getAllFavKanjis;
    final allMarked = KanjiBloc.instance.getAllMarkedKanjis;
    final allLists = KanjiListBloc.instance.allKanjiLists;

    uploadFavKanjis(allFav);
    uploadMarkedKanjis(allMarked);
    for (final list in allLists) {
      uploadKanjiList(list);
    }
  }

  ///Fetch all remote data from FirebaseFirestore if is upgradable.
  void fetchAll() async {
    final allFav = await fetchFavKanjis();
    final allMarked = await fetchMarkedKanjis();
    final allLists = await fetchKanjiLists().toList();

    for (var kanji in allFav) {
      KanjiBloc.instance.addFav(kanji);
    }

    for (var kanji in allMarked) {
      KanjiBloc.instance.addStar(kanji);
    }

    KanjiListBloc.instance.clearThenAddKanjiLists(allLists);

    SharedPreferencesProvider.instance.lastFetchedAt =
        DateTime.now().millisecondsSinceEpoch;
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
