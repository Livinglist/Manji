import 'dart:async';
import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart' show ImageSource;
import 'package:permission_handler/permission_handler.dart';

import '../bloc/kana_bloc.dart';
import '../bloc/kanji_bloc.dart';
import '../bloc/kanji_list_bloc.dart';
import '../bloc/search_bloc.dart';
import '../bloc/siri_suggestion_bloc.dart';
import 'bookmark_page.dart';
import 'components/compact_kanji_list_tile.dart';
import 'components/daily_kanji_card.dart';
import 'components/home_page_background.dart';
import 'custom_list_page.dart';
import 'education_kanji_page.dart';
import 'jlpt_kanji_page.dart';
import 'kana_page.dart';
import 'kanji_detail_page/kanji_detail_page.dart';
import 'kanji_recognize_page/kanji_recognize_page.dart';
import 'progress_pages/progress_page.dart';
import 'quiz_pages/quiz_page.dart';
import 'search_result_page.dart';
import 'settings_page.dart';
import 'text_recognize_page/text_recognize_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final textEditingController = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final backgroundKey = GlobalKey<HomePageBackgroundState>();
  final focusNode = FocusNode();
  final searchBloc = SearchBloc();
  double mainPageScale = 1.0;
  double opacity = 0;
  AnimationController animationController;
  Tween<double> tween = Tween<double>(begin: 0, end: 1);
  bool isEntering = false;

  @override
  void initState() {
    kanaBloc.init();
    KanjiListBloc.instance.init();
    animationController = AnimationController(
        vsync: this, value: 1, duration: const Duration(seconds: 1));

    //FeatureDiscovery.clearPreferences(context, <String>{ 'kanji_recognition', 'kanji_extraction' });
    SchedulerBinding.instance.addPostFrameCallback((duration) {
      FeatureDiscovery.discoverFeatures(
        context,
        const <String>{'kanji_recognition', 'kanji_extraction'},
      );
    });

    super.initState();

    Timer(const Duration(seconds: 2), () {
      setState(() {
        opacity = 1;
      });
    });

    SiriSuggestionBloc.instance.siriSuggestion.listen((kanjiStr) {
      if (kanjiStr != null) {
        final kanji = KanjiBloc.instance.allKanjisMap[kanjiStr];
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => KanjiDetailPage(kanji: kanji)));
      }
    });

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          isEntering = true;
        });
      } else {
        setState(() {
          isEntering = false;
        });
      }
    });
  }

  Future<ImageSource> getImageSource() {
    return showCupertinoModalPopup<ImageSource>(
        context: context,
        builder: (context) => CupertinoActionSheet(
              message: const Text("Choose an image to detect kanji from"),
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context, null);
                },
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                  child: const Text('Camera',
                      style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    return Permission.camera.status.then((status) {
                      if (status.isGranted) {
                        Navigator.pop(context, ImageSource.camera);
                        return ImageSource.camera;
                      } else if (status == PermissionStatus.permanentlyDenied) {
                        openAppSettings();
                        return null;
                      }
                      return Permission.camera.request().then((val) {
                        if (val.isGranted) {
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
                  child: const Text('Gallery',
                      style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    return Permission.photos.status.then((status) {
                      if (status.isGranted) {
                        Navigator.pop(context, ImageSource.gallery);
                        return ImageSource.gallery;
                      } else if (status == PermissionStatus.permanentlyDenied ||
                          status == PermissionStatus.denied) {
                        openAppSettings();
                        return null;
                      }

                      return Permission.photos.request().then((val) {
                        if (val.isGranted) {
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
    final width = MediaQuery.of(context).size.width;
    final subtitleStyle = TextStyle(
        color: Theme.of(context).primaryColor == Colors.black
            ? Colors.white60
            : Colors.black54);

    return Scaffold(
        drawerEdgeDragWidth: 50,
        key: scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          actions: <Widget>[
            DescribedFeatureOverlay(
              featureId: 'kanji_recognition',
              // Unique id that identifies this overlay.
              tapTarget: IconButton(
                  onPressed: null,
                  icon: Transform.translate(
                      offset: const Offset(0, -1.5),
                      child: const Icon(FontAwesomeIcons.edit, size: 20))),
              // The widget that will be displayed as the tap target.
              title: const Text('Write it down'),
              description: const Text(
                  'Write down the kanji and Manji will tell you what kanji it is.'),
              backgroundColor: Theme.of(context).primaryColor,
              targetColor: Colors.white,
              textColor: Colors.white,
              child: IconButton(
                  icon: Transform.translate(
                      offset: const Offset(0, -1.5),
                      child: const Icon(FontAwesomeIcons.edit, size: 20)),
                  onPressed: () {
                    focusNode.unfocus();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => KanjiRecognizePage()));
                  }),
            ),
            DescribedFeatureOverlay(
                featureId: 'kanji_extraction',
                // Unique id that identifies this overlay.
                tapTarget: IconButton(
                    onPressed: null,
                    icon: Transform.rotate(
                        angle: pi / 2, child: const Icon(Icons.flip))),
                title: const Text('Look it up'),
                description: const Text(
                    'Upload an image and all the kanji on it will be extracted.'),
                backgroundColor: Theme.of(context).primaryColor,
                targetColor: Colors.white,
                textColor: Colors.white,
                child: IconButton(
                  icon: Transform.rotate(
                      angle: pi / 2, child: const Icon(Icons.flip)),
                  onPressed: () {
                    focusNode.unfocus();
                    Connectivity().checkConnectivity().then((val) {
                      if (val == ConnectivityResult.none) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text(
                            'Text Recognition requires access to Internet',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.red,
                          action: SnackBarAction(
                              label: 'Dismiss',
                              onPressed: () => ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar()),
                        ));
                      } else {
                        getImageSource().then((val) {
                          if (val != null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        TextRecognizePage(imageSource: val)));
                          }
                        });
                      }
                    });
                  },
                )),
          ],
          title: const Text('Manji'),
          elevation: 0,
        ),
        drawer: DrawerListener(
          onPositionChange: (offset) {
            if (Device.get().isTablet == false) {
              animationController.value = offset.dx;
            }
          },
          child: Drawer(
              child: Material(
            color: Theme.of(context).primaryColor == Colors.black
                ? Colors.black
                : Colors.grey[600],
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 50,
                ),
                ListTile(
                  title:
                      const Text('仮名', style: TextStyle(color: Colors.white)),
                  subtitle: Text('Kana', style: subtitleStyle),
                  onTap: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => KanaPage()));
                  },
                ),
                ListTile(
                  title: const Text('日本語能力試験漢字',
                      style: TextStyle(color: Colors.white)),
                  subtitle: Text('JLPT Kanji', style: subtitleStyle),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => JLPTKanjiPage()));
                  },
                ),
                ListTile(
                  title:
                      const Text('教育漢字', style: TextStyle(color: Colors.white)),
                  subtitle: Text('Kyōiku Kanji', style: subtitleStyle),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => EducationKanjiPage()));
                  },
                ),
                ListTile(
                  title: const Text('収蔵した漢字',
                      style: TextStyle(color: Colors.white)),
                  subtitle: Text('Favorite Kanji', style: subtitleStyle),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => MyKanjiPage()));
                  },
                ),
                ListTile(
                  title: const Text('漢字リスト',
                      style: TextStyle(color: Colors.white)),
                  subtitle: Text('Kanji Lists', style: subtitleStyle),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => MyListPage()));
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Divider(color: Colors.white60, height: 0),
                ),
                ListTile(
                  title:
                      const Text('進度', style: TextStyle(color: Colors.white)),
                  subtitle: Text('Progress', style: subtitleStyle),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ProgressPage()));
                  },
                ),
                ListTile(
                  title:
                      const Text('クイズ', style: TextStyle(color: Colors.white)),
                  subtitle: Text('Quiz', style: subtitleStyle),
                  onTap: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => QuizPage()));
                  },
                ),
                ListTile(
                  title:
                      const Text('設定', style: TextStyle(color: Colors.white)),
                  subtitle: Text('Settings', style: subtitleStyle),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => SettingsPage()));
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
                          callback: (kanji) {
                            if (textEditingController.text.isEmpty ||
                                textEditingController.text.length == 1) {
                              focusNode.unfocus();
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
                        decoration: const BoxDecoration(boxShadow: [
                          BoxShadow(color: Colors.black54, blurRadius: 8)
                        ], shape: BoxShape.rectangle, color: Colors.white),
                        height: 42,
                        //width: MediaQuery.of(context).size.width * 0.9,
                        child: Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Material(
                              color: Colors.transparent,
                              child: textEditingController.text.isEmpty
                                  ? const IconButton(
                                      icon: Icon(Icons.search), onPressed: null)
                                  : IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        setState(() {
                                          textEditingController.clear();
                                          searchBloc.clear();
                                        });
                                      },
                                    ),
                            ),
                            Expanded(
                              child: TextField(
                                autofocus: false,
                                controller: textEditingController,
                                cursorWidth: 1,
                                cursorColor: Theme.of(context).primaryColor,
                                cursorRadius: const Radius.circular(1),
                                decoration:
                                    const InputDecoration(hintText: 'Find'),
                                focusNode: focusNode,
                                onTap: () {
                                  setState(() {
                                    isEntering = true;
                                  });
                                },
                                onSubmitted: (_) {
                                  setState(() {
                                    isEntering = false;
                                  });
                                },
                                onChanged: (text) {
                                  setState(() {
                                    if (text.isEmpty) {
                                      searchBloc.clear();
                                    } else {
                                      searchBloc.search(text);
                                    }
                                  });
                                },
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: IconButton(
                                  splashColor: Colors.grey,
                                  icon: Icon(Icons.arrow_forward,
                                      color: isEntering
                                          ? Colors.black
                                          : Colors.grey),
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
                            return Opacity(
                                opacity:
                                    tween.animate(animationController).value,
                                child: child);
                          }))),
              Positioned(
                  top: 122,
                  left: Device.get().isTablet ? (width < 505 ? 22 : 256) : 22,
                  right: Device.get().isTablet ? (width < 505 ? 22 : 256) : 22,
                  child: Center(
                      child: StreamBuilder(
                    stream: searchBloc.results,
                    builder: (_, snapshot) {
                      if (snapshot.hasData && snapshot.data.isNotEmpty) {
                        final kanjis = snapshot.data;
                        return Container(
                            decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black54, blurRadius: 8)
                                ],
                                shape: BoxShape.rectangle,
                                color: Theme.of(context).primaryColor),
                            height: 480,
                            //width: MediaQuery.of(context).size.width * 0.9,
                            child: ListView(
                                children: kanjis
                                    .map((e) => Material(
                                          color: Theme.of(context).primaryColor,
                                          child: CompactKanjiListTile(
                                            kanji: e,
                                          ),
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
    final text = textEditingController.text;
    if (text.length == 1 && KanjiBloc.instance.allKanjisMap.containsKey(text)) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => KanjiDetailPage(
                    kanjiStr: textEditingController.text,
                  ))).then((value) {
        searchBloc.clear();
      });
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
    for (var i = 0; i < text.length; i++) {
      if (text.codeUnitAt(i) > 12543) {
        continue;
      } else {
        return false;
      }
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
  final _drawerKey = GlobalKey();
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
          final newOffset = box.globalToLocal(Offset.zero);
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
      widget.onPositionChange(const FractionalOffset(1.0, 0));
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
