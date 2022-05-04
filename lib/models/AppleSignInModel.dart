import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleSignInModel extends ChangeNotifier {
  Future signIn() async {
    try {
      final applecredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      OAuthProvider AppleAuthProvider = OAuthProvider('apple.com');
      final OAuthCredential credential = AppleAuthProvider.credential(
          idToken: applecredential.identityToken,
          accessToken: applecredential.authorizationCode);

      final result =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (result.additionalUserInfo!.isNewUser) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(result.user!.uid)
            .set({
          'name': 'Riddle Taro',
          'email': result.user!.email,
          'photoURL':
              'https://firebasestorage.googleapis.com/v0/b/riddle-b4b7b.appspot.com/o/Account.jpg?alt=media&token=97b13594-5418-4ddb-9823-abaf8e937da9',
          'MyRiddleList': [],
          'FavoriteRiddleList': [],
          'SubscribedChannelList': []
        });
      }
    } catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }
}
