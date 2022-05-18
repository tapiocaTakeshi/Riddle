import 'package:Riddle/screens/ProfileEditingPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/GoogleSignInModel.dart';

class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: AppBar(
            elevation: 1,
            title: Text(
              '設定',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1!.color),
            ),
            centerTitle: true,
          ),
        ),
        body: ListView(
          padding: EdgeInsets.all(24),
          children: [
            Divider(),
            ListTile(
              leading: Icon(Icons.logout_outlined),
              title: Text('ログアウト'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('プロフィール編集'),
              onTap: () async {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ProfileEditingPage()));
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.shield_outlined),
              title: Text('ブロックリスト'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.help_center_outlined),
              title: Text('ヘルプセンター'),
              onTap: () async {
                Navigator.of(context).pop();
              },
            ),
            Divider(),
          ],
        ));
  }
}
