
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Approval extends StatelessWidget {
  final String imageUrl;
  final String channelName;
  final String uid;
  final String name;

  const Approval({Key key, this.imageUrl, this.channelName, this.uid,this.name})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 140,
      padding: EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              imageUrl == "" ? CircleAvatar() : Image.network(imageUrl),
              SizedBox(width: 5),
              Text(name)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              FlatButton(
                  onPressed: () {
                    Firestore.instance
                        .collection("liveuser")
                        .document(channelName)
                        .collection("users")
                        .document(uid)
                        .delete();
                  },
                  child: Text("Reject")),
              FlatButton(
                  onPressed: () {
                    Firestore.instance
                        .collection("liveuser")
                        .document(channelName)
                        .collection("users")
                        .document(uid)
                        .updateData({"pproval": true});
                  },
                  child: Text("Accept"))
            ],
          )
        ],
      ),
    );
  }
}
