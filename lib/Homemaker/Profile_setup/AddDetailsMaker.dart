import 'package:flutter/material.dart';
import 'dart:async';
import 'package:econoomaccess/localization/language.dart';
import 'package:econoomaccess/localization/language_constants.dart';
import 'package:econoomaccess/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:econoomaccess/common/Loading/loading.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

bool load = false;

class AddDetailsMaker extends StatefulWidget {
  @override
  _AddDetailsMakerState createState() => _AddDetailsMakerState();
}

class _AddDetailsMakerState extends State<AddDetailsMaker> {
  String lang = "Please Select Your Language";
  Language language;
  void _changeLanguage(Language language) async {
    Locale _locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, _locale);
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;
  var _value;

  String _buissnessname, _name, _dob = "Select Date";
  bool _delivery = true;

  nextPage() {
    var menu = [];

    if (_formKey.currentState.validate()) {
      setState(() {
        load = true;
      });
      _formKey.currentState.save();
      _auth.onAuthStateChanged.listen((user) async {
        String token = await FirebaseMessaging().getToken();
        firestore.collection('homemakers').document(user.uid).setData({
          'name': _name,
          'buissnessname': _buissnessname,
          'dob': _dob,
          'language': lang,
          'menu': menu,
          'orders': menu,
          'userType': "homemaker",
          'mobileno': user.phoneNumber,
          "rating": 0,
          "delivery": _delivery,
          "payouts": menu,
          "mealtype": ['Any'],
          '5StarReviews': 0,
          'createdate': Timestamp.now(),
          'token': token,
        });
        firestore.collection('promotion').document(user.uid).setData({
          'promotion': menu,
        }).whenComplete(() {
          Navigator.pushReplacementNamed(context, "/BuissnessLocationPage");
        });
      });
    }
  }

  var selectedDate = DateTime.now();
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(selectedDate.year - 100, 1),
        lastDate: DateTime(selectedDate.year + 1));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        _dob = "${selectedDate.toLocal()}".split(' ')[0];
      });
  }

  @override
  Widget build(BuildContext context) {
    return load
        ? Loading
        : Scaffold(
            backgroundColor: Color(0xffF9F9F9),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 50),
                    Text(
                      getTranslated(context, "details"),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Gilroy",
                        fontSize: 30.0,
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
                              style: TextStyle(
                                  color: Color.fromRGBO(38, 50, 56, .50)),
                              validator: (input) {
                                RegExp re = RegExp(r'^[a-zA-Z\s]+$');
                                if (!re.hasMatch(input) || input.isEmpty) {
                                  // print(input);
                                  return getTranslated(context, "enterMob");
                                }
                                return null;
                              },
                              onSaved: (input) => _buissnessname = input,
                              decoration: InputDecoration(
                                hintText: getTranslated(context, "enterbuiss"),
                                hintStyle: TextStyle(
                                  color: Color.fromRGBO(38, 50, 56, 0.30),
                                  fontSize: 15.0,
                                  fontFamily: "Gilroy",
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 1.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 1.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6.0)),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            TextFormField(
                              style: TextStyle(
                                  color: Color.fromRGBO(38, 50, 56, .50)),
                              validator: (input) {
                                RegExp re = RegExp(r'^[a-zA-Z]+( [a-zA-Z]+)*$');
                                if (!re.hasMatch(input) || input.isEmpty) {
                                  // print(input);
                                  return getTranslated(context, "enterMob");
                                }
                                return null;
                              },
                              onSaved: (input) => _name = input,
                              decoration: InputDecoration(
                                hintText: getTranslated(context, "enterMob"),
                                hintStyle: TextStyle(
                                  color: Color.fromRGBO(38, 50, 56, 0.30),
                                  fontSize: 15.0,
                                  fontFamily: "Gilroy",
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 1.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white, width: 1.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6.0)),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: TextFormField(
                                    enabled: false,
                                    style: TextStyle(
                                        color: Color.fromRGBO(38, 50, 56, .50)),
                                    validator: (input) {
                                      if (_dob == "Select Date") {
                                        return "Select Date";
                                      }
                                      return null;
                                    },
                                    onSaved: (input) => _dob =
                                        "${selectedDate.toLocal()}"
                                            .split(' ')[0],
                                    decoration: InputDecoration(
                                      hintText: "${_dob}",
                                      hintStyle: TextStyle(
                                        color: Color.fromRGBO(38, 50, 56, 0.30),
                                        fontSize: 15.0,
                                        fontFamily: "Gilroy",
                                      ),
                                      errorStyle: TextStyle(
                                        color: Colors.red,
                                        fontFamily: "Gilroy",
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 20.0),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.0)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.0)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.white, width: 1.0),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(6.0)),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                GestureDetector(
                                    onTap: () {
                                      _selectDate(context);
                                      print("${selectedDate.toLocal()}"
                                          .split(' ')[0]);
                                    },
                                    child: Icon(Icons.calendar_today))
                              ],
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 50.0,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Center(
                                child: DropdownButton<Language>(
                                  hint: Text(lang),
                                  style: TextStyle(
                                    color: Color.fromRGBO(38, 50, 56, 0.30),
                                    fontSize: 15.0,
                                    fontFamily: "Gilroy",
                                  ),
                                  underline: SizedBox(),
                                  onChanged: (Language language) {
                                    _changeLanguage(language);
                                    setState(() {
                                      lang = language.name;
                                    });
                                  },
                                  items: Language.languageList()
                                      .map<DropdownMenuItem<Language>>(
                                        (e) => DropdownMenuItem<Language>(
                                          value: e,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                e.name,
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 50.0,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.0)),
                              child: Center(
                                child: DropdownButton<String>(
                                  value: _value,
                                  hint: Text(
                                      "Do you want to provide delivery facilities ?"),
                                  style: TextStyle(
                                    color: Color.fromRGBO(38, 50, 56, 0.30),
                                    fontSize: 15.0,
                                    fontFamily: "Gilroy",
                                  ),
                                  underline: SizedBox(),
                                  onChanged: (value) {
                                    setState(() {
                                      _delivery = value == "True";
                                    });
                                  },
                                  items: [
                                    DropdownMenuItem(
                                      value: "True",
                                      child: Text(
                                        "Yes",
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: "False",
                                      child: Text(
                                        "No",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  nextPage();
                                },
                                child: Container(
                                  width: 60.0,
                                  height: 60.0,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFF6530),
                                            Color(0xFFFE4E74)
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter)),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 30.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                          ]),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
