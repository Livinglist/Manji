import 'dart:io';

import 'package:feature_discovery/feature_discovery.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_siri_suggestions/flutter_siri_suggestions.dart';

import 'bloc/kanji_bloc.dart';
import 'bloc/settings_bloc.dart';
import 'bloc/siri_suggestion_bloc.dart';
import 'resource/db_provider.dart';
import 'resource/firebase_auth_provider.dart';
import 'ui/components/home_page_background.dart';
import 'ui/home_page.dart';

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
    FlutterSiriSuggestions.instance.configure(onLaunch: (message) async {
      final String siriKanji = message['key'];
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
              duration: const Duration(milliseconds: 300),
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
                              ? const Scaffold(
                                  body: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : Scaffold(
                                  appBar: AppBar(
                                    elevation: 0,
                                    title: const Text('Manji'),
                                    centerTitle: false,
                                  ),
                                  drawer: Container(),
                                  body: HomePageBackground());
                        }
                      },
                    );
                  }

                  return const Scaffold(
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
