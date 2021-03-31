import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:intl/intl.dart';

class Weekday extends StatefulWidget {
  final String desc, temp;
  final GeoPoint geopoint;
  final String user_uid, uid;
  final Map<String, dynamic> aiData;
  const Weekday(
      {Key key,
      this.desc,
      this.temp,
      this.geopoint,
      this.user_uid,
      this.uid,
      @required this.aiData})
      : super(key: key);
  @override
  _WeekdayState createState() => _WeekdayState();
}

class _WeekdayState extends State<Weekday> with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  final _database = Firestore.instance;
  Geoflutterfire geo;
  List<dynamic> weekDates = [];
  var dateTime = DateTime.now();
  List<String> monthList = [];
  List<String> weekList = [];
  final List<String> weekDays = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];
  int currentDay = DateTime.now().weekday;
  TabController tabController;

  getWeekName() {
    List<String> woke = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday"
    ];
    weekList.insert(0,woke[currentDay-1]);
    for (int k = 1; k <= 6; k++) {
      weekList.insert(k,woke[(currentDay -1+ k) % 7]);
    }
    return weekList;
  }

  @override
  void initState() {
    generateCurrentWeekDays();
    geo = Geoflutterfire();
    tabController = TabController(initialIndex: 0, length: 7, vsync: this);
    super.initState();
  }

  getIndex(String e) {
    var index = weekDays.indexOf(e);
    return index;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 280,
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TabBar(
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              indicatorColor: Color(0xffFE506D),
              indicatorSize: TabBarIndicatorSize.label,
              isScrollable: true,
              labelColor: Colors.pink,
              unselectedLabelColor: Colors.black26,
              labelStyle: TextStyle(
                  fontSize: 18,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(
                  fontSize: 15,
                  fontFamily: "Gilroy",
                  fontWeight: FontWeight.w300),
              controller: tabController,
              tabs: weekDays
                  .map((e) => Container(
                        child: Column(
                          children: <Widget>[
                            currentIndex == getIndex(e)
                                ? Text(weekDates[getIndex(e)][0].toString() +
                                    "" +
                                    weekDates[getIndex(e)][1].toString())
                                : Text(weekDates[getIndex(e)][0].toString()),
                            currentIndex == getIndex(e)
                                ? Text(
                                    getWeekName()[getIndex(e)],
                                    style: TextStyle(fontSize: 15),
                                  )
                                : Text(
                                    getWeekName()[getIndex(e)].substring(0, 1),
                                    style: TextStyle(fontSize: 15),
                                  ),
                          ],
                        ),
                      ))
                  .toList()),
          Expanded(
              child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Card(
                  elevation: 5.0,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 60,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        !widget.aiData["festival"].isEmpty
                            ? Text(
                                "Celebrating today",
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w100,
                                    fontFamily: "Gilroy"),
                              )
                            : Container(),
                        widget.aiData["festival"].isEmpty
                            ? Text(
                                "No Festivals Today",
                                style: TextStyle(
                                    color: Color(0xffFE506D),
                                    fontFamily: "Gilroy",
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              )
                            : ListView.builder(
                                itemCount: widget.aiData["festival"].length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Text(
                                    widget.aiData["festival"][index],
                                    style: TextStyle(
                                        color: Color(0xffFE506D),
                                        fontFamily: "Gilroy",
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  );
                                })
                      ],
                    ),
                  ),
                ),
                Container(
                    padding: EdgeInsets.fromLTRB(15, 20, 0, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Expected Weather",
                          style: TextStyle(
                              fontFamily: "Gilroy",
                              fontSize: 14,
                              fontWeight: FontWeight.w200),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.desc,
                          style: TextStyle(
                              color: Color(0xffFE506D),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Gilroy"),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget.temp,
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.black,
                                  fontFamily: "Gilroy",
                                  fontWeight: FontWeight.bold),
                            ),
                            Text("°C",
                                style: TextStyle(
                                    fontFamily: "Gilroy",
                                    fontSize: 15,
                                    fontWeight: FontWeight.w200,
                                    color: Colors.black))
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    )),
                Text(
                  "Recommended",
                  style: TextStyle(
                      fontFamily: "Gilroy",
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: widget.geopoint != null
                      ? StreamBuilder(
                          stream: geo
                              .collection(
                                  collectionRef:
                                      _database.collection('homemakers'))
                              .within(
                                  center: geo.point(
                                      latitude: widget.geopoint.latitude,
                                      longitude: widget.geopoint.longitude),
                                  radius: 10,
                                  field: 'position'),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                                    child: Text(
                                        "OOPS, Looks like no one is serving!"));
                              }

                              temp.every((element) {
                                for (int i = 0;
                                    i < element.data["menu"].length;
                                    i++) {
                                  menu.add({
                                    "name": element.data["name"],
                                    "item": element.data["menu"][i]
                                  });
                                }
                                return true;
                              });
                              Map<String, List<String>> homemakers = {};

                              for (int i = 0;
                                  i <
                                      widget
                                          .aiData["food_recommendation"].length;
                                  i++) {
                                List<String> tempdata = [];
                                for (int j = 0; j < menu.length; j++) {
                                  if (widget.aiData["food_recommendation"][i] ==
                                      menu[j]["item"]["name"]) {
                                    tempdata.add(menu[j]["name"]);
                                  }
                                }
                                if (tempdata.isEmpty) {
                                  homemakers.putIfAbsent(
                                      widget.aiData["food_recommendation"][i],
                                      () => ["No one is preparing"]);
                                } else {
                                  homemakers.putIfAbsent(
                                      widget.aiData["food_recommendation"][i],
                                      () => tempdata);
                                }
                              }

                              return Container(
                                height: 500,
                                child: ListView.builder(
                                  itemCount: widget
                                      .aiData["food_recommendation"].length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      margin: EdgeInsets.all(10.0),
                                      width: MediaQuery.of(context).size.width,
                                      height: 85,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          SizedBox(width: 10),
                                          Container(
                                            width: 100,
                                            height: 70,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: AssetImage(
                                                        "images/noRecipe.jpg"),
                                                    fit: BoxFit.fitWidth),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        15.0)),
                                          ),
                                          SizedBox(
                                            width: 10.0,
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                widget.aiData[
                                                        "food_recommendation"]
                                                    [index],
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
                                                homemakers[widget.aiData[
                                                            "food_recommendation"]
                                                        [index]]
                                                    .toString(),
                                                style: TextStyle(
                                                    fontFamily: "Gilroy",
                                                    fontSize: 13.0,
                                                    color: Colors.black),
                                              ),
                                              SizedBox(
                                                height: 5.0,
                                              ),
                                            ],
                                          ),
                                          Expanded(child: SizedBox()),
                                          SizedBox(
                                            width: 5.0,
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            }
                            return SizedBox();
                          },
                        )
                      : Center(
                          child: Text(
                              "Oops, Looks like no one is delivering near you!"),
                        ),
                )
              ],
            ),
          ))
        ],
      ),
    );
  }

  events(int currentIndexx) {
    return Container(
      child: Text(currentIndex.toString()),
    );
  }

  generateCurrentWeekDays() {
    for (int i = 0; i < 7; i++) {
      weekDates.add((DateFormat('d - MMMM - yyyy')
              .format(dateTime.add(new Duration(days: i))))
          .split("-"));
    }
  }
}
