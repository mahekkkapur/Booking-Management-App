import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econoomaccess/Homemaker/MakerDrawer.dart';
import 'package:flutter/material.dart';

class PromotionList extends StatefulWidget {
  @override
  _PromotionListState createState() => _PromotionListState();
}

class _PromotionListState extends State<PromotionList> {
  @override
  Widget build(BuildContext context) {
    String s = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      drawer: MakerDrawerWidget(uid: s),
      appBar: AppBar(
        iconTheme: IconThemeData(color:Colors.black),
        elevation: 0.0,
        backgroundColor: Color(0xFFFF9F9F9),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.all(20.0),
              child: Text(
                "Promotion",
                style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Gilroy"),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height - 200,
              child: StreamBuilder<DocumentSnapshot>(
                  stream: Firestore.instance
                      .collection("promotion")
                      .document(s)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasData) {
                      return ListView.builder(
                          itemCount: snapshot.data.data['promotion'].length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              margin: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(width: 10),
                                      Container(
                                        width: 100,
                                        height: 70,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: NetworkImage(snapshot
                                                        .data.data['promotion']
                                                    [index]['image']),
                                                fit: BoxFit.fitWidth),
                                            borderRadius:
                                                BorderRadius.circular(15.0)),
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
                                            snapshot.data.data['promotion']
                                                [index]['name'],
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
                                            "₹${snapshot.data.data['promotion'][index]['price'].toString()}/plate",
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                              width: 20.0,
                                              height: 20.0,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: snapshot.data.data[
                                                                      'promotion']
                                                                  [
                                                                  index]['veg'] ==
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
                                                          BorderRadius.circular(
                                                              50.0),
                                                      color: snapshot.data.data[
                                                                      'promotion']
                                                                  [
                                                                  index]['veg'] ==
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
                                                Text(snapshot
                                                    .data
                                                    .data['promotion'][index]
                                                        ['rating']
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
                                  Container(
                                    padding: EdgeInsets.all(20.0),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              "Earned from promotions",
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontFamily: "Gilroy"),
                                            ),
                                            Expanded(child: SizedBox()),
                                            Text("75\$/100\$")
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              "Paid to promoters",
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontFamily: "Gilroy"),
                                            ),
                                            Expanded(child: SizedBox()),
                                            Text("4\$/10\$")
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              "Days Active",
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontFamily: "Gilroy"),
                                            ),
                                            Expanded(child: SizedBox()),
                                            Text("7/10Days")
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10.0,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              "Activity",
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  fontFamily: "Gilroy"),
                                            ),
                                            Expanded(child: SizedBox()),
                                            Container(
                                              height: 30.0,
                                              width: 80.0,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0)),
                                              child: Row(
                                                children: <Widget>[
                                                  GestureDetector(
                                                    onTap: () {
                                                      snapshot.data.data[
                                                                  "promotion"]
                                                              [index]
                                                          ["promoted"] = true;
                                                      Firestore.instance
                                                          .collection(
                                                              "promotion")
                                                          .document(s)
                                                          .updateData({
                                                        "promotion": snapshot
                                                            .data
                                                            .data["promotion"]
                                                      });
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(5.0),
                                                      width: 40,
                                                      height: 50.0,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            width: 1.0,
                                                            color: Color(
                                                                0xffFE506D)),
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        20.0),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        20.0)),
                                                        color: snapshot.data.data[
                                                                            "promotion"]
                                                                        [index][
                                                                    "promoted"] ==
                                                                true
                                                            ? Color(0xffFE506D)
                                                            : Colors.white,
                                                      ),
                                                      child: Text("ON"),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      snapshot.data.data[
                                                                  "promotion"]
                                                              [index]
                                                          ["promoted"] = false;
                                                      Firestore.instance
                                                          .collection(
                                                              "promotion")
                                                          .document(s)
                                                          .updateData({
                                                        "promotion": snapshot
                                                            .data
                                                            .data["promotion"]
                                                      });
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(5.0),
                                                      width: 40,
                                                      height: 50.0,
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              width: 1.0,
                                                              color: Color(
                                                                  0xffFE506D)),
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          20.0),
                                                                  bottomRight:
                                                                      Radius.circular(
                                                                          20.0)),
                                                          color: snapshot.data.data["promotion"]
                                                                          [index]
                                                                      ["promoted"] ==
                                                                  false
                                                              ? Color(0xffFE506D)
                                                              : Colors.white),
                                                      child: Text("OFF"),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          });
                    } else {
                      return Center(
                          child: Text("No Promotions Available!",
                              style: TextStyle(fontSize: 25)));
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}
