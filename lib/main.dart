import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_siri_suggestions/flutter_siri_suggestions.dart';
import 'package:kanji_dictionary/resource/firebase_api_provider.dart';

import 'ui/home_page.dart';
import 'ui/components/home_page_background.dart';
import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import 'resource/db_provider.dart';
import 'resource/firebase_auth_provider.dart';
import 'bloc/siri_suggestion_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool initialized = false;
  CrossFadeState crossFadeState = CrossFadeState.showSecond;
  Widget child = Platform.isAndroid
      ? Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        )
      : Scaffold(
          appBar: AppBar(
            title: Text('Manji'),
          ),
          body: HomePageBackground());

  @override
  void initState() {
    super.initState();

    //This is for Siri suggestion.
    FlutterSiriSuggestions.instance.configure(
        onLaunch: (Map<String, dynamic> message) async {
      String siriKanji = message['key'];
      SiriSuggestionBloc.instance.suggest(siriKanji);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Manji',
        theme: ThemeData(
            primaryColor: Colors.grey[700], primarySwatch: Colors.grey),
        home: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          child: FutureBuilder(
            future: Firebase.initializeApp(),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                return StreamBuilder(
                    stream: kanjiBloc.allKanjis,
                    builder: (_, __) {
                      if (__.hasData) {
                        firebaseApiProvider
                            .fetchAllSentencesFromJishoByAllKanjis();
                        return HomePage();
                      } else {
                        if (!initialized) {
                          initialized = true;
                          kanjiBloc.getAllKanjis();
                          FirebaseAuthProvider.instance.checkForUpdates();
                        } else {
                          DBProvider.db
                              .initDB(refresh: true)
                              .whenComplete(kanjiBloc.getAllKanjis)
                              .whenComplete(FirebaseAuthProvider
                                  .instance.checkForUpdates);
                        }
                        return Platform.isAndroid
                            ? Scaffold(
                                body: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : Scaffold(
                                appBar: AppBar(
                                  elevation: 0,
                                  title: Text('Manji'),
                                ),
                                body: HomePageBackground());
                      }
                    });
              } else
                return Container();
            },
          ),
        ));
  }
}
