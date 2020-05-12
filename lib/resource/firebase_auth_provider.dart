import 'dart:async';
import 'dart:core';
import 'dart:convert';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

export 'package:firebase_auth/firebase_auth.dart';

enum SignInMethod { Apple, Google }

class FirebaseAuthProvider {
  FirebaseUser firebaseUser;

  static final instance = FirebaseAuthProvider._();

  FirebaseAuthProvider._();

  final Stream<FirebaseUser> onAuthStateChanged = FirebaseAuth.instance.onAuthStateChanged;

  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );

  Future uploadUser(FirebaseUser firebaseUser) async {
    return Firestore.instance.collection('users').document(firebaseUser.uid).setData({
      'email': firebaseUser.email,
    });
  }

  Future<FirebaseUser> registerNewUser(String email, String password) async {
    return FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password).then((AuthResult authResult) {
      //verify email address
      authResult.user.sendEmailVerification();

      saveEmailAndPassword(email, password);

      return authResult.user;
    });
  }

  Future<FirebaseUser> signInUser(String email, String password) async {
    return FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).then((AuthResult authResult) async {
      if (authResult.user.isEmailVerified || true) {
        firebaseUser = authResult.user;
        return firebaseUser;
      } else {
        firebaseUser = authResult.user;
        return firebaseUser;
        // return Future.value(null);
      }
    }).catchError((Object err) {
      print(err);
      throw err;
    });
  }

  ///Sign in user silently if previously signed in.
  Future<FirebaseUser> signInUserSilently() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    String email = sharedPrefs.getString('email');
    String password = sharedPrefs.getString('password');
    print(email);
    if (email != null && password != null) {
      print(email);
      return FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).then((AuthResult authResult) {
        firebaseUser = authResult.user;
        return firebaseUser;
      }).catchError((_) {});
    } else {
      return Future.value(null);
    }
  }

  Future signOut() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.remove('email');
    sharedPrefs.remove('password');
    firebaseUser = null;
    FirebaseAuth.instance.signOut();
  }

  Future forgetPassword(String email) async {
    FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<FirebaseUser> signInApple() async {
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

        if (appleIdCredential.email == null || (result.credential.fullName.familyName == null && result.credential.fullName.givenName == null)) {
          email = sharedPrefs.getString(emailKey);
          password = sharedPrefs.getString(passwordKey);

          if (email == null) {
            var snapshot = await Firestore.instance.collection('appleIdToEmail').document(userId).get();
            email = snapshot.data[emailKey];
            password = snapshot.data[passwordKey];
          }

          return firebaseAuth.signInWithEmailAndPassword(email: email, password: password).then((authResult) {
            this.firebaseUser = authResult.user;

            return authResult.user;
          }, onError: (PlatformException error) {
            ///TODO: The problem is that if names are null, email is going to be null as well.
            if (error.code == 'ERROR_USER_NOT_FOUND') {
              return registerNewUser(appleIdCredential.email, appleIdCredential.email).then((value) {
                saveEmailAndPassword(email, password);

                firebaseUser = value;

                return value;
              });
            }
            return null;
          });
        } else {
          return firebaseAuth.signInWithEmailAndPassword(email: email, password: password).then((authResult) {
            this.firebaseUser = authResult.user;

            return authResult.user;
          }, onError: (Object error) {
            ///TODO: The problem is that if names are null, email is going to be null as well.
            if (error is PlatformException) {
              if (error.code == 'ERROR_USER_NOT_FOUND') {
                return registerNewUser(appleIdCredential.email, appleIdCredential.email).then((firebaseUser) async {
                  saveEmailAndPassword(email, password);

                  return firebaseUser;
                }).whenComplete(() {
                  Firestore.instance.collection('appleIdToEmail').document(userId).setData({
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

  Future<FirebaseUser> signInGoogle() async {
    var firebaseAuth = FirebaseAuth.instance;
    GoogleSignInAccount googleSignInAccount;

    var googleUser = await googleSignIn.signIn().then((value) {
      googleSignInAccount = value;
      return value;
    }, onError: (_) {
      return null;
    });

    if (googleUser == null) return null;

    var email = googleUser.email;
    var password = email;

    return firebaseAuth.signInWithEmailAndPassword(email: email, password: email).then((authResult) {
      this.firebaseUser = authResult.user;

      return authResult.user;
    }, onError: (Object error) {
      if (error is PlatformException) {
        if (error.code == "ERROR_USER_NOT_FOUND") {
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
