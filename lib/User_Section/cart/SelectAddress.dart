import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SelectAddress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String uid = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Address",style: TextStyle(
          color: Colors.black,
          fontFamily: "Gilroy",
        ),),
        backgroundColor: Color(0xfff9f9f9),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection("users").document(uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            DocumentSnapshot doc = snapshot.data;
            List addresses = doc.data["address"];
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        var address = addresses[index];
                        return GestureDetector(
                          onTap: (){
                            Navigator.pop(context,addresses[index]);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(address["name"],style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),),
                                Text(address["address"]),
                                Text(address["locality"]),
                                Row(
                                  children: <Widget>[
                                    Text("${address["city"]},"),
                                    const SizedBox(width: 10,),
                                    Text(address["state"]),
                                  ],
                                ),
                                Text(address["pincode"]),
                                Text(address["phone"]),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text("Add New Address"),
                    textColor: Colors.white,
                    color: Colors.redAccent,
                    onPressed: (){
                      Navigator.pushNamed(context, "/UpdateMapPage");
                    },
                  )
                ],
              ),
            );
          } else {
            return Column(
              children: <Widget>[
                SizedBox(height:100),
                Text("No addresses saved !!"),
                SizedBox(height:300),
                FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text("Add New Address"),
                    textColor: Colors.white,
                    color: Colors.redAccent,
                    onPressed: (){
                      Navigator.pushNamed(context, "/UpdateMapPage");
                    },
                  )
              ],
            );
          }
        },
      ),
    );
  }
}
