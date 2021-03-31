import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final Firestore firestore = Firestore.instance;

Future<String> getUser() async {
  return "Madhu_Homemaker";
}

class ReviewOrder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    pop() => Navigator.pop(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0),
      ),
      body: ReviewOrderBody(
          map: ModalRoute.of(context).settings.arguments, pop: pop),
    );
  }
}

class ReviewOrderBody extends StatefulWidget {
  final Map map;
  final Function pop;

  ReviewOrderBody({this.map, this.pop});

  @override
  _ReviewOrderBodyState createState() => _ReviewOrderBodyState();
}

class _ReviewOrderBodyState extends State<ReviewOrderBody> {
  var _uid;

  final DateFormat df = new DateFormat.MMMd().add_y().add_Hm();

  void getData() async {
    _auth.onAuthStateChanged.listen((user) async {
      setState(() {
        _uid = user.uid;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  static const String serverKey =
      "AAAAgNeqQUU:APA91bGf97wJkAGes42Tr8LeUexfwQT5YlkgnjYrVo0ZlYRyEpHonanba-qcL-SHv5vBpCZmfpJaKIEjEnnBGTDLBLxP1YAfUTTUpQsTmjpi2foUEledKs8zPklBCv_nj2_YnhkYBAKV";

  List orders = [];

  void cancelItem(int index) async {
    firestore
        .collection('homemakers')
        .document(_uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      List orders = List.from(snapshot.data['orders']);
      List newOrders = [];
      for (int i = 0; i < orders.length; i++) {
        Map item = Map.from(orders[i]);
        if (item['orderId'] == widget.map['orderId']) {
          List newItems = List.from(item['items']);
          newItems.removeAt(index);
          if (newItems.length != 0) {
            item['items'] = newItems;
            newOrders.add(item);
          }
        } else {
          newOrders.add(item);
        }
      }
      firestore
          .collection('homemakers')
          .document(_uid)
          .updateData({'orders': newOrders});
    });
    firestore
        .collection('users')
        .document(widget.map['user'])
        .get()
        .then((DocumentSnapshot snapshot) {
      List orders = List.from(snapshot.data['orders']);
      List newOrders = [];
      for (int i = 0; i < orders.length; i++) {
        Map item = Map.from(orders[i]);
        if (item['orderId'] == widget.map['orderId']) {
          if (item['homemaker'] == _uid) {
            List newItems = List.from(item['items']);
            newItems.removeAt(index);
            if (newItems.length != 0) {
              item['items'] = newItems;
              newOrders.add(item);
            }
          } else {
            newOrders.add(item);
          }
        } else {
          newOrders.add(item);
        }
      }
      firestore
          .collection('users')
          .document(widget.map['user'])
          .updateData({'orders': newOrders});
    });
    await http
        .post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': '${orders[index]["item"]} has been cancelled',
            'title': '${orders[index]["item"]} has been cancelled'
          },
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': orders[index]["token"],
        },
      ),
    )
        .then((value) {
      print(value.body);
    });
    orders.removeAt(index);
    print("hello");
  }

  @override
  Widget build(BuildContext context) {
    Map order;
    int total = 0;
    return StreamBuilder(
      stream: firestore.collection('homemakers').document(_uid).snapshots(),
      builder: (context, snapshot) {
        List<TableRow> toShow = [];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        List orders = List.from(snapshot.data['orders']);
        for (int i = 0; i < orders.length; i++) {
          if (Map.from(orders[i])['orderId'] == widget.map['orderId']) {
            order = orders[i];
            List items = List.from(Map.from(orders[i])['items']);
            total = 0;
            for (int j = 0; j < items.length; j++) {
              var price =
                  ((snapshot.data["menu"] as List).firstWhere((element) {
                return element['name'] == items[j]["item"];
              })["price"]);
              total += price;
              toShow.add(
                CustomReviewCard(
                        item: Map.from(items[j])['item'],
                        quantity: Map.from(items[j])['quantity'],
                        index: j,
                        callback: cancelItem,
                        cost: price)
                    .getRow(),
              );
            }
          }
        }

        if (toShow.length > 0) {
          DateTime placedAt = order["order_placed_at"].toDate();
          DateTime outForDeliveryAt =
              order["order_out_for_delivery_at"].toDate();
          var dateDifference = outForDeliveryAt.difference(placedAt).inHours;
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    child: Text(
                      "Review order,",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 4.0),
                        blurRadius: 3.0,
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 0),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            (order["accepted"])
                                ? "Advanced Order"
                                : "Live Order",
                            style: TextStyle(
                                fontFamily: "Gilroy",
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("#${order["orderId"]}"),
                          trailing: Text(df.format(placedAt)),
                        ),
                        Table(
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          columnWidths: {
                            0: FlexColumnWidth(3),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(1),
                          },
                          children: toShow,
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Text("Total", style: TextStyle(fontSize: 22)),
                              const SizedBox(width: 25),
                              Text("₹$total",
                                  style: TextStyle(
                                      fontSize: 30, color: Colors.red)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Divider(color: Colors.black),
                        const SizedBox(height: 10),
                        Text(
                          "DUE: ${df.format(outForDeliveryAt)}",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 24,
                          ),
                        ),
                        Text("$dateDifference Hours left",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Divider(color: Colors.black),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(order["address"]["name"],
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text("${order["address"]["address"]}"),
                                Text("${order["address"]["locality"]}"),
                                Text(
                                    "${order["address"]["city"]}, ${order["address"]["pincode"]}"),
                                Text(order["address"]["phone"]),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                    (order["Home_Delivery"])
                                        ? "Home Delivery"
                                        : "Self Pickup",
                                    style: TextStyle(
                                        color: Colors.redAccent, fontSize: 24)),
                                Text("OTP: 11111",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    createFlatButton("Cancel", () {
                      orderCancelCallback(order);
                    }, small: true),
                    const SizedBox(width: 30),
                    createFlatButton("Chat", () {
                      Navigator.of(context).pushNamed("/MakerChatPage",
                          arguments: <String>[_uid, order["user"]]);
                    }, small: true),
                  ],
                ),
                const SizedBox(height: 10),
                createFlatButton("Confirm Order Preparation", () {
                  acceptCallback(order, "accepted");
                }),
                const SizedBox(height: 10),
                createFlatButton("  Confirm Order Delivery   ", () {
                  acceptCallback(order, "out_for_delivery");
                }),
              ],
            ),
          );
        } else {
          return Center(
            child: Text(
              "Order Cancelled",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          );
        }
      },
    );
  }

  Widget createFlatButton(String text, Function handler, {bool small = false}) {
    return FlatButton(
      child: Text(text),
      onPressed: handler,
      color: (small) ? Colors.white : Colors.redAccent,
      textColor: (small) ? Colors.redAccent : Colors.white,
      padding: const EdgeInsets.all(15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
        side: BorderSide(color: Colors.redAccent),
      ),
    );
  }

  void orderCancelCallback(Map order) async {
    firestore.collection('homemakers').document(_uid).updateData({
      'orders': FieldValue.arrayRemove([order])
    });

    firestore.collection('users').document(order["user"]).updateData({
      'orders': FieldValue.arrayRemove([order])
    });

    await http
        .post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'Order has been cancelled',
            'title': 'Order has been cancelled'
          },
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': order["token"],
        },
      ),
    )
        .then((value) {
      print(value.body);
    });
  }

  void acceptCallback(Map order, String type) async {
    firestore
        .collection('homemakers')
        .document(_uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      List orders = List.from(snapshot.data['orders']);
      List newOrders = [];
      for (int i = 0; i < orders.length; i++) {
        Map item = Map.from(orders[i]);
        if (item['orderId'] == order["orderId"]) {
          item[type] = true;
          if (type == 'accepted') {
            item['order_accepted_at'] = Timestamp.now();
          } else {
            item['order_out_for_delivery_at'] = Timestamp.now();
          }
        }
        newOrders.add(item);
      }
      firestore
          .collection('homemakers')
          .document(_uid)
          .updateData({'orders': newOrders});
    });

    firestore
        .collection('users')
        .document(order["user"])
        .get()
        .then((DocumentSnapshot snapshot) {
      List orders = List.from(snapshot.data['orders']);
      List newOrders = [];
      for (int i = 0; i < orders.length; i++) {
        Map item = Map.from(orders[i]);
        if (item['orderId'] == order["orderId"] &&
            item['homemaker'] == _uid.toString()) {
          item[type] = true;
          if (type == 'accepted') {
            item['order_accepted_at'] = Timestamp.now();
          } else {
            item['order_out_for_delivery_at'] = Timestamp.now();
          }
        }
        newOrders.add(item);
      }
      firestore
          .collection('users')
          .document(order["user"])
          .updateData({'orders': newOrders});
    });
    String notifText =
        (type == "accepted") ? "has been accepted" : "is out for delivery";
    await http
        .post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'Order $notifText',
            'title': 'Order $notifText'
          },
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': order["token"],
        },
      ),
    )
        .then((value) {
      print(value.body);
    });
  }
}

class CustomReviewCard {
  final Function callback;
  final String item;
  final int quantity;
  final int index;
  final int mapNumber;
  final DocumentReference order;
  final int cost;

  CustomReviewCard(
      {this.item,
      this.quantity,
      this.index,
      this.callback,
      this.order,
      this.mapNumber,
      this.cost});

  TableRow getRow() {
    return TableRow(
      children: <Widget>[
        Text(
          "$item",
          style: TextStyle(fontSize: 15),
        ),
        Center(
          child: Text(
            "x$quantity",
            style: TextStyle(fontSize: 18),
          ),
        ),
        Center(
          child: Text(
            "₹$cost",
            style: TextStyle(fontSize: 18),
          ),
        ),
        cancelButton(),
      ],
    );
  }

  Widget cancelButton() {
    return IconButton(
      icon: Icon(Icons.cancel),
      onPressed: () => callback(this.index),
      color: Colors.redAccent,
      iconSize: 28,
    );
  }

  Widget cancelIcon() {
    return ButtonTheme(
      minWidth: 5.0,
      height: 20.0,
      child: OutlineButton(
        color: Color(0xffFE506D),
        textColor: Color(0xffFE506D),
        borderSide: BorderSide(
          color: Color(0xffFE506D),
          style: BorderStyle.solid,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Icon(Icons.close)),
        onPressed: () {
          callback(this.index);
        },
      ),
    );
  }
}
