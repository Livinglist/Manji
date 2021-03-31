import 'dart:convert';

import '../resource/constants.dart';
import 'word.dart';

enum JLPTLevel { n1, n2, n3, n4, n5 }
enum Grade { g1, g2, g3, g4, g5, g6, g7, g8 }
enum Yomikata { kunyomi, onyomi }

Map<String, String> radicalsToMeaning = {
  '一': 'one',
  '丨': 'line',
  '丶': 'dot',
  '丿': 'slash',
  '乛(乙,⺄,乚)': 'second',
  '亅': 'hook',
  '爪(爫)': 'claw',
  '二': 'two',
  '亠': 'lid',
  '人(亻)': 'man, human',
  '儿': 'legs',
  '入': 'enter',
  '八': 'eight',
  '冂': 'open country',
  '目': 'eye',
  '冖': 'cover',
  '冫': 'ice',
  '几': 'table',
  '夂': 'go',
  '凵': 'container, open mouth',
  '刀(刂)': 'knife, sword',
  '力': 'power, force',
  '勹': 'wrap, embrace',
  '匕': 'spoon',
  '匚': 'box',
  '匸': 'hiding enclosure',
  '十': 'ten, complete',
  '卩': 'kneel',
  '厂': 'cliff',
  '小': 'small, insignificant',
  '厶': 'private',
  '又': 'right hand',
  '口': 'mouth, opening',
  '囗': 'enclosure',
  '土': 'earth',
  '士': 'scholar, bachelor',
  '爿': 'split wood',
  '夊': 'go slowly',
  '夕': 'evening, sunset',
  '大': 'big, very',
  '女': 'woman, female',
  '子': 'child, seed',
  '宀': 'roof',
  '寸': 'thumb, inch',
  '尢(尣)': 'lame',
  '尸': 'corpse',
  '屮': 'sprout',
  '山': 'mountain',
  '巛(川,巜)': 'river',
  '木': 'tree',
  '工': 'work',
  '己(巳,已,㔾)': 'oneself',
  '巾': 'turban, scarf',
  '干': 'pestle',
  '幺': 'short, tiny',
  '广': 'house on cliff',
  '廴': 'long stride',
  '廾': 'two hands, twenty',
  '弋': 'shoot, arrow',
  '弓': 'bow',
  '彐(彑)': 'pig snout',
  '彡': 'bristle, beard',
  '彳': 'step',
  '心(忄,⺗)': 'heart',
  '戈': 'spear, halberd',
  '戶(户,戸)': 'door, house',
  '手(扌龵)': 'hand',
  '支': 'branch',
  '攴(攵)': 'rap',
  '文': 'script, literature',
  '齊': 'even, uniformly',
  '斗': 'dipper',
  '斤': 'axe',
  '方': 'square',
  '无': 'perish',
  '日': 'sun, day',
  '曰': 'say',
  '月': 'moon, month',
  '肉(⺼)': 'meat',
  '欠': 'lack, yawn',
  '止': 'stop',
  '歹(歺)': 'death, decay',
  '殳': 'weapon, lance',
  '毋(母,⺟)': 'mother, do not',
  '比': 'compare, compete',
  '毛': 'fur, hair',
  '氏': 'clan',
  '气': 'steam, breath',
  '水(氵,氺)': 'water',
  '火(灬)': 'fire',
  '父': 'father',
  '爻': 'mix, twine, cross',
  '牛(牜)': 'cow',
  '犬(犭)': 'dog',
  '玄': 'dark, profound',
  '玉(王)': 'jade (king)',
  '甘': 'sweet',
  '生': 'life',
  '用(甩)': 'use',
  '田': 'field',
  '疋(⺪)': 'bolt of cloth',
  '疒': 'sickness',
  '癶': 'footsteps',
  '白': 'white',
  '皿': 'dish',
  '羊(⺶)': 'sheep',
  '矛': 'spear',
  '矢': 'arrow',
  '石': 'stone',
  '示(礻)': 'sign',
  '禾': 'grain',
  '穴': 'cave',
  '立': 'stand, erect',
  '竹(⺮)': 'bamboo',
  '米': 'rice',
  '聿(⺻)': 'brush',
  '糸(糹)': 'silk',
  '网(罒,⺲,罓,⺳)': 'net',
  '羽': 'feather',
  '老(耂)': 'old',
  '而': 'beard',
  '耒': 'plow',
  '耳': 'ear',
  '臣': 'minster, official',
  '自': 'self',
  '至': 'arrive',
  '臼': 'mortar',
  '舌': 'tongue',
  '舛': 'opposite',
  '舟': 'boat',
  '艮': 'stopping',
  '色': 'colour, prettiness',
  '艸(艹)': 'grass',
  '辵(辶,⻌,⻍)': 'walk',
  '虍': 'tiger stripes',
  '虫': 'insect',
  '血': 'blood',
  '行': 'go, do',
  '衣(衤)': 'clothes',
  '西(襾,覀)': 'west',
  '見': 'see',
  '角': 'horn',
  '言(訁)': 'speech',
  '谷': 'valley',
  '豆': 'bean',
  '豕': 'pig',
  '貝': 'shell',
  '赤': 'red, naked',
  '走(赱)': 'run',
  '足(⻊)': 'foot',
  '車': 'cart, car',
  '辛': 'bitter',
  '辰': 'morning',
  '邑(阝)': 'town (阝 right)',
  '牙': 'fang',
  '酉': 'wine, alcohol',
  '釆': 'divide, distinguish, choose',
  '里': 'village, mile',
  '金(釒)': 'metal, gold',
  '長(镸)': 'long, grow',
  '門': 'gate',
  '阜(阝)': 'mound, dam (阝 left)',
  '隶': 'slave, capture',
  '隹': 'small bird',
  '雨': 'rain',
  '青(靑)': 'blue',
  '非': 'wrong',
  '面(靣)': 'face',
  '革': 'leather, rawhide',
  '音': 'sound',
  '頁': 'leaf',
  '風': 'wind',
  '飛': 'fly',
  '食(飠)': 'eat, food',
  '首': 'head',
  '香': 'fragrance',
  '馬': 'horse',
  '骨': 'bone',
  '高(髙)': 'tall',
  '髟': 'long hair',
  '鬼': 'ghost, demon',
  '魚': 'fish',
  '鳥': 'bird',
  '鹿': 'deer',
  '麻': 'hemp, flax',
  '黃': 'yellow',
  '黍': 'millet',
  '黑': 'black',
  '鼓': 'drum',
  '龍': 'dragon',
  '瓜': 'melon',
  '皮': 'skin',
  '片': 'slice',
  '卜': 'divination',
  '禸': 'track',
  '瓦': 'tile',
  '齒': 'tooth, molar',
  '缶': 'jar',
  '韋': 'tanned leather',
  '麥': 'wheat',
  '豸': 'cat, badger',
  '身': 'body',
  '鼻': 'nose'
};

class Kanji {
  int id;
  String kanji;
  List<String> onyomi;
  List<String> kunyomi;
  String meaning;
  String radicals;
  String radicalsMeaning;
  int strokes;
  bool isFaved;
  List<int> timeStamps = [];

  set timeStamp(int timeStamp) => timeStamps.add(timeStamp);

  JLPTLevel get jlptLevel {
    switch (jlpt) {
      case 1:
        return JLPTLevel.n1;
      case 2:
        return JLPTLevel.n2;
      case 3:
        return JLPTLevel.n3;
      case 4:
        return JLPTLevel.n4;
      case 5:
        return JLPTLevel.n5;
    }
    return null;
  }

  int grade;
  int jlpt;
  int frequency;
  List<String> parts;
  List<Word> onyomiWords;
  List<Word> kunyomiWords;

  Kanji(
      {this.id,
      this.kanji,
      this.onyomi,
      this.kunyomi,
      this.meaning,
      this.grade,
      this.jlpt,
      this.strokes,
      this.frequency,
      this.parts,
      this.onyomiWords,
      this.kunyomiWords,
      this.isFaved = false})
      : assert((grade >= 0 && grade <= 7)),
        assert(jlpt >= 0 && jlpt <= 5),
        assert(strokes != 0),
        assert(frequency >= 0);

  Map toMap() => {
        Keys.gradeKey: this.grade,
        Keys.jlptKey: this.jlpt,
        Keys.kanjiKey: this.kanji,
        Keys.frequencyKey: this.frequency,
        Keys.onyomiKey: this.onyomi,
        Keys.kunyomiKey: this.kunyomi,
        Keys.strokesKey: this.strokes,
        Keys.partsKey: this.parts,
        Keys.meaningKey: this.meaning,
        Keys.kunyomiWordsKey: this.kunyomiWords,
        Keys.onyomiWordsKey: this.onyomiWords
      };

  Kanji.fromMap(Map map) {
    kanji = map[Keys.kanjiKey];
    meaning = map[Keys.meaningKey];
    strokes = map[Keys.strokesKey];
    grade = map[Keys.gradeKey];
    jlpt = map[Keys.jlptKey];
    frequency = map[Keys.frequencyKey];
    parts = ((map[Keys.partsKey] as List) ?? []).cast<String>();
    kunyomi = (map[Keys.kunyomiKey] as List ?? []).cast<String>();
    kunyomiWords = (map[Keys.kunyomiWordsKey] as List ?? []).cast<String>().map((str) => Word.fromString(str)).toList();
    onyomi = (map[Keys.onyomiKey] as List ?? []).cast<String>();
    onyomiWords = (map[Keys.onyomiWordsKey] as List ?? []).cast<String>().map((str) => Word.fromString(str)).toList();
  }

  Map<String, dynamic> toDBMap() => {
        Keys.idKey: Keys.idKey,
        Keys.gradeKey: this.grade,
        Keys.jlptKey: this.jlpt,
        Keys.kanjiKey: this.kanji,
        Keys.frequencyKey: this.frequency,
        Keys.onyomiKey: jsonEncode(this.onyomi),
        Keys.kunyomiKey: jsonEncode(this.kunyomi),
        Keys.strokesKey: this.strokes,
        Keys.partsKey: jsonEncode(this.parts),
        Keys.meaningKey: this.meaning,
        Keys.radicalKey: this.radicals,
        Keys.radicalsMeaningKey: this.radicalsMeaning,
        Keys.kunyomiWordsKey: jsonEncode(this.kunyomiWords.map((word) => word.toMap()).toList()),
        Keys.onyomiWordsKey: jsonEncode(this.onyomiWords.map((word) => word.toMap()).toList()),
        Keys.studiedTimeStampsKey: jsonEncode(this.timeStamps)
      };

  Kanji.fromDBMap(Map map) {
    id = map[Keys.idKey];
    kanji = map[Keys.kanjiKey];
    meaning = map[Keys.meaningKey];
    radicals = map[Keys.radicalKey];
    radicalsMeaning = map[Keys.radicalsMeaningKey];
    strokes = map[Keys.strokesKey];
    grade = map[Keys.gradeKey];
    jlpt = map[Keys.jlptKey];
    frequency = map[Keys.frequencyKey];
    parts = (jsonDecode(map[Keys.partsKey]) as List).cast<String>();
    kunyomi = (jsonDecode(map[Keys.kunyomiKey]) as List).cast<String>();
    kunyomiWords = (jsonDecode(map[Keys.kunyomiWordsKey]) as List).map((str) => Word.fromMap(str)).toList();
    onyomi = (jsonDecode(map[Keys.onyomiKey]) as List).cast<String>();
    onyomiWords = (jsonDecode(map[Keys.onyomiWordsKey]) as List).map((str) => Word.fromMap(str)).toList();
    timeStamps = (jsonDecode(map[Keys.studiedTimeStampsKey] ?? '[]') as List).cast<int>();
  }

  String toString() {
    return 'Instance of Kanji: $kanji, meaning: $meaning';
  }
}
