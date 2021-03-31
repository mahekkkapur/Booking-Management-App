import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final Firestore firestore = Firestore.instance;

class ChooseTrackOrder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<dynamic> s = ModalRoute.of(context).settings.arguments;
    Fluttertoast.showToast(msg: s.toString());
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        title: Text("Orders"),
        elevation: 0,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Choose vendor, ",
                style: TextStyle(
                    color: Color(0xffFE506D),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            ChooseTrackOrderBody(orderId: s[0])
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class ChooseTrackOrderBody extends StatelessWidget {
  final String orderId;
  ChooseTrackOrderBody({this.orderId});
  String uid;

  void getUser() async {
    await _auth.currentUser().then((val) {
      uid = val.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> s = ModalRoute.of(context).settings.arguments;
    var user = s[1];
    getUser();
    return StreamBuilder(
      stream: firestore.collection('users').document(user).snapshots(),
      builder: (context, snapshot) {
        Fluttertoast.showToast(msg: snapshot.toString());
        // if (snapshot.connectionState == ConnectionState.waiting)
        //   return Center(child: CircularProgressIndicator());
        List orders = List.from(Map.from(snapshot.data.data)['orders']);

        // print(orders);
        List toDisplay = [];
        for (int i = 0; i < orders.length; i++) {
          if (Map.from(orders[i])['orderId'] == this.orderId) {
            toDisplay.add(Map.from(orders[i])["homemaker"]);
          }
        }
        return ListView.builder(
            shrinkWrap: true,
            itemCount: toDisplay.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, "/TrackOrder",
                      arguments: {
                        'orderId': this.orderId,
                        'homemaker': toDisplay[index]
                      }),
                  child: Card(
                      child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(toDisplay[index]),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  )),
                ),
              );
            });
      },
    );
  }
}
