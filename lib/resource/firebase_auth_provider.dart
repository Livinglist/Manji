import 'dart:async';
import 'dart:core';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../resource/firestore_provider.dart';

export 'package:firebase_auth/firebase_auth.dart';

enum SignInMethod { Apple, Google }

class FirebaseAuthProvider {
  User get firebaseUser => FirebaseAuth.instance.currentUser;

  static final instance = FirebaseAuthProvider._();

  FirebaseAuthProvider._();

  Stream<User> get onAuthStateChanged =>
      FirebaseAuth.instance.authStateChanges();

  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );

  Future checkForUpdates() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirestoreProvider.instance.isUpgradable().then((isUpgradable) {
        if (isUpgradable) {
          FirestoreProvider.instance.fetchAll();
        }
      });
    }
  }

  Future uploadUser(User firebaseUser) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(firebaseUser.uid)
        .set({
      'email': firebaseUser.email,
    });
  }

  Future<User> registerNewUser(String email, String password) async {
    return FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((UserCredential cred) {
      //verify email address
      cred.user.sendEmailVerification();

      saveEmailAndPassword(email, password);

      FirebaseFirestore.instance
          .collection(usersKey)
          .doc(cred.user.uid)
          .set({}).whenComplete(FirestoreProvider.instance.uploadAll);
      return cred.user;
    });
  }

  Future<User> signInUser(String email, String password) async {
    return FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((UserCredential cred) async {
      if (cred.user.emailVerified || true) {
        var firebaseUser = cred.user;
        return firebaseUser;
      } else {
        var firebaseUser = cred.user;
        return firebaseUser;
      }
    }).catchError((Object err) {
      print(err);
      throw err;
    });
  }

  Future signOut() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.remove('email');
    sharedPrefs.remove('password');
    FirebaseAuth.instance.signOut();
  }

  Future forgetPassword(String email) async {
    FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<User> signInApple() async {
    var firebaseAuth = FirebaseAuth.instance;
    var sharedPrefs = await SharedPreferences.getInstance();

    if (await AppleSignIn.isAvailable()) {
      final result = await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      if (result.status == AuthorizationStatus.authorized) {
        var appleIdCredential = result.credential;

        var userId = appleIdCredential.user;

        var email = appleIdCredential.email;
        var password = appleIdCredential.email;

        if (appleIdCredential.email == null ||
            (result.credential.fullName.familyName == null &&
                result.credential.fullName.givenName == null)) {
          email = sharedPrefs.getString(emailKey);
          password = sharedPrefs.getString(passwordKey);

          if (email == null) {
            var snapshot = await FirebaseFirestore.instance
                .collection('appleIdToEmail')
                .doc(userId)
                .get();
            email = snapshot.data()[emailKey];
            password = snapshot.data()[passwordKey];
          }

          return firebaseAuth
              .signInWithEmailAndPassword(email: email, password: password)
              .then((cred) {
            FirestoreProvider.instance.isUpgradable().then((isUpgradable) {
              if (isUpgradable) {
                FirestoreProvider.instance.fetchAll();
              }
            });

            return cred.user;
          }, onError: (error) {
            ///TODO: The problem is that if names are null, email is going to be null as well.
            print(error.runtimeType);
            if (error.code == 'ERROR_USER_NOT_FOUND') {
              return registerNewUser(
                      appleIdCredential.email, appleIdCredential.email)
                  .then((value) {
                saveEmailAndPassword(email, password);

                return value;
              });
            }
            return null;
          });
        } else {
          return firebaseAuth
              .signInWithEmailAndPassword(email: email, password: password)
              .then((cred) {
            return cred.user;
          }, onError: (Object error) {
            if (error is FirebaseAuthException) {
              if (error.code == 'user-not-found') {
                return registerNewUser(
                        appleIdCredential.email, appleIdCredential.email)
                    .then((firebaseUser) async {
                  saveEmailAndPassword(email, password);

                  return firebaseUser;
                }).whenComplete(() {
                  FirebaseFirestore.instance
                      .collection('appleIdToEmail')
                      .doc(userId)
                      .set({
                    'email': email,
                    'password': password,
                  });
                });
              }
            }
            return null;
          });
        }
      } else {
        return Future.value(null);
      }
    } else {
      print('Apple SignIn is not available for your device');
      return Future.value(null);
    }
  }

  Future<User> signInGoogle() async {
    var firebaseAuth = FirebaseAuth.instance;

    var googleUser = await googleSignIn.signIn().then((value) {
      return value;
    }, onError: (_) {
      return null;
    });

    if (googleUser == null) return null;

    var email = googleUser.email;
    var password = email;

    return firebaseAuth
        .signInWithEmailAndPassword(email: email, password: email)
        .then((cred) {
      FirestoreProvider.instance.isUpgradable().then((isUpgradable) {
        if (isUpgradable) {
          FirestoreProvider.instance.fetchAll();
        }
      });

      return cred.user;
    }, onError: (Object error) {
      if (error is FirebaseAuthException) {
        if (error.code == "user-not-found") {
          return registerNewUser(email, password).then((firebaseUser) {
            saveEmailAndPassword(email, password);

            return firebaseUser;
          });
        }
      }
      return null;
    });
  }

  ///Store the email and password in shared preferences
  static Future saveEmailAndPassword(String email, String password) async {
    final sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setString(emailKey, email);
    sharedPrefs.setString(pwKey, password);
  }
}

const String isSelfKey = 'isSelf';
const String usersKey = 'users';
const String messagesKey = 'messages';
const String postsKey = 'post';
const String chatsKey = 'chats';
const String senderIdKey = 'sender';
const String msgKey = 'messages';
const String timestampKey = 'timestamp';
const String emailKey = 'email';
const String passwordKey = 'password';
const String pwKey = 'password';
const String msgTextKey = 'text';
