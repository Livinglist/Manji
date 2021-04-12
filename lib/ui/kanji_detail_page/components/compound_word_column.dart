import 'package:flutter/material.dart';

import '../../../bloc/kanji_bloc.dart';
import '../../../bloc/sentence_bloc.dart';
import '../../../bloc/kanji_list_bloc.dart';
import '../../components/spring_curve.dart';
import '../../word_detail_page.dart';
import '../../components/furigana_text.dart';

class CompoundWordColumn extends StatelessWidget {
  final Kanji kanji;
  final BuildContext scaffoldContext;

  CompoundWordColumn({this.scaffoldContext, this.kanji})
      : super(key: UniqueKey());

  @override
  Widget build(BuildContext context) {
    return buildCompoundWordColumn(context);
  }

  Widget buildCompoundWordColumn(BuildContext context) {
    var onyomiGroup = <Widget>[];
    var kunyomiGroup = <Widget>[];
    var onyomiVerbGroup = <Widget>[];
    var kunyomiVerbGroup = <Widget>[];

    var onyomis = kanji.onyomi.where((s) => s.contains(r'-') == false).toList();
    var kunyomis =
        kanji.kunyomi.where((s) => s.contains(r'-') == false).toList();

//

    List<Word> onyomiWords = Set<Word>.from(kanji.onyomiWords)
        .toList(); //..sort((a, b) => a.wordFurigana.length.compareTo(b.wordFurigana.length));
    onyomis.sort((a, b) => b.length.compareTo(a.length));
    for (var onyomi in onyomis) {
      var words = List.from(onyomiWords.where((onyomiWord) => onyomiWord
          .wordFurigana
          .contains(onyomi.replaceAll('.', '').replaceAll('-', ''))));

      onyomiWords.removeWhere((word) => words.contains(word));
      var tileTitle = Stack(
        children: <Widget>[
          Positioned.fill(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(4),
                child: Container(
                  child: Padding(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        onyomi,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )),
                  decoration: BoxDecoration(
                    //boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(
                            5.0) //                 <--- border radius here
                        ),
                  ),
                ),
              )
            ],
          )),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.add_circle_outline, color: Colors.white),
              onPressed: () =>
                  showCustomBottomSheet(yomi: onyomi, isOnyomi: true),
            ),
          )
        ],
      );

      var tileChildren = <Widget>[];

      for (var word in words) {
        tileChildren.add(ListTile(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => WordDetailPage(word: word)));
          },
          onLongPress: () {
            showModalBottomSheet(
                context: context,
                builder: (_) => ListTile(
                      title: Text('Delete from $onyomi'),
                      onTap: () {
                        kanji.onyomiWords.remove(word);
                        KanjiBloc.instance.updateKanji(kanji, isDeleted: true);
                        Navigator.pop(context);
                      },
                    ));
          },
          title: FuriganaText(
            text: word.wordText,
            tokens: [Token(text: word.wordText, furigana: word.wordFurigana)],
            style: TextStyle(fontSize: 24),
          ),
          subtitle:
              Text(word.meanings, style: TextStyle(color: Colors.white54)),
        ));
        tileChildren.add(Divider(
          height: 0,
          indent: 8,
          endIndent: 8,
        ));
      }

      if (words.isEmpty) {
      } else {
        tileChildren.removeLast();
      }

      if (onyomi.contains(RegExp(r'[.-]'))) {
        if (onyomiVerbGroup.isNotEmpty) {
          onyomiVerbGroup.add(Padding(
            padding: EdgeInsets.only(top: 12),
            child: tileTitle,
          ));
        } else {
          onyomiVerbGroup.add(tileTitle);
        }
        onyomiVerbGroup.addAll(tileChildren);
      } else {
        if (onyomiGroup.isNotEmpty) {
          onyomiGroup.add(Padding(
            padding: EdgeInsets.only(top: 12),
            child: tileTitle,
          ));
        } else {
          onyomiGroup.add(tileTitle);
        }
        onyomiGroup.addAll(tileChildren);
      }
    }

    var kunyomiWords = Set<Word>.from(kanji.kunyomiWords).toList();

    kunyomis.sort((a, b) => b.length.compareTo(a.length));

    for (var kunyomi in kunyomis) {
      var words = List.from(kunyomiWords.where((kunyomiWord) => kunyomiWord
          .wordFurigana
          .contains(kunyomi.replaceAll('.', '').replaceAll('-', ''))));

      kunyomiWords.removeWhere((word) => words.contains(word));

      var tileTitle = Stack(
        children: <Widget>[
          Positioned.fill(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(4),
                child: Container(
                  child: Padding(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        kunyomi,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )),
                  decoration: BoxDecoration(
                    //boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(
                            5.0) //                 <--- border radius here
                        ),
                  ),
                ),
              )
            ],
          )),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.add_circle_outline, color: Colors.white),
              onPressed: () =>
                  showCustomBottomSheet(yomi: kunyomi, isOnyomi: false),
            ),
          )
        ],
      );

      var tileChildren = <Widget>[];

      for (var word in words) {
        tileChildren.add(ListTile(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => WordDetailPage(word: word)));
          },
          onLongPress: () {
            showModalBottomSheet(
                context: context,
                builder: (_) => ListTile(
                      title: Text('Delete from $kunyomi'),
                      onTap: () {
                        kanji.kunyomiWords.remove(word);
                        KanjiBloc.instance.updateKanji(kanji, isDeleted: true);
                        Navigator.pop(context);
                      },
                    ));
          },
          title: FuriganaText(
            text: word.wordText,
            tokens: [Token(text: word.wordText, furigana: word.wordFurigana)],
            style: TextStyle(fontSize: 24),
          ),
          subtitle:
              Text(word.meanings, style: TextStyle(color: Colors.white54)),
        ));
        tileChildren.add(Divider(height: 0, indent: 8, endIndent: 8));
      }

      if (words.isEmpty) {
        // tileChildren.add(Container(
        //   height: 100,
        //   child: Center(
        //     child: Text(
        //       'No compound words found _(┐「ε:)_',
        //       style: TextStyle(color: Colors.white54),
        //     ),
        //   ),
        // ));
      } else {
        tileChildren.removeLast();
      }

      if (kunyomi.contains(RegExp(r'[.-]'))) {
        if (kunyomiVerbGroup.isNotEmpty) {
          kunyomiVerbGroup.add(Padding(
            padding: EdgeInsets.only(top: 12),
            child: tileTitle,
          ));
        } else {
          kunyomiVerbGroup.add(tileTitle);
        }
        kunyomiVerbGroup.addAll(tileChildren);
      } else {
        if (kunyomiGroup.isNotEmpty) {
          kunyomiGroup.add(Padding(
            padding: EdgeInsets.only(top: 12),
            child: tileTitle,
          ));
        } else {
          kunyomiGroup.add(tileTitle);
        }
        kunyomiGroup.addAll(tileChildren);
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ...onyomiGroup,
      ...kunyomiGroup,
      Padding(
          padding: EdgeInsets.all(12),
          child: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Flexible(
                flex: 4,
                child: Divider(color: Colors.white60),
              ),
              Flexible(
                  flex: 5,
                  child: Container(
                    child: Center(
                        child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(children: [
                              TextSpan(
                                  text: 'どうし　　　　けいようし' + '\n',
                                  style: TextStyle(
                                      fontSize: 9, color: Colors.white)),
                              TextSpan(
                                  text: '動詞 と 形容詞',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white)),
                            ]))),
                  )),
              Flexible(
                flex: 4,
                child: Divider(color: Colors.white60),
              ),
            ],
          )),
      if (onyomiVerbGroup.isEmpty && kunyomiVerbGroup.isEmpty)
        Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Text(
              'No related verbs found _(┐「ε:)_',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ...onyomiVerbGroup,
      ...kunyomiVerbGroup,
    ]);
  }

  ///show modal bottom sheet where user can add words to onyomi or kunyomi
  void showCustomBottomSheet({String yomi, bool isOnyomi}) {
    var yomiTextEditingController = TextEditingController();
    var wordTextEditingController = TextEditingController();
    var meaningTextEditingController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    yomiTextEditingController.text = yomi.replaceFirst('.', '');

    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 300),
      context: scaffoldContext,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: 368,
              margin: EdgeInsets.only(top: 48, left: 12, right: 12),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: Theme.of(scaffoldContext).primaryColor),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Add a word to',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          SizedBox(width: 12),
                          Container(
                            child: Padding(
                                padding: EdgeInsets.all(4),
                                child: Text(
                                  yomi,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                )),
                            decoration: BoxDecoration(
                              //boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(
                                      5.0) //                 <--- border radius here
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: TextFormField(
                          validator: (str) {
                            if (str == null || str.isEmpty) {
                              return "Can't be empty";
                            }
                            return null;
                          },
                          controller: yomiTextEditingController,
                          decoration: InputDecoration(
                            focusColor: Colors.white,
                            labelText: isOnyomi ? 'Onyomi' : 'Kunyomi',
                            labelStyle: TextStyle(color: Colors.white70),
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70)),
                          ),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                          minLines: 1,
                          maxLines: 1,
                        )),
                    SizedBox(height: 12),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: TextFormField(
                        validator: (str) {
                          if (str == null || str.isEmpty) {
                            return "Can't be empty";
                          }
                          return null;
                        },
                        controller: wordTextEditingController,
                        decoration: InputDecoration(
                          focusColor: Colors.white,
                          labelText: 'Word',
                          labelStyle: TextStyle(color: Colors.white70),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70)),
                        ),
                        style: TextStyle(color: Colors.white),
                        minLines: 1,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(height: 12),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: TextFormField(
                        validator: (str) {
                          if (str == null || str.isEmpty) {
                            return "Can't be empty";
                          }
                          return null;
                        },
                        controller: meaningTextEditingController,
                        decoration: InputDecoration(
                          focusColor: Colors.white,
                          labelText: 'Meaning',
                          labelStyle: TextStyle(color: Colors.white70),
                          border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70)),
                        ),
                        style: TextStyle(color: Colors.white),
                        minLines: 1,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                          width: MediaQuery.of(scaffoldContext).size.width - 24,
                          height: 42,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: ElevatedButton(
                              child: Text(
                                'Add',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                if (formKey.currentState.validate()) {
                                  if (isOnyomi) {
                                    kanji.onyomiWords.add(Word(
                                        wordText:
                                            wordTextEditingController.text,
                                        wordFurigana:
                                            yomiTextEditingController.text,
                                        meanings:
                                            meaningTextEditingController.text));
                                  } else {
                                    kanji.kunyomiWords.add(Word(
                                        wordText:
                                            wordTextEditingController.text,
                                        wordFurigana:
                                            yomiTextEditingController.text,
                                        meanings:
                                            meaningTextEditingController.text));
                                  }
                                }
                                Navigator.pop(scaffoldContext);
                                KanjiBloc.instance.updateKanji(kanji);
                              })),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(
              CurvedAnimation(parent: anim, curve: SpringCurve.underDamped)),
          child: child,
        );
      },
    );
  }
}
