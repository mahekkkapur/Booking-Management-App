import 'package:flutter/material.dart';
import 'package:econoomaccess/localization/language_constants.dart';
import 'package:econoomaccess/main.dart';
import 'package:econoomaccess/localization/language.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;
  var _language, uid;
  Language language;
  void _changeLanguage(Language language) async {
    Locale _locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, _locale);
  }

  void getData() async {
    var temp;
    _auth.onAuthStateChanged.listen((user) async {
      temp = await firestore.collection('users').document(user.uid).get();
      setState(() {
        uid = user.uid;
        _language = temp.data['language'];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            getTranslated(context, "settings") ?? "",
            style: TextStyle(
                color: Colors.black,
                fontFamily: "Gilroy",
                fontWeight: FontWeight.bold),
          ),
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.grey[50],
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                      child: Text(getTranslated(context, "language") ?? "",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold))),
                  Container(
                    width: 100.0,
                    height: 50.0,
                    decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12.0)),
                    child: Center(
                      child: DropdownButton<Language>(
                        hint: Text(_language),
                        style: TextStyle(
                          color: Color.fromRGBO(38, 50, 56, 0.30),
                          fontSize: 15.0,
                          fontFamily: "Gilroy",
                        ),
                        underline: SizedBox(),
                        onChanged: (Language language) {
                          print(language.name);
                          firestore
                              .collection("users")
                              .document(uid)
                              .updateData(
                                  {"language": language.name}).whenComplete(() {
                            getData();
                            _changeLanguage(language);
                          });
                        },
                        items: Language.languageList()
                            .map<DropdownMenuItem<Language>>(
                              (e) => DropdownMenuItem<Language>(
                                value: e,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      e.name,
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
