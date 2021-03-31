import 'dart:async';
import 'dart:io';
import 'package:econoomaccess/User_Section/Bottom_nav/logintocontinue.dart';
import 'package:econoomaccess/User_Section/Bottom_nav/explore_page/week_day_widget.dart';
import 'package:econoomaccess/Homemaker/Profile_setup/happy_cooking.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:econoomaccess/localization/language_constants.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'dart:developer';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _database = Firestore.instance;
  FirebaseUser user;
  var uid;
  Geoflutterfire geo;
  GeoPoint _geopoint;
  Geolocator geolocator;
  TabController tabController;
  var temperature, desc;
  var address;
  var state;
  bool _isAvailable = false;
  bool _isListening = false;

  String resultText = "";

  bool type;

  Future getWeather(GeoPoint geoPoint) async {
    var apiKey = "dbdaf522e4997681584a75225a93b56a";
    if (geoPoint != null) {
      http.Response res = await http.get(
          'http://api.openweathermap.org/data/2.5/weather?lat=${geoPoint.latitude}&lon=${geoPoint.longitude}&appid=$apiKey');
      var results = jsonDecode(res.body);
      setState(() {
        temperature = results["main"]["temp"];
        desc = results["weather"][0]["description"];
      });
    }
  }

  var location;
  getUser() async {
    await _auth.currentUser().then((val) {
      Firestore.instance
          .collection('users')
          .document(val.uid)
          .get()
          .then((doc) => {
                setState(() {
                  user = val;
                  uid = val.uid;
                  location = doc['state'];
                }),
                getAIData(),
              });
    });
  }

  Map<String, dynamic> aiData = {};
  void getAIData() async {
    String url = "http://naaniz.pythonanywhere.com/getrecommendation";
    var body = {"state": '$location'};
    http.Response response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );
    if (response.statusCode == 200) {
      setState(() {
        aiData = json.decode(response.body);
      });
    }
  }

  String menuType = "special";
  Map<String, dynamic> pref;
  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
    getType();
    initDynamicLink();
    geo = Geoflutterfire();
    getUser();
  }

  getType() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      type = user.isAnonymous;
    });
    getLocation();
  }

  getLocation() async {
    if (type) {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      setState(() {
        // this.state = place.administrativeArea;
        _geopoint = GeoPoint(position.latitude, position.longitude);
        getWeather(_geopoint);
      });
    } else {
      var loc;
      FirebaseAuth.instance.onAuthStateChanged.listen((user) async {
        loc = await Firestore.instance
            .collection('users')
            .document(user.uid)
            .get();
        if (!mounted) return;
        setState(() {
          _geopoint = loc["position"]["geopoint"];
          getWeather(_geopoint);
        });
      });
    }
    getWeather(_geopoint);
  }

  getOrderList(List<DocumentSnapshot> snapshot) {
    List<DocumentSnapshot> newSnap = [];

    List<double> rates = [];
    for (var k in snapshot) {
      if (!rates.contains(k["rating"])) {
        rates.add(k["rating"].toDouble());
      }
    }
    rates.sort();

    for (int k = rates.length - 1; k >= 0; k--) {
      for (var p in snapshot) {
        if (p.data["rating"] == rates[k]) {
          newSnap.add(p);
        }
      }
    }
    return newSnap;
  }

  Widget topRated() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _geopoint == null
              ? Center(child: Text("OOPS, Looks like no one is serving!"))
              : StreamBuilder(
                  stream: geo
                      .collection(
                          collectionRef: _database.collection('homemakers'))
                      .within(
                          center: geo.point(
                              latitude: _geopoint.latitude,
                              longitude: _geopoint.longitude),
                          radius: 10,
                          field: 'position'),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                    List<DocumentSnapshot> toprated = [];
                    if (snapshot.hasData) {
                      snapshot.data.every((element) {
                        if (toprated.length < 5) {
                          toprated.add(element);
                        }
                        return true;
                      });
                      toprated = getOrderList(toprated);

                      if (snapshot.data.isEmpty) {
                        return Center(
                            child: Text("OOPS, Looks like no one is serving!"));
                      }
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: 200.0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: toprated.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed('/ProfilePage',
                                    arguments: toprated[index].documentID);
                              },
                              child: Container(
                                alignment: Alignment.bottomCenter,
                                margin: EdgeInsets.all(10.0),
                                width: 160.0,
                                height: 220.0,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    image: DecorationImage(
                                        image: toprated[index].data['image'] ==
                                                null
                                            ? NetworkImage(
                                                'https://firebasestorage.googleapis.com/v0/b/naniz-team.appspot.com/o/defaultImage.jpg?alt=media&token=8fa0d735-4c1b-4ef4-bb3f-a9f45bd31d83')
                                            : NetworkImage(
                                                toprated[index].data['image']),
                                        fit: BoxFit.fill)),
                                child: Container(
                                  padding: EdgeInsets.only(left: 5.0),
                                  width: 160,
                                  height: 60.0,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "${toprated[index].data["name"]}\'s Kitchen",
                                        style: TextStyle(
                                            fontSize: 17.0,
                                            fontFamily: "Gilroy",
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            toprated[index].data['mealtype']
                                                    [0] +
                                                " | " +
                                                toprated[index]
                                                    .data["rating"]
                                                    .toString(),
                                            style: TextStyle(
                                                fontSize: 13.0,
                                                fontFamily: "Gilroy",
                                                color: Colors.black),
                                          ),
                                          Icon(
                                            Icons.star,
                                            color: Color(0xffFE506D),
                                            size: 15.0,
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                    return SizedBox();
                  },
                ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              chip("Chocolates", null),
              chip("Ice creams", null),
              chip("Kulfi", null),
              chip("Sweets", null)
            ],
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.all(20.0),
            child: Text(
              getTranslated(context, "topPicks"),
              style: TextStyle(
                  fontSize: 25.0,
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Gilroy"),
            ),
          ),
          if (_geopoint != null)
            StreamBuilder(
              stream: geo
                  .collection(collectionRef: _database.collection('homemakers'))
                  .within(
                      center: geo.point(
                          latitude: _geopoint.latitude,
                          longitude: _geopoint.longitude),
                      radius: 10,
                      field: 'position'),
              builder: (BuildContext context,
                  AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  List<DocumentSnapshot> temp = [];
                  List<Map<String, dynamic>> menu = [];
                  snapshot.data.every((element) {
                    temp.add(element);
                    return true;
                  });
                  if (snapshot.data.isEmpty) {
                    return Center(
                        child: Text("OOPS, Looks like no one is serving!"));
                  }

                  temp.every((element) {
                    for (int i = 0; i < element.data["menu"].length; i++) {
                      menu.add({
                        "name": element.data["name"],
                        "item": element.data["menu"][i]
                      });
                    }
                    return true;
                  });

                  return Container(
                    height: 500,
                    child: ListView.builder(
                      controller: _controller,
                      itemCount: menu.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Dismissible(
                          key: Key(menu[index]["item"]["name"]),
                          onDismissed: (direction) {
                            if (this.type) {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => LoginPlease()));
                            }
                            _database
                                .collection('users')
                                .document(user.uid)
                                .get()
                                .then((DocumentSnapshot usersnapshot) => {
                                      if (usersnapshot.exists)
                                        {
                                          if (usersnapshot
                                                  .data['current_cart'] ==
                                              null)
                                            {
                                              _database
                                                  .collection('users')
                                                  .document(uid)
                                                  .updateData({
                                                'current_cart': [
                                                  {
                                                    'homemaker': snapshot
                                                        .data[index].documentID,
                                                    'item': menu[index]["item"],
                                                    'quantity': 1
                                                  }
                                                ]
                                              })
                                            }
                                          else
                                            {
                                              _database
                                                  .collection('users')
                                                  .document(uid)
                                                  .updateData({
                                                'current_cart':
                                                    FieldValue.arrayUnion([
                                                  {
                                                    'homemaker': snapshot
                                                        .data[index].documentID,
                                                    'item': menu[index]["item"],
                                                    'quantity': 1
                                                  }
                                                ])
                                              })
                                            }
                                        }
                                    });
                          },
                          background: Container(
                              color: Color(0xffFE516E),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Text("BUY",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25)),
                                  ],
                                ),
                              )),
                          child: Container(
                            margin: EdgeInsets.all(10.0),
                            width: MediaQuery.of(context).size.width,
                            height: 85,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0)),
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
                                              menu[index]["item"]["image"]),
                                          fit: BoxFit.fitWidth),
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      menu[index]["item"]["name"],
                                      style: TextStyle(
                                          fontFamily: "Gilroy",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15.0,
                                          color: Colors.black),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(
                                      "${menu[index]["name"]}\'s Kitchen",
                                      style: TextStyle(
                                          fontFamily: "Gilroy",
                                          fontSize: 13.0,
                                          color: Colors.black),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Text(
                                      "₹${menu[index]["item"]["price"].toString()}/plate",
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
                                  padding: const EdgeInsets.only(
                                      right: 10, bottom: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        width: 20.0,
                                        height: 20.0,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: menu[index]["item"]
                                                            ["veg"] ==
                                                        true
                                                    ? Colors.green
                                                    : Colors.red,
                                                width: 1.0)),
                                        child: Center(
                                          child: Container(
                                            width: 10.0,
                                            height: 10.0,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50.0),
                                                color: menu[index]["item"]
                                                            ["veg"] ==
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
                                          Text(menu[index]["item"]["rating"]
                                              .toString()),
                                          Icon(
                                            Icons.star,
                                            color: Color(0xffFE506D),
                                            size: 15.0,
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 5.0,
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
                return SizedBox();
              },
            )
          else
            Center(
              child: Text("Oops, Looks like no one is delivering near you!"),
            ),
        ],
      ),
    );
  }

  ScrollController _controller = new ScrollController();
  int currentTabIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Color(0xFFF9F9F9),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(children: <Widget>[
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.all(20.0),
                  child: Text(
                    getTranslated(context, "discover"),
                    style: TextStyle(
                        fontSize: 25.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Gilroy"),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 30.0),
                child: GestureDetector(
                    child: Icon(Icons.mic, color: Colors.black),
                    onTap: () async {
                      if (_isAvailable || !_isListening)
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Align(
                                alignment: Alignment.bottomCenter,
                                child: AnimatedContainer(
                                  height:
                                      MediaQuery.of(context).size.height / 4,
                                  decoration: new BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    color: Color(0xFFFE4E74),
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  duration: Duration(seconds: 10),
                                  child: Column(children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.all(20),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          border: Border.all(
                                              width: 2, color: Colors.white)),
                                      child: Icon(
                                        Icons.mic,
                                        size: 90,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      "",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ]),
                                ),
                              );
                            });
                    }),
              ),
            ]),
            Container(
              padding: EdgeInsets.only(left: 15),
              child: TabBar(
                  onTap: (index) => setState(() => currentTabIndex = index),
                  labelPadding: EdgeInsets.only(right: 30),
                  isScrollable: true,
                  indicatorColor: Colors.transparent,
                  controller: tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black26,
                  labelStyle: TextStyle(fontSize: 18, fontFamily: "Gilroy"),
                  unselectedLabelStyle:
                      TextStyle(fontSize: 15, fontFamily: "Gilroy"),
                  tabs: [
                    Tab(
                      text: getTranslated(context, "top"),
                    ),
                    Tab(text: "AI Recommends"),
                  ]),
            ),
            Expanded(
                child: IndexedStack(
                    index: currentTabIndex,
                    children: [topRated(), getAIRecommends()])),
          ],
        ),
      ),
    );
  }

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

  getAIRecommends() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          aiData["weather"] != null
              ? Weekday(
                  desc: aiData["weather"]["weather_type"],
                  temp: aiData["weather"]["temperature"].toString(),
                  geopoint: _geopoint,
                  aiData: aiData,
                  uid: uid,
                  user_uid: user.uid,
                )
              : Center(
                  child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 30),
                    Text(
                      "Loading",
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Gilroy",
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    )
                  ],
                )),
        ],
      ),
    );
  }

  void initDynamicLink() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;
    if (deepLink != null) {
      Navigator.of(context).pushReplacementNamed("/BottomBarPage",
          arguments: deepLink.pathSegments);
    }

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData link) async {
      final Uri deepLink = link?.link;
      if (deepLink != null) {
        log("${deepLink.pathSegments}");
        Navigator.of(context).pushReplacementNamed("/BottomBarPage",
            arguments: deepLink.pathSegments);
      }
    }, onError: (OnLinkErrorException e) async {
      log("error");
      log(e.message);
    });
  }

  Widget chip(String name, Function ontap) {
    return GestureDetector(
     
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Card(
          shadowColor: Colors.blueGrey,
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 6,
          child: Container(
            padding: EdgeInsets.all(8),
            child: Text(name,
                style: TextStyle(
                    fontFamily: "Gilroy",
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
