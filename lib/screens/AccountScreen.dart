
import 'dart:ui';

import 'package:Riddle/screens/AccountPage.dart';
import 'package:Riddle/screens/SignUpPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'DetailPage.dart';
import 'package:animations/animations.dart';
import '../GoogleSignInModel.dart';

class AccountScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=>AccountScreenState();
}

class AccountScreenState extends State<AccountScreen> {

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return StreamBuilder<User>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context,snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator());
        }else if(snapshot.hasData){
          return AccountPage();
        }else if(snapshot.hasError){
          return Center(child: Text("ログインできませんでした"));
        }else{
          return SignUpPage();
        }
      },
    );
  }
}

