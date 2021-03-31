import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econoomaccess/User_Section/drawer.dart';
import 'package:econoomaccess/common/chats/bot_chat_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

DateFormat dateFormat = DateFormat.Hm();

class ChatPage extends StatelessWidget {
  final String uid, name;

  ChatPage({Key key, @required this.uid, @required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Chats",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Colors.black54,
            fontFamily: "Gilroy",
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Color(0xfff9f9f9),
        elevation: 0.0,
        actions: <Widget>[
          Container(
              padding: EdgeInsets.only(top: 3),
              margin: EdgeInsets.only(top: 8, right: 11),
              child: CircleAvatar(
                backgroundColor: Colors.red,
                radius: 20,
                backgroundImage: AssetImage("images/cropped-naaniz-logo.png"),
              )),
        ],
      ),
      drawer: DrawerWidget(uid: uid),
      body: Container(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            GestureDetector(
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          AssetImage("images/cropped-naaniz-logo.png"),
                      backgroundColor: Colors.black,
                      radius: 30,
                    ),
                    title: Row(
                      children: [
                        Text(
                          "Naaniz Kitchen",
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontFamily: "Gilroy",
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(4, 5, 4, 5),
                          decoration: BoxDecoration(
                              color: Color(0xffFE506D),
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(
                            "BOT",
                            style: TextStyle(
                                fontSize: 10,
                                fontFamily: "Gilroy",
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                    subtitle: Text(
                      "Welcome to Naaniz kitchen!",
                      style: TextStyle(
                        fontFamily: "Gilroy",
                        fontSize: 12,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BotChat(uid, true)));
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection("users")
                    .document(uid)
                    .collection("messages")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());
                  else {
                    List<DocumentSnapshot> docs = snapshot.data.documents;
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        Map lastMessage = docs[index].data["message"].last;
                        List<String> names = docs[index].documentID.split("-");
                        return Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    docs[index].data["homemakerImage"] == null
                                        ? AssetImage("images/defaultImage")
                                        : NetworkImage(
                                            docs[index].data["homemakerImage"]),
                                backgroundColor: Colors.black,
                                radius: 30,
                              ),
                              title: Text(
                                name == lastMessage["reciever"]
                                    ? lastMessage["sender"]
                                    : lastMessage["reciever"],
                                style: TextStyle(
                                  fontFamily: "Gilroy",
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                lastMessage["content"] ?? "",
                                style: TextStyle(
                                  fontFamily: "Gilroy",
                                  fontSize: 12,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                              trailing: Text(dateFormat
                                  .format(lastMessage["time"].toDate())),
                              onTap: () {
                                Navigator.pushNamed(context, "/ChatPage",
                                    arguments: [names[0], names[1]]);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
