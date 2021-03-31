import 'package:econoomaccess/Homemaker/bottom_nav/MenuPage.dart';
import 'package:econoomaccess/Homemaker/bottom_nav/MerchantOrder.dart';
import 'package:econoomaccess/Homemaker/bottom_nav/homemaker_profile.dart';
import 'package:econoomaccess/Homemaker/bottom_nav/recommended.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:econoomaccess/common/icon/my_flutter_app_icons.dart';
import 'dart:io';
import 'package:econoomaccess/Homemaker/MakerDrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';

int currentTabIndex = 0;

class BottomBarMaker extends StatefulWidget {
  @override
  _BottomBarMakerState createState() => _BottomBarMakerState();
}

class _BottomBarMakerState extends State<BottomBarMaker> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var _uid;

  Future<bool> willpop() async {
    return showDialog(
        context: context,
        child: AlertDialog(
          title: Text(
            "Are you sure want to exit?",
            style: TextStyle(
              fontFamily: "Gilroy",
            ),
          ),
          actions: [
            FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("No")),
            FlatButton(
                onPressed: () {
                  exit(0);
                },
                child: Text("Yes"))
          ],
        ));
  }

  getUser() async {
    await _auth.currentUser().then((val) {
      setState(() {
        _uid = val.uid;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MakerDrawerWidget(uid: _uid),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.grey[50],
        elevation: 0,
      ),
      body: WillPopScope(
        onWillPop: willpop,
        child: Center(
          child: IndexedStack(index: currentTabIndex, children: [
            MenuPage(),
            MerchantOrder(),
            Recommended(),
            HomemakerProfile(),
          ]),
        ),
      ),
      extendBody: true,
      bottomNavigationBar: FloatingNavbar(
        backgroundColor: Colors.white70,
        selectedBackgroundColor: Colors.black87,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        onTap: (int val) {
          setState(() {
            currentTabIndex = val;
          });
          return val;
        },
        currentIndex: currentTabIndex,
        items: [
          FloatingNavbarItem(icon: Icons.assignment, title: 'Menu'),
          FloatingNavbarItem(icon: MyFlutterApp.orders_solid, title: 'Orders'),
          FloatingNavbarItem(
              icon: MyFlutterApp.recommended_outline, title: 'Suggestion'),
          FloatingNavbarItem(icon: Icons.person, title: 'Profile'),
        ],
      ),
    );
  }
}
