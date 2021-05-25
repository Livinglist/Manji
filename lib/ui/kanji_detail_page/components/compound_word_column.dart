import 'package:flutter/material.dart';

import '../../../bloc/kanji_bloc.dart';
import '../../../bloc/kanji_list_bloc.dart';
import '../../../bloc/sentence_bloc.dart';
import '../../components/furigana_text.dart';
import '../../components/spring_curve.dart';
import '../../word_detail_page.dart';

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
    final onyomiGroup = <Widget>[];
    final kunyomiGroup = <Widget>[];
    final onyomiVerbGroup = <Widget>[];
    final kunyomiVerbGroup = <Widget>[];

    final onyomis =
        kanji.onyomi.where((s) => s.contains(r'-') == false).toList();
    final kunyomis =
        kanji.kunyomi.where((s) => s.contains(r'-') == false).toList();

    final onyomiWords = Set<Word>.from(kanji.onyomiWords).toList();
    onyomis.sort((a, b) => b.length.compareTo(a.length));
    for (var onyomi in onyomis) {
      final words = List.from(onyomiWords.where((onyomiWord) => onyomiWord
          .wordFurigana
          .contains(onyomi.replaceAll('.', '').replaceAll('-', ''))));

      onyomiWords.removeWhere(words.contains);
      final tileTitle = Stack(
        children: <Widget>[
          Positioned.fill(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        onyomi,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )),
                  decoration: const BoxDecoration(
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
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              onPressed: () =>
                  showCustomBottomSheet(yomi: onyomi, isOnyomi: true),
            ),
          )
        ],
      );

      final tileChildren = <Widget>[];

      for (final word in words) {
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
            style: const TextStyle(fontSize: 24),
          ),
          subtitle: Text(word.meanings,
              style: const TextStyle(color: Colors.white54)),
        ));
        tileChildren.add(const Divider(
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
            padding: const EdgeInsets.only(top: 12),
            child: tileTitle,
          ));
        } else {
          onyomiVerbGroup.add(tileTitle);
        }
        onyomiVerbGroup.addAll(tileChildren);
      } else {
        if (onyomiGroup.isNotEmpty) {
          onyomiGroup.add(Padding(
            padding: const EdgeInsets.only(top: 12),
            child: tileTitle,
          ));
        } else {
          onyomiGroup.add(tileTitle);
        }
        onyomiGroup.addAll(tileChildren);
      }
    }

    final kunyomiWords = Set<Word>.from(kanji.kunyomiWords).toList();

    kunyomis.sort((a, b) => b.length.compareTo(a.length));

    for (var kunyomi in kunyomis) {
      final words = List.from(kunyomiWords.where((kunyomiWord) => kunyomiWord
          .wordFurigana
          .contains(kunyomi.replaceAll('.', '').replaceAll('-', ''))));

      kunyomiWords.removeWhere(words.contains);

      final tileTitle = Stack(
        children: <Widget>[
          Positioned.fill(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        kunyomi,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      )),
                  decoration: const BoxDecoration(
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
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              onPressed: () =>
                  showCustomBottomSheet(yomi: kunyomi, isOnyomi: false),
            ),
          )
        ],
      );

      final tileChildren = <Widget>[];

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
            style: const TextStyle(fontSize: 24),
          ),
          subtitle: Text(word.meanings,
              style: const TextStyle(color: Colors.white54)),
        ));
        tileChildren.add(const Divider(height: 0, indent: 8, endIndent: 8));
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
            padding: const EdgeInsets.only(top: 12),
            child: tileTitle,
          ));
        } else {
          kunyomiVerbGroup.add(tileTitle);
        }
        kunyomiVerbGroup.addAll(tileChildren);
      } else {
        if (kunyomiGroup.isNotEmpty) {
          kunyomiGroup.add(Padding(
            padding: const EdgeInsets.only(top: 12),
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
          padding: const EdgeInsets.all(12),
          child: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              const Flexible(
                flex: 4,
                child: Divider(color: Colors.white60),
              ),
              Flexible(
                  flex: 5,
                  child: Container(
                    child: Center(
                        child: RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(children: [
                              TextSpan(
                                  text: 'どうし　　　　けいようし\n',
                                  style: TextStyle(
                                      fontSize: 9, color: Colors.white)),
                              TextSpan(
                                  text: '動詞 と 形容詞',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white)),
                            ]))),
                  )),
              const Flexible(
                flex: 4,
                child: Divider(color: Colors.white60),
              ),
            ],
          )),
      if (onyomiVerbGroup.isEmpty && kunyomiVerbGroup.isEmpty)
        Container(
          height: 100,
          width: MediaQuery.of(context).size.width,
          child: const Center(
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
    final yomiTextEditingController = TextEditingController();
    final wordTextEditingController = TextEditingController();
    final meaningTextEditingController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    yomiTextEditingController.text = yomi.replaceFirst('.', '');

    showGeneralDialog(
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      context: scaffoldContext,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: Container(
              height: 368,
              margin: const EdgeInsets.only(top: 48, left: 12, right: 12),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  color: Theme.of(scaffoldContext).primaryColor),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            'Add a word to',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  yomi,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                )),
                            decoration: const BoxDecoration(
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
                        padding: const EdgeInsets.symmetric(horizontal: 12),
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
                            labelStyle: const TextStyle(color: Colors.white70),
                            border: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70)),
                          ),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                          minLines: 1,
                          maxLines: 1,
                        )),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextFormField(
                        validator: (str) {
                          if (str == null || str.isEmpty) {
                            return "Can't be empty";
                          }
                          return null;
                        },
                        controller: wordTextEditingController,
                        decoration: const InputDecoration(
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
                        style: const TextStyle(color: Colors.white),
                        minLines: 1,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextFormField(
                        validator: (str) {
                          if (str == null || str.isEmpty) {
                            return "Can't be empty";
                          }
                          return null;
                        },
                        controller: meaningTextEditingController,
                        decoration: const InputDecoration(
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
                        style: const TextStyle(color: Colors.white),
                        minLines: 1,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                          width: MediaQuery.of(scaffoldContext).size.width - 24,
                          height: 42,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: ElevatedButton(
                              child: const Text(
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
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(CurvedAnimation(
                  parent: anim, curve: SpringCurve.underDamped)),
          child: child,
        );
      },
    );
  }
}
