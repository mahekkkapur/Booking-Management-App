import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econoomaccess/User_Section/drawer.dart';
import 'ActivePromotionItemCard.dart';
import 'PromotionItemCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PromotionsPage extends StatefulWidget {
  @override
  _PromotionsPageState createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  String uid;
  var promotionItems;
  String userName;
  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() {
    FirebaseAuth.instance.currentUser().then((val) {
      Firestore.instance
          .collection("users")
          .document(val.uid)
          .get()
          .then((value) {
        setState(() {
          uid = val.uid;
          promotionItems = value.data["promotionItems"];
        });
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      userName = ModalRoute.of(context).settings.arguments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white70,
      drawer: DrawerWidget(uid: uid),
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: TextStyle(
              color: Colors.black,
              fontFamily: "Gilroy",
              fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[50],
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: StreamBuilder(
          stream: Firestore.instance.collection("promotion").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              QuerySnapshot data = snapshot.data;
              List<DocumentSnapshot> docs = data.documents;
              return ListView.builder(
                  itemCount: docs.length ?? 0,
                  itemBuilder: (context, docsIndex) {
                    if (docs[docsIndex]["promotion"].length == 0) {
                      return SizedBox(
                        height: 0,
                      );
                    } else {
                      List<dynamic> promotions;
                      promotions = docs[docsIndex]["promotion"];
                      return Container(
                        padding: docs[docsIndex]["promotion"].length == 0
                            ? EdgeInsets.all(0)
                            : const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ListView.builder(
                              physics: BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: promotions?.length ?? 0,
                              itemBuilder: (context, promotionIndex) {
                                if (promotions[promotionIndex]["promoted"] ==
                                        true ||
                                    true) {
                                  String docId = docs[docsIndex].documentID;
                                  String mealName =
                                      promotions[promotionIndex]["name"];
                                  String fcmToken = docs[docsIndex]["fcm"];
                                  if (promotionItems != null &&
                                      promotionItems[docId] != null &&
                                      promotionItems[docId][mealName] != null) {
                                    return ActivePromotionItemCard(
                                      data: promotionItems[docId][mealName],
                                      docId: docId,
                                    );
                                  } else {
                                    return PromotionItemCard(
                                      docId: docId,
                                      data: promotions[promotionIndex],
                                      uid: this.uid,
                                      fcm: fcmToken,
                                      userName: userName,
                                    );
                                  }
                                } else
                                  return SizedBox(
                                    height: 0,
                                  );
                              },
                            )
                          ],
                        ),
                      );
                    }
                  });
            }
          },
        ),
      ),
    );
  }
}
