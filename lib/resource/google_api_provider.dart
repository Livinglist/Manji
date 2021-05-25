import 'package:googleapis/vision/v1.dart';
import 'package:googleapis_auth/auth_io.dart';

import '../utils/string_extension.dart';
import 'google_api_credentials.dart';

const _scopes = [VisionApi.cloudVisionScope];

class GoogleApiProvider {
  static Future<String> extractTextFromImage(String imgStr) async {
    print("before starting extract text from image");
    return clientViaServiceAccount(credentials, _scopes).then((httpClient) {
      final vision = VisionApi(httpClient);

      final r = BatchAnnotateImagesRequest();
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

      return vision.images.annotate(r).then((batchAnnotateImagesResponse) {
        return batchAnnotateImagesResponse
                .responses.single.textAnnotations.isEmpty
            ? ""
            : batchAnnotateImagesResponse
                .responses.single.fullTextAnnotation.text;
      });
    }, onError: (err) {
      print(err);
    }).catchError(print);
  }

  static Future<List<String>> extractKanjiFromImage(String imgStr) =>
      extractTextFromImage(imgStr)
          .then<List<String>>((text) => text.getKanjis());
}
