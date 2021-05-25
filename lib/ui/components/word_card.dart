import 'package:flutter/material.dart';

import '../../models/sentence.dart';
import '../../models/word.dart';
import '../../ui/components/furigana_text.dart';

class WordCard extends StatefulWidget {
  final Word word;
  final String wordText;
  final String wordFurigana;

  WordCard({this.word, this.wordText, this.wordFurigana})
      : assert(wordText != null || word != null);

  @override
  State<StatefulWidget> createState() => WordCardState();
}

class WordCardState extends State<WordCard>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Tween<double> tween = Tween(begin: 0, end: 1);

  @override
  void initState() {
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    //Future.doWhile(startAnimation);
    super.initState();
    animationController.forward();
  }

  Future<bool> startAnimation() {
    if (mounted) {
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
              onTap: () {
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: FuriganaText(
                              text: widget.wordText,
                              tokens: [
                                Token(
                                    text: widget.wordText,
                                    furigana: widget.wordFurigana)
                              ],
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 28),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ));
      },
    );
  }
}
