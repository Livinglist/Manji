import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart' show ImageSource;
import 'package:connectivity/connectivity.dart';
import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import 'package:kanji_dictionary/bloc/search_bloc.dart';
import 'package:kanji_dictionary/ui/components/kanji_list_tile.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_device_type/flutter_device_type.dart';

import 'package:kanji_dictionary/bloc/kanji_list_bloc.dart';
import 'package:kanji_dictionary/bloc/kana_bloc.dart';
import 'package:kanji_dictionary/bloc/siri_suggestion_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'components/home_page_background.dart';
import 'components/daily_kanji_card.dart';
import 'kanji_detail_page.dart';
import 'jlpt_kanji_page.dart';
import 'bookmark_page.dart';
import 'kana_page.dart';
import 'settings_page.dart';
import 'education_kanji_page.dart';
import 'search_result_page.dart';
import 'custom_list_page.dart';
import 'quiz_pages/quiz_page.dart';
import 'text_recognize_page/text_recognize_page.dart';
import 'kanji_recognize_page/kanji_recognize_page.dart';
import 'progress_pages/progress_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
  final textEditingController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final backgroundKey = GlobalKey<HomePageBackgroundState>();
  double mainPageScale = 1.0;
  double opacity = 0;
  AnimationController animationController;
  Tween<double> tween = Tween<double>(begin: 0, end: 1);
  bool isEntering = false;

  @override
  void initState() {
    kanaBloc.init();
    KanjiListBloc.instance.init();
    animationController = AnimationController(vsync: this, value: 1, duration: Duration(seconds: 1));
    super.initState();

    Timer(Duration(seconds: 2), () {
      setState(() {
        opacity = 1;
      });
    });

    SiriSuggestionBloc.instance.siriSuggestion.listen((kanjiStr) {
      if (kanjiStr != null) {
        var kanji = KanjiBloc.instance.allKanjisMap[kanjiStr];
        Navigator.push(context, MaterialPageRoute(builder: (_) => KanjiDetailPage(kanji: kanji)));
      }
    });
  }

  Future<ImageSource> getImageSource() {
    return showCupertinoModalPopup<ImageSource>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              message: Text("Choose an image to detect kanji from"),
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context, null);
                },
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  child: Text('Camera', style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    return Permission.camera.status.then((status) {
                      if (status == PermissionStatus.granted) {
                        Navigator.pop(context, ImageSource.camera);
                        return ImageSource.camera;
                      } else if (status == PermissionStatus.permanentlyDenied || status == PermissionStatus.denied) {
                        launch("app-settings:");
                        return null;
                      }
                      return [Permission.camera].request().then((val) {
                        if (val[Permission.camera] == PermissionStatus.granted) {
                          Navigator.pop(context, ImageSource.camera);
                          return ImageSource.camera;
                        } else {
                          return null;
                        }
                      });
                    });
                  },
                ),
                CupertinoActionSheetAction(
                  child: Text('Gallery', style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    return Permission.photos.status.then((status) {
                      if (status == PermissionStatus.granted) {
                        Navigator.pop(context, ImageSource.gallery);
                        return ImageSource.gallery;
                      } else if (status == PermissionStatus.permanentlyDenied || status == PermissionStatus.denied) {
                        launch("app-settings:");
                        return null;
                      }
                      return [Permission.photos].request().then((val) {
                        if (val[Permission.photos] == PermissionStatus.granted) {
                          Navigator.pop(context, ImageSource.gallery);
                          return ImageSource.gallery;
                        } else {
                          return null;
                        }
                      });
                    });
                  },
                ),
              ],
            )).then((value) => value ?? null);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        drawerEdgeDragWidth: 50,
        key: scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
                icon: Transform.translate(offset: Offset(0, -1.5), child: Icon(FontAwesomeIcons.edit, size: 20)),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => KanjiRecognizePage()));
                }),
            IconButton(
              icon: Transform.rotate(angle: pi / 2, child: Icon(Icons.flip)),
              onPressed: () {
                FocusScope.of(context).unfocus();
                Connectivity().checkConnectivity().then((val) {
                  if (val == ConnectivityResult.none) {
                    scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: Text(
                        'Text Recognition requires access to Internet',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                      action: SnackBarAction(label: 'Dismiss', onPressed: () => scaffoldKey.currentState.hideCurrentSnackBar()),
                    ));
                  } else {
                    getImageSource().then((val) {
                      if (val != null) Navigator.push(context, MaterialPageRoute(builder: (_) => TextRecognizePage(imageSource: val)));
                    });
                  }
                });
              },
            )
          ],
          title: Text('Manji'),
          elevation: 0,
        ),
        drawer: DrawerListener(
          onPositionChange: (FractionalOffset offset) {
            if (Device.get().isTablet == false) animationController.value = offset.dx;
          },
          child: Drawer(
              child: Material(
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Divider(color: Colors.white60, height: 0),
                ),
                ListTile(
                  title: Text('進度', style: TextStyle(color: Colors.white)),
                  subtitle: Text('Progress'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ProgressPage()));
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
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                  child: AnimatedBuilder(
                      animation: animationController,
                      builder: (_, __) {
                        return HomePageBackground(
                          key: backgroundKey,
                          animationController: animationController,
                          callback: (String kanji) {
                            if (textEditingController.text.isEmpty || textEditingController.text.length == 1) {
                              textEditingController.text = kanji;
                            }
                          },
                        );
                      })),
              Positioned(
                  top: 80,
                  left: Device.get().isTablet ? (width < 505 ? 22 : 256) : 22,
                  right: Device.get().isTablet ? (width < 505 ? 22 : 256) : 22,
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
                                onChanged: (text) {
                                  if (text.isEmpty) {
                                    SearchBloc.instance.clear();
                                  } else {
                                    SearchBloc.instance.search(text);
                                  }
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
                  left: Device.get().isTablet ? (width < 505 ? 22 : 256) : 22,
                  right: Device.get().isTablet ? (width < 505 ? 22 : 256) : 22,
                  child: Container(
                      child: AnimatedBuilder(
                          animation: animationController,
                          child: DailyKanjiCard(),
                          builder: (_, child) {
                            return Opacity(opacity: tween.animate(animationController).value, child: child);
                          }))),
              Positioned(
                  top: 122,
                  left: Device.get().isTablet ? (width < 505 ? 22 : 256) : 22,
                  right: Device.get().isTablet ? (width < 505 ? 22 : 256) : 22,
                  child: Center(
                      child: StreamBuilder(
                    stream: SearchBloc.instance.results,
                    builder: (_, AsyncSnapshot<List<Kanji>> snapshot) {
                      if (snapshot.hasData && snapshot.data.isNotEmpty) {
                        var kanjis = snapshot.data;
                        return Container(
                            decoration: BoxDecoration(
                                boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8)],
                                shape: BoxShape.rectangle,
                                color: Theme.of(context).primaryColor),
                            height: 480,
                            //width: MediaQuery.of(context).size.width * 0.9,
                            child: ListView(
                                children: kanjis
                                    .map((e) => KanjiListTile(
                                          kanji: e,
                                        ))
                                    .toList()));
                      } else {
                        return Container();
                      }
                    },
                  ))),
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

class DrawerListener extends StatefulWidget {
  final Widget child;
  final ValueChanged<FractionalOffset> onPositionChange;

  DrawerListener({
    @required this.child,
    this.onPositionChange,
  });

  @override
  _DrawerListenerState createState() => _DrawerListenerState();
}

class _DrawerListenerState extends State<DrawerListener> {
  GlobalKey _drawerKey = GlobalKey();
  int taskID;
  Offset currentOffset;

  @override
  void initState() {
    super.initState();
    _postTask();
  }

  _postTask() {
    taskID = SchedulerBinding.instance.scheduleFrameCallback((_) {
      if (widget.onPositionChange != null) {
        final RenderBox box = _drawerKey.currentContext?.findRenderObject();
        if (box != null) {
          Offset newOffset = box.globalToLocal(Offset.zero);
          if (newOffset != currentOffset) {
            currentOffset = newOffset;
            widget.onPositionChange(
              FractionalOffset.fromOffsetAndRect(
                currentOffset,
                Rect.fromLTRB(0, 0, box.size.width, box.size.height),
              ),
            );
          }
        }
      }

      _postTask();
    });
  }

  @override
  void dispose() {
    SchedulerBinding.instance.cancelFrameCallbackWithId(taskID);
    if (widget.onPositionChange != null) {
      widget.onPositionChange(FractionalOffset(1.0, 0));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _drawerKey,
      child: widget.child,
    );
  }
}
