import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econoomaccess/User_Section/profile_setup/UpdateMapPage.dart';
import 'package:econoomaccess/localization/language.dart';
import 'package:econoomaccess/localization/language_constants.dart';
import 'package:econoomaccess/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:typicons_flutter/typicons_flutter.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;
  var _name, _uid, _phone, _language, _location, _image, menuType = "profile";
  Language language;
  List<String> _allergies;
  void _changeLanguage(Language language) async {
    Locale _locale = await setLocale(language.languageCode);
    MyApp.setLocale(context, _locale);
  }

  void getData() async {
    var temp;
    if (!mounted) return;
    _auth.onAuthStateChanged.listen((user) async {
      temp = await firestore.collection('users').document(user.uid).get();
      print('user-id = ${user.uid}');
      setState(() {
        _uid = user.uid;
        _name = temp.data['name'];
        _phone = temp.data['mobileno'];
        _image = temp.data['image'];
        _language = temp.data['language'];
        _location = temp.data['city'];
        _allergies = List.from(temp.data['allergies']);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
    getData();
  }

  Widget ProfileItems() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(getTranslated(context, "phone"),
                style: TextStyle(fontSize: 15)),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              child: Container(
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 10),
                    Expanded(
                        child: Text(
                      "$_phone",
                      style: TextStyle(fontSize: 15),
                    )),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                        child: Icon(Icons.edit),
                        onTap: () {
                          TextEditingController mobileController =
                              TextEditingController();
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20.0)),
                                  //this right here
                                  child: Container(
                                    height: 230,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 15, 15, 15),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: <Widget>[
                                              SizedBox(width: 220),
                                              GestureDetector(
                                                  onTap: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child:
                                                      Icon(Icons.highlight_off))
                                            ],
                                          ),
                                          Text(
                                            "Enter your new mobile number :",
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
                                            controller: mobileController,
                                            keyboardType: TextInputType.number,
                                            autovalidate: true,
                                            validator: (value) {
                                              if (value.isNotEmpty) {
                                                if (value.length > 10 ||
                                                    value.length < 10)
                                                  return "Enter valid no";
                                                else
                                                  return null;
                                              }
                                              return "Enter valid no";
                                            },
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          SizedBox(
                                            width: 300.0,
                                            child: RaisedButton(
                                              onPressed: () {
                                                firestore
                                                    .collection("users")
                                                    .document(_uid)
                                                    .updateData({
                                                  "mobileno":
                                                      mobileController.text
                                                }).whenComplete(() {
                                                  getData();
                                                  print("Done");
                                                  Navigator.of(context).pop();
                                                });
                                              },
                                              child: Text(
                                                "Change Number",
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
                              });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(getTranslated(context, "language"),
                style: TextStyle(fontSize: 15)),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              child: Container(
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 10),
                    Expanded(
                        child: Text(
                      "$_language",
                      style: TextStyle(fontSize: 15),
                    )),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                        child: Icon(Icons.edit),
                        onTap: () {
                          var lang;
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20.0)),
                                  //this right here
                                  child: Container(
                                    height: 230,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 15, 15, 15),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: <Widget>[
                                              SizedBox(width: 220),
                                              GestureDetector(
                                                  onTap: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child:
                                                      Icon(Icons.highlight_off))
                                            ],
                                          ),
                                          Text(
                                            "Select Language :",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'SF Pro Text',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15.0,
                                              letterSpacing: -0.8,
                                              height: 1.15,
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 50.0,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        12.0)),
                                            child: Center(
                                              child: DropdownButton<Language>(
                                                hint: Text("Select Language"),
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      38, 50, 56, 0.30),
                                                  fontSize: 15.0,
                                                  fontFamily: "Gilroy",
                                                ),
                                                underline: SizedBox(),
                                                onChanged: (Language language) {
                                                  _changeLanguage(language);
                                                  setState(() {
                                                    lang = language.name;
                                                  });
                                                },
                                                items: Language.languageList()
                                                    .map<
                                                        DropdownMenuItem<
                                                            Language>>(
                                                      (e) => DropdownMenuItem<
                                                          Language>(
                                                        value: e,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Text(
                                                              e.name,
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          SizedBox(
                                            width: 300.0,
                                            child: RaisedButton(
                                              onPressed: () {
                                                firestore
                                                    .collection("users")
                                                    .document(_uid)
                                                    .updateData({
                                                  "language": lang
                                                }).whenComplete(() {
                                                  getData();
                                                  print("Done");
                                                  Navigator.of(context).pop();
                                                });
                                              },
                                              child: Text(
                                                "Change Language",
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
                              });
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(getTranslated(context, "location"),
                style: TextStyle(fontSize: 15)),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              child: Container(
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 10),
                    Expanded(
                        child: Text(
                      "$_location",
                      style: TextStyle(fontSize: 15),
                    )),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                        child: Icon(Icons.edit),
                        onTap: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => UpdateMapPage()));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            //TODO add to resources/language -> allergy
            Text("Allergies (If any)", style: TextStyle(fontSize: 15)),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              child: Container(
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: _allergies.length,
                          itemBuilder: (context, int index) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(10, 10, 15, 0),
                              child: Text(
                                _allergies[index],
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w300),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      height: 100,
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        child: Icon(Icons.edit),
                        onTap: () {
                          TextEditingController mobileController =
                              TextEditingController();
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Container(
                                height: 330,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 15, 15, 15),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: <Widget>[
                                          SizedBox(width: 220),
                                          GestureDetector(
                                            onTap: () =>
                                                Navigator.of(context).pop(),
                                            child: Icon(
                                              Icons.highlight_off,
                                            ),
                                          )
                                        ],
                                      ),
                                      Text(
                                        "Edit allergies :",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'SF Pro Text',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0,
                                          letterSpacing: -0.8,
                                          height: 1.15,
                                        ),
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          height: 100,
                                          child: ListView.separated(
                                            scrollDirection: Axis.vertical,
                                            itemCount: _allergies.length,
                                            itemBuilder: (context, int index) {
                                              return Dismissible(
                                                key:
                                                    ValueKey(_allergies[index]),
                                                direction:
                                                    DismissDirection.startToEnd,
                                                background: Container(
                                                  color: Colors.redAccent,
                                                  child: Icon(
                                                    Icons.delete_forever,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                child: ListTile(
                                                  dense: true,
                                                  title: Text(
                                                    _allergies[index],
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w300),
                                                  ),
                                                ),
                                                onDismissed: (direction) {
                                                  setState(() {
                                                    _allergies.removeAt(index);
                                                  });
                                                },
                                              );
                                            },
                                            separatorBuilder:
                                                (context, index) => Divider(),
                                          ),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: mobileController,
                                        keyboardType: TextInputType.text,
                                        autovalidate: true,
                                        validator: (value) {
                                          if (value.isNotEmpty) {
                                            return null;
                                          }
                                          return "Enter valid allergy";
                                        },
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (term) {
                                          if (mobileController.text != "") {
                                            setState(() {
                                              print('${mobileController.text}');
                                              _allergies
                                                  .add(mobileController.text);
                                            });
                                            mobileController.clear();
                                          }
                                        },
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      SizedBox(
                                        width: 300.0,
                                        child: RaisedButton(
                                          onPressed: () {
//                                            _allergies[index] =
//                                                mobileController.text;
                                            firestore
                                                .collection("users")
                                                .document(_uid)
                                                .updateData({
                                              "allergies": _allergies
                                            }).whenComplete(() {
                                              getData();
                                              print("Done");
                                              Navigator.of(context).pop();
                                            });
                                          },
                                          child: Text(
                                            "Update Allergies",
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
                            ),
                          );
                        },
                      ),
                    ),

//                    Padding(
//                      padding: const EdgeInsets.all(10.0),
//                      child: GestureDetector(
//                        child: Icon(Icons.edit),
//                        onTap: () {
//                          TextEditingController mobileController =
//                              TextEditingController();
//                          showDialog(
//                              context: context,
//                              builder: (BuildContext context) {
//                                return Dialog(
//                                  shape: RoundedRectangleBorder(
//                                      borderRadius:
//                                          BorderRadius.circular(20.0)),
//                                  //this right here
//                                  child: Container(
//                                    height: 230,
//                                    child: Padding(
//                                      padding: const EdgeInsets.fromLTRB(
//                                          15, 15, 15, 15),
//                                      child: Column(
//                                        mainAxisAlignment:
//                                            MainAxisAlignment.start,
//                                        crossAxisAlignment:
//                                            CrossAxisAlignment.start,
//                                        children: [
//                                          Row(
//                                            children: <Widget>[
//                                              SizedBox(width: 220),
//                                              GestureDetector(
//                                                  onTap: () =>
//                                                      Navigator.of(context)
//                                                          .pop(),
//                                                  child:
//                                                      Icon(Icons.highlight_off))
//                                            ],
//                                          ),
//                                          Text(
//                                            "Enter your new mobile number :",
//                                            style: TextStyle(
//                                              color: Colors.black,
//                                              fontFamily: 'SF Pro Text',
//                                              fontWeight: FontWeight.bold,
//                                              fontSize: 15.0,
//                                              letterSpacing: -0.8,
//                                              height: 1.15,
//                                            ),
//                                          ),
//                                          TextFormField(
//                                            controller: mobileController,
//                                            keyboardType: TextInputType.number,
//                                            autovalidate: true,
//                                            validator: (value) {
//                                              if (value.isNotEmpty) {
//                                                if (value.length > 10 ||
//                                                    value.length < 10)
//                                                  return "Enter valid no";
//                                                else
//                                                  return null;
//                                              }
//                                              return "Enter valid no";
//                                            },
//                                          ),
//                                          SizedBox(
//                                            height: 20,
//                                          ),
//                                          SizedBox(
//                                            width: 300.0,
//                                            child: RaisedButton(
//                                              onPressed: () {
//                                                firestore
//                                                    .collection("users")
//                                                    .document(_uid)
//                                                    .updateData({
//                                                  "mobileno":
//                                                      mobileController.text
//                                                }).whenComplete(() {
//                                                  getData();
//                                                  print("Done");
//                                                  Navigator.of(context).pop();
//                                                });
//                                              },
//                                              child: Text(
//                                                "Change Number",
//                                                style: TextStyle(
//                                                  color: Colors.white,
//                                                  fontFamily: 'SF Pro Text',
//                                                  fontSize: 15.0,
//                                                  fontWeight: FontWeight.bold,
//                                                  height: 1.15,
//                                                ),
//                                              ),
//                                              color: Color(0xffFE4E74),
//                                            ),
//                                          ),
//                                        ],
//                                      ),
//                                    ),
//                                  ),
//                                );
//                              });
//                        },
//                      ),
//                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 70,
            )
          ],
        ),
      ),
    );
  }

  Widget ReviewItems() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: StreamBuilder(
          stream: Firestore.instance
              .collection("users")
              .document(uid)
              .collection("reviews")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              print(snapshot.data.documents.isEmpty);
              if (!snapshot.data.documents.isEmpty) {
                return Container(
                  height: 400,
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          margin: EdgeInsets.all(10.0),
                          width: MediaQuery.of(context).size.width,
                          height: 85,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                        child: Text(
                                      "${snapshot.data.documents[index].data["dishname"]}",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    )),
                                    Text(
                                        "${snapshot.data.documents[index].data["rating"]}",
                                        style: TextStyle(fontSize: 15)),
                                    Icon(
                                      Icons.star,
                                      color: Color(0xffFE516E),
                                      size: 20,
                                    )
                                  ],
                                ),
                                // SizedBox(height:5),
                                Text(
                                    "${snapshot.data.documents[index].data["homemaker"]}",
                                    style: TextStyle(fontSize: 10)),
                                SizedBox(height: 5),
                                Text(
                                    "${snapshot.data.documents[index].data["text"]}",
                                    style: TextStyle(fontSize: 10)),
                              ],
                            ),
                          ),
                        );
                      }),
                );
              } else {
                return Column(
                  children: <Widget>[
                    SizedBox(
                      height: 100,
                    ),
                    Container(
                      child: Center(
                          child: Text("No Reviews Posted !!",
                              style: TextStyle(fontSize: 30))),
                    ),
                  ],
                );
              }
            }
            return SizedBox();
          }),
    );
  }

  String uid;

  getUser() async {
    await _auth.currentUser().then((val) {
      setState(() {
        uid = val.uid;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE5E5E5),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(25),
                  bottomLeft: Radius.circular(25)),
              child: Container(
                height: 230,
                width: MediaQuery.of(context).size.width,
                decoration: new BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.grey[50],
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(20.0, 30.0),
                      blurRadius: 40.0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _image != null
                        ? Container(
                            width: 155,
                            height: 155,
                            decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage("$_image"))))
                        : CircleAvatar(
                            backgroundColor: Colors.grey.withOpacity(0.6),
                            radius: 60,
                            child: Icon(
                              Typicons.user_outline,
                              size: 80,
                              color: Colors.black26,
                            ),
                          ),
                    SizedBox(height: 10),
                    Text("$_name",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Container(
                // margin: EdgeInsets.only(left: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          menuType = "profile";
                        });
                      },
                      child: Container(
                          margin: EdgeInsets.all(5.0),
                          child: Text(
                            getTranslated(context, "profile"),
                            style: TextStyle(
                                fontSize: menuType == "profile" ? 20.0 : 17.0,
                                color: menuType == "profile"
                                    ? Colors.black
                                    : Colors.black45,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Gilroy"),
                          )),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          menuType = "reviews";
                        });
                      },
                      child: Container(
                          margin: EdgeInsets.all(5.0),
                          child: Text(
                            getTranslated(context, "reviews"),
                            style: TextStyle(
                                fontSize: menuType == "reviews" ? 20.0 : 17.0,
                                color: menuType == "reviews"
                                    ? Colors.black
                                    : Colors.black45,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Gilroy"),
                          )),
                    ),
                  ],
                ),
              ),
            ),
            menuType == "profile" ? this.ProfileItems() : this.ReviewItems(),
          ],
        ),
      ),
    );
  }
}
