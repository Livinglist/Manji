import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import '../components/kanji_list_tile.dart';

import 'constants.dart';
import 'kanji_recog_bloc.dart';

class DrawingPainter extends CustomPainter {
  DrawingPainter({this.offsetPoints});
  List<Offset> offsetPoints;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < offsetPoints.length - 1; i++) {
      if (offsetPoints[i] != null && offsetPoints[i + 1] != null) {
        canvas.drawLine(offsetPoints[i], offsetPoints[i + 1], kDrawingPaint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

class KanjiRecognizePage extends StatefulWidget {
  KanjiRecognizePage({Key key, this.title = ""}) : super(key: key);

  final String title;

  @override
  _KanjiRecognizePageState createState() => _KanjiRecognizePageState();
}

class _KanjiRecognizePageState extends State<KanjiRecognizePage> {
  final scrollController = ScrollController();
  bool showShadow = false;
  List<Offset> points = List();
  Uint8List bytesData;

  void _cleanDrawing() {
    setState(() {
      points = List();
    });
  }

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (this.mounted) {
        if (scrollController.offset <= 0) {
          setState(() {
            showShadow = false;
          });
        } else if (showShadow == false) {
          setState(() {
            showShadow = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: showShadow ? 8 : 0,
        title: Text(widget.title),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(12),
            child: StreamBuilder(
              stream: kanjiRecogBloc.predictedKanji,
              initialData: <Kanji>[],
              builder: (_, AsyncSnapshot<List<Kanji>> snapshot) {
                var kanjis = snapshot.data;
                if (kanjis.isEmpty) {
                  return Container();
                }

                return Center(child: Text('${kanjis.length} kanji found'));
              },
            )
          )
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
                height: MediaQuery.of(context).size.width - MediaQuery.of(context).padding.top,
                width: MediaQuery.of(context).size.width,
                child: StreamBuilder(
                  stream: kanjiRecogBloc.predictedKanji,
                  initialData: <Kanji>[],
                  builder: (_, AsyncSnapshot<List<Kanji>> snapshot) {
                    var kanjis = snapshot.data;
                    if (kanjis.isEmpty) {
                      return Center(child: Text(r'Empty ¯\_(ツ)_/¯', style: TextStyle(color: Colors.white70)));
                    }
                    for (var i in kanjis) {
                      print(i.kanji);
                    }
                    return SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: <Widget>[...kanjis.map((k) => KanjiListTile(kanji: k))],
                      ),
                    );
                  },
                )
            ),
            Spacer(),
            Container(
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
//                border: Border.all(
//                  width: 3.0,
//                  color: Colors.blue,
//                ),
                color: Colors.white,
              ),
              child: Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        RenderBox renderBox = context.findRenderObject();
                        points.add(renderBox.globalToLocal(details.globalPosition));
                      });
                    },
                    onPanStart: (details) {
                      setState(() {
                        RenderBox renderBox = context.findRenderObject();
                        points.add(renderBox.globalToLocal(details.globalPosition));
                      });
                    },
                    onPanEnd: (details) {
                      points.add(null);

                      kanjiRecogBloc.predict(points, MediaQuery.of(context).size.width);
//                      brain.processCanvasPoints(points, ).then((predictions) {
//                        print(predictions[0].runtimeType);
//                        print(predictions[0]['label']);
//
//                        var temp = [];
//                        for (var i in predictions) {
//                          print(i);
//                          if (kanjiBloc.allKanjisMap.containsKey(i)) {
//                            temp.add(kanjiBloc.allKanjisMap[i]);
//                          }
//                        }
//                        setState(() {
//                          resultKanji = temp;
//                        });
//                      });
                    },
                    child: ClipRect(
                      child: CustomPaint(
                        size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.width),
                        painter: DrawingPainter(
                          offsetPoints: points,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _cleanDrawing();
        },
        tooltip: 'Clean',
        child: Icon(Icons.delete),
      ),
    );
  }
}
