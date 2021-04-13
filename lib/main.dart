import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_siri_suggestions/flutter_siri_suggestions.dart';
import 'package:feature_discovery/feature_discovery.dart';

import 'bloc/settings_bloc.dart';
import 'ui/home_page.dart';
import 'ui/components/home_page_background.dart';
import 'bloc/kanji_bloc.dart';
import 'bloc/siri_suggestion_bloc.dart';
import 'resource/db_provider.dart';
import 'resource/firebase_auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool initialized = false;
  CrossFadeState crossFadeState = CrossFadeState.showSecond;

  @override
  void initState() {
    super.initState();

    //This is for Siri suggestion.
    FlutterSiriSuggestions.instance.configure(
        onLaunch: (Map<String, dynamic> message) async {
      String siriKanji = message['key'];
      print("Siri suggestion kanji is $siriKanji");
      SiriSuggestionBloc.instance.suggest(siriKanji);
    });

    SettingsBloc.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    return FeatureDiscovery(
      child: StreamBuilder(
        stream: SettingsBloc.instance.themeMode,
        initialData: ThemeMode.system,
        builder: (_, themeSnapshot) {
          final themeMode = themeSnapshot.data;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Manji',
            theme: ThemeData(
                primaryColor: Colors.grey[700], primarySwatch: Colors.grey),
            darkTheme: ThemeData(
                primaryColor: Colors.black, primarySwatch: Colors.grey),
            themeMode: themeMode,
            home: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              child: FutureBuilder(
                future: DBProvider.db.initDB(),
                builder: (_, dbSnapshot) {
                  if (dbSnapshot.hasData) {
                    return StreamBuilder(
                      stream: KanjiBloc.instance.allKanjis,
                      builder: (_, snapshot) {
                        if (snapshot.hasData) {
                          return HomePage();
                        } else {
                          KanjiBloc.instance.getAllKanjis();
                          FirebaseAuthProvider.instance.checkForUpdates();
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
                                    centerTitle: false,
                                  ),
                                  drawer: Container(),
                                  body: HomePageBackground());
                        }
                      },
                    );
                  }

                  return Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
