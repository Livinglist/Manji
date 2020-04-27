import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kanji_dictionary/bloc/kanji_bloc.dart';

import 'components/kanji_card.dart';
import 'kanji_study_help_page.dart';

class KanjiStudyPage extends StatefulWidget {
  final List<Kanji> kanjis;

  KanjiStudyPage({List<Kanji> kanjis})
      : assert(kanjis != null),
        this.kanjis = List.from(kanjis);

  @override
  _KanjiStudyPageState createState() => _KanjiStudyPageState();
}

class _KanjiStudyPageState extends State<KanjiStudyPage> with SingleTickerProviderStateMixin {
  final PageController pageController = PageController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final Tween<double> angleTween = Tween(begin: 0, end: pi / 8);

  AnimationController animationController;
  GlobalKey<KanjiCardState> mainCardKey = GlobalKey<KanjiCardState>();
  List<KanjiCardContent> contents = [];
  Widget mainCard;
  int index = 0;
  double initialDx = 0;
  double distance = 0;

  ///The progress indicating how many cards out of all have been viewed.
  double cardsProgress = 0.0;

  ///The progress indicating how many cards out of all have been memorized.
  double studyProgress = 0.0;

  int cardsCount;

  static const List<String> celebrateString = const [
    "You are the chosen one.",
    "お前はもう死んでいる!",
    "Dannnnng, ain't nobody told me you this good.",
    "Good",
    "Perfecto",
    "You are one step away from being the King of Kanji. ( ͡° ͜ʖ ͡°)",
    "WOW",
    "( ✧≖ ͜ʖ≖)",
    "(ó﹏ò｡)",
    "ヽ(ﾟДﾟ)ﾉ",
    "(ง ͡ʘ ͜ʖ ͡ʘ)ง",
    "(☞ ͡° ͜ʖ ͡°)☞",
    "ᕕ( ͡° ͜ʖ ͡°)ᕗ",
    "( ✧≖ ͜ʖ≖)",
    "( ͡~ ͜ʖ ͡°)",
    "♡(ŐωŐ人)",
    "( ͡°( ͡° ͜ʖ( ͡° ͜ʖ ͡°)ʖ ͡°) ͡°)",
    "(ᗒᗣᗕ)՞ STOP IT",
    "ಥ_ಥ, Can I have at least a five star review",
    "(╬ಠ益ಠ)",
    "ᕙ(▀̿̿Ĺ̯̿̿▀̿ ̿) ᕗ",
    "(╯ ͠° ͟ʖ ͡°)╯┻━┻ Why are you so good",
    "•́ε•̀٥",
    "( ͡ʘ ͜ʖ ͡ʘ) すごい！",
    "すごい...君の名前は？",
    "这么牛逼的吗",
    "666"
  ];

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(vsync: this, lowerBound: -1, upperBound: 1);
    animationController.value = 0;

    for (var kanji in widget.kanjis) {
      for (var type in ContentType.values) {
        var content = KanjiCardContent(kanji: kanji, contentType: type);
        contents.add(content);
      }
    }

    cardsCount = contents.length;
    contents.shuffle(Random(DateTime.now().millisecondsSinceEpoch));

    mainCard = GestureDetector(
      child: KanjiCard(kanjiCardContent: contents.first, key: mainCardKey),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(''),
          actions: <Widget>[
            Padding(padding: EdgeInsets.all(12), child: Center(child: Text('$index/$cardsCount', style: TextStyle(fontSize: 18)))),
            IconButton(
              icon: Icon(FontAwesomeIcons.solidQuestion, color: Colors.white, size: 18),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => KanjiStudyHelpPage())),
            )
          ],
          bottom: PreferredSize(
              child: Stack(
                children: <Widget>[
                  LinearProgressIndicator(
                      value: cardsProgress, valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey), backgroundColor: Colors.grey),
                  LinearProgressIndicator(
                      value: studyProgress, valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[800]), backgroundColor: Colors.transparent),
                ],
              ),
              preferredSize: Size.fromHeight(0)),
        ),
        body: Listener(
          onPointerDown: (downEvent) {
            setState(() {
              initialDx = downEvent.position.dx;
              distance = MediaQuery.of(context).size.width - initialDx;
            });
          },
          onPointerMove: (moveEvent) {
            if (moveEvent.position.dx - initialDx < 0) {
              animationController.value = (moveEvent.position.dx - initialDx) / initialDx;
            } else {
              animationController.value = (moveEvent.position.dx - initialDx) / distance;
            }
          },
          onPointerUp: (_) {
            animationController.value = 0;
          },
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                ...buildMockCards(),
                if (contents.length >= 1)
                  Positioned(
                      top: 80,
                      child: Draggable(
                          data: contents[0],
                          childWhenDragging: contents.length > 1 ? KanjiCard(kanjiCardContent: contents[1]) : Container(),
                          feedback: AnimatedBuilder(
                            animation: animationController,
                            builder: (_, __) {
                              return Transform.rotate(angle: animationController.drive(angleTween).value, child: mainCard);
                            },
                          ),
                          onDragStarted: onDragStarted,
                          onDragCompleted: () {},
                          onDragEnd: (dragDetails) {
                            //Swipe right.
                            if (dragDetails.offset.dx > 230 || dragDetails.velocity.pixelsPerSecond.dx > 1600) {
                              setState(() {
                                contents.add(contents[0]);
                                contents.removeAt(0);
                                mainCardKey = GlobalKey<KanjiCardState>();
                                mainCard = GestureDetector(
                                  child: KanjiCard(kanjiCardContent: contents.first, key: mainCardKey),
                                );
                                cardsProgress = cardsProgress == 1 ? 1 : cardsProgress + 1.0 / cardsCount;
                              });

                              //Swipe left.
                            } else if (dragDetails.offset.dx < -170 || dragDetails.velocity.pixelsPerSecond.dx < -1600) {
                              setState(() {
                                index++;
                                contents.removeAt(0);
                                mainCardKey = GlobalKey<KanjiCardState>();
                                if (contents.isEmpty) {
                                  mainCard = Container();
                                  var timeStamp = DateTime.now().millisecondsSinceEpoch;
                                  for (var i in widget.kanjis) {
                                    i.timeStamp = timeStamp;
                                  }
                                  kanjiBloc.updateTimeStampsForKanjis(widget.kanjis);
                                } else {
                                  mainCard = GestureDetector(
                                    child: KanjiCard(kanjiCardContent: contents.first, key: mainCardKey),
                                  );
                                }

                                studyProgress = studyProgress == 1 ? 1 : studyProgress + 1.0 / cardsCount;
                              });
                            }
                          },
                          child: mainCard)),
                if (contents.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                        child: Text(
                      celebrateString.elementAt(Random(DateTime.now().millisecondsSinceEpoch).nextInt(celebrateString.length)),
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      textAlign: TextAlign.center,
                    )),
                  )
              ],
            ),
          ),
        ));
  }

  List<Widget> buildMockCards() {
    var children = <Widget>[];
    if (contents.length > 1) {
      for (int i = min(contents.length - 1, 10); i >= 1; i--) {
        children.add(Positioned(
          top: 80 - i * 15.0 + i * i,
          child: Transform.scale(
              alignment: Alignment.topCenter,
              scale: 0.6 + (0.4 / 10) * (10 - i),
              child: KanjiCard(
                color: Colors.grey[700].withAlpha(200 + ((55 / 10) * (10 - i)).toInt()),
                kanjiCardContent: contents.elementAt(i),
              )),
        ));
      }
    }

    return children;
  }

  void onDragStarted() {}
}
