import 'package:econoomaccess/User_Section/bottomBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:econoomaccess/User_Section/SignUp/SignUpUserPage.dart';
import 'package:econoomaccess/Homemaker/signUp/SignUpMakerPage.dart' as maker;
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AuthChoosePage extends StatefulWidget {
  @override
  _AuthChoosePageState createState() => _AuthChoosePageState();
}

class _AuthChoosePageState extends State<AuthChoosePage> {
  bool skipped = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
      Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffFF6530), Color(0xffFE4E74)]),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 80,
            ),
            Image(
              image: AssetImage('images/Image1.png'),
              fit: BoxFit.cover,
              height: 100,
              width: MediaQuery.of(context).size.width / 4 + 20,
            ),
            Expanded(
              child: Container(
                  child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      elevation: 0.0,
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => SignUpPage()));
                        },
                        minWidth: 250.0,
                        height: 50.0,
                        child: Text(
                          'LOG IN AS USER',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Gilroy",
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      elevation: 0.0,
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => maker.SignUpPage()));
                        },
                        minWidth: 250.0,
                        height: 50.0,
                        child: Text(
                          'LOGIN AS HOMEMAKER',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Gilroy",
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    !skipped
                        ? GestureDetector(
                            onTap: () async {
                              // SharedPreferences sp = await SharedPreferences.getInstance();
                              // sp.setString("isUserLoggedin", "user");
                              setState(() {
                                skipped = !skipped;
                              });
                              FirebaseAuth.instance
                                  .signInAnonymously()
                                  .whenComplete(() => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => BottomBar())));
                            },
                            child: Text(
                              "Skip for Now",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Gilroy",
                                fontSize: 15.0,
                              ),
                            ),
                          )
                        : SpinKitWave(
                            color: Colors.white,
                            size: 30,
                          )
                  ],
                ),
              )),
            ),
            Container(
              height: 150,
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 130,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(45.0),
                            topRight: Radius.circular(45.0),
                          )),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              MaterialButton(
                                color: Colors.blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                onPressed: () {
                                  //Implement login functionality.
                                },
                                height: 50,
                                child: Text(
                                  'Sign In with Google',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Gilroy",
                                    fontSize: 10.0,
                                  ),
                                ),
                              ),
                              MaterialButton(
                                color: Colors.black,
                                onPressed: () {
                                  //Implement login functionality.
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20.0))),
                                height: 50,
                                child: Text(
                                  'Sign In with Apple',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Gilroy",
                                    fontSize: 10.0,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Terms and conditions",
                            style: TextStyle(
                                color: Colors.blueAccent,
                                // fontWeight: FontWeight.bold,
                                fontSize: 10,
                                fontFamily: "Gilroy"),
                          )
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Material(
                      shape: CircleBorder(),
                      elevation: 10.0,
                      child: CircleAvatar(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        radius: 25,
                        child: Text(
                          "OR",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Gilroy",
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ]));
  }
}
