import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class ReportPage extends StatefulWidget {
  String id;
  ReportPage(this.id);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formkey = GlobalKey<FormState>();
  String _name = '';
  String _emailaddress = '';
  String _reportUserName = '';
  String _content = '';
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: AppBar(
            elevation: 1,
            title: Text(
              'ユーザー報告フォーム',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText1!.color),
            ),
          ),
        ),
        body: Form(
            key: _formkey,
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('氏名'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        autofocus: true,
                        decoration:
                            InputDecoration(border: OutlineInputBorder()),
                        onSaved: (value) => setState(() {
                          _name = value!;
                        }),
                        validator: (value) => value!.isEmpty ? '必須入力です' : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('メールアドレス'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        autofocus: true,
                        decoration:
                            InputDecoration(border: OutlineInputBorder()),
                        onSaved: (value) => setState(() {
                          _emailaddress = value!;
                        }),
                        validator: (value) => value!.isEmpty
                            ? '必須入力です'
                            : !value.contains('@')
                                ? 'アットマーク「＠」がありません'
                                : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('報告ユーザー名'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        autofocus: true,
                        decoration:
                            InputDecoration(border: OutlineInputBorder()),
                        onSaved: (value) => setState(() {
                          _reportUserName = value!;
                        }),
                        validator: (value) => value!.isEmpty ? '必須入力です' : null,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('内容'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        autofocus: true,
                        minLines: 10,
                        maxLines: 10,
                        decoration:
                            InputDecoration(border: OutlineInputBorder()),
                        onSaved: (value) => setState(() {
                          _content = value!;
                        }),
                        validator: (value) => value!.isEmpty ? '必須入力です' : null,
                      ),
                    ),
                    Center(
                        child: ElevatedButton(
                      onPressed: () async {
                        if (_formkey.currentState!.validate()) {
                          _formkey.currentState!.save();
                          final Email email = Email(
                              body:
                                  '氏名\n${_name}\n\nメールアドレス\n${_emailaddress}\n\n報告ユーザー名\n${_reportUserName}\n\n報告コンテンツID\n${widget.id}\n\n内容\n${_content}',
                              subject: 'ユーザー報告',
                              recipients: ['higuchiyuya.riddle@gmail.com']);
                          await FlutterEmailSender.send(email);
                        }
                      },
                      child: Text('送信'),
                    ))
                  ]),
            )),
      ),
    );
  }
}
