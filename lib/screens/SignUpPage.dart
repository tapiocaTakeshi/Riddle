import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../GoogleSignInModel.dart';


class SignUpPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      color: Colors.white,
      child: Center(
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Material(
              color: Colors.white,
              child: Text('Welcome to ',
                  style: TextStyle(fontSize: 32,color: Colors.black,fontWeight: FontWeight.w400)
              ),
            ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                    height: 40,
                    child: Image.asset('assets/images/RiddleLogo.jpg')
                ),
              ),],),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                child: Text('ログイン',style: TextStyle(fontWeight: FontWeight.bold),),
                style: TextButton.styleFrom(
                  primary: Colors.blueAccent
                ),
                onPressed: (){
                  final provider = Provider.of<GoogleSignInModel>(context,listen: false);
                  provider.signIn();
                },
              ),
            ),
          ],
        ),
      ),
    );
    }
}