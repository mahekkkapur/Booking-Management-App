import 'package:econoomaccess/models/exchange.dart';
import 'package:econoomaccess/widgets/user_section/food_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:econoomaccess/localization/language_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<String> tags = [];
  List<String> mealTypes = [];
  var uid;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool restaurantSelected = true;
  final String defaultImageUrl =
      "https://firebasestorage.googleapis.com/v0/b/naniz-team.appspot.com/o/defaultImage.jpg?alt=media&token=8fa0d735-4c1b-4ef4-bb3f-a9f45bd31d83";

  bool type;
  Geoflutterfire geo;
  List<String> recentSearches;
  SharedPreferences pref;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool micListening = false;
  GeoPoint _geopoint;
  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  String _currentLocaleId = "";
  final SpeechToText speech = SpeechToText();

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    if (hasSpeech) {
      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale.localeId;
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  getLocation() async {
    if (type) {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _geopoint = GeoPoint(position.latitude, position.longitude);
      });
    } else {
      var loc;
      FirebaseAuth.instance.onAuthStateChanged.listen((user) async {
        loc = await Firestore.instance
            .collection('users')
            .document(user.uid)
            .get();
        if (!mounted) return;
        setState(() {
          _geopoint = loc["position"]["geopoint"];
        });
      });
    }
  }

  void requestPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.microphone);

    if (permission != PermissionStatus.granted) {
      await PermissionHandler()
          .requestPermissions([PermissionGroup.microphone]);
    }
  }

  void startListening() {
    lastWords = "";
    lastError = "";
    speech.listen(
      onResult: resultListener,
      listenFor: Duration(seconds: 10),
      localeId: _currentLocaleId,
      onSoundLevelChange: soundLevelListener,
      cancelOnError: true,
      partialResults: true,
    );

    setState(() {});
  }

  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = "${result.recognizedWords}";
      setState(() {
        searchController.text = lastWords;
        searchValue = lastWords;
      });
    });
  }

  void soundLevelListener(double level) {
    minSoundLevel = math.min(minSoundLevel, level);
    maxSoundLevel = math.max(maxSoundLevel, level);
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) {
    Fluttertoast.showToast(msg: status);
    setState(() {
      lastStatus = "$status";
      if ("$status" == "notListening") {
        setState(() {
          micListening = false;
        });
      }
    });
  }

  getUser() async {
    await _auth.currentUser().then((val) {
      setState(() {
        uid = val.uid;
        type = val.isAnonymous;
      });
    });
    getLocation();
    pref = await SharedPreferences.getInstance();
    recentSearches = pref.getStringList("searches") ?? [];
  }

  @override
  void initState() {
    super.initState();
    geo = Geoflutterfire();
    getUser();
    initSpeechState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String searchValue = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                textCapitalization: TextCapitalization.sentences,
                controller: searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.only(left: 15),
                  suffixIcon: GestureDetector(
                    child: micListening ? Icon(Icons.mic_off) : Icon(Icons.mic),
                    onTap: () {
                      if (micListening) {
                        setState(() {
                          micListening = !micListening;
                        });
                        if (speech.isListening) {
                          stopListening();
                        }
                      } else {
                        requestPermission();
                        setState(() {
                          micListening = !micListening;
                        });
                        if (!(!_hasSpeech || speech.isListening)) {
                          startListening();
                        }
                      }
                    },
                  ),
                  hintText: micListening ? "Listening voice....." : '',
                  labelText: getTranslated(context, "searchLabel"),
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Gilroy',
                    fontSize: 15.0,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchValue = value;
                  });
                },
                onFieldSubmitted: (String val) {
                  recentSearches.add(val);
                  pref.setStringList("searches", recentSearches);
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                      child: FlatButton(
                    shape: (restaurantSelected)
                        ? Border(
                            bottom:
                                BorderSide(width: 2, color: Colors.redAccent),
                          )
                        : Border(),
                    child: Text("Restaurant"),
                    onPressed: (restaurantSelected)
                        ? null
                        : () {
                            setState(() {
                              restaurantSelected = true;
                            });
                          },
                  )),
                  Expanded(
                      child: FlatButton(
                    shape: (!restaurantSelected)
                        ? Border(
                            bottom:
                                BorderSide(width: 2, color: Colors.redAccent),
                          )
                        : Border(),
                    child: Text("Dishes"),
                    onPressed: (!restaurantSelected)
                        ? null
                        : () {
                            setState(() {
                              restaurantSelected = false;
                            });
                          },
                  )),
                ],
              ),
              const SizedBox(height: 10),
              ...getFilter(),
              (searchValue.isEmpty)
                  ? Text(
                      "Recent Searches",
                      style: TextStyle(
                          fontSize: 25.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Gilroy"),
                    )
                  : Container(),
              getRecentSearches(),
              Expanded(
                child: (restaurantSelected) ? restaurantList() : dishList(),
              )
            ]),
      ),
    );
  }

  Stream<List<DocumentSnapshot>> restaurantSearch() {
    CollectionReference colRef = Firestore.instance.collection("homemakers");
    //search is case sensitive - make name of restaurant be all lowercase
    if (searchValue.isNotEmpty) {
      colRef = colRef
          .where("name", isGreaterThanOrEqualTo: searchValue)
          .where("name", isLessThan: searchValue + 'z')
          .reference();
    } else if (mealTypes.isNotEmpty) {
      colRef =
          colRef.where("mealtype", arrayContainsAny: mealTypes).reference();
    }
    return geo
        .collection(
          collectionRef: colRef,
        )
        .within(
            center: geo.point(
                latitude: _geopoint.latitude, longitude: _geopoint.longitude),
            radius: 100000,
            field: 'position');
  }

  Widget createMealFilterChip(String filterValue) {
    List<String> filterList = mealTypes;
    return FilterChip(
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 1),
        borderRadius: BorderRadius.circular(11.5),
      ),
      label: Text(
        filterValue,
        style: TextStyle(
          color:
              (filterList.contains(filterValue)) ? Colors.white : Colors.black,
        ),
      ),
      checkmarkColor: Colors.white,
      selectedColor: Color(0xffFE506D),
      backgroundColor: Colors.white,
      selected: filterList.contains(filterValue),
      padding: const EdgeInsets.all(10),
      onSelected: (value) {
        if (value) {
          setState(() {
            filterList.add(filterValue);
          });
        } else {
          setState(() {
            filterList.remove(filterValue);
          });
        }
      },
    );
  }

  Widget createFilterChip(String filterValue, List<String> filterList,
      Color bgColor, Color textColor) {
    return FilterChip(
      label: Text(
        filterValue,
        style: TextStyle(
          color: (filterList.contains(filterValue)) ? Colors.white : textColor,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          width: 0,
          color: (filterValue == "Non Veg") ? Colors.black : bgColor,
        ),
      ),
      checkmarkColor: Colors.white,
      selectedColor: Color(0xffFE506D),
      backgroundColor: bgColor,
      selected: filterList.contains(filterValue),
      padding: const EdgeInsets.all(10),
      onSelected: (value) {
        if (value) {
          setState(() {
            filterList.add(filterValue);
          });
        } else {
          setState(() {
            filterList.remove(filterValue);
          });
        }
      },
    );
  }

  List<Widget> getFilter() {
    if (searchController.text.isEmpty) {
      if (restaurantSelected) {
        return <Widget>[
          Wrap(
            spacing: 10,
            children: <Widget>[
              createMealFilterChip("Burgers"),
              createMealFilterChip("Coffee"),
              createMealFilterChip("Sandwiches"),
              createMealFilterChip("Rice"),
              createMealFilterChip("Paratha"),
              createMealFilterChip("Maggi"),
              createMealFilterChip("Rolls"),
              createMealFilterChip("Sweets"),
            ],
          ),
          const SizedBox(height: 10),
        ];
      } else
        return <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              createFilterChip("Top dishes", tags, Colors.black, Colors.white),
              createFilterChip("Veg", tags, Color(0xff15D0A1), Colors.black),
              createFilterChip("Non Veg", tags, Colors.white, Colors.black),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            getTranslated(context, "popular"),
            style: TextStyle(
                fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
        ];
    } else
      return <Widget>[Container()];
  }

  StreamBuilder restaurantList() {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: restaurantSearch(),
      builder: (context, snapshot) {
        if (snapshot.hasError)
          return Text("${snapshot.error}");
        else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Color(0xffFE506D),
            ),
          );
        } else {
          List<DocumentSnapshot> restaurants = snapshot.data;
          if (restaurants.length == 0)
            return Center(child: Text("No one is serving near you"));
          return ListView.builder(
            itemCount: restaurants.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed("/ProfilePage",
                      arguments: restaurants[index].documentID);
                },
                child: Container(
                  margin: EdgeInsets.all(5.0),
                  width: MediaQuery.of(context).size.width,
                  height: 85,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(width: 10),
                      Container(
                        width: 100,
                        height: 70,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                  restaurants[index].data["image"] ??
                                      defaultImageUrl),
                              fit: BoxFit.fitWidth,
                            ),
                            borderRadius: BorderRadius.circular(15.0)),
                      ),
                      const SizedBox(width: 10.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            restaurants[index].data['name'],
                            style: TextStyle(
                                fontFamily: "Gilroy",
                                fontWeight: FontWeight.w600,
                                fontSize: 15.0,
                                color: Colors.black),
                          ),
                        ],
                      ),
                      const Expanded(child: SizedBox()),
                      Padding(
                        padding: const EdgeInsets.only(right: 10, bottom: 15),
                        child: Row(
                          children: <Widget>[
                            Text(restaurants[index]['rating'].toString()),
                            const Icon(
                              Icons.star,
                              color: Color(0xffFE506D),
                              size: 15.0,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 5.0)
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  StreamBuilder dishList() {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: geo
          .collection(
              collectionRef: Firestore.instance.collection("homemakers"))
          .within(
              center: geo.point(
                  latitude: _geopoint.latitude, longitude: _geopoint.longitude),
              radius: 1000000000,
              field: 'position'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          List<DocumentSnapshot> docs = snapshot.data;
          List meals = [];
          docs.forEach((doc) {
            List menu = doc.data["menu"];
            for (int i = 0; i < menu.length; i++) {
              menu[i]["homemaker"] = doc.data["name"];
              menu[i]["docId"] = doc.documentID;
              menu[i]["delivery"] = doc.data["delivery"];
              menu[i]["index"] = i;
              meals.add(menu[i]);
            }
          });

          if (searchController.text.isNotEmpty) {
            meals = meals.where((meal) {
              if (meal["name"]
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase())) return true;
              return false;
            }).toList();
          }
          meals = meals.where((meal) {
            if (tags.contains("Veg") && tags.contains("Non Veg")) return true;
            if (tags.contains("Veg")) {
              if (meal["veg"] == true)
                return true;
              else
                return false;
            }
            if (tags.contains("Non Veg")) {
              if (meal["veg"] == false)
                return true;
              else
                return false;
            }
            return true;
          }).toList();

          if (tags.contains("Top dishes")) {
            meals.sort((a, b) {
              a["rating"] ??= 0;
              b["rating"] ??= 0;
              return b["rating"].compareTo(a["rating"]);
            });
          }
          return ListView.builder(
            // controller: _controller,
            itemCount: meals.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  var args = ScreenArguments(
                      meals[index]["docId"],
                      meals[index]['name'],
                      meals[index]['veg'],
                      meals[index]['rating'],
                      meals[index]['price'],
                      meals[index]['image'],
                      meals[index]["index"],
                      meals[index]["delivery"]);
                  Navigator.of(context)
                      .pushNamed("/RecipePage", arguments: args);
                },
                child: FoodCard(
                    price: "₹${meals[index]['price'].toString()}/plate",
                    homemakername: "${meals[index]["homemaker"]}\'s Kitchen",
                    isveg: meals[index]['veg'] == true,
                    recipename: meals[index]['name'],
                    offerAvailable: false,
                    imageUrl: meals[index]['image']),
              );
            },
          );
        }
      },
    );
  }

  Widget getRecentSearches() {
    if (searchValue.isNotEmpty) return Container();
    return Wrap(
      spacing: 10,
      children: recentSearches?.map((value) {
            return FlatButton(
              child: Text(value),
              onPressed: () {
                searchController.text = value;
                setState(() {
                  searchValue = value;
                });
              },
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          })?.toList() ??
          [],
    );
  }
}
