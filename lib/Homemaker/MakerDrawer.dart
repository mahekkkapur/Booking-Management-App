import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econoomaccess/Homemaker/Chat/MakerChatPage.dart';
import 'package:econoomaccess/common/about/aboutPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:typicons_flutter/typicons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class MakerDrawerWidget extends StatelessWidget {
  final String uid;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  MakerDrawerWidget({Key key, @required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(uid);

    return ClipRRect(
      borderRadius: BorderRadius.only(bottomRight: Radius.circular(50)),
      child: Drawer(
          elevation: 10,
          child: StreamBuilder(
              stream: Firestore.instance
                  .collection('homemakers')
                  .document(uid)
                  .snapshots(),
              builder: (context, streamSnapshot) {
                if (streamSnapshot.connectionState == ConnectionState.waiting)
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                // final documents = streamSnapshot.data.documents;

                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: MediaQuery.of(context).padding.top),
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
                            child: streamSnapshot.data['image'] == null
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
                          padding: const EdgeInsets.only(top: 8.0, left: 15),
                          child: Text(
                            streamSnapshot.data['name'],
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      ListTile(
                        dense: true,
                        title: Text(
                          'Menu',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .pushReplacementNamed("/BottomBarMakerPage");
                        },
                      ),
                      // ListTile(
                      //   dense: true,
                      //   title: Text(
                      //     'Inventory',
                      //     style: TextStyle(
                      //       fontSize: 18,
                      //     ),
                      //   ),
                      //   onTap: () {

                      //   },
                      // ),
                      ListTile(
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
                                  builder: (context) => MakerChatPage(
                                      uid: uid,
                                      name: streamSnapshot.data['name'])));
                        },
                      ),
                      // ListTile(
                      //   dense: true,
                      //   title: Text(
                      //     'Notifications',
                      //     style: TextStyle(
                      //       fontSize: 18,
                      //     ),
                      //   ),
                      // ),
                      // ListTile(
                      //   dense: true,
                      //   title: Text(
                      //     'Offer Section',
                      //     style: TextStyle(
                      //       fontSize: 18,
                      //     ),
                      //   ),
                      // ),
                      // ListTile(
                      //   dense: true,
                      //   title: Text(
                      //     'Your Orders',
                      //     style: TextStyle(
                      //       fontSize: 18,
                      //     ),
                      //   ),
                      //   onTap: () {
                      //     Navigator.of(context)
                      //         .pushNamed("/MerchantOrderPage", arguments: uid);
                      //   },
                      // ),
                      // ListTile(
                      //   dense: true,
                      //   title: Text(
                      //     'Recipes',
                      //     style: TextStyle(
                      //       fontSize: 18,
                      //     ),
                      //   ),
                      //   onTap: () {
                      //     Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) => RecipeList(uid: uid)));
                      //   },
                      // ),
                      ListTile(
                        dense: true,
                        title: Text(
                          'Analytics',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed("/AnalyticsPage", arguments: uid);
                        },
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                          'Payouts',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed("/PayoutPage", arguments: uid);
                        },
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                          'Promotions',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed("/PromotionListPage", arguments: uid);
                        },
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                          'Loyalty',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed("/LoyaltyPage", arguments: uid);
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
                          // showAboutDialog(
                          //     context: context,
                          //     applicationVersion: 'Beta v1.0.1',
                          //     applicationIcon: Container(
                          //       height: 50,
                          //       width: 50,
                          //       decoration: BoxDecoration(
                          //         image: DecorationImage(
                          //           image: AssetImage(
                          //             'images/cropped-naaniz-logo.png',
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //     applicationName: 'Naniz Eats',
                          //     applicationLegalese: 'Anyone can deliver food.');
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => About()));
                        },
                      ),
                      ListTile(
                        dense: true,
                        title: Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        onTap: () {
                          savePrefs();
                          _auth.signOut().whenComplete(() {
                            Navigator.of(context)
                                .pushReplacementNamed("/AuthChoosePage");
                          });
                        },
                      ),
                      Center(
                          child: IconButton(
                              icon: Icon(
                                Typicons.delete_outline,
                                size: 60,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              })),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                );
              })),
    );
  }

  savePrefs() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("isUserLoggedin", null);
  }
}
