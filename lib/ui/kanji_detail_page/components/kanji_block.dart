import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../resource/constants.dart';

class KanjiBlock extends StatefulWidget {
  final String kanjiStr;
  final double scaleFactor;

  KanjiBlock({this.kanjiStr, this.scaleFactor = 1})
      : assert(kanjiStr != null && kanjiStr.length == 1),
        super(key: UniqueKey());

  @override
  _KanjiBlockState createState() => _KanjiBlockState();
}

class _KanjiBlockState extends State<KanjiBlock> {
  VideoPlayerController videoController;
  bool isPlaying = false;

  @override
  void initState() {
    loadVideo();

    super.initState();
  }

  void loadVideo() async {
    if (allVideoFiles.contains(widget.kanjiStr)) {
      setState(() {
        videoController = VideoPlayerController.asset(
            Uri.encodeFull('video/${widget.kanjiStr}.mp4'))
          ..initialize().then((_) {
            setState(() {});
          })
          ..addListener(() async {
            if (videoController != null && mounted) {
              if (await videoController.position >=
                      videoController.value.duration &&
                  isPlaying) {
                videoController.pause();
                videoController.seekTo(const Duration(seconds: 0));

                setState(() {
                  isPlaying = false;
                });
              }
            }
          });
      });
    }
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
            child: Image.asset(
          'data/matts.png',
        )),
        if (isPlaying == false)
          Align(
            alignment: Alignment.center,
            child: Center(
                child: Hero(
                    tag: widget.kanjiStr,
                    child: Material(
                      //wrap the text in Material so that Hero transition doesn't glitch
                      color: Colors.transparent,
                      child: Text(
                        widget.kanjiStr,
                        style: const TextStyle(
                            fontFamily: 'strokeOrders', fontSize: 128),
                        textScaleFactor: widget.scaleFactor,
                        textAlign: TextAlign.center,
                      ),
                    ))),
          ),
        if (videoController != null &&
            videoController.value.isInitialized &&
            isPlaying == true)
          Positioned.fill(
              child: Center(
                  child: Padding(
            padding: const EdgeInsets.all(24),
            child: FutureBuilder(
              future: videoController.initialize(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return AspectRatio(
                    aspectRatio: videoController.value.aspectRatio,
                    // Use the VideoPlayer widget to display the video.
                    child: VideoPlayer(videoController),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ))),
        if (isPlaying)
          Positioned.fill(
              child: Image.asset(
            'data/matts.png',
          )),
        if (videoController != null &&
            videoController.value.isInitialized &&
            isPlaying == false)
          Positioned.fill(
              child: Center(
                  child: Opacity(
                      opacity: 0.7,
                      child: Material(
                        child: InkWell(
                            onTap: () {
                              setState(() {
                                isPlaying = true;
                                videoController.play();
                              });
                            },
                            child: const Icon(Icons.play_arrow)),
                      ))))
      ],
    );
  }
}
