import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' hide Image;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as im;
import 'package:tflite/tflite.dart';

import 'constants.dart';

export 'package:flutter/material.dart' show Offset;

final kBackgroundPaint = Paint()..color = kBrushBlack;

class AppBrain {
  Future loadModel() async {
    Tflite.close();
    try {
      await Tflite.loadModel(
        model: "data/model.tflite",
        labels: "data/labels.txt",
      );
    } on PlatformException {
      print('Failed to load model.');
    }
  }

  Future<List> processCanvasPoints(
      List<Offset> points, double canvasSize) async {
    // We create an empty canvas 280x280 pixels
    final canvasSizeWithPadding = canvasSize;
    //final canvasOffset = Offset(kCanvasInnerOffset, kCanvasInnerOffset);
    final recorder = PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromPoints(
        const Offset(0.0, 0.0),
        Offset(canvasSize, canvasSize),
      ),
    );

    // Our image is expected to have a black background and a white drawing trace,
    // quite the opposite of the visual representation of our canvas on the screen

    canvas.drawRect(
        Rect.fromLTWH(0, 0, canvasSizeWithPadding, canvasSizeWithPadding),
        kBackgroundPaint);

    // Now we draw our list of points on white paint
    for (var i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        //canvas.drawLine(points[i] + canvasOffset, points[i + 1] + canvasOffset, kWhitePaint);
        canvas.drawLine(points[i], points[i + 1], kWhitePaint);
      }
    }

    // At this point our virtual canvas is ready and we can export an image from it
    final picture = recorder.endRecording();
    final img = await picture.toImage(
      canvasSizeWithPadding.toInt(),
      canvasSizeWithPadding.toInt(),
    );
    final imgBytes = await img.toByteData(format: ImageByteFormat.png);
    final pngUint8List = imgBytes.buffer.asUint8List();

    // There's quite a funny game at this point. The image class we are using doesn't allow resizing.
    // In order to achieve that, we need to convert it to another image class that we are importing
    // as 'im' from package:image/image.dart
    final imImage = im.decodeImage(pngUint8List);
    final resizedImage = im.copyResize(
      imImage,
      width: kModelInputSize,
      height: kModelInputSize,
    );

    // Finally, we can return our the prediction we will perform over that
    // resized image
    return predictImage(resizedImage).then((val) {
      print(val);
      return val;
    });
  }

  Future<List> predictImage(im.Image image) async {
    return Tflite.runModelOnBinary(
        binary: imageToByteListFloat32(image, kModelInputSize),
        threshold: 0,
        numResults: 10);
  }

  Uint8List imageToByteListFloat32(im.Image image, int inputSize) {
    final convertedBytes = Float32List(inputSize * inputSize);
    final buffer = Float32List.view(convertedBytes.buffer);
    var pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        final pixel = image.getPixel(j, i);
        final r = im.getRed(pixel);
        final g = im.getGreen(pixel);
        final b = im.getBlue(pixel);
        final gray = (0.299 * r + 0.597 * g + 0.114 * b) / 255;
        buffer[pixelIndex++] = gray;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  double convertPixel(int color) {
    return (255 -
            (((color >> 16) & 0xFF) * 0.299 +
                ((color >> 8) & 0xFF) * 0.587 +
                (color & 0xFF) * 0.114)) /
        255.0;
  }
}
