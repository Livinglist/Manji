import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StrokeAnimationPlayer extends StatelessWidget {
  final String kanjiStr;
  final VideoPlayerController videoController;

  StrokeAnimationPlayer({this.kanjiStr, this.videoController})
      : assert(kanjiStr != null && kanjiStr.length == 1);

  @override
  Widget build(BuildContext context) {
    if (videoController == null) return Container();
    return FutureBuilder(
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
    );
  }
}
