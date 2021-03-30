import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

import '../../bloc/text_recognize_bloc.dart';
import '../../bloc/kanji_bloc.dart';
import '../../utils/string_extension.dart';
import '../components/kanji_list_view.dart';
import '../components/kanji_grid_view.dart';
import '../components/furigana_text.dart';

class TextRecognizePage extends StatefulWidget {
  final ImageSource imageSource;

  TextRecognizePage({this.imageSource}) : assert(imageSource != null);

  @override
  _TextRecognizePageState createState() => _TextRecognizePageState();
}

class _TextRecognizePageState extends State<TextRecognizePage> {
  final scrollController = ScrollController();
  String text = "";
  List<Kanji> kanjis = [];
  bool didChooseImage = false, showShadow = false, showGrid = false;
  ImageSource imageSource;

  Future getImage() async {
    if (imageSource == null) return;

    var image =
        await ImagePicker.pickImage(source: imageSource, imageQuality: 85);

    if (image == null) {
      return;
    }

    setState(() {
      textRecognizeBloc.reset();
      didChooseImage = true;
    });

    var bytes = await image.readAsBytes();
    var base64Str = base64Encode(bytes);

    textRecognizeBloc.extractTextFromImage(base64Str);
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
                    Navigator.pop(context, ImageSource.camera);
                  },
                ),
                CupertinoActionSheetAction(
                  child: Text('Gallery', style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    Navigator.pop(context, ImageSource.gallery);
                  },
                ),
              ],
            )).then((value) => value ?? null);
  }

  @override
  void initState() {
    imageSource = widget.imageSource;
    getImage();

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
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: textRecognizeBloc.text,
      builder: (_, AsyncSnapshot<String> snapshot) {
        text = snapshot.data;

        if (text != null && text.isNotEmpty) {
          kanjis = text
              .getKanjis()
              .where((str) => KanjiBloc.instance.allKanjisMap.containsKey(str))
              .map((str) => KanjiBloc.instance.allKanjisMap[str])
              .toList();
        }

        Widget body;

        if (!didChooseImage) {
          body = Center(
              child: Text(
            "Choose an image first.",
            style: TextStyle(color: Colors.white70),
          ));
        } else if (!snapshot.hasData) {
          body = Center(child: CircularProgressIndicator());
        } else if (text.isEmpty || kanjis.isEmpty) {
          body = Center(
              child: Text("No kanji was found in the image.",
                  style: TextStyle(color: Colors.white70)));
        } else {
          body = SingleChildScrollView(
            controller: scrollController,
            child: Flex(
              direction: Axis.vertical,
              children: <Widget>[
                Text(
                  text,
                  style: TextStyle(color: Colors.white),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 8, left: 20),
                    child: Text(
                      "Found ${kanjis.length} kanji in the image:",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                showGrid
                    ? KanjiGridView(
                        kanjis: kanjis,
                        scrollPhysics: NeverScrollableScrollPhysics())
                    : KanjiListView(
                        kanjis: kanjis,
                        scrollPhysics: NeverScrollableScrollPhysics())
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            actions: <Widget>[
              if (didChooseImage && snapshot.hasData)
                IconButton(
                  icon: AnimatedCrossFade(
                    firstChild: Icon(
                      Icons.view_headline,
                      color: Colors.white,
                    ),
                    secondChild: Icon(
                      Icons.view_comfy,
                      color: Colors.white,
                    ),
                    crossFadeState: showGrid
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: Duration(milliseconds: 200),
                  ),
                  onPressed: () {
                    setState(() {
                      showGrid = !showGrid;
                    });
                  },
                ),
            ],
            title: FuriganaText(
              text: '画像漢字認識',
              tokens: [
                Token(text: '画像', furigana: 'がぞう'),
                Token(text: '漢字', furigana: 'かんじ'),
                Token(text: '認識', furigana: 'にんしき'),
              ],
              style: TextStyle(fontSize: 18),
            ),
            elevation: showShadow ? 8 : 0,
          ),
          backgroundColor: Theme.of(context).primaryColor,
          body: body,
          floatingActionButton: FloatingActionButton(
            onPressed: () => getImageSource().then((val) {
              if (val != null) {
                imageSource = val;
                getImage();
              }
            }),
            tooltip: 'Pick Image',
            child: Icon(Icons.add_a_photo),
          ),
        );
      },
    );
  }
}
