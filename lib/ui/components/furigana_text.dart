import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../models/sentence.dart';
import '../../utils/string_extension.dart';

export '../../models/sentence.dart';

List<String> getKanjis(String text) {
  final kanjis = <String>[];
  for (var i = 0; i < text.length; i++) {
    if (text.codeUnitAt(i) > 12543) {
      kanjis.add(text[i]);
    }
  }
  return kanjis;
}

class FuriganaText extends StatelessWidget {
  final bool markTarget;
  final String target;
  final String text;
  final TextStyle style;
  final TextAlign textAlign;
  final WrapAlignment alignment;
  final List<Token> tokens;

  FuriganaText(
      {this.markTarget = false,
      this.target,
      this.text,
      this.style,
      this.tokens,
      this.alignment = WrapAlignment.start,
      this.textAlign = TextAlign.start})
      : assert(text != null),
        assert(tokens != null),
        super();

  @override
  Widget build(BuildContext context) {
    final richTexts = <RichText>[];

    final queue = Queue<Token>.from(tokens.where(
        (element) => text.contains(element.text) || element.furigana != null));

    final unmarkedColor = Colors.white.withOpacity(0.8);
    const markedColor = Colors.white;
    const targetColor = Colors.orange;
    final furiganaTextStyle = style == null
        ? TextStyle(
            fontSize: Theme.of(context).textTheme.bodyText2.fontSize * 0.5,
            color: markedColor)
        : TextStyle(fontSize: style.fontSize * 0.5, color: style.color);
    final targetFuriganaTextStyle = style == null
        ? TextStyle(
            fontSize: Theme.of(context).textTheme.bodyText2.fontSize * 0.5,
            color: targetColor)
        : TextStyle(fontSize: style.fontSize * 0.5, color: style.color);
    final markedTextStyle = style == null
        ? TextStyle(
            fontSize: Theme.of(context).textTheme.bodyText2.fontSize,
            color: markedColor)
        : TextStyle(fontSize: style.fontSize, color: style.color);
    final targetTextStyle = style == null
        ? TextStyle(
            fontSize: Theme.of(context).textTheme.bodyText2.fontSize,
            color: targetColor)
        : TextStyle(fontSize: style.fontSize, color: style.color);
    final textTextStyle = style == null
        ? TextStyle(
            fontSize: Theme.of(context).textTheme.bodyText2.fontSize * 0.5,
            color: unmarkedColor)
        : TextStyle(fontSize: style.fontSize, color: style.color);
    final invisibleTextStyle = style == null
        ? TextStyle(
            fontSize: furiganaTextStyle.fontSize, color: Colors.transparent)
        : TextStyle(
            fontSize: furiganaTextStyle.fontSize, color: Colors.transparent);

    //try {
    var i = 0;
    for (; i < text.length;) {
      if (queue.isEmpty) break;

      final currentText = queue.first.text;
      var hasFurigana = false;
      String japText, furigana;

      if (currentText[0] == text[i]) {
        if (currentText ==
            text.substring(i, min(text.length, i + currentText.length))) {
          hasFurigana = true;
          if (currentText ==
              text.substring(i, min(text.length, i + currentText.length))) {
            japText = currentText;
          } else {
            var matchIndex =
                text.substring(i).indexOf(currentText[currentText.length - 1]);
            if (matchIndex == -1) {
              matchIndex = text.length - 1;
            } else {
              matchIndex = min(text.length, matchIndex);
            }
            japText = text.substring(i, i + matchIndex + 1);
          }

          furigana = queue.first.furigana ?? '';
          i += japText.length;
          queue.removeFirst();
        } else {
          hasFurigana = true;

          //The current one did not match any word in the sentence then
          // we replace the part in the sentence that is incorrect.
          final nextWord = queue.length >= 2 ? queue.elementAt(1) : null;
          var nextWordIndex = nextWord == null
              ? null
              : text.substring(i).indexOf(nextWord.text);

          if (nextWordIndex != null &&
              nextWordIndex != -1 &&
              text
                  .substring(i, i + nextWordIndex - 1)
                  .contains(RegExp(r'[、。「」？！.]'))) {
            nextWordIndex = text
                .substring(i, i + nextWordIndex - 1)
                .indexOf(RegExp(r'[、。「」？！.]'));
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
        var isTarget = false;
        if (markTarget &&
            japText != null &&
            (japText.contains(target) ||
                japText.contains(target
                    .getKanjis()
                    .reduce((value, element) => '[$value$element]')))) {
          isTarget = true;
        }
        final color = isTarget
            ? targetColor
            : (furigana.isEmpty ? unmarkedColor : markedColor);
        if (japText[0].isKanji() &&
            japText[japText.length - 1].isKanji() == false &&
            tokens.length != 1) {
          richTexts.add(RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                  style: TextStyle(
                    color: color,
                  ),
                  children: [
                    TextSpan(
                        text: '$furigana\n',
                        style: isTarget
                            ? targetFuriganaTextStyle
                            : furiganaTextStyle),
                    TextSpan(
                        text: japText,
                        style: isTarget ? targetTextStyle : textTextStyle)
                  ])));
        } else {
          richTexts.add(RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: TextStyle(
                    color: color,
                  ),
                  children: [
                    TextSpan(
                        text: furigana + (furigana.isEmpty ? 'あ\n' : '\n'),
                        style: furigana.isEmpty
                            ? invisibleTextStyle
                            : furiganaTextStyle),
                    TextSpan(text: japText, style: markedTextStyle)
                  ])));
        }
      } else {
        richTexts.add(RichText(
            textAlign: textAlign,
            text: TextSpan(children: [
              TextSpan(text: 'あ\n', style: invisibleTextStyle),
              TextSpan(text: text[i], style: textTextStyle)
            ])));
        i++;
      }
    }
    richTexts.add(RichText(
        textAlign: textAlign,
        text: TextSpan(children: [
          TextSpan(text: 'あ\n', style: invisibleTextStyle),
          TextSpan(text: text.substring(i, text.length), style: textTextStyle)
        ])));
//    } catch (ex) {
//      throw ex;
//    }

    return Wrap(
        children: richTexts, alignment: alignment, runAlignment: alignment);
    //return RichText(text: TextSpan(children: textSpanChildren));
  }
}
