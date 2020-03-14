import 'dart:io';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kanji_dictionary/models/kanji.dart';
import 'package:kanji_dictionary/models/sentence.dart';
import 'package:kanji_dictionary/models/kana.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  Future initDB({bool refresh = false}) async {
    ///Initialize database in external storage
//    Directory extStoraheDor = await getExternalStorageDirectory();
//    String path = join(extStoraheDor.path, "dictDB.db");
//    return await openDatabase(
//      path,
//      version: 1,
//      onOpen: (db) {},
//    );

    ///Initialize database in external storage
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String path = join(appDocDir.path, "dictDB.db");

    if (await File(path).exists() && !refresh) {
      //return await openDatabase(path);
      print("hi there loading");
      return openDatabase(
        path,
        version: 1,
        onOpen: (db) async {
          print(await db.query("sqlite_master"));

//          var res = await db.query('Kanji');
//
//          kanjis = res.isNotEmpty
//              ? res.map((r) {
//            //print(r.toString());
//            return Kanji.fromDBMap(r);
//          }).toList()
//              : [];
        },
      );
    } else {
      print("hi there copying");

      ByteData data = await rootBundle.load("data/dictDB.db");
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
      return openDatabase(
        path,
        version: 1,
        onOpen: (db) async {
          print(await db.query("sqlite_master"));
        },
      );
    }
  }

  static List<Kanji> kanjis = <Kanji>[];
  Future<List<Kanji>> getAllKanjis() async {
    final db = await database;
    var res = await db.query('Kanji');

    return res.isNotEmpty
        ? res.map((r) {
            //print(r.toString());
            return Kanji.fromDBMap(r);
          }).toList()
        : [];
//    if (kanjis.isNotEmpty) {
//      final db = await database;
//      var res = await db.query('Kanji');
//
//      return res.isNotEmpty
//          ? res.map((r) {
//              //print(r.toString());
//              return Kanji.fromDBMap(r);
//            }).toList()
//          : [];
//    } else {
//      return kanjis;
//    }
  }

  @Deprecated('')
  Future<List<Sentence>> getSentencesByKanji(String kanjiStr) async {
    final db = await database;
    //print(await db.query("sqlite_master"));
    //var res = await db.query('Sentence', where: '"kanji" = ?',whereArgs: [kanjiStr] );
    var res = await db.rawQuery("SELECT * FROM Sentence WHERE kanji = '$kanjiStr' LIMIT 1");
    var sentences = await jsonStringToSentences(res.single['text']);

    return sentences;
  }

  @Deprecated('')
  Stream<Sentence> getSentencesByKanjiStream(String kanjiStr) async* {
    final db = await database;
    print(await db.query("sqlite_master"));
    //var res = await db.query('Sentence', where: '"kanji" = ?',whereArgs: [kanjiStr] );
    var res = await db.rawQuery("SELECT * FROM Sentence WHERE kanji = '$kanjiStr' LIMIT 1");
    jsonToSentencesStream(res.single['text']).listen((sentence) async* {
      yield sentence;
    });
  }

  Future<String> getSentencesJsonStringByKanji(String kanjiStr) async {
    final db = await database;
    //print(await db.query("sqlite_master"));
    //var res = await db.query('Sentence', where: '"kanji" = ?',whereArgs: [kanjiStr] );
    var res = await db.rawQuery("SELECT * FROM Sentence WHERE kanji = '$kanjiStr' LIMIT 1");
    if (res.isNotEmpty)
      return res.single['text'];
    else
      return null;
  }

  Future<int> addKanji(Kanji kanji) async {
    final db = await database;
    var map = kanji.toDBMap();
    var raw = await db.insert('Kanji', map);
    return raw;
  }

  ///Used for fetching from Firestore and loading to local database
  Future<int> addSentence(Sentence sentence) async {
    final db = await database;
    //var table = await db.rawQuery('SELECT MAX(id)+1 as id FROM Sentence');
    //int id = table.first['id'];
    //sentence.id = id;
    var map = sentence.toDBMap();
    //print("the id is $id");
    //await db.insert('Sentence', map);
    var raw = await db.rawInsert('INSERT Into Sentence (kanji, text) VALUES (?,?)', [
      sentence.kanji,
      map['text'],
    ]);
    return raw;
  }

  Future addSentences(List<Sentence> sentences) async {
    final db = await database;
    //var table = await db.rawQuery('SELECT MAX(id)+1 as id FROM Sentence');
    //int id = table.first['id'];
    //sentence.id = id;
    //print("the id is $id");
    //await db.insert('Sentence', map);
    var raw = await db.rawQuery("INSERT Into Sentence (kanji, text) VALUES (?,?)", [sentences.first.kanji, sentencesToJson(sentences)]);
    return raw;
  }

  Future doScript() async {
    final db = await database;

    var kanjis = (await db.query('Kanji', columns: ['kanji'])).map((map) => map['kanji']);

    for (String kanji in kanjis) {
      var q = await db.rawQuery("SELECT * FROM Sentence WHERE kanji = '$kanji'");
      var sentences = q.map((map) => Sentence.fromDBMap(map)).toList();
      print(kanji);

      db.rawDelete("DELETE FROM Sentence WHERE kanji = '$kanji'").then((_) {
        db.rawQuery("INSERT Into Sentence (kanji, text) VALUES (?,?)", [kanji, sentencesToJson(sentences)]);
      });
//      await db.delete('Sentence', where: '"kanji" = ?', whereArgs: [kanji]).then((_) {
//        db.rawQuery("INSERT Into Sentence (kanji, text) VALUES (?,?)", [kanji, sentencesToJson(sentences)]);
//      });
    }
  }

  Future<List<Hiragana>> getAllHiragana() async{
    final db = await database;
    var res = await db.query('Hiragana');

    return res.isNotEmpty
        ? res.map((r) {
      //print(r.toString());
      return Hiragana.fromMap(r);
    }).toList()
        : [];
  }

  Future<List<Katakana>> getAllKatakana() async{
    final db = await database;
    var res = await db.query('Katakana');

    return res.isNotEmpty
        ? res.map((r) {
      //print(r.toString());
      return Katakana.fromMap(r);
    }).toList()
        : [];
  }

  Future updateKanji(Kanji kanji) async {
    var map = kanji.toDBMap();
    var db = await database;

    db.rawUpdate("UPDATE Kanji SET onyomiWords = ?, onyomi = ?, kunyomiWords = ?, kunyomi = ? WHERE kanji = ?", [
      map['onyomiWords'],
      map['onyomi'],
      map['kunyomiWords'],
      map['kunyomi'],
      kanji.kanji
    ]);
  }

  Future<Kanji> getSingleKanji(String kanjiStr) async {
    var db = await database;
    var query = await db.rawQuery("SELECT FROM Kanji WHERE kanji = '$kanjiStr' LIMIT 1");
    if(query == null || query.isEmpty) return null;

    return Kanji.fromDBMap(query.single);
  }
}

Future<bool> getDatabaseStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('databaseStatus');
}

void setDatabaseStatus(bool dbStatus) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('databaseStatus', dbStatus);
}

//final dbProvider = DBProvider._();
