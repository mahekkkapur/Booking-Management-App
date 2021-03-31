import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econoomaccess/Homemaker/MakerDrawer.dart';
import 'LoyaltyBottomSheet.dart';
import 'LoyaltyRuleCard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoyaltyPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    String s = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      backgroundColor: Color(0xffe5e5e5),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color(0xffe5e5e5),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: MakerDrawerWidget(
        uid: s,
      ),
      body: Builder(
        builder: (context) => Container(
          margin: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(bottom: 20),
                alignment: Alignment.centerLeft,
                child: Text(
                  "Loyalty Rules",
                  style: TextStyle(
                      fontSize: 25.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Gilroy"),
                ),
              ),
              MaterialButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text("Add New Loyalty rule",style: TextStyle(
                      fontSize: 15.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Gilroy"),),
                    Icon(Icons.add),
                  ],
                ),
                height: 65,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(width: 1),
                ),
                minWidth: double.infinity,
                onPressed: () {
                  //TODO add function
                  showBottomSheet(
                      context: context,
                      builder: (context) {
                        return LoyaltyBottomSheet(uid:s);
                      });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              StreamBuilder(
                //TODO make Madhu dynamic
                stream: Firestore.instance
                    .collection("homemakers")
                    .document(s)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  else {
                    Map<String, dynamic> data = snapshot.data.data;
                    if (data["loyalty"] == null) return Text("No rules added");
                    return Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return LoyaltyRuleCard(
                              data["loyalty"][index], loyaltyToggleHandler);
                        },
                        itemCount: data["loyalty"].length,
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  loyaltyToggleHandler(int value, var data) {
    _auth.onAuthStateChanged.listen((user) async {
      if (value == 0 && data["enabled"] == false ||
          value == 1 && data["enabled"] == true) {
        //TODO make this dynamic
        DocumentReference docRef =
            Firestore.instance.collection("homemakers").document(user.uid);
        Firestore.instance.runTransaction((transaction) async {
          transaction.update(docRef, {
            "loyalty": FieldValue.arrayRemove([data]),
          });

          data["enabled"] = !data["enabled"];

          transaction.update(docRef, {
            "loyalty": FieldValue.arrayUnion([data]),
          });
        });
      }
    });
  }
}
