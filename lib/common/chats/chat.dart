import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;
  FirebaseUser loggedInUser;
  String messageText;
  var peerId, userId;
  var temp;
  var userName, makerName;
  String homemakerImageUrl;
  String userImageUrl;

  //peerid = homemaker s[1]
  //userid = user s[0]

  @override
  void initState() {
    super.initState();
    getData();
    getUserData();
  }

  getData() async {
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      loggedInUser = user;
    });
  }

  Stream<DocumentSnapshot> fetchDetails() {
    return _firestore
        .collection('users')
        .document(userId)
        .collection('messages')
        .document('$userId-$peerId')
        .snapshots();
  }

  void getUserData() async {
    _auth.onAuthStateChanged.listen((user) async {
      temp = await Firestore.instance
          .collection('users')
          .document(user.uid)
          .get()
          .then((val) {
        setState(() {
          userName = val.data["name"];
          userImageUrl = val.data["image"];
        });
      });
    });
    _auth.onAuthStateChanged.listen((user) async {
      temp = await Firestore.instance
          .collection('homemakers')
          .document(peerId)
          .get()
          .then((val) {
        setState(() {
          makerName = val.data["name"];
          homemakerImageUrl = val.data["image"];
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> s = ModalRoute.of(context).settings.arguments;
    userId = s[0];
    peerId = s[1];

    return Scaffold(
      backgroundColor: Color(0xffE5E5E5),
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 25.0,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        centerTitle: true,
        title: Text(
          "$makerName",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: "Gilroy",
              fontSize: 25),
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<DocumentSnapshot>(
                stream: fetchDetails(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                    );
                  } else {
                    List<MessageBubble> messageBubbles = [];
                    if (snapshot.data.data != null) {
                      final messages = snapshot.data.data["message"].reversed;
                      for (var message in messages) {
                        final messageText = message["content"];
                        final messageSender = message['sender'];
                        final messageBubble = MessageBubble(
                            sender: messageSender,
                            text: messageText,
                            isMe: userName == messageSender);
                        messageBubbles.add(messageBubble);
                      }
                    }
                    return Expanded(
                      child: ListView(
                        reverse: true,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 20.0),
                        children: messageBubbles,
                      ),
                    );
                  }
                }),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Enter Message",
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
                        controller: messageTextController,
                        onChanged: (value) {
                          messageText = value;
                        },
                      ),
                    ),
                    FlatButton(
                        onPressed: () {
                          if (messageTextController.text.isNotEmpty) {
                            _firestore
                                .collection('homemakers')
                                .document(peerId)
                                .collection('messages')
                                .document('$peerId-$userId')
                                .setData({
                              "userImage": userImageUrl,
                              "message": FieldValue.arrayUnion([
                                {
                                  'content': messageText,
                                  'sender': userName,
                                  'reciever': makerName,
                                  'time': DateTime.now(),
                                }
                              ])
                            }, merge: true);
                            messageTextController.clear();
                            _firestore
                                .collection('users')
                                .document(userId)
                                .collection('messages')
                                .document('$userId-$peerId')
                                .setData({
                              "homemakerImage": homemakerImageUrl,
                              "message": FieldValue.arrayUnion([
                                {
                                  'content': messageText,
                                  'sender': userName,
                                  'reciever': makerName,
                                  'time': DateTime.now(),
                                }
                              ])
                            }, merge: true);
                            messageTextController.clear();
                          }
                        },
                        child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xffFE506D)),
                            child: Transform.rotate(
                                angle: -pi / 6,
                                child: Icon(Icons.send, color: Colors.white)))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({this.sender, this.text, this.isMe});

  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender ?? " ",
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: BorderRadius.only(
                topLeft: isMe ? Radius.circular(25.0) : Radius.circular(0.0),
                topRight: !isMe ? Radius.circular(25.0) : Radius.circular(0.0),
                bottomLeft: Radius.circular(25.0),
                bottomRight: Radius.circular(25.0)),
            elevation: 2.0,
            color: isMe ? Color(0xffFE506D) : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text ?? "",
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
