import 'package:econoomaccess/User_Section/drawer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final Firestore firestore = Firestore.instance;

class ExistingOrders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var s = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      drawer: DrawerWidget(uid: s),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: Text("Orders"),
        elevation: 0,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0),
      ),
      body: ExistingOrdersBody(),
    );
  }
}

var uid;

void getUser() {
  _auth.currentUser().then((val) {
    uid = val.uid;
  });
}

class ExistingOrdersBody extends StatefulWidget {
  @override
  _ExistingOrdersBodyState createState() => _ExistingOrdersBodyState();
}

class _ExistingOrdersBodyState extends State<ExistingOrdersBody> {
  var uid;

  void getUser() async {
    await _auth.currentUser().then((val) {
      setState(() {
        this.uid = val.uid;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var s = ModalRoute.of(context).settings.arguments;
    getUser();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Text("Your Orders",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            SizedBox(
              height: 10,
            ),
            StreamBuilder(
              stream: firestore.collection('users').document(s).snapshots(),
              builder: (context, snapshot) {
                List toShow = [];
                List orders = snapshot.data.data["orders"] != null
                    ? List.from(Map.from(snapshot.data.data)['orders'])
                    : [];

                if (!orders.isEmpty) {
                  for (int i = 0; i < orders.length; i++) {
                    bool found = false;
                    for (int j = 0; j < toShow.length; j++) {
                      if (toShow[j]['orderId'] == orders[i]['orderId']) {
                        found = true;
                        toShow[j]['homemakers'].add(orders[i]['homemakerName']);
                        toShow[j]['delivered'] =
                            orders[i]['delivered'] && toShow[j]['delivered'];
                      }
                    }
                    if (!found) {
                      toShow.add({
                        'orderId': orders[i]['orderId'],
                        'homemakers': [orders[i]['homemakerName']],
                        'delivered': orders[i]['delivered']
                      });
                    }
                  }
                  print("toShow: $toShow");
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: toShow.length,
                    itemBuilder: (context, index) {
                      return CustomCard(map: toShow[index]);
                    },
                  );
                } else {
                  return Column(
                    children: <Widget>[
                      SizedBox(height: 200),
                      Center(
                          child: Text("No Orders Done !!",
                              style: TextStyle(fontSize: 30.0))),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final Map map;
  CustomCard({this.map});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Order Id: ${map['orderId']}",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 20, color: Color(0xffFE506D)),
                ),
              ),
            ),
            ListView.builder(
                shrinkWrap: true,
                itemCount: map['homemakers'].length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("${map['homemakers'][index]} Kitchen"),
                  );
                }),
            Align(
                alignment: Alignment.centerRight,
                child: Padding(
                    padding: EdgeInsets.all(8),
                    child: !map['delivered']
                        ? RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            textColor: Colors.white,
                            color: Color(0xffFE506D),
                            child: Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Text(
                                "Track Order",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: "Gilroy",
                                ),
                              ),
                            ),
                            onPressed: () {
                              print(map['homemakers'].length);
                              var temp = [map['orderId'], uid];
                              map['homemakers'].length > 1
                                  ? Navigator.pushNamed(
                                      context, "/ChooseTrackOrder",
                                      arguments: temp)
                                  : Navigator.pushNamed(context, "/TrackOrder",
                                      arguments: {
                                          'orderId': map['orderId'],
                                          'homemaker': map['homemakers'][0]
                                        });
                            },
                          )
                        : Icon(
                            Icons.check_circle,
                            color: Color(0xffFE506D),
                          ))),
          ],
        ),
      ),
    );
  }
}
