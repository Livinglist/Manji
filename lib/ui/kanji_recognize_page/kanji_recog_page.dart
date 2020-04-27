import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';

import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import '../components/kanji_list_tile.dart';

import 'resource/constants.dart';
import 'bloc/kanji_recog_bloc.dart';

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
    print(MediaQuery.of(context).size.width - MediaQuery.of(context).padding.top);
    return Scaffold(
      appBar: AppBar(
        elevation: showShadow ? 8 : 0,
        title: Text(widget.title),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.all(12),
              child: StreamBuilder(
                stream: kanjiRecogBloc.predictedKanji,
                builder: (_, AsyncSnapshot<List<Kanji>> snapshot) {
                  if (snapshot.hasData) {
                    var kanjis = snapshot.data;

                    return Center(child: Text('${kanjis.length} kanji found'));
                  }
                  return Container();
                },
              ))
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Device.get().isTablet ? buildTopForTablet() : buildTopForPhone(),
            Device.get().isTablet ? buildForTablet() : buildForPhone()
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

  Widget buildTopForPhone() {
    return Container(
        color: Theme.of(context).primaryColor,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2),
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
        ));
  }

  Widget buildTopForTablet() {
    return Container(
        color: Theme.of(context).primaryColor,
        //constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2),
        height: MediaQuery.of(context).size.height - 460,
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
        ));
  }

  Widget buildForPhone() {
    return Container(
      constraints: BoxConstraints(maxHeight: 360, maxWidth: 360),
      height: MediaQuery.of(context).size.width,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
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

              kanjiRecogBloc.predict(points, (MediaQuery.of(context).size.width > 360) ? 360 : MediaQuery.of(context).size.width);
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
    );
  }

  Widget buildForTablet() {
    return Container(
      constraints: BoxConstraints(maxHeight: 360, maxWidth: 360),
      height: 360,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black54,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
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

              kanjiRecogBloc.predict(points, (MediaQuery.of(context).size.width > 360) ? 360 : MediaQuery.of(context).size.width);
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
    );
  }
}
