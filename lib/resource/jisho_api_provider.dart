import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

import '../models/sentence.dart';
import '../models/kanji.dart';
import '../models/word.dart';
import 'firebase_api_provider.dart';
import 'db_provider.dart';

class JishoApiProvider {
  final client = Client();

  Stream<Sentence> fetchSentencesByKanji(String kanji,
      {int currentPage = 0}) async* {
    //get the html from
    Response response = await client.get(Uri.parse(
        'https://jisho.org/search/$kanji%20%23sentences?page=${currentPage + 1}'));
    var doc = parse(response.body);

    int index = 0;

    //from element we can fetch tokens in a Japanese sentence, each element contains all the tokens of one Japanese sentence
    List elements = doc.querySelectorAll('#secondary > div > ul > li');

    List<Element> engEles = doc.querySelectorAll(
        '#secondary > div > ul > li > div.sentence_content > div > span.english');

    //the reason we are getting uls is because ul.text contains the full Japanese sentence with punctuations,
    //however it contains both furigana and kanji in its text so we will get rid of them in the end by excluding all
    //the furigana we fetched from elements
    List uls = doc.querySelectorAll(
        '#secondary > div > ul > li > div.sentence_content > ul');

    if (elements.isEmpty) {
      yield null;
    }

    for (var ele in elements) {
      int childIndex = 1;
      List<Token> tokens = [];
      while (true) {
        var element = ele.querySelector(
            'div.sentence_content > ul > li:nth-child($childIndex) > span.unlinked');
        var nextnextElement = ele.querySelector(
            'div.sentence_content > ul > li:nth-child(${childIndex + 2}) > span.unlinked');
        var nextElement = ele.querySelector(
            'div.sentence_content > ul > li:nth-child(${childIndex + 1}) > span.unlinked');

        if (element == null && nextElement == null && nextnextElement == null)
          break;
        if (element == null) {
          childIndex++;
          continue;
        }
        String japText = element.text;

        element = ele.querySelector(
            'div.sentence_content > ul > li:nth-child($childIndex) > span.furigana');

        if (element == null) {
          tokens.add(Token(text: japText));
        } else {
          String furigana = element.text;
          tokens.add(Token(text: japText, furigana: furigana));
        }
        childIndex++;
      }

      String japSentence = uls[index].text;

      for (var token in tokens) {
        if (token.furigana == null) continue;
        japSentence = japSentence.replaceAll(token.furigana, '');
      }

      var sentence = Sentence(
          tokens: tokens,
          text: japSentence.trim(),
          englishText: engEles[index].text);
      yield sentence;

      index++;
    }

    return;
  }

  Stream<Word> fetchWordsByKanji(String kanji, {int currentPage = 0}) async* {
    var response = await client.get(Uri.parse(
        'https://jisho.org/search/$kanji%20%23words?page=${currentPage + 1}'));
    var doc = parse(response.body);

    //Each wordDiv contains a section for one word
    var wordDivs = doc.querySelectorAll('#primary > div > div');

    for (int i = 0; i < wordDivs.length; i++) {
      var furiganaSpan = wordDivs.elementAt(i).querySelector(
          'div.concept_light-wrapper.columns.zero-padding > div.concept_light-readings.japanese.japanese_gothic > div > span.furigana');
      var textSpan = wordDivs.elementAt(i).querySelector(
          'div.concept_light-wrapper.columns.zero-padding > div.concept_light-readings.japanese.japanese_gothic > div > span.text');

      var meaningDivs =
          wordDivs.elementAt(i).getElementsByClassName('meaning-meaning');
      String meanings = '';
      for (var meaningDiv in meaningDivs) {
        meanings += meaningDiv.text;
      }

      if (furiganaSpan == null) {} //TODO: handle this
      if (textSpan == null) {}

      var word = Word(
          wordFurigana: furiganaSpan.text,
          wordText: textSpan.text,
          meanings: meanings);

      yield word;
    }
  }

//  Future<List<Word>> fetchAllWordsByKanji(String kanji, WordType wordType) async {
//    var response = await client.get('https://jisho.org/search/$kanji%20%23words');
//    var doc = parse(response.body);
//
//    //Each wordDiv contains a section for one word
//    var wordDivs = doc.querySelectorAll('#primary > div > div');
//
//    var words = <Word>[];
//
//    for (int i = 0; i < wordDivs.length; i++) {
//      var furiganaSpan = wordDivs.elementAt(i).querySelector(
//          'div.concept_light-wrapper.columns.zero-padding > div.concept_light-readings.japanese.japanese_gothic > div > span.furigana');
//      var textSpan = wordDivs
//          .elementAt(i)
//          .querySelector('div.concept_light-wrapper.columns.zero-padding > div.concept_light-readings.japanese.japanese_gothic > div > span.text');
//
//      var meaningDivs = wordDivs.elementAt(i).getElementsByClassName('meaning-meaning');
//      String meanings = '';
//      for (var meaningDiv in meaningDivs) {
//        meanings += meaningDiv.text;
//      }
//
//      if (furiganaSpan == null) {} //TODO: handle this
//      if (textSpan == null) {}
//
//      var word = Word(wordFurigana: furiganaSpan.text, wordText: textSpan.text, meanings: meanings);
//      words.add(word);
//    }
//    return words
//  }

  Stream<List> fetchAllWordsByKanjis(List<String> kanjis) async* {
    var types = [WordType.noun, WordType.verb, WordType.adjective];

    for (var kanji in kanjis) {
      for (var type in types) {
        int pageNum = 1;
        var response = await client.get(Uri.parse(
            'https://jisho.org/search/$kanji%20%23words%20%23${wordTypeToString(type)}?page=$pageNum'));
        var doc = parse(response.body);

        //Each wordDiv contains a section for one word
        var wordDivs = doc.querySelectorAll('#primary > div > div');

        while (wordDivs != null && wordDivs.isNotEmpty) {
          for (int i = 0; i < wordDivs.length; i++) {
            var furiganaSpan = wordDivs.elementAt(i).querySelector(
                'div.concept_light-wrapper.columns.zero-padding > div.concept_light-readings.japanese.japanese_gothic > div > span.furigana');
            var textSpan = wordDivs.elementAt(i).querySelector(
                'div.concept_light-wrapper.columns.zero-padding > div.concept_light-readings.japanese.japanese_gothic > div > span.text');

            var meaningDivs =
                wordDivs.elementAt(i).getElementsByClassName('meaning-meaning');
            String meanings = '';
            for (var meaningDiv in meaningDivs) {
              meanings += meaningDiv.text;
            }

            if (furiganaSpan == null) {} //TODO: handle this
            if (textSpan == null) {}

            var word = Word(
                wordFurigana: furiganaSpan.text,
                wordText: textSpan.text,
                meanings: meanings);

            yield [kanji, type, word];
          }
          pageNum++;
          response = await client.get(Uri.parse(
              'https://jisho.org/search/$kanji%20%23words%20%23${wordTypeToString(type)}?page=$pageNum'));
          doc = parse(response.body);

          //Each wordDiv contains a section for one word
          wordDivs = doc.querySelectorAll('#primary > div > div');
        }
      }
    }
  }

  //Used for scrapping.
  Stream<List> fetchAllSentencesByKanjis(List<String> kanjis) async* {
    //const alreadyScrappedKanjis = <String>['一','二'];
    var mainCollc = 'wordSentences';
    var firebase = FirebaseFirestore.instance;
    for (var kanji in kanjis) {
      print('now fetching for $kanji');

      var ref = firebase.collection(mainCollc).doc(kanji);
      var snap = await ref.get();
      bool completed = snap.data() != null && snap.data().containsKey('length');

      if (completed) continue;

      print("Deleting $kanji");
      await ref.delete();

      await ref.set({'kanji': kanji});
      //if(alreadyScrappedKanjis.contains(kanji)) continue;
      //get the html from
      int pageNum = 1;
      Response response = await client.get(Uri.parse(
          'https://jisho.org/search/$kanji%20%23sentences?page=$pageNum'));
      var doc = parse(response.body);

      int sentenceCount = 0;
      int index = 0;

      //from element we can fetch tokens in a Japanese sentence, each element contains all the tokens of one Japanese sentence
      List elements = doc.querySelectorAll('#secondary > div > ul > li');

      List<Element> engEles = doc.querySelectorAll(
          '#secondary > div > ul > li > div.sentence_content > div > span.english');

      //the reason we are getting uls is because ul.text contains the full Japanese sentence with punctuations,
      //however it contains both furigana and kanji in its text so we will get rid of them in the end by excluding all
      //the furigana we fetched from elements
      List uls = doc.querySelectorAll(
          '#secondary > div > ul > li > div.sentence_content > ul');
      while (elements.isNotEmpty && elements != null) {
        for (var ele in elements) {
          int childIndex = 1;
          List<Token> tokens = [];
          while (true) {
            var element = ele.querySelector(
                'div.sentence_content > ul > li:nth-child($childIndex) > span.unlinked');
            var nextnextElement = ele.querySelector(
                'div.sentence_content > ul > li:nth-child(${childIndex + 2}) > span.unlinked');
            var nextElement = ele.querySelector(
                'div.sentence_content > ul > li:nth-child(${childIndex + 1}) > span.unlinked');

            if (element == null &&
                nextElement == null &&
                nextnextElement == null) break;
            if (element == null) {
              childIndex++;
              continue;
            }
            String japText = element.text;

            element = ele.querySelector(
                'div.sentence_content > ul > li:nth-child($childIndex) > span.furigana');

            if (element == null) {
              tokens.add(Token(text: japText));
            } else {
              String furigana = element.text;
              tokens.add(Token(text: japText, furigana: furigana));
            }
            childIndex++;
          }

          String japSentence = uls[index].text;

          for (var token in tokens) {
            if (token.furigana == null) continue;
            japSentence = japSentence.replaceAll(token.furigana, '');
          }

          sentenceCount++;

          print(
              '$kanji $sentenceCount: ${japSentence.trim()} ${japSentence.trim().hashCode}');
          var sentence = Sentence(
              kanji: kanji,
              tokens: tokens,
              text: japSentence.trim(),
              englishText: engEles[index].text);

          await ref
              .collection('sentences')
              .doc(sentence.text.hashCode.toString())
              .set({
            'text': sentence.text,
            'englishText': sentence.englishText,
            'tokens': sentence.tokens.map((token) => token.toMap()).toList()
          });

          yield [kanji, sentence];

          index++;
        }

        pageNum++;
        response = await client.get(Uri.parse(
            'https://jisho.org/search/$kanji%20%23sentences?page=$pageNum'));
        doc = parse(response.body);

        index = 0;

        //from element we can fetch tokens in a Japanese sentence, each element contains all the tokens of one Japanese sentence
        elements = doc.querySelectorAll('#secondary > div > ul > li');

        engEles = doc.querySelectorAll(
            '#secondary > div > ul > li > div.sentence_content > div > span.english');

        uls = doc.querySelectorAll(
            '#secondary > div > ul > li > div.sentence_content > ul');
      }
      print("$kanji has $sentenceCount sentences fetched.");
      await ref.set({'length': sentenceCount}, SetOptions(merge: true));
    }
  }

  @Deprecated('Used for scrapping')
  Future<List<Sentence>> fetchAllSentencesByKanjisAsync(
      List<String> kanjis) async {
    //const alreadyScrappedKanjis = <String>['一','二'];
    var sentences = <Sentence>[];
    for (var kanji in kanjis) {
      print('now fetching for $kanji');
      //if(alreadyScrappedKanjis.contains(kanji)) continue;
      //get the html from
      int pageNum = 1;
      Response response = await client.get(Uri.parse(
          'https://jisho.org/search/$kanji%20%23sentences?page=$pageNum'));
      var doc = parse(response.body);

      int sentenceCount = 0;
      int index = 0;

      //from element we can fetch tokens in a Japanese sentence, each element contains all the tokens of one Japanese sentence
      List elements = doc.querySelectorAll('#secondary > div > ul > li');

      List<Element> engEles = doc.querySelectorAll(
          '#secondary > div > ul > li > div.sentence_content > div > span.english');

      //the reason we are getting uls is because ul.text contains the full Japanese sentence with punctuations,
      //however it contains both furigana and kanji in its text so we will get rid of them in the end by excluding all
      //the furigana we fetched from elements
      List uls = doc.querySelectorAll(
          '#secondary > div > ul > li > div.sentence_content > ul');
      while (elements.isNotEmpty && elements != null && sentenceCount < 240) {
        for (var ele in elements) {
          int childIndex = 1;
          List<Token> tokens = [];
          while (true) {
            var element = ele.querySelector(
                'div.sentence_content > ul > li:nth-child($childIndex) > span.unlinked');
            var nextnextElement = ele.querySelector(
                'div.sentence_content > ul > li:nth-child(${childIndex + 2}) > span.unlinked');
            var nextElement = ele.querySelector(
                'div.sentence_content > ul > li:nth-child(${childIndex + 1}) > span.unlinked');

            if (element == null &&
                nextElement == null &&
                nextnextElement == null) break;
            if (element == null) {
              childIndex++;
              continue;
            }
            String japText = element.text;

            element = ele.querySelector(
                'div.sentence_content > ul > li:nth-child($childIndex) > span.furigana');

            if (element == null) {
              tokens.add(Token(text: japText));
            } else {
              String furigana = element.text;
              tokens.add(Token(text: japText, furigana: furigana));
            }
            childIndex++;
          }

          String japSentence = uls[index].text;

          for (var token in tokens) {
            if (token.furigana == null) continue;
            japSentence = japSentence.replaceAll(token.furigana, '');
          }

          print('$kanji $sentenceCount: ${japSentence.trim()}');
          var sentence = Sentence(
              kanji: kanji,
              tokens: tokens,
              text: japSentence.trim(),
              englishText: engEles[index].text);
          sentences.add(sentence);
          sentenceCount++;

          index++;
        }

        pageNum++;
        response = await client.get(Uri.parse(
            'https://jisho.org/search/$kanji%20%23sentences?page=$pageNum'));
        doc = parse(response.body);

        index = 0;

        //from element we can fetch tokens in a Japanese sentence, each element contains all the tokens of one Japanese sentence
        elements = doc.querySelectorAll('#secondary > div > ul > li');

        engEles = doc.querySelectorAll(
            '#secondary > div > ul > li > div.sentence_content > div > span.english');

        uls = doc.querySelectorAll(
            '#secondary > div > ul > li > div.sentence_content > ul');
      }
      print("$kanji has ${sentenceCount + 1} sentences fetched.");
    }
    return sentences;
  }

  //Used for scrapping.
  Stream<Sentence> fetchAllSentencesByKanji(String kanji) async* {
    //get the html from
    int pageNum = 1;
    var c = Client();
    Response response = await c.get(Uri.parse(
        'https://jisho.org/search/$kanji%20%23sentences?page=$pageNum'));
    var doc = parse(response.body);

    int index = 0;

    //from element we can fetch tokens in a Japanese sentence, each element contains all the tokens of one Japanese sentence
    List elements = doc.querySelectorAll('#secondary > div > ul > li');

    List<Element> engEles = doc.querySelectorAll(
        '#secondary > div > ul > li > div.sentence_content > div > span.english');

    //the reason we are getting uls is because ul.text contains the full Japanese sentence with punctuations,
    //however it contains both furigana and kanji in its text so we will get rid of them in the end by excluding all
    //the furigana we fetched from elements
    List uls = doc.querySelectorAll(
        '#secondary > div > ul > li > div.sentence_content > ul');
    while (elements.isNotEmpty && elements != null) {
      for (var ele in elements) {
        int childIndex = 1;
        List<Token> tokens = [];
        while (true) {
          var element = ele.querySelector(
              'div.sentence_content > ul > li:nth-child($childIndex) > span.unlinked');
          var nextnextElement = ele.querySelector(
              'div.sentence_content > ul > li:nth-child(${childIndex + 2}) > span.unlinked');
          var nextElement = ele.querySelector(
              'div.sentence_content > ul > li:nth-child(${childIndex + 1}) > span.unlinked');

          if (element == null && nextElement == null && nextnextElement == null)
            break;
          if (element == null) {
            childIndex++;
            continue;
          }
          String japText = element.text;

          element = ele.querySelector(
              'div.sentence_content > ul > li:nth-child($childIndex) > span.furigana');

          if (element == null) {
            tokens.add(Token(text: japText));
          } else {
            String furigana = element.text;
            //print(japText);
            tokens.add(Token(text: japText, furigana: furigana));
          }
          childIndex++;
        }

        //print(uls[index].text);

        String japSentence = uls[index].text;

        for (var token in tokens) {
          if (token.furigana == null) continue;
          japSentence = japSentence.replaceAll(token.furigana, '');
        }

        var sentence = Sentence(
            kanji: kanji,
            tokens: tokens,
            text: japSentence.trim(),
            englishText: engEles[index].text);
        yield sentence;

        index++;
      }

      pageNum++;
      response = await c.get(Uri.parse(
          'https://jisho.org/search/$kanji%20%23sentences?page=$pageNum'));
      doc = parse(response.body);

      index = 0;

      //from element we can fetch tokens in a Japanese sentence, each element contains all the tokens of one Japanese sentence
      elements = doc.querySelectorAll('#secondary > div > ul > li');

      engEles = doc.querySelectorAll(
          '#secondary > div > ul > li > div.sentence_content > div > span.english');

      uls = doc.querySelectorAll(
          '#secondary > div > ul > li > div.sentence_content > ul');
    }
    c.close();
    return;
  }

  @Deprecated('Used for scrapping')
  Future<List<Sentence>> fetchAllSentencesByKanjiAsync(String kanji) async {
    //get the html from
    var sentences = <Sentence>[];
    int pageNum = 1;
    Response response = await client.get(Uri.parse(
        'https://jisho.org/search/$kanji%20%23sentences?page=$pageNum'));
    var doc = parse(response.body);

    int index = 0;

    //from element we can fetch tokens in a Japanese sentence, each element contains all the tokens of one Japanese sentence
    List elements = doc.querySelectorAll('#secondary > div > ul > li');

    List<Element> engEles = doc.querySelectorAll(
        '#secondary > div > ul > li > div.sentence_content > div > span.english');

    //the reason we are getting uls is because ul.text contains the full Japanese sentence with punctuations,
    //however it contains both furigana and kanji in its text so we will get rid of them in the end by excluding all
    //the furigana we fetched from elements
    List uls = doc.querySelectorAll(
        '#secondary > div > ul > li > div.sentence_content > ul');
    while (elements.isNotEmpty && elements != null) {
      for (var ele in elements) {
        int childIndex = 1;
        List<Token> tokens = [];
        while (true) {
          var element = ele.querySelector(
              'div.sentence_content > ul > li:nth-child($childIndex) > span.unlinked');
          var nextnextElement = ele.querySelector(
              'div.sentence_content > ul > li:nth-child(${childIndex + 2}) > span.unlinked');
          var nextElement = ele.querySelector(
              'div.sentence_content > ul > li:nth-child(${childIndex + 1}) > span.unlinked');

          if (element == null && nextElement == null && nextnextElement == null)
            break;
          if (element == null) {
            childIndex++;
            continue;
          }
          String japText = element.text;

          element = ele.querySelector(
              'div.sentence_content > ul > li:nth-child($childIndex) > span.furigana');

          if (element == null) {
            tokens.add(Token(text: japText));
          } else {
            String furigana = element.text;
            //print(japText);
            tokens.add(Token(text: japText, furigana: furigana));
          }
          childIndex++;
        }

        //print(uls[index].text);

        String japSentence = uls[index].text;

        for (var token in tokens) {
          if (token.furigana == null) continue;
          japSentence = japSentence.replaceAll(token.furigana, '');
        }

        var sentence = Sentence(
            kanji: kanji,
            tokens: tokens,
            text: japSentence.trim(),
            englishText: engEles[index].text);

        print(sentence.text);
        sentences.add(sentence);

        index++;
      }

      pageNum++;
      response = await client.get(Uri.parse(
          'https://jisho.org/search/$kanji%20%23sentences?page=$pageNum'));
      doc = parse(response.body);

      index = 0;

      //from element we can fetch tokens in a Japanese sentence, each element contains all the tokens of one Japanese sentence
      elements = doc.querySelectorAll('#secondary > div > ul > li');

      engEles = doc.querySelectorAll(
          '#secondary > div > ul > li > div.sentence_content > div > span.english');

      uls = doc.querySelectorAll(
          '#secondary > div > ul > li > div.sentence_content > ul');
    }

    print("the length of sentences is ${sentences.length}");
    return sentences;
  }

  JLPTLevel _nextLevel(JLPTLevel jlpt) {
    switch (jlpt) {
      case JLPTLevel.n5:
        return JLPTLevel.n4;
      case JLPTLevel.n4:
        return JLPTLevel.n3;
      case JLPTLevel.n3:
        return JLPTLevel.n2;
      case JLPTLevel.n2:
        return JLPTLevel.n1;
      case JLPTLevel.n1:
        return null;
    }
    return null;
  }

  String _jlptLevelToSearchString(JLPTLevel jlptLevel) {
    switch (jlptLevel) {
      case JLPTLevel.n1:
        return 'jlpt-n1';
      case JLPTLevel.n2:
        return 'jlpt-n2';
      case JLPTLevel.n3:
        return 'jlpt-n3';
      case JLPTLevel.n4:
        return 'jlpt-n4';
      case JLPTLevel.n5:
        return 'jlpt-n5';
    }
    throw Exception('unmatched JLPTLevel, in _jlptLevelToSearchString');
  }

  Stream<Kanji> fetchKanjisByJLPTLevel(JLPTLevel jlptLevel) async* {
    //var url = Uri.encodeFull('https://jisho.org/search/${_jlptLevelToSearchString(jlptLevel)} #kanji');
    int pageNum = 1;
    var url = Uri.parse(
        'https://jisho.org/search/%23${_jlptLevelToSearchString(jlptLevel)}%20%23kanji?page=1');
    var response = await client.get(url);
    var doc = parse(response.body);

    print('hi there jplt is ${_jlptLevelToSearchString(jlptLevel)}');
    var allKanjiEles = doc.querySelectorAll(
        '#secondary > div > div > div > div.literal_block > span > a');

    int index = 1;
    jlptLevel = JLPTLevel.n1;
    while (jlptLevel != null) {
      pageNum = 10;
      url = Uri.parse(
          'https://jisho.org/search/%23${_jlptLevelToSearchString(jlptLevel)}%20%23kanji?page=$pageNum');
      response = await client.get(url);
      doc = parse(response.body);
      allKanjiEles = doc.querySelectorAll(
          '#secondary > div > div > div > div.literal_block > span > a');
      while (allKanjiEles != null) {
        //print('end the length is ${allKanjiEles.length}');
        var kanjiStrs = <String>[];
        for (var ele in allKanjiEles) {
          kanjiStrs.add(ele.text);
        }
        kanjiStrs.forEach(print);
        for (var kanjiStr in kanjiStrs) {
          Kanji kanji = await fetchKanjiInfo(kanjiStr);
          print(kanji.kanji);
          firebaseApiProvider.uploadKanji(kanji);
          yield kanji;
          print("total kanji count:$index");
          index++;
        }
        pageNum++;
        url = Uri.parse(
            'https://jisho.org/search/%23${_jlptLevelToSearchString(jlptLevel)}%20%23kanji?page=$pageNum');
        response = await client.get(url);
        doc = parse(response.body);
        allKanjiEles = doc.querySelectorAll(
            '#secondary > div > div > div > div.literal_block > span > a');
      }
      jlptLevel = _nextLevel(jlptLevel);
      print(_jlptLevelToSearchString(jlptLevel));
    }
    yield null;
  }

  Stream<Kanji> fetchKanjisByGrade(int grade) async* {
    //var url = Uri.encodeFull('https://jisho.org/search/${_jlptLevelToSearchString(jlptLevel)} #kanji');
    int pageNum = 1;
    var url = Uri.parse(
        'https://jisho.org/search/%23grade%3A$grade%20%23kanji?page=1');
    var response = await client.get(url);
    var doc = parse(response.body);

    var allKanjiEles = doc.querySelectorAll(
        '#secondary > div > div > div > div.literal_block > span > a');

    int index = 1;
    while (grade >= 1) {
      pageNum = 1;
      url = Uri.parse(
          'https://jisho.org/search/%23grade%3A$grade%20%23kanji?page=$pageNum');
      response = await client.get(url);
      doc = parse(response.body);
      allKanjiEles = doc.querySelectorAll(
          '#secondary > div > div > div > div.literal_block > span > a');
      while (allKanjiEles != null) {
        //print('end the length is ${allKanjiEles.length}');
        var kanjiStrs = <String>[];
        for (var ele in allKanjiEles) {
          kanjiStrs.add(ele.text);
        }
        kanjiStrs.forEach(print);
        for (var kanjiStr in kanjiStrs) {
          if (!((await firebaseApiProvider.firestore
                  .collection('kanjis')
                  .doc(kanjiStr)
                  .get())
              .exists)) {
            Kanji kanji = await fetchKanjiInfo(kanjiStr);
            print(kanji.kanji);
            firebaseApiProvider.uploadKanji(kanji);
            DBProvider.db.addKanji(kanji);
            yield kanji;
            print("grade right now $grade");
            print("total kanji count:$index");
            index++;
          }
        }
        pageNum++;
        url = Uri.parse(
            'https://jisho.org/search/%23grade%3A$grade%20%23kanji?page=$pageNum');
        response = await client.get(url);
        doc = parse(response.body);
        allKanjiEles = doc.querySelectorAll(
            '#secondary > div > div > div > div.literal_block > span > a');
      }
      grade--;
    }
    yield null;
  }

  //'Used for scrapping'
  Future<Kanji> fetchKanjiInfo(String kanji) async {
    var url = Uri.parse('https://jisho.org/search/$kanji%20%23kanji');
    var response = await client.get(url);
    var doc = parse(response.body);

    var strokesStrEle = doc
        .getElementsByClassName('kanji-details__stroke_count')
        .single
        .querySelector('strong');

    if (strokesStrEle == null) return null;

    var allPartsEles = doc
        .getElementsByClassName('dictionary_entry on_yomi')
        .elementAt(1)
        .querySelectorAll('dd > a');
    var meaningDiv = doc.querySelector(
        '#result_area > div > div:nth-child(1) > div.small-12.large-10.columns > div > div.small-12.large-7.columns.kanji-details__main > div.kanji-details__main-meanings');
    var kunyomiEles = doc.querySelectorAll(
        '#result_area > div > div:nth-child(1) > div.small-12.large-10.columns > div > div.small-12.large-7.columns.kanji-details__main > div.kanji-details__main-readings > dl.dictionary_entry.kun_yomi > dd > a');
    var onyomiEles = doc.querySelectorAll(
        '#result_area > div > div:nth-child(1) > div.small-12.large-10.columns > div > div.small-12.large-7.columns.kanji-details__main > div.kanji-details__main-readings > dl.dictionary_entry.on_yomi > dd > a');
    var gradeStrEle = doc.querySelector(
        '#result_area > div > div:nth-child(1) > div.small-12.large-10.columns > div > div.small-12.large-5.columns > div > div.grade > strong');
    var jlptStrEle = doc.querySelector(
        '#result_area > div > div:nth-child(1) > div.small-12.large-10.columns > div > div.small-12.large-5.columns > div > div.jlpt > strong');
    var frequencyStrEle = doc.querySelector(
        '#result_area > div > div:nth-child(1) > div.small-12.large-10.columns > div > div.small-12.large-5.columns > div > div.frequency > strong');

    var onyomiWords = <Word>[];
    var kunyomiWords = <Word>[];

    //if the there are two wordsDivs, than the kanji has both onyomi and kunyomi words, onyomi came first
    var wordsDivs = doc.getElementsByClassName('small-12 large-6 columns');
    if (wordsDivs.length == 2) {
      var onyomiLis = wordsDivs.elementAt(0).querySelectorAll('ul > li');

      //sample onyomiLi.text:
      //後日
      //【ゴジツ】
      //in the future, another day, later
      for (var onyomiLi in onyomiLis) {
        var str = onyomiLi.text;
        var subStrs = str.split('\n');
        var furiganaStr = subStrs[2].trim();
        furiganaStr = furiganaStr.substring(1, furiganaStr.length - 1);
        onyomiWords.add(Word(
            wordText: subStrs[1].trim(),
            wordFurigana: furiganaStr,
            meanings: subStrs[3].trim()));
      }

      var kunyomiLis = wordsDivs.elementAt(1).querySelectorAll('ul > li');
      for (var kunyomiLi in kunyomiLis) {
        var str = kunyomiLi.text;
        var subStrs = str.split('\n');
        var furiganaStr = subStrs[2].trim();
        furiganaStr = furiganaStr.substring(1, furiganaStr.length - 1);
        kunyomiWords.add(Word(
            wordText: subStrs[1].trim(),
            wordFurigana: furiganaStr,
            meanings: subStrs[3].trim()));
      }
    } else if (wordsDivs.isNotEmpty) {
      var yomiLis = wordsDivs.single.querySelectorAll('ul > li');
      var words = <Word>[];
      for (var yomiLi in yomiLis) {
        var str = yomiLi.text;
        var subStrs = str.split('\n');
        var furiganaStr = subStrs[2].trim();
        furiganaStr = furiganaStr.substring(1, furiganaStr.length - 1);
        words.add(Word(
            wordText: subStrs[1].trim(),
            wordFurigana: furiganaStr,
            meanings: subStrs[3].trim()));
      }
      if (wordsDivs.single.querySelector('h2').text.startsWith('On')) {
        onyomiWords.addAll(words);
      } else {
        kunyomiWords.addAll(words);
      }
    }

    var strokes = getNumberFromStr(strokesStrEle.text);

    var parts = <String>[];
    for (var ele in allPartsEles) {
      parts.add(ele.text);
    }

    var meaning = meaningDiv.text.trim();

    var kunyomi = <String>[];
    for (var kunyomiEle in kunyomiEles) {
      kunyomi.add(kunyomiEle.text);
    }

    var onyomi = <String>[];
    for (var onyomiEle in onyomiEles) {
      onyomi.add(onyomiEle.text);
    }

    int grade;
    int jlpt;
    int frequency;
    if (gradeStrEle == null)
      grade = 0;
    else
      grade = getGradeFromString(gradeStrEle.text.trim());

    if (jlptStrEle == null)
      jlpt = 0;
    else
      jlpt = getJLPTFromString(jlptStrEle.text);

    if (frequencyStrEle == null)
      frequency = 0;
    else
      frequency = int.tryParse(frequencyStrEle.text) ?? 0;

//    print("Kanji: $kanji");
//    print("Strokes: $strokes");
//    print("Meaning: $meaning");
//    print("JLPT N: $jlpt");
//    print("Grade: $grade");
//    print("Frequency: $frequency");
//    onyomi.forEach(print);
//    kunyomi.forEach(print);
//    parts.forEach(print);

    return Kanji(
        kanji: kanji,
        meaning: meaning,
        strokes: strokes,
        jlpt: jlpt,
        grade: grade,
        frequency: frequency,
        onyomi: onyomi,
        kunyomi: kunyomi,
        parts: parts,
        onyomiWords: onyomiWords,
        kunyomiWords: kunyomiWords);
  }

  ///sample str: N2
  int getJLPTFromString(String str) {
    return int.parse(str[1]) ?? 0;
  }

  ///sample str: grade 1
  int getGradeFromString(String str) {
    //if the string's length is greater than 0, than the kanji is taught in junior high
    if (str.length > 7) {
      return 0;
    }
    return int.parse(str[6]) ?? 0;
  }

  int getNumberFromStr(String str) {
    var regExp = RegExp(r'\b(?<!\.)\d+(?!\.)\b');
    var numberStr = regExp.firstMatch(str).group(0);
    return int.tryParse(numberStr) ?? 0;
  }
}

final jishoApiProvider = JishoApiProvider();
