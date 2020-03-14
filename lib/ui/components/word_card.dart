import 'package:flutter/material.dart';

import 'package:kanji_dictionary/models/sentence.dart';
import 'package:kanji_dictionary/models/word.dart';
import 'package:kanji_dictionary/ui/components/furigana_text.dart';
import 'package:kanji_dictionary/ui/word_detail_page.dart';

class WordCard extends StatefulWidget {
  final Word word;
  final String wordText;
  final String wordFurigana;

  WordCard({this.word,this.wordText, this.wordFurigana}) : assert(wordText != null || word !=null);

  @override
  State<StatefulWidget> createState() => WordCardState();
}

class WordCardState extends State<WordCard> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Tween<double> tween = Tween(begin: 0, end: 1);

  @override
  void initState() {
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    //Future.doWhile(startAnimation);
    super.initState();
    animationController.forward();
  }

  Future<bool> startAnimation() {
    if (this.mounted) {
      animationController.forward();
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (_, __) {
        return Opacity(
          opacity: tween.animate(animationController).value,
          child: InkWell(
            onTap: (){
              //Navigator.push(context, MaterialPageRoute(builder: (_)=>WordDetailPage(word: )));
            },
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: FuriganaText(
                            text: widget.wordText,
                            tokens: [Token(text: widget.wordText, furigana: widget.wordFurigana)],
                            style: TextStyle(color: Colors.black, fontSize: 28),
                          ),
//                            child: RichText(
//                                textAlign: TextAlign.left,
//                                maxLines: 2,
//                                text: TextSpan(style: TextStyle(color: Colors.black), children: [
//                                  TextSpan(style: TextStyle(fontSize: 15), text: widget.wordFurigana + '\n'),
//                                  TextSpan(style: TextStyle(fontSize: 28), text: widget.wordText)
//                                ]))
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          )
        );
      },
    );
  }
}
