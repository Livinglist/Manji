import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';

import 'components/furigana_text.dart';
import '../resource/repository.dart';
import '../resource/firebase_auth_provider.dart';
import '../resource/in_app_repo.dart';
import '../bloc/settings_bloc.dart';
import '../models/font_selection.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    InAppRepo().purchaseStream.listen((purchaseDetails) {
      for (var p in purchaseDetails) {
        print(p.error);
        print(p.productID);
        print(p.status);
        print(p.transactionDate);
      }
      if (purchaseDetails != null && purchaseDetails.isNotEmpty) {
        if (purchaseDetails.first.status != PurchaseStatus.pending) {
          InAppRepo().completePurchase(purchaseDetails.first);
        }
        if (purchaseDetails.first.status == PurchaseStatus.purchased) {
          showCoffeePurchasedDialog();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0,
        title: FuriganaText(
          text: '設定',
          tokens: [Token(text: '設定', furigana: 'せってい')],
          style: TextStyle(fontSize: 20),
        ),
      ),
      body: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          StreamBuilder(
            stream: FirebaseAuthProvider.instance.onAuthStateChanged,
            builder: (_, AsyncSnapshot<User> snapshot) {
              var user = snapshot.data;

              if (user != null) {
                return ListTile(
                  leading: Icon(
                    FontAwesomeIcons.signOut,
                    color: Colors.white,
                    size: 22,
                  ),
                  title:
                      Text('Sign out', style: TextStyle(color: Colors.white)),
                  subtitle:
                      Text(user.email, style: TextStyle(color: Colors.white)),
                  onTap: () => FirebaseAuthProvider.instance.signOut(),
                );
              }

              return ListTile(
                leading: Icon(
                  FontAwesomeIcons.signIn,
                  color: Colors.white,
                  size: 22,
                ),
                title: Text('Sign in', style: TextStyle(color: Colors.white)),
                onTap: () => getSignInMethod().then((method) {
                  switch (method) {
                    case SignInMethod.Apple:
                      FirebaseAuthProvider.instance.signInApple();
                      return;
                    case SignInMethod.Google:
                      FirebaseAuthProvider.instance.signInGoogle();
                      return;
                    default:
                      return;
                  }
                }),
              );
            },
          ),
          Divider(height: 0),
          StreamBuilder(
            stream: SettingsBloc.instance.fontSelection,
            builder: (_, snapshot) {
              var subtitle = '';

              if (snapshot.hasData) {
                switch (snapshot.data) {
                  case FontSelection.handwriting:
                    subtitle = 'Handwriting';
                    break;
                  case FontSelection.print:
                    subtitle = 'Print';
                    break;
                }
              }

              return ListTile(
                leading: Icon(
                    snapshot.data == FontSelection.print
                        ? FontAwesomeIcons.font
                        : FontAwesomeIcons.pen,
                    color: Colors.white),
                title: Text('Font', style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  subtitle,
                  style: TextStyle(color: Colors.white54),
                ),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) {
                        return StreamBuilder(
                          stream: SettingsBloc.instance.fontSelection,
                          builder: (_, snapshot) {
                            if (snapshot.hasData) {
                              final mode = snapshot.data;

                              return AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    RadioListTile(
                                      value: FontSelection.handwriting,
                                      groupValue: mode,
                                      onChanged: (val) =>
                                          SettingsBloc.instance.setFont(val),
                                      title: Text('Handwriting',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ),
                                    RadioListTile(
                                      value: FontSelection.print,
                                      groupValue: mode,
                                      onChanged: (val) =>
                                          SettingsBloc.instance.setFont(val),
                                      title: Text('Print',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Container();
                          },
                        );
                      });
                },
              );
            },
          ),
          Divider(height: 0),
          ListTile(
            leading: Icon(
              Icons.swap_horiz,
              color: Colors.white,
              size: 26,
            ),
            title:
                Text('Transfer my data', style: TextStyle(color: Colors.white)),
            subtitle: Text(
              'Transfer your data to a another device',
              style: TextStyle(color: Colors.white54),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  'Data Transfer is not yet available',
                  style: TextStyle(color: Colors.black),
                ),
                backgroundColor: Colors.yellow,
                action: SnackBarAction(
                    label: 'Dismiss',
                    onPressed: () =>
                        ScaffoldMessenger.of(context).hideCurrentSnackBar()),
              ));
            },
          ),
          Divider(height: 0),
          StreamBuilder(
            stream: SettingsBloc.instance.themeMode,
            builder: (_, snapshot) {
              var subtitle = '';

              if (snapshot.hasData) {
                switch (snapshot.data) {
                  case ThemeMode.system:
                    subtitle = 'System';
                    break;
                  case ThemeMode.light:
                    subtitle = 'Light';
                    break;
                  case ThemeMode.dark:
                    subtitle = 'Dark';
                    break;
                }
              }

              return ListTile(
                leading: Icon(Icons.stream, color: Colors.white),
                title: Text('Theme', style: TextStyle(color: Colors.white)),
                subtitle: Text(
                  subtitle,
                  style: TextStyle(color: Colors.white54),
                ),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) {
                        return StreamBuilder(
                          stream: SettingsBloc.instance.themeMode,
                          builder: (_, snapshot) {
                            if (snapshot.hasData) {
                              final mode = snapshot.data;

                              return AlertDialog(
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    RadioListTile(
                                      value: ThemeMode.light,
                                      groupValue: mode,
                                      onChanged: (val) => SettingsBloc.instance
                                          .setThemeMode(val),
                                      title: Text('Light',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ),
                                    RadioListTile(
                                      value: ThemeMode.dark,
                                      groupValue: mode,
                                      onChanged: (val) => SettingsBloc.instance
                                          .setThemeMode(val),
                                      title: Text('Dark',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ),
                                    RadioListTile(
                                      value: ThemeMode.system,
                                      groupValue: mode,
                                      onChanged: (val) => SettingsBloc.instance
                                          .setThemeMode(val),
                                      title: Text('System',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return Container();
                          },
                        );
                      });
                },
              );
            },
          ),
          Divider(height: 0),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            child: FutureBuilder(
              future: repo.getIsUpdated(),
              builder: (_, AsyncSnapshot<bool> snapshot) {
                if (snapshot.hasData) {
                  var isUpdated = snapshot.data;
                  if (isUpdated) {
                    return ListTile(
                      leading: Icon(Icons.wrap_text, color: Colors.white),
                      title: Text('Update database',
                          style: TextStyle(color: Colors.white)),
                      subtitle: Text(
                          'Keeping dictionary database up to date increases the accuracy and reliability \n(Your database is up to date)',
                          style: TextStyle(color: Colors.white54)),
                      onTap: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            'Your database is up to date',
                            style: TextStyle(color: Colors.black),
                          ),
                          backgroundColor: Theme.of(context).accentColor,
                          action: SnackBarAction(
                            label: 'Dismiss',
                            onPressed: () => ScaffoldMessenger.of(context)
                                .hideCurrentSnackBar(),
                            textColor: Colors.blueGrey,
                          ),
                        ));
                      },
                    );
                  } else {
                    return ListTile(
                        leading: Icon(Icons.wrap_text, color: Colors.white),
                        title: Text('Update database',
                            style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                            'Keeping dictionary database up to date increases the accuracy and reliability \n(Your database needs to be updated)',
                            style: TextStyle(color: Colors.white54)),
                        onTap: () {
                          repo.fetchUpdates().whenComplete(() {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                'Database has been updated successfully',
                                style: TextStyle(color: Colors.black),
                              ),
                              backgroundColor: Theme.of(context).accentColor,
                              action: SnackBarAction(
                                label: 'Dismiss',
                                onPressed: () => ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar(),
                                textColor: Colors.blueGrey,
                              ),
                            ));
                          });
                        });
                  }
                } else {
                  return ListTile(
                    leading: Icon(Icons.wrap_text, color: Colors.white),
                    title: Text('Update database',
                        style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                        'Keeping dictionary database up to date increases the accuracy and reliability',
                        style: TextStyle(color: Colors.white54)),
                  );
                }
              },
            ),
          ),
          Divider(height: 0),
          ListTile(
            leading: Icon(FontAwesomeIcons.coffeeTogo, color: Colors.brown),
            title:
                Text('Buy me a coffee', style: TextStyle(color: Colors.white)),
            subtitle: Text('If you like this app',
                style: TextStyle(color: Colors.white54)),
            onTap: () async {
              InAppRepo().purchaseCoffee();
            },
          ),
          Divider(height: 0),
          ListTile(
            leading: Icon(Icons.person, color: Colors.white),
            title: Text('About me', style: TextStyle(color: Colors.white)),
            onTap: () async {
              final url = Uri.encodeFull('https://github.com/Livinglist');

              if (await canLaunch(url)) {
                await launch(url, forceSafariVC: true, forceWebView: true);
              } else {
                throw 'Could not launch $url';
              }
            },
          ),
          Divider(height: 0),
          ListTileTheme(
              textColor: Colors.white70,
              child: AboutListTile(
                applicationIcon: Container(
                  height: 50,
                  width: 50,
                  child: Image.asset(
                    'data/1024.png',
                    fit: BoxFit.contain,
                  ),
                ),
                applicationName: "Manji",
                applicationVersion: "v2.5.6",
                aboutBoxChildren: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      launch("https://livinglist.github.io");
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(FontAwesomeIcons.addressCard),
                        SizedBox(
                          width: 12,
                        ),
                        Text("Developer"),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      launch("https://github.com/Livinglist/Manji");
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(FontAwesomeIcons.github),
                        SizedBox(
                          width: 12,
                        ),
                        Text("Source Code"),
                      ],
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  void showCoffeePurchasedDialog() {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('Thank You!'),
            content: Text('You just fed the developer a cup of coffee.'),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("You are welcome.")),
            ],
          );
        });
  }

  void appleLogIn() async {
    if (await AppleSignIn.isAvailable()) {
      final result = await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);
      switch (result.status) {
        case AuthorizationStatus.authorized:
          print(
              result.credential.user ?? "null"); //All the required credentials
          print(result.credential.fullName.familyName);
          break;
        case AuthorizationStatus.error:
          print("Sign in failed: ${result.error.localizedDescription}");
          break;
        case AuthorizationStatus.cancelled:
          print('User cancelled');
          break;
      }
    } else {
      print('Apple SignIn is not available for your device');
    }
  }

  Future<SignInMethod> getSignInMethod() {
    return showCupertinoModalPopup<SignInMethod>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
              message: Text("Sign In Via"),
              cancelButton: CupertinoActionSheetAction(
                isDefaultAction: true,
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context, null);
                },
              ),
              actions: <Widget>[
                CupertinoActionSheetAction(
                    child: Text('Apple', style: TextStyle(color: Colors.blue)),
                    onPressed: () =>
                        Navigator.pop(context, SignInMethod.Apple)),
                CupertinoActionSheetAction(
                    child: Text('Google', style: TextStyle(color: Colors.blue)),
                    onPressed: () =>
                        Navigator.pop(context, SignInMethod.Google)),
              ],
            )).then((value) => value ?? null);
  }
}
