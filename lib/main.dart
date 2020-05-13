import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ui/home_page.dart';
import 'ui/components/home_page_background.dart';
import 'package:kanji_dictionary/bloc/kanji_bloc.dart';
import 'resource/db_provider.dart';
import 'resource/firebase_auth_provider.dart';

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

    FirebaseAuthProvider.instance.signInUserSilently();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Manji',
        theme: ThemeData(primaryColor: Colors.grey[700], primarySwatch: Colors.grey),
        home: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          child: StreamBuilder(
              stream: kanjiBloc.allKanjis,
              builder: (_, __) {
                if (__.hasData) {
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
                        .whenComplete(FirebaseAuthProvider.instance.checkForUpdates);
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
              }),
        ));
  }
}
