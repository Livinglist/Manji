import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_device_type/flutter_device_type.dart';

import '../../bloc/kanji_bloc.dart';
import '../../bloc/kanji_recognition_bloc.dart';
import '../components/kanji_list_tile.dart';
import 'resource/constants.dart';

class DrawingPainter extends CustomPainter {
  DrawingPainter({this.offsetPoints});
  List<Offset> offsetPoints;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < offsetPoints.length - 1; i++) {
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

class _KanjiRecognizePageState extends State<KanjiRecognizePage>
    with SingleTickerProviderStateMixin {
  final scrollController = ScrollController();
  AnimationController animationController;
  bool showShadow = false, canvasEnabled = true;
  List<Offset> points = [];
  Uint8List bytesData;

  void _cleanDrawing() {
    setState(() {
      points = [];
    });
  }

  @override
  void initState() {
    animationController = AnimationController(vsync: this, value: 1);

    scrollController.addListener(() {
      if (mounted) {
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

    scrollController.addListener(() {
      if (mounted) {
        scrollController.addListener(() {
          if (mounted) {
            animationController.value = scrollController.offset >= 120
                ? 0
                : 1 - scrollController.offset / 120;
          }
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print(MediaQuery.of(context).size.width - MediaQuery.of(context).padding.top);
    return Scaffold(
      appBar: AppBar(
        elevation: showShadow ? 8 : 0,
        title: Text(widget.title),
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.all(12),
              child: StreamBuilder(
                stream: kanjiRecognizeBloc.predictedKanji,
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    final kanjis = snapshot.data;

                    return Center(child: Text('${kanjis.length} kanji found'));
                  }
                  return Container();
                },
              ))
        ],
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Device.get().isTablet
                ? buildTopForTablet()
                : buildTopForPhone(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedBuilder(
              animation: animationController,
              child: Device.get().isTablet ? buildForTablet() : buildForPhone(),
              builder: (_, child) {
                return Opacity(
                  opacity: animationController.value,
                  child: animationController.value <= 0 ? Container() : child,
                );
              },
            ),
          ),
        ],
      ),
//      body: Container(
//          color: Colors.white,
//          child: SingleChildScrollView(
//            physics: NeverScrollableScrollPhysics(),
//            child: Column(
//              mainAxisAlignment: MainAxisAlignment.start,
//              children: <Widget>[
//                Device.get().isTablet ? buildTopForTablet() : buildTopForPhone(),
//                Device.get().isTablet ? buildForTablet() : buildForPhone(),
//                Container(
//                  height: 50,
//                  color: Colors.white,
//                )
//              ],
//            ),
//          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _cleanDrawing();
        },
        tooltip: 'Clean',
        child: const Icon(Icons.delete),
      ),
    );
  }

  Widget buildTopForPhone() {
    return Container(
        color: Theme.of(context).primaryColor,
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height / 2),
        height: MediaQuery.of(context).size.width -
            MediaQuery.of(context).padding.top,
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder(
          stream: kanjiRecognizeBloc.predictedKanji,
          initialData: const <Kanji>[],
          builder: (_, snapshot) {
            final kanjis = snapshot.data;
            if (kanjis.isEmpty) {
              return const Center(
                  child: Text(r'Empty ¯\_(ツ)_/¯',
                      style: TextStyle(color: Colors.white70)));
            }

            final children = <Widget>[];

            for (var k in kanjis) {
              print(k.kanji);
              children.add(Material(
                color: Colors.transparent,
                child: KanjiListTile(kanji: k),
              ));
              children.add(const Divider(height: 0));
            }

            children.removeLast();

            children.add(const SizedBox(height: 360));

            return ListView(
              controller: scrollController,
              children: children,
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
          stream: kanjiRecognizeBloc.predictedKanji,
          initialData: const <Kanji>[],
          builder: (_, snapshot) {
            final kanjis = snapshot.data;
            if (kanjis.isEmpty) {
              return const Center(
                  child: Text(r'Empty ¯\_(ツ)_/¯',
                      style: TextStyle(color: Colors.white70)));
            }

            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: <Widget>[
                  ...kanjis.map((k) => KanjiListTile(kanji: k))
                ],
              ),
            );
          },
        ));
  }

  Widget buildForPhone() {
    print(MediaQuery.of(context).size.width);
    return Container(
      height: MediaQuery.of(context).size.width,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Builder(
        builder: (context) {
          return GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                final renderBox = context.findRenderObject() as RenderBox;
                points.add(renderBox.globalToLocal(details.globalPosition));
              });
            },
            onPanStart: (details) {
              setState(() {
                final renderBox = context.findRenderObject() as RenderBox;
                points.add(renderBox.globalToLocal(details.globalPosition));
              });
            },
            onPanEnd: (details) {
              points.add(null);

              kanjiRecognizeBloc.predict(
                  points,
                  (MediaQuery.of(context).size.width > 360)
                      ? 360
                      : MediaQuery.of(context).size.width);
            },
            child: ClipRect(
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.width),
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
      constraints: const BoxConstraints(maxHeight: 360, maxWidth: 360),
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
        builder: (context) {
          return GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                final renderBox = context.findRenderObject() as RenderBox;
                points.add(renderBox.globalToLocal(details.globalPosition));
              });
            },
            onPanStart: (details) {
              setState(() {
                final renderBox = context.findRenderObject() as RenderBox;
                points.add(renderBox.globalToLocal(details.globalPosition));
              });
            },
            onPanEnd: (details) {
              points.add(null);

              kanjiRecognizeBloc.predict(
                  points,
                  (MediaQuery.of(context).size.width > 360)
                      ? 360
                      : MediaQuery.of(context).size.width);
            },
            child: ClipRect(
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.width),
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
