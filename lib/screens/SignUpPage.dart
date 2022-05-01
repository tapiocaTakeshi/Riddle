import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../models/AppleSignInModel.dart';
import '../models/GoogleSignInModel.dart';

class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Material(
      child: Container(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome to ',
                      style: TextStyle(
                          fontSize: 32,
                          color: Theme.of(context).textTheme.bodyText1!.color,
                          fontWeight: FontWeight.w400)),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                        height: 40,
                        child: Image.asset('assets/images/RiddleLogo.png')),
                  ),
                ],
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GoogleAuthButton(
                    onPressed: () {
                      final provider = Provider.of<GoogleSignInModel>(context,
                          listen: false);
                      provider.signIn();
                    },
                  )),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppleAuthButton(
                    onPressed: () async {
                      final provider =
                          Provider.of<AppleSignInModel>(context, listen: false);
                      provider.signIn();
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
