import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../GoogleSignInModel.dart';

class SignUpPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(backgroundColor: Colors.white,elevation: 1, centerTitle: false,),
      body: Center(
        child: RaisedButton(onPressed: () async {
          final provider = Provider.of<GoogleSignInModel>(context,listen: false);
          provider.signInWithGoogle();
        }),
      ),
    );
    }
}