import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econoomaccess/common/Loading/loading.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:econoomaccess/localization/language_constants.dart';

bool load = false;

class FoodPref extends StatefulWidget {
  @override
  _FoodPrefState createState() => _FoodPrefState();
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

final database = Firestore.instance;

class _FoodPrefState extends State<FoodPref> {
  List<Map<String, dynamic>> prefs = [
    {"name": "VEG", "preference": false},
    {"name": "NON VEG", "preference": false},
    {"name": "Quick Snacks", "preference": false},
    {"name": "Baked", "preference": false},
    {"name": "Coffee", "preference": false},
    {"name": "Chinese", "preference": false},
    {"name": "North Indian", "preference": false},
    {"name": "South Indian", "preference": false},
    {"name": "Pizzas/Pastas", "preference": false},
    {"name": "Meal Combos", "preference": false},
    {"name": "Finger Food", "preference": false},
    {"name": "Wraps/Rolls", "preference": false},
  ];

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final key = new GlobalKey<ScaffoldState>();

    return load ? Loading() : Scaffold(
      key: key,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 25.0,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/UserDetailsPage");
            }),
        elevation: 0.0,
        backgroundColor: Color(0xFFFF9F9F9),
      ),
      body: Container(
        color: Color(0xFFFF9F9F9),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.all(20.0),
              child: Text(
                getTranslated(context, "foodpref"),
                style: TextStyle(
                    fontSize: 20.0,
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.w700,
                    color: Colors.black),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
              child: Text(
                getTranslated(context, "foodprefcontent"),
                style: TextStyle(
                    fontSize: 15.0, fontFamily: "Gilroy", color: Colors.black),
              ),
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(10.0),
              height: MediaQuery.of(context).size.height / 1.9,
              child: ScrollConfiguration(
                behavior: MyBehavior(),
                child: ListView.builder(
                  itemCount: 6,
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              prefs[index]["preference"] == false
                                  ? prefs[index]["preference"] = true
                                  : prefs[index]["preference"] = false;
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 700),
                            margin: EdgeInsets.all(10.0),
                            width: MediaQuery.of(context).size.width / 2.4,
                            height: 45,
                            decoration: BoxDecoration(
                                gradient: prefs[index]["preference"] == true
                                    ? LinearGradient(
                                        colors: [
                                            Color(0xFFFF6530),
                                            Color(0xFFFE4E74)
                                          ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter)
                                    : LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomLeft,
                                        colors: [
                                          Color.fromRGBO(245, 245, 245, 1),
                                          Colors.white,
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Center(
                              child: Text(
                                prefs[index]["name"],
                                style: TextStyle(
                                    fontFamily: "Gilroy",
                                    color: prefs[index]["preference"] == true
                                        ? Colors.white
                                        : Colors.black),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              prefs[index + 6]["preference"] == false
                                  ? prefs[index + 6]["preference"] = true
                                  : prefs[index + 6]["preference"] = false;
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 700),
                            width: MediaQuery.of(context).size.width / 2.4,
                            margin: EdgeInsets.all(10.0),
                            height: 45,
                            decoration: BoxDecoration(
                                gradient: prefs[index + 6]["preference"] == true
                                    ? LinearGradient(
                                        colors: [
                                            Color(0xFFFF6530),
                                            Color(0xFFFE4E74)
                                          ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter)
                                    : LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomLeft,
                                        colors: [
                                          Color.fromRGBO(245, 245, 245, 1),
                                          Colors.white,
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Center(
                              child: Text(
                                prefs[index + 6]["name"],
                                style: TextStyle(
                                    fontFamily: "Gilroy",
                                    color:
                                        prefs[index + 6]["preference"] == true
                                            ? Colors.white
                                            : Colors.black),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
            Expanded(child: SizedBox()),
            Center(
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    load = true;
                  });
                  Map<String, bool> temp = {};
                  prefs.every((element) {
                    temp.putIfAbsent(
                        element["name"], () => element["preference"]);
                    return true;
                  });
                  _auth.onAuthStateChanged.listen((user) async {
                    await database
                        .collection("users")
                        .document(user.uid)
                        .updateData({"preference": temp}).whenComplete(() {
                      // key.currentState.showSnackBar(SnackBar(
                      //   elevation: 10.0,
                      //   backgroundColor: Colors.white,
                      //   content: Text(
                      //     "Food Preference Updated",
                      //     style: TextStyle(
                      //         fontFamily: "Gilroy", color: Colors.black),
                      //   ),
                      //   duration: Duration(seconds: 2),
                      // ));
                      _auth.currentUser().then((value){
                        Navigator.pushReplacementNamed(context, "/AllergiesPage");
                      });
                      
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
                    _auth.onAuthStateChanged.listen((user) async {
                    await database
                        .collection("users")
                        .document(user.uid)
                        .updateData({"preference": []}).whenComplete(() {
                      // key.currentState.showSnackBar(SnackBar(
                      //   elevation: 10.0,
                      //   backgroundColor: Colors.white,
                      //   content: Text(
                      //     "Food Preference Updated",
                      //     style: TextStyle(
                      //         fontFamily: "Gilroy", color: Colors.black),
                      //   ),
                      //   duration: Duration(seconds: 2),
                      // ));
                      _auth.currentUser().then((value){
                        Navigator.pushReplacementNamed(context, "/AllergiesPage");
                      });
                      
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
          ],
        ),
      ),
    );
  }
}
