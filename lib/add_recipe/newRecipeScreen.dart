import 'package:econoomaccess/User_Section/Drawer/recipes/recipeList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:econoomaccess/AuthChoosePage.dart';
import 'package:provider/provider.dart';
import 'package:econoomaccess/User_Section/Drawer/Your_orders/ExistingOrder.dart';

class RecipeScreen extends StatelessWidget {
  final String name;
  final DocumentSnapshot snap;
  RecipeScreen({Key key, @required this.name, @required this.snap})
      : super(key: key);
  // String dishName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RecipeList(uid: uid)));
            },
            child: Icon(Icons.arrow_back_ios)),
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          name,
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: "Gilroy",
              fontSize: 25),
        ),
        backgroundColor: Color(0xFFFF9F9F9),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: ChangeNotifierProvider(
        create: (context) => QuantityModel(),
        child: firestoreRecipe(name, snap),
      ),
    );
  }
}

class RecipeQuantityWidget extends StatefulWidget {
  @override
  _RecipeQuantityWidgetState createState() => _RecipeQuantityWidgetState();
}

class _RecipeQuantityWidgetState extends State<RecipeQuantityWidget> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: () {
            Provider.of<QuantityModel>(context).subtract();
          },
        ),
        Text("${Provider.of<QuantityModel>(context).quantity}"),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            FirebaseAuth.instance.currentUser().then((value) {
              if (value != null) {
                Provider.of<QuantityModel>(context).add();
              } else {
                Navigator.push(context,
                    CupertinoPageRoute(builder: (context) => AuthChoosePage()));
                Fluttertoast.showToast(msg: "Please Login to continue");
              }
            });
          },
        )
      ],
    );
  }
}

class DishDetail extends StatefulWidget {
  final List<dynamic> ingredients;
  final String instructions;
  final List<dynamic> analyzedInstructions;
  final List<dynamic> nutrients;
  const DishDetail({
    this.ingredients,
    this.instructions,
    this.analyzedInstructions,
    this.nutrients,
  });
  @override
  _DishDetailState createState() => _DishDetailState();
}

class _DishDetailState extends State<DishDetail> {
  double rating = 0;
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.25,
      maxChildSize: 0.9,
      minChildSize: 0.25,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                )
              ]),
          child: ListView(
            controller: scrollController,
            children: <Widget>[
              Center(
                child: Text(
                  "Dish Details",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 15),
              Table(
                border: TableBorder.all(),
                children: getNutrients(),
              ),
              const SizedBox(height: 15),
              Center(
                child: Text(
                  "Recipe",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Card(
                elevation: 15,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Ingredients",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...getIngredients(),
                      const SizedBox(height: 10),
                      Text(
                        "Steps",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      getInstructions(context),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
            ],
          ),
        );
      },
    );
  }

  List<TableRow> getNutrients() {
    List<TableRow> list = [];
    for (int i = 0; i < 5; i++) {
      list.add(TableRow(children: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(widget.nutrients[i]["title"]),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
                "${widget.nutrients[i]["quantity"]} ${widget.nutrients[i]["unit"]}"),
          ),
        ),
      ]));
    }
    return list;
  }

  List<Widget> getIngredients() {
    List<Widget> list = [];
    widget.ingredients.forEach((ingredient) {
      list.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text("${ingredient["name"]}"),
          Text("${ingredient["amount"]} ${ingredient["unit"]}"),
        ],
      ));
    });
    return list;
  }

  Widget getInstructions(BuildContext context) {
    if (widget.analyzedInstructions == null ||
        widget.analyzedInstructions.isEmpty)
      return Text(widget.instructions);
    else {
      return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.analyzedInstructions.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                child: Text(
                  "${index + 1}",
                  style: TextStyle(
                      color: Colors.white, fontFamily: "Gilroy", fontSize: 13),
                ),
                backgroundColor: Color(0xffFE4E74),
                radius: 15,
              ),
              title: Text(
                "${widget.analyzedInstructions[index]["step"]}",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Gilroy",
                    fontSize: 15),
              ),
            );
          });
    }
  }
}

Widget firestoreRecipe(String recipeText, DocumentSnapshot snap) {
  return StreamBuilder<QuerySnapshot>(
    stream: Firestore.instance.collection("recipe").snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      dynamic recipe;
      recipe = snap.data["recipe"];
      var recipeImage = snap.data["image"];
      List<dynamic> nullNutrients = [
        {"unit": "Data", "quantity": "No", "title": "Energy"},
        {"unit": "Data", "quantity": "No", "title": "Fat"},
        {"unit": "Data", "quantity": "No", "title": "Saturated"},
        {"unit": "Data", "quantity": "No", "title": "Protein"},
        {"unit": "Data", "quantity": "No", "title": "Carbs"}
      ];

      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
            child: Column(
              children: <Widget>[
                ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    child: recipeImage == null
                        ? Image.asset("images/noRecipe.jpg")
                        : Image.network(
                            recipeImage,
                            height: 200,
                          )),
                const SizedBox(height: 20),
                Center(
                  child: Text(recipeText,
                      style: TextStyle(
                        fontSize: 22,
                      )),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          DishDetail(
            ingredients: (recipe["extendedIngredients"]),
            instructions: recipe["instructions"],
            analyzedInstructions: (null),
            nutrients: recipe["nutrition"]["nutrients"].isEmpty
                ? nullNutrients
                : recipe["nutrition"]["nutrients"],
          ),
        ]),
      );
    },
  );
}

class QuantityModel extends ChangeNotifier {
  int _quantity = 1;
  int get quantity => _quantity;

  void add() {
    _quantity += 1;
    notifyListeners();
  }

  void subtract() {
    if (_quantity > 1) {
      _quantity -= 1;
    }
    notifyListeners();
  }
}
