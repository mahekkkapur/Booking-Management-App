import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econoomaccess/User_Section/Drawer/recipes/recipeList.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:econoomaccess/add_recipe/recipeVariables.dart' as variable;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class Instructions extends StatefulWidget {
  final String userType, name, uid, image;
  final int ingredients;
  final List<String> type;

  const Instructions(
      {Key key,
      this.userType,
      this.name,
      this.uid,
      this.image,
      this.ingredients,
      this.type})
      : super(key: key);
  @override
  _InstructionsState createState() => _InstructionsState();
}

class _InstructionsState extends State<Instructions> {
  static List<dynamic> ingredient = [];
  List<dynamic> nutrition = [];

  Map<String, dynamic> temp = {
    "extendedIngredients": ingredient,
    "instructions": variable.recipe.text,
    "analyzedInstructions": [
      {"steps": variable.recipe.text}
    ],
    "nutrition": {"nutrients": []},
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        elevation: 0.0,
        backgroundColor: Color(0xFFFF9F9F9),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Color(0xFFFF9F9F9),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.all(20.0),
                child: Text(
                  "Add Steps",
                  style: TextStyle(
                      fontSize: 25.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Gilroy"),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width - 50,
                height: MediaQuery.of(context).size.height - 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.grey,
                ),
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  controller: variable.recipe,
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () async => saveDetails(),
                  child: Container(
                    width: 60.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        gradient: LinearGradient(
                            colors: [Color(0xFFFF6530), Color(0xFFFE4E74)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter)),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 30.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              )
            ],
          ),
        ),
      ),
    );
  }

  saveDetails() async {
    if (widget.userType == "homeMaker") {
      Fluttertoast.showToast(msg: "PLEASE WAIT !!");
      List<dynamic> ingr = [];
      ingredient.clear();
      for (int i = 0; i < widget.ingredients; i++) {
        ingr.add(
            variable.quantity[i].text+ " " +widget.type[i]+ " " + variable.ingredients[i].text);
        ingredient.add({
          "name": variable.ingredients[i].text,
          "amount": variable.quantity[i].text+' '+widget.type[i],
          "unit": widget.type[i]
        });
      }
      String url =
          "https://api.edamam.com/api/nutrition-details?app_id=ac67fa2b&app_key=682b70ce63db98f7e29adc77364eb756";
      var body = {"ingr": ingr};
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> nutrients = json.decode(response.body);

        print(nutrients["totalNutrients"]["ENERC_KCAL"]["label"]);

        temp["nutrition"]["nutrients"].add({
          "title": nutrients["totalNutrients"]["ENERC_KCAL"]["label"],
          "quantity": nutrients["totalNutrients"]["ENERC_KCAL"]["quantity"],
          "unit": nutrients["totalNutrients"]["ENERC_KCAL"]["unit"]
        });

        temp["nutrition"]["nutrients"].add({
          "title": nutrients["totalNutrients"]["FAT"]["label"],
          "quantity": nutrients["totalNutrients"]["FAT"]["quantity"],
          "unit": nutrients["totalNutrients"]["FAT"]["unit"]
        });

        temp["nutrition"]["nutrients"].add({
          "title": nutrients["totalNutrients"]["FASAT"]["label"],
          "quantity": nutrients["totalNutrients"]["FASAT"]["quantity"],
          "unit": nutrients["totalNutrients"]["FASAT"]["unit"]
        });

        temp["nutrition"]["nutrients"].add({
          "title": nutrients["totalNutrients"]["PROCNT"]["label"],
          "quantity": nutrients["totalNutrients"]["PROCNT"]["quantity"],
          "unit": nutrients["totalNutrients"]["PROCNT"]["unit"]
        });

        temp["nutrition"]["nutrients"].add({
          "title": nutrients["totalNutrients"]["CHOCDF"]["label"],
          "quantity": nutrients["totalNutrients"]["CHOCDF"]["quantity"],
          "unit": nutrients["totalNutrients"]["CHOCDF"]["unit"]
        });
      }
      print(temp);
      temp["extendedIngredients"] = ingredient;
      temp["instructions"] = variable.recipe.text;
      temp["analyzedInstructions"] = [
        {"steps": variable.recipe.text}
      ];
      DocumentSnapshot snap = await Firestore.instance
          .collection("homemakers")
          .document(widget.uid)
          .get();
      for (int i = 0; i < snap["menu"].length; i++) {
        if (snap["menu"][i]["name"] == widget.name) {
          snap["menu"][i].putIfAbsent("recipe", () => temp);
          Firestore.instance
              .collection("homemakers")
              .document(widget.uid)
              .updateData({"menu": snap["menu"]}).whenComplete(() {
            variable.ingredients.forEach((element) {
              element.clear();
            });
            variable.quantity.forEach((element) {
              element.clear();
            });
          });
        }
      }
      Firestore.instance.collection("recipe").add({
        "image": widget.image,
        "name": widget.name,
        "recipe": temp,
        "user": widget.uid,
        "approved": false
      }).whenComplete(() {
        Navigator.of(context).pushReplacementNamed('/BottomBarMakerPage');
      });
    } else if (widget.userType == "user") {
      Fluttertoast.showToast(msg: "Please wait");
      List<dynamic> ingr = [];
      ingredient.clear();
      for (int i = 0; i < widget.ingredients; i++) {
        ingr.add(
            variable.quantity[i].text + " " +widget.type[i]+ " " + variable.ingredients[i].text);
        ingredient.add({
          "name": variable.ingredients[i].text,
          "amount": variable.quantity[i].text+' '+widget.type[i],
          "unit": ""
        });
      }
      String url =
          "https://api.edamam.com/api/nutrition-details?app_id=ac67fa2b&app_key=682b70ce63db98f7e29adc77364eb756";
      var body = {"ingr": ingr};
      http.Response response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> nutrients = json.decode(response.body);

        print(nutrients["totalNutrients"]["ENERC_KCAL"]["label"]);

        temp["nutrition"]["nutrients"].add({
          "title": nutrients["totalNutrients"]["ENERC_KCAL"]["label"],
          "quantity": nutrients["totalNutrients"]["ENERC_KCAL"]["quantity"],
          "unit": nutrients["totalNutrients"]["ENERC_KCAL"]["unit"]
        });

        temp["nutrition"]["nutrients"].add({
          "title": nutrients["totalNutrients"]["FAT"]["label"],
          "quantity": nutrients["totalNutrients"]["FAT"]["quantity"],
          "unit": nutrients["totalNutrients"]["FAT"]["unit"]
        });

        temp["nutrition"]["nutrients"].add({
          "title": nutrients["totalNutrients"]["FASAT"]["label"],
          "quantity": nutrients["totalNutrients"]["FASAT"]["quantity"],
          "unit": nutrients["totalNutrients"]["FASAT"]["unit"]
        });

        temp["nutrition"]["nutrients"].add({
          "title": nutrients["totalNutrients"]["PROCNT"]["label"],
          "quantity": nutrients["totalNutrients"]["PROCNT"]["quantity"],
          "unit": nutrients["totalNutrients"]["PROCNT"]["unit"]
        });

        temp["nutrition"]["nutrients"].add({
          "title": nutrients["totalNutrients"]["CHOCDF"]["label"],
          "quantity": nutrients["totalNutrients"]["CHOCDF"]["quantity"],
          "unit": nutrients["totalNutrients"]["CHOCDF"]["unit"]
        });
      }
      print(temp);
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      temp["extendedIngredients"] = ingredient;
      temp["instructions"] = variable.recipe.text;
      temp["analyzedInstructions"] = [
        {"steps": variable.recipe.text}
      ];
      Firestore.instance.collection("recipe").add({
        "name": widget.name,
        "recipe": temp,
        "image": widget.image,
        "user": user.uid,
        "approved": false
      }).whenComplete(() {
        variable.ingredients.forEach((element) {
          element.clear();
        });
        variable.quantity.forEach((element) {
          element.clear();
        });
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => RecipeList(uid: user.uid)));
      });
    } else {
      return null;
    }
  }
}
