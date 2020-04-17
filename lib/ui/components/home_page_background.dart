import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef KanjiCallback = void Function(String);

class HomePageBackground extends StatefulWidget {
  final KanjiCallback callback;
  final AnimationController animationController;

  HomePageBackground({Key key, this.callback, this.animationController}) : super(key: key);

  @override
  HomePageBackgroundState createState() => HomePageBackgroundState();
}

class HomePageBackgroundState extends State<HomePageBackground> {
  final total = 190;
  final perRow = 10;
  double width, height;
  List<GlobalKey> keys;
  List<String> kanji = ['', '', ''];
  GlobalKey targetKey;
  List<dynamic> kanjiJsons;
  bool initialized = false;
  bool visible = false;

  @override
  void initState() {
    super.initState();
    keys = List.generate(total, (_) => GlobalKey());
  }

  setTarget(Offset ptrPos) {
    for (int i = 0; i < keys.length; i++) {
      var cxt = keys[i].currentContext;
      if (cxt != null) {
        final RenderBox rBox = cxt.findRenderObject();
        final pos = rBox.localToGlobal(Offset.zero);

        if (ptrPos.dy >= pos.dy && ptrPos.dy <= pos.dy + cxt.size.height && ptrPos.dx >= pos.dx && ptrPos.dx <= pos.dx + (width / perRow)) {
          setState(() {
            targetKey = keys[i];
            kanji = [
              kanjiJsons[i]["character"],
              kanjiJsons[i]["onyomi"]["katakana"].toString() + ' ' + kanjiJsons[i]["kunyomi"]["hiragana"].toString().replaceAll("n/a", ""),
              kanjiJsons[i]["meaning"]["english"].toString()
            ];
            widget.callback(kanjiJsons[i]["character"]);
            visible = true;
          });
          break;
        }
      }
    }
  }

  fetch() async {
    if (!initialized) {
      var res = await rootBundle.loadString('data/data').whenComplete(() => initialized = true);
      kanjiJsons = (json.decode(res) as List).map((map) => map["kanji"]).toList()..shuffle();
      kanjiJsons = kanjiJsons.take(total);
    }
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.1, 0.5, 0.7, 1.0],
          colors: [
            Theme.of(context).primaryColor,
            Colors.grey[600],
            Colors.grey[500],
            Colors.grey[400],
          ],
        ),
      ),
      child: Scaffold(
        //backgroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.transparent,
        body: GestureDetector(
            onPanDown: (dtl) => setTarget(dtl.globalPosition),
            onPanStart: (dtl) => setTarget(dtl.globalPosition),
            onPanUpdate: (dtl) => setTarget(dtl.globalPosition),
            onPanEnd: (_) => setState(() {
                  targetKey = null;
                  visible = false;
                }),
            onPanCancel: () => setState(() {
                  targetKey = null;
                  visible = true;
                }),
            child: FutureBuilder(
                future: fetch(),
                builder: (_, snap) {
                  if (initialized) {
                    return Container(
                      height: double.infinity,
                      child: GridView(
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: perRow),
                          children: buildChildren()),
                    );
                  } else
                    return Container();
                  //return Center(child: CircularProgressIndicator());
                })),
      ),
    );
  }

  List<Widget> buildChildren() {
    return List.generate(
      total,
      (i) => Transform.scale(
          scale: widget.animationController?.value ?? 1,
          child: AnimatedOpacity(
              opacity: keys[i] == targetKey ? 1 : 0.2,
              duration: Duration(milliseconds: 300),
              key: keys[i],
              //decoration: BoxDecoration(color: targetKey == keys[i] ? Colors.white : Theme.of(context).primaryColor),
              child: Center(
                child: Text(kanjiJsons[i]["character"], style: TextStyle(color: Colors.white, fontSize: 26, fontFamily: 'kazei')),
              ))),
    );
  }
}
