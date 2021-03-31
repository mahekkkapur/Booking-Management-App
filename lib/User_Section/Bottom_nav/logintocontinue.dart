import 'package:econoomaccess/AuthChoosePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class LoginPlease extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Image.asset(
          "images/Image4.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Container(
          padding: EdgeInsets.only(left: 30, right: 30),
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Please Login to get access to this feature...",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      fontFamily: "Gilroy"),
                ),
                SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () {
                    FirebaseAuth.instance.signOut().whenComplete(() =>
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AuthChoosePage())));
                  },
                  child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: Colors.redAccent,
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        "Login to continue",
                        style: TextStyle(
                            fontFamily: "Gilroy",
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.white),
                      )),
                )
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
