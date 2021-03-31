import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econoomaccess/agora_live_session/joining_screen.dart';
import 'package:econoomaccess/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class LiveSessions extends StatefulWidget {
  @override
  _LiveSessionsState createState() => _LiveSessionsState();
}

class _LiveSessionsState extends State<LiveSessions> {
  String uid;
  String userName, image;
  @override
  void initState() {
    getData();
    getUid();
    super.initState();
  }

  getUid() async {
    await FirebaseAuth.instance.currentUser().then((val) {
      setState(() {
        uid = val.uid;
      });
    });
  }

  void getData() async {
    FirebaseAuth.instance.onAuthStateChanged.listen((user) async {
      var temp =
          await Firestore.instance.collection('users').document(user.uid).get();
      if (!mounted) return;
      setState(() {
        userName = temp["name"];
        image = temp["image"];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Live Sessions",
          style: TextStyle(
              color: Colors.black,
              fontFamily: "GIlroy",
              fontWeight: FontWeight.bold,
              fontSize: 24,
              letterSpacing: 2),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        child: StreamBuilder(
            stream: Firestore.instance.collection("liveuser").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.data.documents.length != 0) {
                return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          saveData(
                              userName,
                              snapshot.data.documents[index]["channelName"],
                              image,
                              uid);
                          onJoin(
                              channelName: snapshot.data.documents[index]
                                  ["channelName"],
                              channelId: snapshot.data.documents[index]
                                  ["channel"],
                              username: userName,
                              hostImage: snapshot.data.documents[index]
                                  ["image"],
                              userImage: image);
                        },
                        child: Container(
                          height: 100,
                          alignment: Alignment.center,
                          child: Text(
                              snapshot.data.documents[index]["channelName"]),
                        ),
                      );
                    });
              } else {
                return Center(
                  child: Text("No live sessions"),
                );
              }
            }),
      ),
    );
  }

  Future<void> onJoin(
      {channelName, channelId, username, hostImage, userImage}) async {
    await _handleCameraAndMic();
    if (channelName.isNotEmpty) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JoiningSessionPage(
              channelName: channelName,
              channelId: channelId,
              username: username,
              hostImage: hostImage,
              uid: uid,
              userImage: userImage,
              ),
        ),
      );
    }
  }

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }

  Future<void> saveData(
      String name, String channelName, String imageurl, String uid) async {
    FirestoreService.addUser(
        name: name, channelName: channelName, imageUrl: imageurl, uid: uid);
  }
}
