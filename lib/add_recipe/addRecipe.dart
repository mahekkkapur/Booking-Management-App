import 'dart:convert';
import 'dart:io';
import 'package:econoomaccess/User_Section/Drawer/recipes/recipeList.dart';
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:econoomaccess/add_recipe/recipeVariables.dart' as variable;
import 'package:http/http.dart' as http;
import 'package:econoomaccess/common/Loading/loading.dart';

bool load = false;

class AddRecipe extends StatefulWidget {
  final File image;
  final String name;
  final String uid;
  AddRecipe(
      {Key key, @required this.name, @required this.uid, @required this.image})
      : super(key: key);
  @override
  _AddRecipeState createState() => _AddRecipeState();
}

class _AddRecipeState extends State<AddRecipe> {
  int ingredients = 1;

  @override
  void initState() {
    super.initState();
    load = false;
  }

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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RecipeList(uid: widget.uid)));
            }),
        elevation: 0.0,
        backgroundColor: Color(0xFFFF9F9F9),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Color(0xFFFF9F9F9),
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.all(20.0),
              child: Text(
                "Add Ingredients",
                style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Gilroy"),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 60.0,
                ),
                Text(
                  "Ingredient",
                  style: TextStyle(fontSize: 20.0, fontFamily: "Gilroy"),
                ),
                Expanded(
                  child: SizedBox(),
                ),
                Text(
                  "Quantity",
                  style: TextStyle(fontSize: 20.0, fontFamily: "Gilroy"),
                ),
                SizedBox(
                  width: 10.0,
                ),
              ],
            ),
            Flexible(
              child: ListView.builder(
                itemCount: ingredients,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 10.0),
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50.0),
                            gradient: LinearGradient(
                                colors: [Color(0xFFFF6530), Color(0xFFFE4E74)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter)),
                        child: Center(
                            child: Text(
                          (index + 1).toString(),
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        )),
                      ),
                      Container(
                        width: 100,
                        height: 50,
                        padding: EdgeInsets.only(left: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey,
                        ),
                        margin: EdgeInsets.all(10.0),
                        child: TextField(
                          controller: variable.ingredients[index],
                          decoration: InputDecoration(border: InputBorder.none),
                        ),
                      ),
                      Container(
                        width: 70,
                        padding: EdgeInsets.only(left: 5.0),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey,
                        ),
                        margin: EdgeInsets.all(10.0),
                        child: TextField(
                          controller: variable.quantity[index],
                          decoration: InputDecoration(border: InputBorder.none),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    ingredients++;
                  });
                },
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
                    Icons.add,
                    size: 30.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Recipe(
                                name: widget.name,
                                ingredients: ingredients,
                                image: widget.image,
                              )));
                },
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
    );
  }
}

class Recipe extends StatefulWidget {
  final File image;
  final String name;
  final int ingredients;
  Recipe(
      {Key key,
      @required this.name,
      @required this.ingredients,
      @required this.image})
      : super(key: key);
  @override
  _RecipeState createState() => _RecipeState();
}

class _RecipeState extends State<Recipe> {
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
    return load
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: 25.0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
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
                        onTap: () async {
                          setState(() {
                            load = true;
                          });
                          // Fluttertoast.showToast(msg: "Please wait");
                          List<dynamic> ingr = [];
                          ingredient.clear();
                          for (int i = 0; i < widget.ingredients; i++) {
                            ingr.add(variable.quantity[i].text +
                                " " +
                                variable.ingredients[i].text);
                            ingredient.add({
                              "name": variable.ingredients[i].text,
                              "amount": variable.quantity[i].text,
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
                            Map<String, dynamic> nutrients =
                                json.decode(response.body);

                            print(nutrients["totalNutrients"]["ENERC_KCAL"]
                                ["label"]);

                            temp["nutrition"]["nutrients"].add({
                              "title": nutrients["totalNutrients"]["ENERC_KCAL"]
                                  ["label"],
                              "quantity": nutrients["totalNutrients"]
                                  ["ENERC_KCAL"]["quantity"],
                              "unit": nutrients["totalNutrients"]["ENERC_KCAL"]
                                  ["unit"]
                            });

                            temp["nutrition"]["nutrients"].add({
                              "title": nutrients["totalNutrients"]["FAT"]
                                  ["label"],
                              "quantity": nutrients["totalNutrients"]["FAT"]
                                  ["quantity"],
                              "unit": nutrients["totalNutrients"]["FAT"]["unit"]
                            });

                            temp["nutrition"]["nutrients"].add({
                              "title": nutrients["totalNutrients"]["FASAT"]
                                  ["label"],
                              "quantity": nutrients["totalNutrients"]["FASAT"]
                                  ["quantity"],
                              "unit": nutrients["totalNutrients"]["FASAT"]
                                  ["unit"]
                            });

                            temp["nutrition"]["nutrients"].add({
                              "title": nutrients["totalNutrients"]["PROCNT"]
                                  ["label"],
                              "quantity": nutrients["totalNutrients"]["PROCNT"]
                                  ["quantity"],
                              "unit": nutrients["totalNutrients"]["PROCNT"]
                                  ["unit"]
                            });

                            temp["nutrition"]["nutrients"].add({
                              "title": nutrients["totalNutrients"]["CHOCDF"]
                                  ["label"],
                              "quantity": nutrients["totalNutrients"]["CHOCDF"]
                                  ["quantity"],
                              "unit": nutrients["totalNutrients"]["CHOCDF"]
                                  ["unit"]
                            });
                          }
                          print(temp);
                          FirebaseUser user =
                              await FirebaseAuth.instance.currentUser();
                          temp["extendedIngredients"] = ingredient;
                          temp["instructions"] = variable.recipe.text;
                          temp["analyzedInstructions"] = [
                            {"steps": variable.recipe.text}
                          ];
                          StorageReference storageReference = FirebaseStorage
                              .instance
                              .ref()
                              .child(Path.basename(widget.image.path));
                          await storageReference
                              .putFile(widget.image)
                              .onComplete;
                          String imageUrl =
                              await storageReference.getDownloadURL();

                          Firestore.instance.collection("recipe").add({
                            "name": widget.name,
                            "recipe": temp,
                            "image": imageUrl,
                            "user": user.uid,
                            "approved": false
                          }).whenComplete(() {
                            variable.ingredients.forEach((element) {
                              element.clear();
                            });
                            variable.quantity.forEach((element) {
                              element.clear();
                            });
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        RecipeList(uid: user.uid)));
                          });
                        },
                        child: Container(
                          width: 60.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFF6530),
                                    Color(0xFFFE4E74)
                                  ],
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
}
