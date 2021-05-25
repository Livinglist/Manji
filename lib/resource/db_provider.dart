import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/kana.dart';
import '../models/kanji.dart';
import '../models/question.dart';
import '../models/sentence.dart';
import 'constants.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  Future<Database> initDB({bool needRefresh = false}) async {
    //Initialize database in external storage
    final appDocDir = await getApplicationDocumentsDirectory();
    final path = join(appDocDir.path, "dictDB.db");

    if (await File(path).exists() && needRefresh == false) {
      print("opening");
      return openDatabase(path, version: 4, onOpen: (db) async {
        _database = db;
        print(await db.query("sqlite_master"));
      }, onUpgrade: (db, oldVersion, newVersion) async {
        print('upgrading');

        if (oldVersion == 1) {
          db.rawQuery('CREATE TABLE IF NOT EXISTS "IncorrectQuestions" ('
              '"id"	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'
              '"kanjiId"	INTEGER NOT NULL,'
              '"choices"	TEXT NOT NULL,'
              '"selectedIndex"	INTEGER NOT NULL,'
              '"rightAnswer"	TEXT NOT NULL,'
              '"questionType" INTEGER NOT NULL DEFAULT 0)');
        }

        if (oldVersion == 2) {
          db.rawQuery(
              "ALTER TABLE IncorrectQuestions ADD questionType INTEGER NOT NULL DEFAULT 0");
          db.rawQuery(
              "ALTER TABLE Kanji ADD studiedTimeStamps TEXT DEFAULT '[]'");
        }

        if (oldVersion == 3) {
          final tempPath = join(appDocDir.path, "temp.db");
          final data = await rootBundle.load("data/dictDB.db");
          final List<int> bytes =
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await File(path).writeAsBytes(bytes);
          final tempDB = await openDatabase(tempPath);
          final kanjis = await tempDB.query("Kanji");
          await db.delete('Kanji');
          await db.rawQuery('''CREATE TABLE "Kanji" (
              "id"	INTEGER PRIMARY KEY AUTOINCREMENT,
              "grade"	INTEGER,
              "kanji"	TEXT,
              "strokes"	INTEGER,
              "onyomi"	TEXT,
              "meaning"	TEXT,
              "jlpt"	INTEGER,
              "frequency"	INTEGER,
              "jinmeiyo"	INTEGER,
              "faved"	INTEGER,
              "kunyomi"	TEXT,
              "kunyomiWords"	TEXT,
              "parts"	TEXT,
              "onyomiWords"	TEXT,
              "studiedTimeStamps"	TEXT DEFAULT '[]',
              "radicals"	TEXT DEFAULT '',
              "radicalsMeaning"	TEXT DEFAULT ''
          )''');
          for (var kanji in kanjis) {
            db.insert('Kanji', kanji);
          }
        }
      });
    } else {
      print("copying");
      final data = await rootBundle.load("data/dictDB.db");
      final List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
      return openDatabase(
        path,
        version: 4,
        onOpen: (db) async {
          _database = db;
          print(await db.query("sqlite_master"));
        },
      );
    }
  }

  static List<Kanji> kanjis = <Kanji>[];

  Future<List<Kanji>> getAllKanjis() async {
    final db = await database;
    final res = await db.query('Kanji').onError((error, stackTrace) {
      print('re-initialize');
      return initDB(needRefresh: true).then((value) => value.query('Kanji'));
    });

    return res.isNotEmpty
        ? res.map((r) {
            return Kanji.fromDBMap(r);
          }).toList()
        : [];
  }

  @Deprecated(
      'Use this only for scripting. Do not use this in the released app.')
  Future<List<Sentence>> getSentencesByKanji(String kanjiStr) async {
    final db = await database;
    final res = await db
        .rawQuery("SELECT * FROM Sentence WHERE kanji = '$kanjiStr' LIMIT 1");
    final sentences = await jsonStringToSentences(res.single['text']);

    return sentences;
  }

  @Deprecated(
      'Use this only for scripting. Do not use this in the released app.')
  Stream<Sentence> getSentencesByKanjiStream(String kanjiStr) async* {
    final db = await database;
    print(await db.query("sqlite_master"));
    final res = await db
        .rawQuery("SELECT * FROM Sentence WHERE kanji = '$kanjiStr' LIMIT 1");
    jsonToSentencesStream(res.single['text']).listen((sentence) async* {
      yield sentence;
    });
  }

  Future<String> getSentencesJsonStringByKanji(String kanjiStr) async {
    final db = await database;
    final res = await db
        .rawQuery("SELECT * FROM Sentence WHERE kanji = '$kanjiStr' LIMIT 1");
    if (res.isNotEmpty) {
      return res.single['text'];
    } else {
      return null;
    }
  }

  Future<int> addKanji(Kanji kanji) async {
    final db = await database;
    final map = kanji.toDBMap();
    final raw = await db.insert('Kanji', map);
    return raw;
  }

  ///Used for fetching from Firestore and loading to local database
  Future<int> addSentence(Sentence sentence) async {
    final db = await database;
    final map = sentence.toDBMap();
    final raw =
        await db.rawInsert('INSERT Into Sentence (kanji, text) VALUES (?,?)', [
      sentence.kanji,
      map['text'],
    ]);
    return raw;
  }

  Future addSentences(List<Sentence> sentences) async {
    final db = await database;
    final raw = await db.rawQuery(
        "INSERT Into Sentence (kanji, text) VALUES (?,?)",
        [sentences.first.kanji, sentencesToJson(sentences)]);
    return raw;
  }

  Future doScript() async {
    final db = await database;

    final kanjis = (await db.query('Kanji', columns: ['kanji']))
        .map((map) => map['kanji']);

    for (String kanji in kanjis) {
      final q =
          await db.rawQuery("SELECT * FROM Sentence WHERE kanji = '$kanji'");
      final sentences = q.map((map) => Sentence.fromDBMap(map)).toList();
      print(kanji);

      db.rawDelete("DELETE FROM Sentence WHERE kanji = '$kanji'").then((_) {
        db.rawQuery("INSERT Into Sentence (kanji, text) VALUES (?,?)",
            [kanji, sentencesToJson(sentences)]);
      });
    }
  }

  Future<List<Hiragana>> getAllHiragana() async {
    final db = await database;
    final res = await db.query('Hiragana');

    return res.isNotEmpty
        ? res.map((r) {
            return Hiragana.fromMap(r);
          }).toList()
        : [];
  }

  Future<List<Katakana>> getAllKatakana() async {
    final db = await database;
    final res = await db.query('Katakana');

    return res.isNotEmpty
        ? res.map((r) {
            return Katakana.fromMap(r);
          }).toList()
        : [];
  }

  Future updateKanji(Kanji kanji) async {
    final map = kanji.toDBMap();
    final db = await database;

    db.rawUpdate(
        "UPDATE Kanji SET onyomiWords = ?, onyomi = ?, kunyomiWords = ?, kunyomi = ? WHERE kanji = ?",
        [
          map['onyomiWords'],
          map['onyomi'],
          map['kunyomiWords'],
          map['kunyomi'],
          kanji.kanji
        ]);
  }

  Future<Kanji> getSingleKanji(String kanjiStr) async {
    final db = await database;
    final query = await db
        .rawQuery("SELECT FROM Kanji WHERE kanji = '$kanjiStr' LIMIT 1");
    if (query == null || query.isEmpty) return null;

    return Kanji.fromDBMap(query.single);
  }

  Future addIncorrectQuestions(List<Question> questions) async {
    final db = await database;
    for (var q in questions) {
      print(q.toMap());
      await db.insert("IncorrectQuestions", q.toMap());
    }
    return;
  }

  Future deleteIncorrectQuestion(Question question) async {
    final db = await database;
    return db.delete("IncorrectQuestions", where: "id = ${question.id}");
  }

  Future<List<Question>> getIncorrectQuestions() async {
    final db = await database;
    var query = await db.query("IncorrectQuestions");

    final qs = <Question>[];
    for (var i in query) {
      query = await db.query("Kanji", where: "id = ${i[Keys.kanjiIdKey]}");
      final kanji = Kanji.fromDBMap(query.single);
      i = Map.from(i);
      i[Keys.kanjiKey] = kanji;
      qs.add(Question.fromMap(i));
    }

    return qs;
  }

  Future updateKanjiStudiedTimeStamps(Kanji kanji) async {
    final db = await database;

    print(kanji.timeStamps);

    return db.rawUpdate(
        "UPDATE Kanji SET studiedTimeStamps = ? WHERE kanji = ?",
        [jsonEncode(kanji.timeStamps), kanji.kanji]);
  }
}

Future<bool> getDatabaseStatus() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('databaseStatus');
}

void setDatabaseStatus({bool dbStatus}) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('databaseStatus', dbStatus);
}
