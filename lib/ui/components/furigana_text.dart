import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:kanji_dictionary/utils/string_extension.dart';
import 'package:kanji_dictionary/models/sentence.dart';
export 'package:kanji_dictionary/models/sentence.dart';

List<String> getKanjis(String text) {
  var kanjis = <String>[];
  for (int i = 0; i < text.length; i++) {
    if (text.codeUnitAt(i) > 12543) {
      kanjis.add(text[i]);
    }
  }
  return kanjis;
}

class FuriganaText extends StatelessWidget {
  final bool showShadow;
  final String text;
  //final List<String> furigana;
  final TextStyle style;
  final TextAlign textAlign;
  final WrapAlignment alignment;
  final List<Token> tokens;

  FuriganaText({this.showShadow = false, this.text, this.style, this.tokens, this.alignment = WrapAlignment.start, this.textAlign = TextAlign.start})
      : assert(text != null),
        assert(tokens != null),
        //assert(getKanjis(text).length == furigana.length),
        super();

  @override
  Widget build(BuildContext context) {
    var richTexts = <RichText>[];

    var queue = Queue<Token>.from(this.tokens.where((element) => text.contains(element.text) || element.furigana != null));

    Color unmarkedColor = Colors.white.withOpacity(0.8);
    Color markedColor = Colors.white;
    TextStyle furiganaTextStyle = style == null
        ? TextStyle(fontSize: Theme.of(context).textTheme.bodyText2.fontSize * 0.5, color: markedColor)
        : TextStyle(fontSize: style.fontSize * 0.5, color: markedColor);
    TextStyle markedTextStyle = style == null
        ? TextStyle(fontSize: Theme.of(context).textTheme.bodyText2.fontSize * 0.5, color: markedColor)
        : TextStyle(fontSize: style.fontSize, color: markedColor);
    TextStyle textTextStyle = style == null
        ? TextStyle(fontSize: Theme.of(context).textTheme.bodyText2.fontSize * 0.5, color: unmarkedColor)
        : TextStyle(fontSize: style.fontSize, color: unmarkedColor);
    TextStyle invisibleTextStyle = style == null
        ? TextStyle(fontSize: furiganaTextStyle.fontSize, color: Colors.transparent)
        : TextStyle(fontSize: furiganaTextStyle.fontSize, color: Colors.transparent);

    debugPrint(text);
    debugPrint(Map<String, String>.fromEntries(tokens.map((e) => MapEntry<String, String>(e.text, e.furigana ?? 'null'))).toString());

    //try {
    int i = 0;
    for (; i < text.length;) {
      if (queue.isEmpty) break;

      var currentText = queue.first.text;
      bool hasFurigana = false;
      String japText, furigana;

      if (currentText[0] == text[i]) {
        if (currentText == text.substring(i, min(text.length, i + currentText.length))) {
          hasFurigana = true;
          if (currentText == text.substring(i, min(text.length, i + currentText.length))) {
            japText = currentText;
          } else {
            int matchIndex = text.substring(i).indexOf(currentText[currentText.length - 1]);
            if (matchIndex == -1)
              matchIndex = text.length - 1;
            else
              matchIndex = min(text.length, matchIndex);
            japText = text.substring(i, i + matchIndex + 1);
          }

          furigana = queue.first.furigana ?? '';
          i += japText.length;
          queue.removeFirst();
        } else {
          hasFurigana = true;

          //The current one did not match any word in the sentence then we replace the part in the sentence that is incorrect.
          var nextWord = queue.length >= 2 ? queue.elementAt(1) : null;
          var nextWordIndex = nextWord == null ? null : text.substring(i).indexOf(nextWord.text);

          if (nextWordIndex != null && nextWordIndex != -1 && text.substring(i, i + nextWordIndex - 1).contains(RegExp(r'[、。「」？！.]'))) {
            nextWordIndex = text.substring(i, i + nextWordIndex - 1).indexOf(RegExp(r'[、。「」？！.]'));
          } else if (nextWordIndex == null) {
            nextWordIndex = text.substring(i).indexOf(RegExp(r'[、。「」？！.]'));
          }

          furigana = queue.first.furigana ?? '';
          japText = currentText;
          i += nextWordIndex ?? japText.length;
          queue.removeFirst();
        }
      }

      if (hasFurigana) {
        if (japText[0].isKanji() && japText[japText.length - 1].isKanji() == false && tokens.length != 1) {
          richTexts.add(RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                  style: TextStyle(
                    shadows: [
                      if (showShadow)
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black45,
                          offset: Offset(0, 0),
                        ),
                    ],
                  ),
                  children: [TextSpan(text: furigana + '\n', style: furiganaTextStyle), TextSpan(text: japText, style: markedTextStyle)])));
        } else {
          richTexts.add(RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: TextStyle(
                    shadows: [
                      if (showShadow)
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black45,
                          offset: Offset(0, 0),
                        ),
                    ],
                  ),
                  children: [
                    TextSpan(text: furigana + '\n', style: furiganaTextStyle),
                    TextSpan(text: japText, style: furigana.isEmpty ? textTextStyle : markedTextStyle)
                  ])));
        }
      } else {
        richTexts.add(RichText(
            textAlign: textAlign,
            text: TextSpan(children: [TextSpan(text: 'あ\n', style: invisibleTextStyle), TextSpan(text: text[i], style: textTextStyle)])));
        i++;
      }
    }
    richTexts.add(RichText(
        textAlign: textAlign,
        text: TextSpan(
            children: [TextSpan(text: 'あ\n', style: invisibleTextStyle), TextSpan(text: text.substring(i, text.length), style: textTextStyle)])));
//    } catch (ex) {
//      throw ex;
//    }

    return Wrap(children: richTexts, alignment: alignment, runAlignment: alignment);
    //return RichText(text: TextSpan(children: textSpanChildren));
  }
}
