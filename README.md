# Manji


![iOS](https://img.shields.io/badge/iOS-11%20-blue)
[![App Store](https://img.shields.io/itunes/v/1464774967?label=App%20Store)](https://apps.apple.com/us/app/manji-learn-kanji/id1464774967#?platform=iphone)
[![App Store](https://img.shields.io/badge/Price-Free-orange)](https://img.shields.io/badge/Price-Free-orange)
[![Play Store](https://img.shields.io/badge/Play%20Store--yellow)](https://play.google.com/store/apps/details?id=jiaqifeng.kanji_dictionary)
[![Visits Badge](https://badges.pufler.dev/visits/livinglist/Manji)](https://badges.pufler.dev)
[![GitHub](https://img.shields.io/github/stars/livinglist/Manji?style=social)](https://img.shields.io/github/stars/livinglist/Manji?style=social)
[![style: effective dart](https://img.shields.io/badge/style-effective_dart-40c4ff.svg)](https://pub.dev/packages/effective_dart)



<p align="center">
  <img width="360" alt="Screen Shot 2020-03-03 at 1 22 57 PM" src="https://user-images.githubusercontent.com/7277662/90493962-d5660b80-e0f7-11ea-9971-dba0951fd60e.png"> 
  <img width="360" alt="Screen Shot 2020-08-20 at 6 16 26 PM" src="https://user-images.githubusercontent.com/7277662/90866236-75b26f00-e348-11ea-82e9-b8af9fd98b3d.png">
<img width="360" alt="Screen Shot 2020-08-20 at 6 16 43 PM" src="https://user-images.githubusercontent.com/7277662/90866275-81059a80-e348-11ea-909d-f2fd1141959c.png">
  <img width="360" alt="Screen Shot 2020-03-03 at 1 25 18 PM" src="https://user-images.githubusercontent.com/7277662/90494379-4d343600-e0f8-11ea-82c2-f462beb91396.png">
<img width="360" alt="Screen Shot 2020-08-20 at 6 21 33 PM" src="https://user-images.githubusercontent.com/7277662/90866315-8e228980-e348-11ea-9df3-35cbcdc71e26.png">
<img width="360" alt="Screen Shot 2020-08-20 at 6 21 48 PM" src="https://user-images.githubusercontent.com/7277662/90866324-8fec4d00-e348-11ea-8d88-e55d66173563.png">
<img width="360" alt="Screen Shot 2020-08-20 at 6 16 50 PM" src="https://user-images.githubusercontent.com/7277662/90866266-7f3bd700-e348-11ea-9bf6-d5a2434f205a.png">
<img width="360" alt="Screen Shot 2020-04-19 at 5 59 00 PM" src="https://user-images.githubusercontent.com/7277662/90494393-51f8ea00-e0f8-11ea-8645-97dd3136844f.png">
  <img width="360" alt="Screen Shot 2020-04-19 at 6 04 58 PM" src="https://user-images.githubusercontent.com/7277662/108948794-029bf500-7618-11eb-9903-ce7a1641f346.png">
<img width="360" alt="Screen Shot 2020-04-20 at 8 01 24 PM" src="https://user-images.githubusercontent.com/7277662/90494401-53c2ad80-e0f8-11ea-8aec-70ebe5e3cb61.png">
</p>


On the surface, Manji is just a Japanese dictionary, but it can actually do more than that:

- Handwritten kanji recognition
- Image kanji extraction
- Kanji card
- Kanji quiz generated dynamically based on selected groups of kanji

Therotically, Manji is cross-platform since it is powered by Flutter, but since I want to maximize the elegance of its user experience and also because I am an Apple fanboy to some degree, I chose to focus on the iOS side. I have already forgotten when the last time was that I debugged and tested on Android but feel free if you want to make it work and optimize for Android.

## Getting Started

1. Because the dictionary file exceeds the size limit of Github, `git-lfs` is used for storing the dictionary file. So make sure you have installed `git-lfs`.
2. Clone this project and run `git-lfs fetch --all` in the project root folder.
3. [Create a service account](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances).
4. Fill up the credential as shown below and save it as `google_api_credentials.dart` and move to Manji/lib/resource/.

```dart
import 'package:googleapis_auth/auth_io.dart';

final credentials = ServiceAccountCredentials.fromJson(r'''
{
  "type": "service_account",
  "project_id": "",
  "private_key_id": "",
  "private_key": "-----BEGIN PRIVATE KEY-----\n-----END PRIVATE KEY-----\n",
  "client_email": "",
  "client_id": "",
  "auth_uri": "",
  "token_uri": "",
  "auth_provider_x509_cert_url": "",
  "client_x509_cert_url": ""
}
''');
```

5. [Setup Firebase for your project.](https://console.firebase.google.com/)
6. (iOS) Download your `GoogleService-Info.plist` and move it to Manji/ios/Runner/.
6. (Android) Download your `google-services.json` and move it to Manji/android/app/.
7. Run the project using `flutter run`.
