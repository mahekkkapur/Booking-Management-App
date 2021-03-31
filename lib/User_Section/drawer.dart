import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econoomaccess/User_Section/Drawer/chat/ChatPage.dart';
import 'package:econoomaccess/User_Section/Drawer/live_sessions/LiveSessions.dart';
import 'package:econoomaccess/common/about/aboutPage.dart';
import 'package:econoomaccess/User_Section/Drawer/recipes/recipeList.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:econoomaccess/User_Section/Drawer/settings/settings.dart';

// ignore: must_be_immutable
class DrawerWidget extends StatelessWidget {
  final String uid;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DrawerWidget({Key key, @required this.uid}) : super(key: key);
  var status;

  getType() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    status = sp.getString("isUserLoggedin");
  }

  @override
  Widget build(BuildContext context) {
    print(uid);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: ClipRRect(
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(70)),
        child: Container(
          color: Colors.white,
          width: width * 0.7,
          child: Drawer(
              elevation: 10,
              child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('users')
                      .document(uid)
                      .snapshots(),
                  builder: (context, streamSnapshot) {
                    getType();
                    if (streamSnapshot.connectionState ==
                        ConnectionState.waiting)
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    if (streamSnapshot.hasData) {
                      return SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                                height: MediaQuery.of(context).padding.top),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                padding: EdgeInsets.only(left: 10, top: 15),
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: status != "user"
                                      ? Image.network(
                                          'https://firebasestorage.googleapis.com/v0/b/naniz-team.appspot.com/o/defaultImage.jpg?alt=media&token=8fa0d735-4c1b-4ef4-bb3f-a9f45bd31d83',
                                          fit: BoxFit.fitWidth,
                                        )
                                      : streamSnapshot.data['image'] == null
                                          ? Image.network(
                                              'https://firebasestorage.googleapis.com/v0/b/naniz-team.appspot.com/o/defaultImage.jpg?alt=media&token=8fa0d735-4c1b-4ef4-bb3f-a9f45bd31d83',
                                              fit: BoxFit.fitWidth,
                                            )
                                          : Image.network(
                                              streamSnapshot.data['image'],
                                              fit: BoxFit.fitWidth,
                                            ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 8.0, left: 15),
                                child: status != "user"
                                    ? Container()
                                    : Text(
                                        streamSnapshot.data['name'],
                                        style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: height * 0.05),
                            ListTile(
                              dense: true,
                              title: Text(
                                'Dashboard',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context)
                                    .pushReplacementNamed("/BottomBarPage");
                              },
                            ),
                            status != "user"
                                ? Container()
                                : ListTile(
                                    dense: true,
                                    title: Text(
                                      'Chats',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ChatPage(
                                                  uid: uid,
                                                  name: streamSnapshot
                                                      .data['name'])));
                                    },
                                  ),
                            ListTile(
                              dense: true,
                              title: Text(
                                'Recipes',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            RecipeList(uid: uid)));
                              },
                            ),
                            status != "user"
                                ? Container()
                                : ListTile(
                                    dense: true,
                                    title: Text(
                                      'Notifications',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.of(context)
                                          .pushNamed("/PromotionPage");
                                    },
                                  ),
                            ListTile(
                              dense: true,
                              title: Text(
                                'Live Sessions',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LiveSessions()));
                              },
                            ),
                            status != "user"
                                ? Container()
                                : ListTile(
                                    dense: true,
                                    title: Text(
                                      'Your Orders',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                          "/ExistingOrders",
                                          arguments: uid);
                                    },
                                  ),
                            ListTile(
                              dense: true,
                              title: Text(
                                'About',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => About()));
                              },
                            ),
                            status != "user"
                                ? Container()
                                : ListTile(
                                    dense: true,
                                    title: Text(
                                      'Settings',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SettingsPage()));
                                    },
                                  ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 20.0, right: 30),
                              child: Divider(
                                thickness: 4,
                              ),
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 3),
                              child: InkWell(
                                onTap: () {
                                  savePrefs();
                                  _auth.signOut().whenComplete(() {
                                    Navigator.of(context).pushReplacementNamed(
                                        "/AuthChoosePage");
                                  });
                                },
                                child: Text(
                                  'Log Out',
                                  style: TextStyle(
                                      fontFamily: "Gilroy",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.redAccent),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      );
                    }
                    return SizedBox();
                  })),
        ),
      ),
    );
  }

  savePrefs() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("isUserLoggedin", null);
  }
}
