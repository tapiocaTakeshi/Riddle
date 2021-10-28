import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInModel extends ChangeNotifier{

  GoogleSignInAccount _user;

  GoogleSignInAccount get user => _user;




  Future signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    if(googleUser == null)return;
    _user = googleUser;
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    notifyListeners();
  }
}