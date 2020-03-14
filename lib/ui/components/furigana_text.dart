import 'dart:collection';

import 'package:flutter/material.dart';

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
  final String text;
  //final List<String> furigana;
  final TextStyle style;
  final List<Token> tokens;

  FuriganaText({this.text, this.style, this.tokens})
      : assert(text != null),
        assert(tokens != null),
        //assert(getKanjis(text).length == furigana.length),
        super();

  @override
  Widget build(BuildContext context) {
    var textSpanChildren = <TextSpan>[];
    var richTexts = <RichText>[];
    var queue = Queue<Token>.from(this.tokens.where((token) => token.isKanji));
    Color unmarkedColor = Colors.white.withOpacity(0.8);
    Color markedColor = Colors.white;
    TextStyle furiganaTextStyle = style == null
        ? TextStyle(fontSize: Theme.of(context).textTheme.body1.fontSize * 0.5, color: markedColor)
        : TextStyle(fontSize: style.fontSize * 0.5, color: markedColor);
    TextStyle markedTextStyle = style == null
        ? TextStyle(fontSize: Theme.of(context).textTheme.body1.fontSize * 0.5, color: markedColor)
        : TextStyle(fontSize: style.fontSize, color: markedColor);
    TextStyle textTextStyle = style == null
        ? TextStyle(fontSize: Theme.of(context).textTheme.body1.fontSize * 0.5, color: unmarkedColor)
        : TextStyle(fontSize: style.fontSize, color: unmarkedColor);
    TextStyle invisibleTextStyle = style == null
        ? TextStyle(fontSize: furiganaTextStyle.fontSize, color: Colors.transparent)
        : TextStyle(fontSize: furiganaTextStyle.fontSize, color: Colors.transparent);

    try {
      int i = 0;
      for (; i < text.length;) {
        if (queue.isEmpty) break;
        if (queue.first.text == text.substring(i, i + queue.first.text.length)) {
          var japText = text.substring(i, i + queue.first.text.length);
          var furigana = queue.first.furigana;
          var containedKanji = _getKanjis(japText);
          var textAlign = TextAlign.center;

//          if(containedKanji.length == 1){
//            if(_isKanji(japText[0])) textAlign = TextAlign.left;
//          }


          richTexts.add(RichText(
              textAlign: textAlign,
              text: TextSpan(children: [
                TextSpan(text: furigana + '\n', style: furiganaTextStyle),
                TextSpan(text: japText, style: markedTextStyle)
              ])));

          i += queue.removeFirst().text.length;
        } else {
          richTexts.add(
              RichText(text: TextSpan(children: [TextSpan(text: 'あ\n', style: invisibleTextStyle), TextSpan(text: text[i], style: textTextStyle)])));
          i++;
        }
      }
      richTexts.add(RichText(
          text: TextSpan(
              children: [TextSpan(text: 'あ\n', style: invisibleTextStyle), TextSpan(text: text.substring(i, text.length), style: textTextStyle)])));
    } catch (ex) {}

    return Wrap(children: richTexts);
    //return RichText(text: TextSpan(children: textSpanChildren));
  }

  List<String> _getKanjis(String text) {
    var kanjis = <String>[];
    for (int i = 0; i < text.length; i++) {
      if (text.codeUnitAt(i) > 12543) {
        kanjis.add(text[i]);
      }
    }
    return kanjis;
  }

  bool _isKanji(String text) {
    if (text.codeUnitAt(0) > 12543) return true;
    return false;
  }
}
