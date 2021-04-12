import 'package:googleapis/vision/v1.dart';
import 'package:googleapis_auth/auth_io.dart';

import 'google_api_credentials.dart';
import '../utils/string_extension.dart';

const _SCOPES = const [VisionApi.cloudVisionScope];

class GoogleApiProvider {
  static Future<String> extractTextFromImage(String imgStr) async {
    print("before starting extract text from image");
    return clientViaServiceAccount(credentials, _SCOPES).then((httpClient) {
      var vision = VisionApi(httpClient);

      BatchAnnotateImagesRequest r = BatchAnnotateImagesRequest();
      r.requests = [
        AnnotateImageRequest.fromJson({
          "image": {
            "content": imgStr,
          },
          "features": [
            {"type": "TEXT_DETECTION", "maxResults": 1}
          ],
          "imageContext": {
            "languageHints": ["ja"],
          }
        })
      ];

      return vision.images.annotate(r).then((BatchAnnotateImagesResponse b) {
        return b.responses.single.textAnnotations.isEmpty
            ? ""
            : b.responses.single.fullTextAnnotation.text;
      });
    }, onError: (Object err) {
      print(err);
    }).catchError((Object e) {
      print(e);
    });
  }

  static Future<List<String>> extractKanjiFromImage(String imgStr) =>
      extractTextFromImage(imgStr)
          .then<List<String>>((text) => text.getKanjis());
}
