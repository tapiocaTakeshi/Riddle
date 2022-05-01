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
          'name': result.user!.displayName,
          'email': result.user!.email,
          'photoURL': result.user!.photoURL,
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
