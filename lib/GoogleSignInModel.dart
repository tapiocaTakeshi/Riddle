import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInModel extends ChangeNotifier{

  GoogleSignInAccount _user;

  GoogleSignInAccount get user => _user;




  Future signIn() async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
      if(googleUser == null)return;
      _user = googleUser;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken
      );

      final result = await FirebaseAuth.instance.signInWithCredential(credential);

      if(result.additionalUserInfo.isNewUser){
        await FirebaseFirestore.instance.collection('Users').doc(result.user.uid).set({
          'name':result.user.displayName,
          'email':result.user.email,
          'MyRiddleList':[],
          'FavoriteRiddleList':[],
          'History':[]
        });
      }

    } catch(e){
      print(e.toString());
    }
    notifyListeners();
  }

  Future signOut() async {
    await GoogleSignIn().disconnect();
    FirebaseAuth.instance.signOut();
  }
}