import 'package:econoomaccess/Homemaker/bottom_nav/EditPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:econoomaccess/model.dart';
import 'package:econoomaccess/localization/language_constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;

  List<User> users;
  bool flag = false;
  var name, duration;
  var temp = [];
  var _uid;

  String menuType = "menu";
  String timeslot = "10AM - 12PM";

  // Stream<QuerySnapshot> fetchProductsAsStream() {
  //   return firestore
  //       .collection('homemakers')
  //       .snapshots();
  // }

  getInventory() {
    firestore.collection('recipe').getDocuments().then((doc) {
      doc.documents.every((element) {
        // setState(() {
        print(element.data);
        temp.add({"name": element.data["name"]});
        // temp.add(element.data);
        return true;
        // });
      });
    });
  }

  void getData() async {
    var temp;
    _auth.onAuthStateChanged.listen((user) async {
      temp = await firestore.collection('homemakers').document(user.uid).get();
      if (!mounted) return;
      setState(() {
        _uid = user.uid;
        name = temp.data['name'];
        duration = temp.data['ohours'];
        flag = !flag;
      });
    });
  }

  Widget addInventoryItem(Map<String, dynamic> meal) {
    var itemTimeslot;
    var itemCategory;
    TextEditingController priceController = TextEditingController();
    print(meal);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      //this right here
      child: Container(
        height: 330,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: <Widget>[
                  SizedBox(width: 220),
                  GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(Icons.highlight_off))
                ],
              ),
              Text(
                "How do you want ${meal["name"]}?",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'SF Pro Text',
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0,
                  letterSpacing: -0.8,
                  height: 1.15,
                ),
              ),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                autovalidate: true,
                validator: (value) {
                  if (value.isNotEmpty) {
                    if (int.parse(value) > 0) return null;
                  }
                  return "Enter valid no";
                },
              ),
              SizedBox(
                height: 5,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  // height: 50.0,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0)),
                  child: Center(
                    child: DropdownButton<String>(
                      value: itemTimeslot,
                      hint: Text("Choose a time slot"),
                      style: TextStyle(
                        color: Color.fromRGBO(38, 50, 56, 0.30),
                        fontSize: 15.0,
                        fontFamily: "Gilroy",
                      ),
                      underline: Container(
                        height: 2,
                        color: Colors.black45,
                      ),
                      onChanged: (value) {
                        setState(() {
                          itemTimeslot = value;
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          value: "10AM - 12PM",
                          child: Text(
                            "10AM - 12PM",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "01PM - 04PM",
                          child: Text(
                            "01PM - 04PM",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "06PM - 09PM",
                          child: Text(
                            "06PM - 09PM",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  // height: 50.0,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0)),
                  child: Center(
                    child: DropdownButton<String>(
                      value: itemCategory,
                      hint: Text("Veg / Non - Veg"),
                      style: TextStyle(
                        color: Color.fromRGBO(38, 50, 56, 0.30),
                        fontSize: 15.0,
                        fontFamily: "Gilroy",
                      ),
                      underline: Container(
                        height: 2,
                        color: Colors.black45,
                      ),
                      onChanged: (value) {
                        setState(() {
                          itemCategory = value == "Veg" ? true : false;
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          value: "Veg",
                          child: Text(
                            "Veg",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        DropdownMenuItem(
                          value: "Non - Veg",
                          child: Text(
                            "Non - Veg",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 300.0,
                child: RaisedButton(
                  onPressed: () {
                    var obj = [
                      {
                        "name": meal["name"],
                        "price": int.parse(priceController.text),
                        "image":
                            "https://s3-alpha-sig.figma.com/img/9768/cb29/ef4adc3714b7a54ad0fbf89560fd4013?Expires=1592179200&Signature=SzeyF3HwjBGr0eOeRTXLrmQyfaqTqqWjrgD6ewg2AbkbyWmhbuQw2Drhico1upmMuiFcHDPbF38qU~AfuUFsutvq5MLCttbdYQWxMrS2LLh6a8Pvoy5q6FAr6TR~~~FKS3~ogyx5nrzfVZ0-56b6CeaYW-wKFuWIdNHbQFTKtazv4G2FqocxdH2VNA8vOSFAYwuCqNlYlSFx5S7euiHvmzkA7IV9Ne60vmDDm433O3eyhodwd1TaDVvadyXxZHvVHScO3pdGooFJx~A4tOmFeI5PHT8hYdnV~cYPBsGwSs0EWtyGFpoTzpMpLdQXHeAZAEaSMKidkMO9HM5ZdjxwKQ__&Key-Pair-Id=APKAINTVSUGEWH5XD5UA",
                        "timeslot": itemTimeslot,
                        "promoted": false,
                        "rating": 0,
                        "veg": itemCategory
                      }
                    ];
                    firestore
                        .collection("homemakers")
                        .document(_uid)
                        .updateData({
                      "menu": FieldValue.arrayUnion(obj),
                    }).whenComplete(() {
                      print("Done");
                      Navigator.of(context).pop();
                    });
                  },
                  child: Text(
                    "Add ${meal["name"]}",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SF Pro Text',
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      height: 1.15,
                    ),
                  ),
                  color: Color(0xffFE4E74),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget InventoryItems() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 400,
          child: StreamBuilder(
              stream:
                  firestore.collection("homemakers").document(_uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  var menu = temp.where((meal) {
                    for (int i = 0;
                        i < snapshot.data.data["menu"].length;
                        i++) {
                      if (snapshot.data.data["menu"][i]["name"] == meal["name"])
                        return false;
                    }
                    return true;
                  }).toList();
                  return ListView.builder(
                      itemCount: menu.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: 15.0, left: 10, right: 10),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "${menu[index]["name"]}",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: "Gilroy",
                                        fontSize: 21.0,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.8,
                                        height: 1.15,
                                      ),
                                    ),
                                    // Text(
                                    //   "₹50/plate",
                                    //   style: TextStyle(
                                    //     color: Colors.black54,
                                    //     fontFamily: "Gilroy",
                                    //     fontSize: 13.0,
                                    //     fontWeight: FontWeight.bold,
                                    //     letterSpacing: -0.8,
                                    //     height: 1.15,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color(0xffFE4E74),
                                      width: 2
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Icon(
                                        Icons.add,
                                        color: Color(0xffFE4E74),
                                        size: 25,
                                      )
                                  ),
                                ),
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return addInventoryItem(menu[index]);
                                      });
                                },
                              ),
                            ],
                          ),
                        );
                      });
                } else
                  return Text("Text");
              }),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    getData();
    getInventory();
  }

  Widget MenuItems() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 26),
        // Text(
        //   "${duration}",
        //   style: TextStyle(
        //     color: Color(0xffFE506D),
        //     fontFamily: "Gilroy",
        //     fontWeight: FontWeight.bold,
        //     fontSize: 20.0,
        //   ),
        // ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            // margin: EdgeInsets.only(left: 15.0),
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      timeslot = "10AM - 12PM";
                    });
                  },
                  child: Container(
                      margin: EdgeInsets.all(5.0),
                      child: Text(
                        "10AM - 12PM",
                        style: TextStyle(
                            fontSize: timeslot == "10AM - 12PM" ? 18.0 : 15.0,
                            color: timeslot == "10AM - 12PM"
                                ? Color(0xffFE506D)
                                : Colors.black26,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Gilroy"),
                      )),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      timeslot = "01PM - 04PM";
                    });
                  },
                  child: Container(
                      margin: EdgeInsets.all(5.0),
                      child: Text(
                        "01PM - 04PM",
                        style: TextStyle(
                            fontSize: timeslot == "01PM - 04PM" ? 18.0 : 15.0,
                            color: timeslot == "01PM - 04PM"
                                ? Color(0xffFE506D)
                                : Colors.black26,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Gilroy"),
                      )),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      timeslot = "06PM - 09PM";
                    });
                  },
                  child: Container(
                      margin: EdgeInsets.all(5.0),
                      child: Text(
                        "06PM - 09PM",
                        style: TextStyle(
                            fontSize: timeslot == "06PM - 09PM" ? 18.0 : 15.0,
                            color: timeslot == "06PM - 09PM"
                                ? Color(0xffFE506D)
                                : Colors.black26,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Gilroy"),
                      )),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: StreamBuilder(
                stream: firestore
                    .collection("homemakers")
                    .document(_uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.data.data == null) {
                    return Center(
                        child: Text(
                      "Your Menu is Empty!!",
                      style: TextStyle(fontSize: 30),
                    ));
                  } else if (snapshot.hasData) {
                    return Container(
                      height: 250,
                      child: ListView.builder(
                          itemCount: snapshot.data.data["menu"].length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            if ((snapshot.data.data["menu"][index]["timeslot"])
                                    .toString() ==
                                timeslot) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        "${snapshot.data.data["menu"][index]["name"]}",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: "Gilroy",
                                          fontSize: 21.0,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.8,
                                          height: 1.15,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "₹${snapshot.data.data["menu"][index]["price"]}/plate",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontFamily: "Gilroy",
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.8,
                                        height: 1.15,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return Container();
                            }
                          }),
                    );
                  }
                  return SizedBox();
                }),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(25, 20, 25, 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Hi ${name},",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Gilroy",
                  fontSize: 25.0,
                ),
              ),
              Text(
                "What are you cooking today?",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Gilroy",
                  fontSize: 20.0,
                ),
              ),
              SizedBox(
                height: 41,
              ),
              Container(
                // margin: EdgeInsets.only(left: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          menuType = "menu";
                        });
                      },
                      child: Container(
                          margin: EdgeInsets.all(5.0),
                          child: Text(
                            getTranslated(context, "menu"),
                            style: TextStyle(
                                fontSize: menuType == "menu" ? 25.0 : 20.0,
                                color: menuType == "menu"
                                    ? Color(0xffFE4E74)
                                    : Colors.black45,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Gilroy"),
                          )),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          menuType = "inventory";
                        });
                      },
                      child: Container(
                          margin: EdgeInsets.all(5.0),
                          child: Text(
                            getTranslated(context, "inventory"),
                            style: TextStyle(
                                fontSize: menuType == "inventory" ? 25.0 : 20.0,
                                color: menuType == "inventory"
                                    ? Color(0xffFE4E74)
                                    : Colors.black45,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Gilroy"),
                          )),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 7),
              menuType == "menu"
                  ? Row(
                      children: <Widget>[
                        Text(
                          getTranslated(context, "currmenu"),
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Gilroy",
                            fontSize: 15.0,
                          ),
                        ),
                        SizedBox(
                          width: 25,
                        ),
                        Container(
                          height: 30,
                          width: 80,
                          child: OutlineButton(
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.edit,
                                    color: Color(0xffFE506D),
                                    size: 15,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  new Text(
                                    getTranslated(context, "edit"),
                                    style: TextStyle(
                                      color: Color(0xffFE506D),
                                      fontFamily: "Gilroy",
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w800
                                    ),
                                  ),
                                ],
                              ),
                              borderSide: BorderSide(color: Color(0xffFE506D),width: 2),
                              onPressed: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                    CupertinoPageRoute(
                                        builder: (context) => EditPage()),
                                    (route) => false);
                              },
                              shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(15))),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        getTranslated(context, "invmenu"),
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: "Gilroy",
                          fontSize: 15.0,
                        ),
                      ),
                    ),
              SizedBox(height: 10),
              menuType == "menu" ? this.MenuItems() : this.InventoryItems(),
            ],
          ),
        ),
      ),
    );
  }
}
