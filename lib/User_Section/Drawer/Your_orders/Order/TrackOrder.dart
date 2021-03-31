import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final Firestore firestore = Firestore.instance;

class TrackOrder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed("/BottomBarPage");
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        title: Text("Orders"),
        elevation: 0,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0),
      ),
      body: TrackOrderBody(map: ModalRoute.of(context).settings.arguments),
    );
  }
}

class TrackOrderBody extends StatefulWidget {
  final Map map;
  TrackOrderBody({this.map});
  @override
  _TrackOrderBodyState createState() => _TrackOrderBodyState();
}

Widget dashedLine() {
  return Dash(
      direction: Axis.vertical,
      length: 100,
      dashLength: 15,
      dashColor: Color(0xffFE506D));
}

Widget line() {
  return Container(
    height: 100,
    child: VerticalDivider(
      color: Color(0xffFE506D),
      thickness: 2,
    ),
  );
}

Widget coloredCheck() {
  return Icon(
    Icons.check_circle,
    color: Color(0xffFE506D),
    size: 35,
  );
}

Widget check() {
  return Icon(
    Icons.check_circle_outline,
    color: Color(0xffFE506D),
    size: 35,
  );
}

class _TrackOrderBodyState extends State<TrackOrderBody> {
  var uid;

  Future<void> getUser() async {
    await _auth.currentUser().then((val) {
      setState(() {
        uid = val.uid;
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
    return StreamBuilder(
        stream: firestore.collection('users').document(uid).snapshots(),
        builder: (context, snapshot) {
          print(snapshot.data);
          List orders = List.from(Map.from(snapshot.data.data)['orders']);
          Map order;
          for (int i = 0; i < orders.length; i++) {
            if (orders[i]['orderId'] == widget.map['orderId'] &&
                orders[i]['homemakerName'] == widget.map['homemaker']) {
              order = orders[i];
            }
          }
          print(order);
          if (snapshot.connectionState == ConnectionState.waiting ||
              order == null) {
            return Center(child: CircularProgressIndicator());
          }
          return SafeArea(
            child: SingleChildScrollView(
                          child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            coloredCheck(),
                            order['accepted'] ? line() : dashedLine(),
                            order['accepted'] ? coloredCheck() : check(),
                            order['out_for_delivery'] ? line() : dashedLine(),
                            order['out_for_delivery'] ? coloredCheck() : check(),
                            order['delivered'] ? line() : dashedLine(),
                            order['delivered'] ? coloredCheck() : check(),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              padding: EdgeInsets.all(16.0),
                              margin: EdgeInsets.symmetric(vertical: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Order Recieved",
                                    style: TextStyle(
                                        color: Color(0xffFE506D),
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${DateTime.parse(order['order_placed_at'].toDate().toString()).day}/${DateTime.parse(order['order_placed_at'].toDate().toString()).month}/${DateTime.parse(order['order_placed_at'].toDate().toString()).year} | ${DateTime.parse(order['order_placed_at'].toDate().toString()).hour}:${DateTime.parse(order['order_placed_at'].toDate().toString()).minute}",
                                    style: TextStyle(fontSize: 12.0),
                                  ),
                                  Text(
                                    "We have Recieved your order and still processing it",
                                    style: TextStyle(fontSize: 15.0),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(16.0),
                              margin: EdgeInsets.symmetric(vertical: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Order Confirmed",
                                    style: TextStyle(
                                        color: Color(0xffFE506D),
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    order['accepted']
                                        ? "${DateTime.parse(order['order_accepted_at'].toDate().toString()).day}/${DateTime.parse(order['order_accepted_at'].toDate().toString()).month}/${DateTime.parse(order['order_accepted_at'].toDate().toString()).year} | ${DateTime.parse(order['order_accepted_at'].toDate().toString()).hour}:${DateTime.parse(order['order_accepted_at'].toDate().toString()).minute}"
                                        : " ",
                                    style: TextStyle(fontSize: 12.0),
                                  ),
                                  Text(
                                    order['accepted']
                                        ? "The vendor has confirmed your order and are getting it ready!"
                                        : "The vendor is yet to confirm your order!",
                                    style: TextStyle(fontSize: 15.0),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(16.0),
                              margin: EdgeInsets.symmetric(vertical: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Order Prepared",
                                    style: TextStyle(
                                        color: Color(0xffFE506D),
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    order['out_for_delivery']
                                        ? "${DateTime.parse(order['order_out_for_delivery_at'].toDate().toString()).day}/${DateTime.parse(order['order_out_for_delivery_at'].toDate().toString()).month}/${DateTime.parse(order['order_out_for_delivery_at'].toDate().toString()).year} | ${DateTime.parse(order['order_out_for_delivery_at'].toDate().toString()).hour}:${DateTime.parse(order['order_out_for_delivery_at'].toDate().toString()).minute}"
                                        : " ",
                                    style: TextStyle(fontSize: 12.0),
                                  ),
                                  Text(
                                    order['out_for_delivery']
                                        ? "Your food is ready and is out for delivery. The wait is almost over!"
                                        : "Your order is still being prepared!",
                                    style: TextStyle(fontSize: 15.0),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(16.0),
                              margin: EdgeInsets.symmetric(vertical: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Order Reached",
                                    style: TextStyle(
                                        color: Color(0xffFE506D),
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    order['delivered']
                                        ? "${DateTime.parse(order['order_delivered_at'].toDate().toString()).day}/${DateTime.parse(order['order_delivered_at'].toDate().toString()).month}/${DateTime.parse(order['order_delivered_at'].toDate().toString()).year} | ${DateTime.parse(order['order_delivered_at'].toDate().toString()).hour}:${DateTime.parse(order['order_delivered_at'].toDate().toString()).minute}"
                                        : " ",
                                    style: TextStyle(fontSize: 12.0),
                                  ),
                                  Text(
                                    order['delivered']
                                        ? "Your food is at your doorsteps.Share OTP to complete order."
                                        : "Your food is still being prepared!",
                                    style: TextStyle(fontSize: 15.0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  order['Home_Delivery']
                      ? FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(45.0),
                              side: BorderSide(color: Colors.red)),
                          color: Color(0xffFE506D),
                          textColor: Colors.white,
                          padding: EdgeInsets.all(16.0),
                          onPressed: () {},
                          child: Text(
                            "OTP 1234",
                            style: TextStyle(
                              fontSize: 20.0,
                              fontFamily: "Gilroy",
                            ),
                          ),
                        )
                      : FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(45.0),
                              side: BorderSide(color: Colors.red)),
                          color: Color(0xffFE506D),
                          textColor: Colors.white,
                          padding: EdgeInsets.all(16.0),
                          onPressed: () {
                            Navigator.pushNamed(context, "/VendorLocation",
                                arguments: order['homemaker']);
                          },
                          child: Text(
                            "Get Location",
                            style: TextStyle(
                              fontSize: 20.0,
                              fontFamily: "Gilroy",
                            ),
                          ),
                        ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Make sure you have recieved the correct items before sharing the OTP.",
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
