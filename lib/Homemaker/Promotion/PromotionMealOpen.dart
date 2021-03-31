import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PromotionMealOpen extends StatefulWidget {
  @override
  _PromotionMealOpenState createState() => _PromotionMealOpenState();
}

class _PromotionMealOpenState extends State<PromotionMealOpen> {
  List<String> data;

  @override
  void didChangeDependencies() {
    data = ModalRoute
        .of(context)
        .settings
        .arguments as List<String>;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    print(data);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection("homemakers")
            .document(data[0])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          else {
            DocumentSnapshot doc = snapshot.data;
            Map<String, dynamic> meal = doc.data["menu"].firstWhere((element) {
              if (element["name"] == data[1]) return true;
              return false;
            });
            return Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              height: MediaQuery
                  .of(context)
                  .size
                  .height,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
              child: Column(
                children: <Widget>[
                  ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      child: Image.network(meal["image"])),
                  const SizedBox(height: 20),
                  Text("${data[0]}| ${data[1]}",
                      style: TextStyle(
                        fontSize: 22,
                      )),
                  const SizedBox(height: 20),
                  RecipeQuantityWidget(
                    homeMaker: data[0],
                    mealName: data[1],
                    uid: data[2],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class RecipeQuantityWidget extends StatefulWidget {
  final String uid;
  final String mealName;
  final String homeMaker;

  RecipeQuantityWidget({this.uid, this.mealName, this.homeMaker});

  @override
  _RecipeQuantityWidgetState createState() => _RecipeQuantityWidgetState();
}

class _RecipeQuantityWidgetState extends State<RecipeQuantityWidget> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text("Quantity"),
            Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: (quantity == 1)
                      ? null
                      : () {
                    setState(() {
                      quantity--;
                    });
                  },
                ),
                Text("$quantity"),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      quantity++;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        MaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "Buy now",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "Gilroy",
                fontSize: 15),
          ),
          color: Colors.deepOrange,
          textColor: Colors.white,
          onPressed: () {
            //TODO add payment logic
            print("${widget.uid}");
            DocumentReference docRef =
            Firestore.instance.collection("users").document(widget.uid);
            Firestore.instance.runTransaction((transaction) async {
              DocumentSnapshot docSnap = await docRef.get();
              Map obj = docSnap.data["promotionItems"];
              obj[widget.homeMaker][widget.mealName]["earned"] += quantity *
                  int.parse(obj[widget.homeMaker][widget.mealName]["cut"]);
              obj[widget.homeMaker][widget.mealName]["orders"] += quantity;

              if (obj[widget.homeMaker][widget.mealName]["orders"] ==
                  int.parse(obj[widget.homeMaker][widget.mealName]["requiredOrders"])) {
                var wallet = obj[widget.homeMaker][widget.mealName]["earned"];
                obj[widget.homeMaker].remove(widget.mealName);
                transaction.update(docRef, {
                  "promotionItems": obj,
                  "wallet": FieldValue.increment(wallet),
                });
                Firestore.instance.collection("homemakers").document(
                    widget.homeMaker).updateData({
                'promotedCut': FieldValue.increment(wallet),
                });
              } else {
                transaction.update(docRef, {
                  "promotionItems": obj,
                });
              }
            });
          },
        ),
      ],
    );
  }
}
