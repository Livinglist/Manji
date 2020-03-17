import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';

import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import 'package:kanji_dictionary/bloc/kanji_list_bloc.dart';
import 'package:kanji_dictionary/bloc/kana_bloc.dart';
import 'package:kanji_dictionary/resource/db_provider.dart';
import 'components/home_page_background.dart';
import 'components/daily_kanji_card.dart';
import 'kanji_detail_page.dart';
import 'jlpt_kanji_page.dart';
import 'my_kanji_page.dart';
import 'kana_page.dart';
import 'settings_page.dart';
import 'education_kanji_page.dart';
import 'search_result_page.dart';
import 'my_list_page.dart';
import 'quiz_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
  final textEditingController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController animationController;
  Tween<double> tween = Tween<double>(begin: 0, end: 1);
  bool isEntering = false;

  @override
  void initState() {
    kanaBloc.init();
    KanjiListBloc.instance.init();
    animationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    super.initState();

    Timer(Duration(seconds: 2), () {
      Future.doWhile(startAnimation);
    });
  }

  Future<bool> startAnimation() async {
    if (this.mounted) {
      animationController.forward();
      return false;
    } else {
      return true;
    }
  }

  Future onScanPressed() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    print('Reached A');

    var visionImage = FirebaseVisionImage.fromFile(image);

    print('Reached B');

    var visionText = await textRecognizer.processImage(visionImage);

    String text = visionText.text;
    for (TextBlock block in visionText.blocks) {
      final Rect boundingBox = block.boundingBox;
      final List<Offset> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<RecognizedLanguage> languages = block.recognizedLanguages;

      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        for (TextElement element in line.elements) {
          // Same getters as TextBlock
          print(element.text);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Transform.rotate(angle: pi / 2, child: Icon(Icons.flip)),
              onPressed: () {
                scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text(
                    'Text Recognition is not yet availible',
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Colors.yellow,
                  action: SnackBarAction(label: 'Dismiss', onPressed: () => scaffoldKey.currentState.hideCurrentSnackBar()),
                ));
              },
            )
          ],
          title: Text('Manji'),
          elevation: 0,
        ),
        drawer: Drawer(
            child: Container(
          color: Colors.grey[600],
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 50,
              ),
              ListTile(
                title: Text('仮名', style: TextStyle(color: Colors.white)),
                subtitle: Text('Kana'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => KanaPage()));
                },
              ),
              ListTile(
                title: Text('日本語能力試験漢字', style: TextStyle(color: Colors.white)),
                subtitle: Text('JLPT Kanji'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => JLPTKanjiPage()));
                },
              ),
              ListTile(
                title: Text('教育漢字', style: TextStyle(color: Colors.white)),
                subtitle: Text('Kyōiku Kanji'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EducationKanjiPage()));
                },
              ),
              ListTile(
                title: Text('収蔵した漢字', style: TextStyle(color: Colors.white)),
                subtitle: Text('Favorite Kanji'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MyKanjiPage()));
                },
              ),
              ListTile(
                title: Text('漢字リスト', style: TextStyle(color: Colors.white)),
                subtitle: Text('Kanji Lists'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MyListPage()));
                },
              ),
              ListTile(
                title: Text('クイズ', style: TextStyle(color: Colors.white)),
                subtitle: Text('Quiz'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => QuizPage()));
                },
              ),
              ListTile(
                title: Text('設定', style: TextStyle(color: Colors.white)),
                subtitle: Text('Settings'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsPage()));
                },
              ),
            ],
          ),
        )),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                  child: AnimatedBuilder(
                      animation: animationController,
                      builder: (_, __) {
                        return Opacity(
                          opacity: tween.animate(animationController).value,
                          child: HomePageBackground(
                            callback: (String kanji) {
                              if (textEditingController.text.isEmpty || textEditingController.text.length == 1) {
                                textEditingController.text = kanji;
                              }
                            },
                          ),
                        );
                      })),
              Positioned(
                  top: 80,
                  left: 22,
                  right: 22,
                  child: Center(
                    child: Container(
                        decoration: BoxDecoration(
                            boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)], shape: BoxShape.rectangle, color: Colors.white),
                        height: 42,
                        //width: MediaQuery.of(context).size.width * 0.9,
                        child: Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            IconButton(icon: Icon(Icons.search)),
                            Expanded(
                              child: TextField(
                                controller: textEditingController,
                                cursorWidth: 1,
                                cursorColor: Theme.of(context).primaryColor,
                                cursorRadius: Radius.circular(1),
                                decoration: InputDecoration(hintText: 'Find'),
                                onTap: () {
                                  setState(() {
                                    isEntering = true;
                                  });
                                },
//                                onEditingComplete: (){},
                                onSubmitted: (_) {
                                  setState(() {
                                    isEntering = false;
                                  });
                                },
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: IconButton(
                                  splashColor: Colors.grey,
                                  icon: Icon(Icons.arrow_forward, color: isEntering ? Colors.black : Colors.grey),
                                  onPressed: onSearchPressed),
                            )
                          ],
                        )),
                  )),
              Positioned(
                  top: 160,
                  left: 22,
                  right: 22,
                  child: Container(
                      //width: MediaQuery.of(context).size.width * 0.9,
                      child: AnimatedBuilder(
                          animation: animationController,
                          builder: (_, __) {
                            return Opacity(opacity: tween.animate(animationController).value, child: DailyKanjiCard());
                          })))
//              StreamBuilder(
//                stream: kanjiBloc.allKanjis,
//                builder: (_, snapshot) {
//                  if (snapshot.hasData) {
//                    return Positioned(
//                        top: 160,
//                        left: 22,
//                        right: 22,
//                        child: Container(
//                            //width: MediaQuery.of(context).size.width * 0.9,
//                            child: AnimatedBuilder(
//                                animation: animationController,
//                                builder: (_, __) {
//                                  return Opacity(opacity: tween.animate(animationController).value, child: DailyKanjiCard());
//                                })));
//                  } else {
//                    return Positioned(
//                        top: 160,
//                        left: 22,
//                        right: 22,
//                        child: Container(
//                          //width: MediaQuery.of(context).size.width * 0.9,
//                          child: RaisedButton(
//                              color: Colors.grey[800],
//                              child: Text(
//                                'Refresh',
//                                style: TextStyle(color: Colors.white),
//                              ),
//                              onPressed: () async {
//                                await DBProvider.db.initDB(refresh: true).then((db) {
//                                  kanjiBloc.getAllKanjis();
//                                });
//                              }),
//                        ));
//                  }
//                },
//              )
            ],
          ),
        ));
  }

  void onSearchPressed() {
    String text = textEditingController.text;
    if (text.length == 1 && text.codeUnitAt(0) > 12543) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => KanjiDetailPage(
                    kanjiStr: textEditingController.text,
                  )));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => SearchResultPage(
                    text: text,
                  )));
    }
  }

  bool areAllKanjis(String text) {
    for (int i = 0; i < text.length; i++) {
      if (text.codeUnitAt(i) > 12543)
        continue;
      else
        return false;
    }
    return true;
  }
}
