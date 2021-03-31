import 'dart:io';
import 'package:econoomaccess/AuthChoosePage.dart';
import 'package:econoomaccess/add_recipe/quantity_details.dart';
import 'package:econoomaccess/agora_live_session/joining_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:econoomaccess/User_Section/drawer.dart';

import 'package:econoomaccess/add_recipe/recipeVariables.dart' as variables;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as Path;

import 'package:image_picker/image_picker.dart';
import 'package:econoomaccess/User_Section/Drawer/recipes/editRecipe.dart';
import 'package:econoomaccess/add_recipe/newRecipeScreen.dart';

class RecipeList extends StatefulWidget {
  final String uid;
  RecipeList({Key key, @required this.uid}) : super(key: key);

  @override
  _RecipeListState createState() => _RecipeListState();
}

String recipeType = "own";
TextEditingController recipeName = new TextEditingController();

class _RecipeListState extends State<RecipeList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File imageFile = null;
  var uid;

  getUser() async {
    await _auth.currentUser().then((val) {
      setState(() {
        uid = val.uid;
      });
    });
  }

  bool type;
  bool load = false;
  getType() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Fluttertoast.showToast(msg: user.isAnonymous.toString());
    setState(() {
      type = user.isAnonymous;
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
    getType();
  }

  sendReq(File image) async {
    Fluttertoast.showToast(msg: "Entered send req for api");
    try {
      String url = "https://naanizflutter.herokuapp.com/food";
      var stream = new http.ByteStream(Stream.castFrom(imageFile.openRead()));
      var length = await imageFile.length();
      var uri = Uri.parse(url);
      var request = new http.MultipartRequest("POST", uri);
      var multipartFile = new http.MultipartFile('file', stream, length,
          filename: Path.basename(imageFile.path));
      request.files.add(multipartFile);
      var response = await request.send();
      print(response.reasonPhrase.toString());
     
    } catch (e) {
      Fluttertoast.showToast(
          msg: "GOt error:" + e.toString(), toastLength: Toast.LENGTH_LONG);
    }
  }

  createDialogue(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            insetAnimationCurve: Curves.easeInOut,
            insetAnimationDuration: Duration(seconds: 1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.camera_alt,
                      size: 30,
                      color: Colors.black54,
                    ),
                    onPressed: () async {
                      await ImagePicker.pickImage(source: ImageSource.camera)
                          .then((image) {
                        setState(() {
                          imageFile = image;

                          sendReq(image);
                        });
                      });
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.photo_library,
                      size: 30,
                      color: Colors.black54,
                    ),
                    onPressed: () async {
                      await ImagePicker.pickImage(source: ImageSource.gallery)
                          .then((image) {
                        setState(() {
                          imageFile = image;
                          print("Image picked at gallery");
                          sendReq(image);
                        });
                      });

                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return load
        ? LoadingPage()
        : Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                showModalBottomSheet(
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0))),
                    context: (context),
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                          builder: (context, StateSetter setState) {
                        return Padding(
                          padding: MediaQuery.of(context).viewInsets,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15.0),
                                  topRight: Radius.circular(15.0)),
                              color: Colors.white,
                            ),
                            height: 450,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () async {
                                    await createDialogue(context)
                                        .whenComplete(() {
                                      setState(() {});
                                    });
                                  },
                                  child: Container(
                                    color: Colors.grey[400],
                                    child: imageFile == null
                                        ? Container(
                                            height: 200,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                100,
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.add,
                                                    size: 100,
                                                    color: Colors.white,
                                                  ),
                                                  Text(
                                                    'Add Image',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20,
                                                        fontFamily: "Gilroy",
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  )
                                                ]),
                                          )
                                        : Image(
                                            height: 200,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                60,
                                            fit: BoxFit.cover,
                                            image: FileImage(imageFile)),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.all(20.0),
                                  child: Text(
                                    "Add Recipe",
                                    style: TextStyle(
                                        fontSize: 25.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Gilroy"),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Color(0xFFF6F6F6),
                                  ),
                                  child: TextField(
                                    style: TextStyle(
                                        fontFamily: "Gilroy", fontSize: 20.0),
                                    decoration: InputDecoration(
                                      hintText: "Enter Recipe name",
                                      border: InputBorder.none,
                                    ),
                                    controller: recipeName,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    if (recipeName.text == null ||
                                        recipeName.text == "") {
                                      Fluttertoast.showToast(
                                          msg: "Please Enter Recipe name");
                                    } else {
                                      addMeal();
                                    }
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
                              ],
                            ),
                          ),
                        );
                      });
                    });
              },
              child: Icon(Icons.add),
              backgroundColor: Color(0xFFFF6530),
            ),
            drawer: DrawerWidget(uid: uid),
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.black),
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
                        "Recipes",
                        style: TextStyle(
                            fontSize: 25.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Gilroy"),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 15.0),
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                recipeType = "own";
                              });
                            },
                            child: Container(
                                margin: EdgeInsets.all(5.0),
                                child: Text(
                                  "My Recipes",
                                  style: TextStyle(
                                      fontSize:
                                          recipeType == "own" ? 18.0 : 15.0,
                                      color: recipeType == "own"
                                          ? Colors.black
                                          : Colors.black26,
                                      fontFamily: "Gilroy"),
                                )),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                recipeType = "other";
                              });
                            },
                            child: Container(
                                margin: EdgeInsets.all(5.0),
                                child: Text(
                                  "All Recipes",
                                  style: TextStyle(
                                      fontSize:
                                          recipeType == "other" ? 18.0 : 15.0,
                                      color: recipeType == "other"
                                          ? Colors.black
                                          : Colors.black26,
                                      fontFamily: "Gilroy"),
                                )),
                          ),
                        ],
                      ),
                    ),
                    recipe(context, recipeType, uid)
                  ],
                ),
              ),
            ),
          );
  }

  Widget recipe(BuildContext context, String type, String uid) {
    File image = null;
    String firebaseImage;

    createDialogue(BuildContext context) {
      return showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              insetAnimationCurve: Curves.easeInOut,
              insetAnimationDuration: Duration(seconds: 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        size: 30,
                        color: Colors.black54,
                      ),
                      onPressed: () async {
                        await ImagePicker.pickImage(source: ImageSource.camera)
                            .then((imageNew) {
                          setState(() {
                            image = imageNew;
                          });
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.photo_library,
                        size: 30,
                        color: Colors.black54,
                      ),
                      onPressed: () async {
                        await ImagePicker.pickImage(source: ImageSource.gallery)
                            .then((imageNew) {
                          setState(() {
                            image = imageNew;
                          });
                        });

                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          });
    }

    TextEditingController recipeNameEdit = new TextEditingController();
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 200,
      child: StreamBuilder(
        stream: Firestore.instance.collection("recipe").snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            List<DocumentSnapshot> temp = [];
            if (type == "own" && !this.type) {
              for (int i = 0; i < snapshot.data.documents.length; i++) {
                if (uid == snapshot.data.documents[i].data["user"]) {
                  temp.add(snapshot.data.documents[i]);
                }
              }
            }
            return GridView.builder(
                physics: BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: this.type ? 1 : 2,
                  childAspectRatio: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.height / 2.5),
                ),
                itemCount: type == "own"
                    ? this.type ? 1 : temp.length
                    : snapshot.data.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  return type == "own"
                      ? this.type
                          ? Container(
                              padding: EdgeInsets.only(bottom: 10.0),
                              margin: EdgeInsets.all(10.0),
                              child: Column(
                                children: <Widget>[
                                  Center(
                                      child: Text(
                                          "Please Login to add your recipes.",
                                          style:
                                              TextStyle(color: Colors.black))),
                                  SizedBox(height: 20),
                                  GestureDetector(
                                    onTap: () {
                                      FirebaseAuth.instance
                                          .signOut()
                                          .whenComplete(() =>
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AuthChoosePage())));
                                    },
                                    child: Container(
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                            color: Colors.redAccent,
                                            border: Border.all(),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Text(
                                          "Login",
                                          style: TextStyle(
                                              fontFamily: "Gilroy",
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white),
                                        )),
                                  )
                                ],
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (context) => RecipeScreen(
                                              name: temp[index]["name"],
                                              snap: temp[index],
                                            )));
                              },
                              child: Container(
                                alignment: Alignment.bottomCenter,
                                padding: EdgeInsets.only(bottom: 10.0),
                                margin: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFFF6530),
                                          Color(0xFFFE4E74)
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter),
                                    image: DecorationImage(
                                      image: temp[index]["image"] == null
                                          ? AssetImage("images/noRecipe.jpg")
                                          : NetworkImage(temp[index]["image"]),
                                      fit: BoxFit.cover,
                                    )),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        GestureDetector(
                                            onTap: () async {
                                              DocumentSnapshot snap =
                                                  await Firestore.instance
                                                      .collection("recipe")
                                                      .document(temp[index]
                                                          .documentID)
                                                      .get();
                                              firebaseImage =
                                                  snap.data["image"];

                                              showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(
                                                                      20.0),
                                                              topRight: Radius
                                                                  .circular(
                                                                      20.0))),
                                                  context: (context),
                                                  builder:
                                                      (BuildContext context) {
                                                    return Padding(
                                                      padding:
                                                          MediaQuery.of(context)
                                                              .viewInsets,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          15.0),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          15.0)),
                                                          color: Colors.white,
                                                        ),
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.7,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            GestureDetector(
                                                              onTap: () {
                                                                createDialogue(
                                                                    context);
                                                              },
                                                              child: Container(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    40,
                                                                color: Colors
                                                                    .grey[400],
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.3,
                                                                child: image ==
                                                                        null
                                                                    ? Image.asset(
                                                                        "images/noRecipe.jpg")
                                                                    : Image(
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        image: FileImage(
                                                                            image)),
                                                              ),
                                                            ),
                                                            Container(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              margin: EdgeInsets
                                                                  .all(20.0),
                                                              child: Text(
                                                                "Add Recipe",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        25.0,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        "Gilroy"),
                                                              ),
                                                            ),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .all(10.0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                                color: Color(
                                                                    0xFFF6F6F6),
                                                              ),
                                                              child:
                                                                  TextFormField(
                                                                onSaved: (v) {
                                                                  setState(() {
                                                                    recipeNameEdit
                                                                        .text = v;
                                                                  });
                                                                },
                                                                onChanged: (v) {
                                                                  setState(() {
                                                                    recipeNameEdit
                                                                        .text = v;
                                                                  });
                                                                },
                                                                initialValue:
                                                                    snap.data[
                                                                            "name"] ??
                                                                        "",
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        "Gilroy",
                                                                    fontSize:
                                                                        20.0),
                                                                decoration:
                                                                    InputDecoration(
                                                                  hintText:
                                                                      "Enter Recipe name",
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                ),
                                                                // controller:
                                                                //     recipeNameEdit,
                                                              ),
                                                            ),
                                                            GestureDetector(
                                                              onTap: () {
                                                                if (recipeNameEdit
                                                                            .text ==
                                                                        null ||
                                                                    recipeNameEdit
                                                                            .text ==
                                                                        "") {
                                                                  Fluttertoast
                                                                      .showToast(
                                                                          msg:
                                                                              "Please Enter Recipe name");
                                                                } else {
                                                                  String name =
                                                                      recipeNameEdit
                                                                          .text;
                                                                  recipeNameEdit
                                                                      .clear();
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          snap.data["recipe"]["extendedIngredients"]
                                                                              .length;
                                                                      i++) {
                                                                    variables
                                                                        .ingredients[
                                                                            i]
                                                                        .text = snap.data["recipe"]
                                                                            [
                                                                            "extendedIngredients"][i]
                                                                        [
                                                                        "name"];
                                                                    variables
                                                                        .quantity[
                                                                            i]
                                                                        .text = snap.data["recipe"]
                                                                            [
                                                                            "extendedIngredients"][i]
                                                                        [
                                                                        "amount"];
                                                                  }
                                                                  variables
                                                                      .recipe
                                                                      .text = snap
                                                                              .data[
                                                                          "recipe"]
                                                                      [
                                                                      "instructions"];
                                                                  Navigator.push(
                                                                      context,
                                                                      CupertinoPageRoute(
                                                                          builder: (context) => EditRecipe(
                                                                                firebaseImage: firebaseImage,
                                                                                image: image,
                                                                                name: name,
                                                                                uid: uid,
                                                                                ingredients: snap.data["recipe"]["extendedIngredients"].length,
                                                                                docId: temp[index].documentID,
                                                                              )));
                                                                }
                                                              },
                                                              child: Container(
                                                                width: 60.0,
                                                                height: 60.0,
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            50),
                                                                    gradient: LinearGradient(
                                                                        colors: [
                                                                          Color(
                                                                              0xFFFF6530),
                                                                          Color(
                                                                              0xFFFE4E74)
                                                                        ],
                                                                        begin: Alignment
                                                                            .topCenter,
                                                                        end: Alignment
                                                                            .bottomCenter)),
                                                                child: Icon(
                                                                  Icons
                                                                      .arrow_forward_ios,
                                                                  size: 30.0,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            },
                                            child: Container(
                                                margin: EdgeInsets.all(2.0),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    gradient: LinearGradient(
                                                        colors: [
                                                          Color(0xFFFF6530),
                                                          Color(0xFFFE4E74)
                                                        ],
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter)),
                                                padding: EdgeInsets.all(5.0),
                                                child: Icon(Icons.edit))),
                                        GestureDetector(
                                            onTap: () {
                                              showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(
                                                                      20.0),
                                                              topRight: Radius
                                                                  .circular(
                                                                      20.0))),
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return Container(
                                                      alignment:
                                                          Alignment.center,
                                                      padding: EdgeInsets.only(
                                                          top: 10.0),
                                                      height: 300,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Text(
                                                            "DO YOU WANT TO DELETE THIS RECIPE?",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    "Gilroy",
                                                                fontSize: 30.0),
                                                          ),
                                                          SizedBox(
                                                            height: 20.0,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: 60.0,
                                                                  height: 60.0,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              50),
                                                                      gradient: LinearGradient(
                                                                          colors: [
                                                                            Color(0xFFFF6530),
                                                                            Color(0xFFFE4E74)
                                                                          ],
                                                                          begin: Alignment
                                                                              .topCenter,
                                                                          end: Alignment
                                                                              .bottomCenter)),
                                                                  child: Icon(
                                                                    Icons.clear,
                                                                    size: 30.0,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 20.0,
                                                              ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  Fluttertoast
                                                                      .showToast(
                                                                          msg:
                                                                              "Please wait");
                                                                  Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "recipe")
                                                                      .document(
                                                                          temp[index]
                                                                              .documentID)
                                                                      .delete()
                                                                      .whenComplete(
                                                                          () {
                                                                    temp.removeAt(
                                                                        index);
                                                                    Navigator.pop(
                                                                        context);
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  width: 60.0,
                                                                  height: 60.0,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              50),
                                                                      gradient: LinearGradient(
                                                                          colors: [
                                                                            Color(0xFFFF6530),
                                                                            Color(0xFFFE4E74)
                                                                          ],
                                                                          begin: Alignment
                                                                              .topCenter,
                                                                          end: Alignment
                                                                              .bottomCenter)),
                                                                  child: Icon(
                                                                    Icons.done,
                                                                    size: 30.0,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  });
                                            },
                                            child: Container(
                                                margin: EdgeInsets.all(2.0),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    gradient: LinearGradient(
                                                        colors: [
                                                          Color(0xFFFF6530),
                                                          Color(0xFFFE4E74)
                                                        ],
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter)),
                                                padding: EdgeInsets.all(5.0),
                                                child:
                                                    Icon(Icons.delete_outline)))
                                      ],
                                    ),
                                    Expanded(child: SizedBox()),
                                    Text(
                                      temp[index].data["name"],
                                      style: TextStyle(
                                          color: temp[index]["image"] == null
                                              ? Colors.black
                                              : Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Gilroy"),
                                    ),
                                  ],
                                ),
                              ),
                            )
                      : GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => RecipeScreen(
                                          name: snapshot.data.documents[index]
                                              .data["name"],
                                          snap: snapshot.data.documents[index],
                                        )));
                          },
                          child: Container(
                            alignment: Alignment.bottomCenter,
                            padding: EdgeInsets.only(bottom: 10.0),
                            margin: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                gradient: snapshot.data.documents[index]
                                            .data["image"] ==
                                        null
                                    ? LinearGradient(
                                        colors: [
                                            Color(0xFFFF6530),
                                            Color(0xFFFE4E74)
                                          ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter)
                                    : null,
                                image: DecorationImage(
                                  image: snapshot.data.documents[index]
                                              .data["image"] ==
                                          null
                                      ? AssetImage("images/noRecipe.jpg")
                                      : NetworkImage(snapshot
                                          .data.documents[index].data["image"]),
                                  fit: BoxFit.cover,
                                )),
                            child: Text(
                              snapshot.data.documents[index].data["name"],
                              style: TextStyle(
                                  color: snapshot.data.documents[index]
                                              .data["image"] ==
                                          null
                                      ? Colors.black
                                      : Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Gilroy"),
                            ),
                          ),
                        );
                });
          }
          return SizedBox();
        },
      ),
    );
  }

  void addMeal() async {
    setState(() {
      load = true;
    });
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(Path.basename(imageFile.path));
    await storageReference.putFile(imageFile).onComplete;
    setState(() async {
      String url = await storageReference.getDownloadURL();
      if (!(url == "")) {
        recipeName.clear();

        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => QuantityDetails(
                    name: recipeName.text,
                    uid: this.uid,
                    imageUrl: url,
                    userType: "user")));
      }
    });
  }
}

class LinkItem {
  final File image;

  LinkItem({this.image});

  LinkItem.fromJson(Map<String, dynamic> json) : image = json['image'];

  Map<String, dynamic> toJson() {
    return {
      'foodimage': image,
    };
  }
}
