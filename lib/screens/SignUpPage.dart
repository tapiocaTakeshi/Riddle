import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../models/AppleSignInModel.dart';
import '../models/GoogleSignInModel.dart';

class SignUpPage extends StatelessWidget {
  final url =
      'https://higuchiyuya-riddle.hatenablog.com/entry/2022/05/03/234027?_ga=2.186036073.1388920404.1651588780-1098742724.1651226562';
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
                      child: Image.asset(
                        MediaQuery.platformBrightnessOf(context) ==
                                Brightness.dark
                            ? 'assets/images/RiddleLogo_DarkMode.png'
                            : 'assets/images/RiddleLogo_LightMode.png',
                        height: 40,
                      ),
                    ),
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
                    darkMode: MediaQuery.platformBrightnessOf(context) ==
                        Brightness.dark,
                  )),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppleAuthButton(
                    onPressed: () async {
                      final provider =
                          Provider.of<AppleSignInModel>(context, listen: false);
                      provider.signIn();
                    },
                    darkMode: MediaQuery.platformBrightnessOf(context) ==
                        Brightness.dark,
                  )),
              TextButton(
                  onPressed: () async {
                    final canLaunch = await canLaunchUrlString(url);
                    if (canLaunch) {
                      launchUrlString(url);
                    }
                  },
                  child: Text('利用規約'))
            ],
          ),
        ),
      ),
    );
  }
}
