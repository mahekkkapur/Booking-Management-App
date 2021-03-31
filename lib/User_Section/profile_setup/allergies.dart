import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econoomaccess/common/Loading/loading.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

bool load = false;

class Allergies extends StatefulWidget {
  @override
  _AllergiesState createState() => _AllergiesState();
}

class _AllergiesState extends State<Allergies> {
  final database = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _currentAllergy = '';

  List<String> _allergyList = [];

  final _controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return load ? Loading() : Scaffold(
        //key: key,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
                size: 25.0,
              ),
              onPressed: () {
              }),
          elevation: 0.0,
          backgroundColor: Color(0xFFFF9F9F9),
        ),
        body: Container(
            color: Color(0xFFFF9F9F9),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.all(20.0),
                    child: Text(
                      "Allergies",
                      style: TextStyle(
                          fontSize: 20.0,
                          fontFamily: "Gilroy",
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    margin:
                        EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                    child: Text(
                      "If you have any allergies, mention them here and  we will warn you every time you order something having that item.",
                      style: TextStyle(
                          fontSize: 15.0,
                          fontFamily: "Gilroy",
                          color: Colors.black),
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                            left: 10, top: 5, bottom: 5, right: 10),
                        height: 52,
                        width: width,
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              _currentAllergy = val;
                            });
                          },
                          controller: _controller,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                _allergyList.add(_currentAllergy);
                                _currentAllergy = '';
                                _controller.clear();
                              },
                            ),
                            fillColor: Colors.white70,
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black38, width: 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black54, width: 1.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black54, width: 1.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6.0)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                      height: height / 2,
                      child: GridView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: _allergyList.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 0,
                          ),
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.only(
                                  left: 10.0, right: 10, top: 30, bottom: 30),
                              width: MediaQuery.of(context).size.width / 2.2,
                              height: 10,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFFF6530),
                                        Color(0xFFFE4E74)
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        spreadRadius: 3)
                                  ],
                                  borderRadius: BorderRadius.circular(15.0)),
                              child: Center(
                                child: Text(
                                  _allergyList[index],
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Gilroy",
                                      color: Colors.white,
                                      fontSize: 20),
                                ),
                              ),
                            );
                          })),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          load = true;
                        });
                        _auth.onAuthStateChanged.listen((user) async {
                          await database
                              .collection("users")
                              .document(user.uid)
                              .updateData(
                                  {"allergies": _allergyList}).whenComplete(() {
                            Navigator.pushReplacementNamed(
                                context, "/UserAddProfilePhotoPage",
                                arguments: user.uid);
                          });
                        });
                      },
                      child: Container(
                        width: 60.0,
                        height: 60.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            gradient: LinearGradient(
                                colors: [Color(0xFFFF6530), Color(0xFFFE4E74)],
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
                  SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            load = true;
                          });
                          var temp = [];

                          _auth.onAuthStateChanged.listen((user) async {
                            await database
                                .collection("users")
                                .document(user.uid)
                                .updateData({"allergies": temp}).whenComplete(
                                    () {
                              Navigator.pushReplacementNamed(
                                  context, "/UserAddProfilePhotoPage",
                                  arguments: user.uid);
                            });
                          });
                        },
                        child: Text(
                          "Skip this step",
                          style: TextStyle(
                              fontFamily: "Gilroy",
                              fontSize: 13.0,
                              color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ]))));
  }
}
