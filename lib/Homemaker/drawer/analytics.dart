import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econoomaccess/Homemaker/bottom_nav/viewReviews.dart';
import 'package:provider/provider.dart';
import 'package:econoomaccess/Homemaker/MakerDrawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Firestore firestore = Firestore.instance;

class Analytics extends StatefulWidget {
  static const routeName = '/analytics';
  @override
  _AnalyticsState createState() => _AnalyticsState();
}

var user;
var temp;
TextEditingController promoteDays = new TextEditingController();
TextEditingController promoteAmount = new TextEditingController();
TextEditingController promoters = new TextEditingController();
TextEditingController promoteCut = new TextEditingController();
TextEditingController promoteMessage = new TextEditingController();
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class _AnalyticsState extends State<Analytics> {
  String fcmToken;
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((value) {
      user = value.uid;
    });
    FirebaseMessaging().getToken().then((value) {
      setState(() {
        fcmToken = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String s = ModalRoute.of(context).settings.arguments;
    temp = s;
    return ChangeNotifierProvider(
      create: (context) => AnalyticsModel(),
      child: Consumer<AnalyticsModel>(
        builder: (context, value, child) => Scaffold(
          key: _scaffoldKey,
          drawer: MakerDrawerWidget(uid: s),
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            elevation: 0.0,
            backgroundColor: Color(0xFFFF9F9F9),
            title: Text(
              "Analytics",
              style: TextStyle(
                  fontSize: 25.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Gilroy"),
            ),
            titleSpacing: NavigationToolbar.kMiddleSpacing,
          ),
          body: Column(
            children: <Widget>[
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height - 160),
                child: StreamBuilder<DocumentSnapshot>(
                    stream: Firestore.instance
                        .collection("homemakers")
                        .document(s)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasData) {
                        final Map<String, dynamic> data = snapshot.data.data;
                        value.updateFields(data, s);
                        List<Widget> children = [
                          SlideButton(
                              type: "Total Orders",
                              index: 0,
                              value: value,
                              val: value.totalOrders),
                          SlideButton(
                              type: "Live Orders",
                              index: 1,
                              value: value,
                              val: value.liveOrders),
                          SlideButton(
                              type: "5 Star Reviews",
                              index: 2,
                              value: value,
                              val: value.reviews),
                          SlideButton(
                              type: "Top Dishes",
                              index: 3,
                              value: value,
                              val: value.dishes),
                        ];

                        return Column(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: children,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                child: value.indexValue(0)
                                    ? TotalOrder(
                                        data: data['orders'],
                                        menu: data['menu'])
                                    : value.indexValue(1)
                                        ? LiveOrder(
                                            data: data['orders'],
                                            menu: data['menu'],
                                          )
                                        : value.indexValue(2)
                                            ? Reviews(
                                                data: s,
                                              )
                                            : value.indexValue(3)
                                                ? TopDishes(data: data['menu'])
                                                : ListView.builder(
                                                    // controller: _controller,
                                                    itemCount: snapshot.data
                                                        .data['menu'].length,
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return Container(
                                                        margin:
                                                            EdgeInsets.all(5.0),
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: 120,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0)),
                                                        child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                SizedBox(
                                                                    width: 10),
                                                                Container(
                                                                  width: 100,
                                                                  height: 70,
                                                                  decoration: BoxDecoration(
                                                                      image: DecorationImage(
                                                                          image: NetworkImage(snapshot.data.data['menu'][index]
                                                                              [
                                                                              'image']),
                                                                          fit: BoxFit
                                                                              .fitWidth),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              15.0)),
                                                                ),
                                                                SizedBox(
                                                                  width: 10.0,
                                                                ),
                                                                Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: <
                                                                      Widget>[
                                                                    Text(
                                                                      snapshot.data.data['menu']
                                                                              [
                                                                              index]
                                                                          [
                                                                          'name'],
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              "Gilroy",
                                                                          fontWeight: FontWeight
                                                                              .w600,
                                                                          fontSize:
                                                                              15.0,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          5.0,
                                                                    ),
                                                                    Text(
                                                                      "${snapshot.data.data['name']}\'s Kitchen",
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              "Gilroy",
                                                                          fontSize:
                                                                              13.0,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          5.0,
                                                                    ),
                                                                    Text(
                                                                      "₹${snapshot.data.data['menu'][index]['price'].toString()}/plate",
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              "Gilroy",
                                                                          fontWeight: FontWeight
                                                                              .w600,
                                                                          fontSize:
                                                                              15.0,
                                                                          color:
                                                                              Colors.black),
                                                                    )
                                                                  ],
                                                                ),
                                                                Expanded(
                                                                    child:
                                                                        SizedBox()),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      right: 10,
                                                                      bottom:
                                                                          15),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Container(
                                                                        width:
                                                                            20.0,
                                                                        height:
                                                                            20.0,
                                                                        decoration:
                                                                            BoxDecoration(border: Border.all(color: snapshot.data.data['menu'][index]['veg'] == true ? Colors.green : Colors.red, width: 1.0)),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                10.0,
                                                                            height:
                                                                                10.0,
                                                                            decoration:
                                                                                BoxDecoration(borderRadius: BorderRadius.circular(50.0), color: snapshot.data.data['menu'][index]['veg'] == true ? Colors.green : Colors.red),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            10.0,
                                                                      ),
                                                                      Row(
                                                                        children: <
                                                                            Widget>[
                                                                          Text(snapshot
                                                                              .data
                                                                              .data['menu'][index]['rating']
                                                                              .toString()),
                                                                          Icon(
                                                                            Icons.star,
                                                                            color:
                                                                                Color(0xffFE506D),
                                                                            size:
                                                                                15.0,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 5.0,
                                                                )
                                                              ],
                                                            ),
                                                            data['menu'][
                                                                            index]
                                                                        [
                                                                        'promoted'] ==
                                                                    true
                                                                ? OutlineButton(
                                                                    onPressed:
                                                                        () {},
                                                                    color: Colors
                                                                        .grey,
                                                                    child: Text(
                                                                      "Already Promoted",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .grey,
                                                                          fontFamily:
                                                                              "Gilroy"),
                                                                    ),
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: Colors
                                                                          .grey,
                                                                      style: BorderStyle
                                                                          .solid,
                                                                      width:
                                                                          1.8,
                                                                    ),
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.0),
                                                                    ),
                                                                  )
                                                                : OutlineButton(
                                                                    onPressed:
                                                                        () {
                                                                      showModalBottomSheet(
                                                                          isScrollControlled:
                                                                              true,
                                                                          elevation:
                                                                              250,
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.only(
                                                                              topRight: Radius.circular(40.0),
                                                                              topLeft: Radius.circular(40.0),
                                                                            ),
                                                                          ),
                                                                          context: _scaffoldKey
                                                                              .currentContext,
                                                                          builder:
                                                                              (contetx) {
                                                                            return PromoteDialog(
                                                                                snapshot: snapshot,
                                                                                index: index,
                                                                                s: s,
                                                                                fcmToken: fcmToken,
                                                                                data: data);
                                                                          });
                                                                    },
                                                                    splashColor:
                                                                        Color(
                                                                            0xffFE506D),
                                                                    focusColor:
                                                                        Color(
                                                                            0xffFE506D),
                                                                    textColor:
                                                                        Colors
                                                                            .white,
                                                                    disabledTextColor:
                                                                        Color(
                                                                            0xffFE506D),
                                                                    highlightedBorderColor:
                                                                        Color(
                                                                            0xffFE506D),
                                                                    borderSide:
                                                                        BorderSide(
                                                                      color: Color(
                                                                          0xffFE506D),
                                                                      style: BorderStyle
                                                                          .solid,
                                                                      width:
                                                                          1.8,
                                                                    ),
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.0),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          Text(
                                                                        "Promote",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Color(0xffFE506D),
                                                                          fontSize:
                                                                              12.0,
                                                                          fontFamily:
                                                                              "Gilroy",
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ))
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                              ),
                            ),
                          ],
                        );
                      }
                      return SizedBox();
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PromoteDialog extends StatelessWidget {
  final AsyncSnapshot snapshot;
  final int index;
  final String s;
  final String fcmToken;
  final Map<String, dynamic> data;

  const PromoteDialog(
      {Key key, this.snapshot, this.index, this.s, this.fcmToken, this.data})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Divider(
            color: Colors.grey,
            height: 20,
            thickness: 5,
            indent: 120,
            endIndent: 120,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "Promote Dish",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(width: 10),
              Container(
                width: 100,
                height: 70,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(
                            snapshot.data.data['menu'][index]['image']),
                        fit: BoxFit.fitWidth),
                    borderRadius: BorderRadius.circular(15.0)),
              ),
              SizedBox(
                width: 10.0,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    snapshot.data.data['menu'][index]['name'],
                    style: TextStyle(
                        fontFamily: "Gilroy",
                        fontWeight: FontWeight.w600,
                        fontSize: 15.0,
                        color: Colors.black),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    "₹${snapshot.data.data['menu'][index]['price'].toString()}/plate",
                    style: TextStyle(
                        fontFamily: "Gilroy",
                        fontWeight: FontWeight.w600,
                        fontSize: 15.0,
                        color: Colors.black),
                  )
                ],
              ),
              Expanded(child: SizedBox()),
              Padding(
                padding: const EdgeInsets.only(right: 10, bottom: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: snapshot.data.data['menu'][index]['veg'] ==
                                      true
                                  ? Colors.green
                                  : Colors.red,
                              width: 1.0)),
                      child: Center(
                        child: Container(
                          width: 10.0,
                          height: 10.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50.0),
                              color: snapshot.data.data['menu'][index]['veg'] ==
                                      true
                                  ? Colors.green
                                  : Colors.red),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      children: <Widget>[
                        Text(snapshot.data.data['menu'][index]['rating']
                            .toString()),
                        Icon(
                          Icons.star,
                          color: Color(0xffFE506D),
                          size: 15.0,
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 5.0,
              )
            ],
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Text(
                "Promote for",
                style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Gilroy"),
              ),
              Expanded(child: SizedBox()),
              Text(
                "Target Amount",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                    fontFamily: "Gilroy"),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Color(0xFFE5E5E5),
                ),
                height: 40.0,
                width: 150,
                child: TextField(
                  controller: promoteDays,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: "0 Days"),
                ),
              ),
              Expanded(child: SizedBox()),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Color(0xFFE5E5E5),
                ),
                height: 40.0,
                width: 150,
                child: TextField(
                  controller: promoteAmount,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: '0 \$'),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Text(
                "Promoters",
                style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Gilroy"),
              ),
              Expanded(child: SizedBox()),
              Text(
                "Pomoter Cut",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                    fontFamily: "Gilroy"),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Color(0xFFE5E5E5),
                ),
                height: 40.0,
                width: 150,
                child: TextField(
                  controller: promoters,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: "0 People"),
                ),
              ),
              Expanded(child: SizedBox()),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Color(0xFFE5E5E5),
                ),
                height: 40.0,
                width: 150,
                child: TextField(
                  controller: promoteCut,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: '0\$/Sale'),
                ),
              )
            ],
          ),
        ),
        Text(
          "Message",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.0,
              fontFamily: "Gilroy"),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Color(0xFFE5E5E5),
          ),
          height: 40.0,
          width: MediaQuery.of(context).size.width - 50,
          child: TextField(
            controller: promoteMessage,
            decoration:
                InputDecoration(border: InputBorder.none, hintText: 'Message'),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 10.0),
          child: Container(
            width: 250,
            child: OutlineButton(
              onPressed: () async {
                DocumentSnapshot snap = await Firestore.instance
                    .collection("promotion")
                    .document(s)
                    .get();
                List<dynamic> promotion = [];
                snap.data["promotion"].forEach((value) {
                  promotion.add(value);
                });
                promotion.add({
                  "name": snapshot.data.data['menu'][index]['name'],
                  "price": snapshot.data.data['menu'][index]['price'],
                  "image": snapshot.data.data['menu'][index]['image'],
                  "rating": snapshot.data.data['menu'][index]['rating'],
                  "veg": snapshot.data.data['menu'][index]['veg'],
                  "promoted": true,
                  "promotedDays": promoteDays.text,
                  "promotedAmount": promoteAmount.text,
                  "promotedCut": promoteCut.text,
                  "promoters": promoters.text,
                  "message": promoteMessage.text
                });
                Firestore.instance
                    .collection("promotion")
                    .document(s)
                    .updateData({
                  "promotion": promotion,
                  "fcm": fcmToken,
                });
                data['menu'][index]['promoted'] = true;
                Firestore.instance
                    .collection("homemakers")
                    .document(s)
                    .updateData({"menu": data["menu"]}).whenComplete(
                        () => Navigator.pop(context));
              },
              splashColor: Color(0xffFE506D),
              focusColor: Color(0xffFE506D),
              textColor: Colors.white,
              disabledTextColor: Color(0xffFE506D),
              highlightedBorderColor: Color(0xffFE506D),
              borderSide: BorderSide(
                color: Color(0xffFE506D),
                style: BorderStyle.solid,
                width: 1.8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "Promote",
                  style: TextStyle(
                    color: Color(0xffFE506D),
                    fontSize: 15.0,
                    fontFamily: "Gilroy",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class SlideButton extends StatelessWidget {
  final String type;
  final int index, val;
  final AnalyticsModel value;
  SlideButton({this.type, this.index, this.value, this.val});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200.0,
      height: 100.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RaisedButton(
          color: Color(0xffFE506D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          onPressed: () {
            print(this.value.indexValue(index));
            this.value.setIndex(this.index);
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  this.val.toString(),
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
                Text(
                  this.type,
                  style: TextStyle(fontSize: 15, color: Colors.white),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TotalOrder extends StatelessWidget {
  final List data, menu;
  final List<Widget> cards = [];
  TotalOrder({this.data, this.menu});
  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < this.data.length; i++) {
      if (Map.from(this.data[i])['delivered'])
        cards.add(customCard(
            orderId: Map.from(this.data[i])['orderId'],
            items: Map.from(this.data[i])['items'],
            cost: 0));
    }
    print("card are $cards");
    return Container(
      child: ListView(
        children: cards,
      ),
    );
  }

  Widget customCard({String orderId, List items, int cost}) {
    List<Widget> item = [];
    int cost = 0;
    for (int i = 0; i < items.length; i++) {
      menu.forEach((element) {
        element['name'] == items[i]['item']
            ? cost += element['price'] * items[i]['quantity']
            : cost += 0;
      });
      item.add(Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Expanded(child: Text("${items[i]['item']}")),
        Expanded(child: Text("----------")),
        Expanded(child: Text("x${items[i]['quantity']}"))
      ]));
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Completed order : $orderId",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xffFE506D)),
              ),
              SizedBox(height: 10),
              Column(
                children: item,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "₹$cost.00",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xffFE506D)),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xffFE506D),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: Text(
                        "Completed",
                        style: TextStyle(color: Color(0xffFE506D)),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TopDishes extends StatelessWidget {
  final List data;
  TopDishes({this.data});
  @override
  Widget build(BuildContext context) {
    // data.sort((a, b) => a['rating'] > b['rating']);
    // print(data);
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: Container(
                padding: EdgeInsets.all(8),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 70,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(data[index]["image"]),
                                fit: BoxFit.fitWidth),
                            borderRadius: BorderRadius.circular(15.0)),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 5),
                            Text(data[index]['name']),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Image.network(
                                  data[index]['veg']
                                      ? 'https://s21425.pcdn.co/wp-content/uploads/2013/05/veg-300x259.jpg'
                                      : 'https://www.iec.edu.in/app/webroot/img/Icons/84246.png',
                                  width: 15,
                                  height: 15,
                                ),
                                SizedBox(width: 10),
                                RatingBarIndicator(
                                  rating: data[index]['rating'].toDouble(),
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 15.0,
                                  direction: Axis.horizontal,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Text(
                        "₹${data[index]['price']}\n/plate",
                        style: TextStyle(
                            fontSize: 20,
                            color: Color(0xffFE506D),
                            fontWeight: FontWeight.bold),
                      )
                    ])),
          ),
        );
      },
    );
  }
}

class Reviews extends StatelessWidget {
  final String data;
  Reviews({this.data});
  @override
  Widget build(BuildContext context) {
    print(data);
    return ViewReviews(
      data: data,
    );
  }
}

class LiveOrder extends StatelessWidget {
  final List data, menu;
  final List<Widget> cards = [];
  LiveOrder({this.data, this.menu});
  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < this.data.length; i++) {
      if (!Map.from(this.data[i])['delivered'])
        cards.add(customCard(
            orderId: Map.from(this.data[i])['orderId'],
            items: Map.from(this.data[i])['items'],
            cost: 0,
            context: context));
    }
    return ListView.builder(
        itemCount: cards.length,
        itemBuilder: (context, index) {
          return cards[index];
        });
  }

  Widget customCard(
      {String orderId, List items, int cost, BuildContext context}) {
    List<Widget> item = [];
    int cost = 0;
    for (int i = 0; i < items.length; i++) {
      menu.forEach((element) {
        element['name'] == items[i]['item']
            ? cost += element['price'] * items[i]['quantity']
            : cost += 0;
      });
      item.add(Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Expanded(child: Text("${items[i]['item']}")),
        Expanded(child: Text("----------")),
        Expanded(child: Text("x${items[i]['quantity']}"))
      ]));
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Live order : $orderId",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xffFE506D)),
              ),
              SizedBox(height: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: item,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "₹$cost.00",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xffFE506D)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(
                          context, "/MerchantOrderPage",
                          arguments: temp);
                    },
                    child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xffFE506D),
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Text(
                          "Review",
                          style: TextStyle(color: Color(0xffFE506D)),
                        )),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AnalyticsModel extends ChangeNotifier {
  List<bool> _page = [false, false, false, false];
  int _totalOrders = 0, _liveOrders = 0, _reviews = 0, _dishes = 0;

  void setIndex(int newIndex) {
    for (int i = 0; i < _page.length; i++) {
      if (i == newIndex)
        _page[i] = true;
      else
        _page[i] = false;
    }
    notifyListeners();
  }

  get totalOrders => _totalOrders;
  get liveOrders => _liveOrders;
  get reviews => _reviews;
  get dishes => _dishes;


  void updateFields(Map data, String homemaker) async {
    print("Data: $data");
    _liveOrders = 0;
    _totalOrders = data['orders'].length;
    _dishes = data['menu'].length;
    for (int i = 0; i < data['orders'].length; i++) {
      if (!data['orders'][i]['delivered']) _liveOrders += 1;
    }
    Firestore.instance
        .collection("homemakers")
        .document(homemaker)
        .get()
        .then((value) {
      _reviews = value.data['5StarReviews'];
    });
    notifyListeners();
  }

  bool indexValue(int index) {
    return _page[index];
  }
}
