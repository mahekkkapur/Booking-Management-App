import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econoomaccess/agora_live_session/hosting_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class LiveSessionTitle extends StatefulWidget {
  @override
  _LiveSessionTitleState createState() => _LiveSessionTitleState();
}

class _LiveSessionTitleState extends State<LiveSessionTitle> {
  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  getData() async {
    FirebaseAuth.instance.onAuthStateChanged.listen((user) async {
      var temp = await Firestore.instance
          .collection('homemakers')
          .document(user.uid)
          .get();
      setState(() {
        imgUrl = temp["image"];
        name = temp["buissnessname"];
      });
    });
  }

  final titleController = TextEditingController();
  String name = "", imgUrl = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            Container(
              height: 170,
              color: Colors.redAccent.withOpacity(0.6),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios,
                              size: 30,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, top: 10),
                          child: Text(
                            "GO Live",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Gilroy",
                                fontSize: 20),
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, right: 16.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.green,
                        radius: 30,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(60)),
                          child: CircleAvatar(
                            radius: 28,
                            child: imgUrl != ""
                                ? Image.network(
                                    imgUrl,
                                    fit: BoxFit.fill,
                                    width: 56,
                                    height: 56,
                                  )
                                : Container(
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                color: Colors.redAccent.withOpacity(0.6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10),
                      child: TextFormField(
                        style:
                            TextStyle(color: Color.fromRGBO(38, 50, 56, .50)),
                        validator: (input) {
                          if (input.isEmpty) {
                            return "Enter Title.";
                          }
                          return null;
                        },
                        controller: titleController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Enter title',
                          hintStyle: TextStyle(
                            color: Color.fromRGBO(38, 50, 56, 0.30),
                            fontSize: 15.0,
                            fontFamily: "Gilroy",
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (titleController.text.isEmpty) {
                          Fluttertoast.showToast(
                              msg: "Title should not be empty");
                        } else {
                          onCreate(username: name,image: imgUrl,channelname: titleController.text);
                        }
                      },
                      child: Center(
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 27,
                            backgroundColor: Colors.redAccent.withOpacity(0.6),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> onCreate({username, image, channelname}) async {
    await _handleCameraAndMic();
    var date = DateTime.now();
    var currentTime = '${DateFormat("dd-MM-yyyy hh:mm:ss").format(date)}';
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HostingPage(
          channelName: channelname,
          time: currentTime,
          image: image,
          name: name,
        ),
      ),
    );
  }

  Future<void> _handleCameraAndMic() async {
    Fluttertoast.showToast(msg: "Entered handleCameraandMic");
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }
}
