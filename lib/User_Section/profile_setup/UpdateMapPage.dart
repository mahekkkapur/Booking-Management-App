import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econoomaccess/User_Section/bottomBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class PlaceLocation {
  final double latitude;
  final double longitude;
  final String address;

  const PlaceLocation({
    this.latitude,
    this.longitude,
    this.address,
  });
}

class UpdateMapPage extends StatefulWidget {
  static const routeName = '/business-location';

  @override
  _UpdateMapPageState createState() => _UpdateMapPageState();
}

class _UpdateMapPageState extends State<UpdateMapPage> {
  GoogleMapController mapController;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;

  Geoflutterfire geo = Geoflutterfire();
  GeoFirePoint point;

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  var _cname, _sname;
  String uid;

  Set<Marker> _markers = HashSet<Marker>();
  String searchAddr;

  var currentLocation = loc.LocationData;

  var location = new loc.Location();

  static LatLng _initialPosition;

  void searchandNavigate() {
    Geolocator().placemarkFromAddress(searchAddr).then((result) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(result[0].position.latitude, result[0].position.longitude),
        zoom: 16.0,
      )));

      setState(() {
        _markers.clear();
        _markers.add(Marker(
          markerId: MarkerId("result[0]"),
          position:
              LatLng(result[0].position.latitude, result[0].position.longitude),
        ));
        _initialPosition =
            LatLng(result[0].position.latitude, result[0].position.longitude);
        print(_initialPosition);
      });
    });
  }

  void _selectLocation(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(Marker(
          markerId: MarkerId(DateTime.now().toString()), position: position));

      _initialPosition = LatLng(position.latitude, position.longitude);

      print(_initialPosition);
    });
  }

  void _onMapCreated(GoogleMapController controller) async {
    try {
      final locData = await loc.Location().getLocation();
      mapController = controller;
      if (!mounted) return;
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId("0"),
          position: LatLng(locData.latitude, locData.longitude),
        ));
      });
    } catch (e) {
      print(e);
    }
  }

  void _getUserLocation() async {
    try {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print('${position.latitude} , ${position.longitude}');

      List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);

        print('New ${placemark[0].locality}');
        print(_initialPosition);
      });
    } catch (e) {
      print(e);
    }
  }

  void _getUser() {
    FirebaseAuth.instance.currentUser().then((value) {
      setState(() {
        uid = value.uid;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _getUser();
    // _getAddressFromLatLng();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Color(0xffE5E5E5),
        appBar: AppBar(
          leading: GestureDetector(
            child: Icon(Icons.arrow_back_ios, color: Colors.black),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(builder: (context) => BottomBar()),
                  (route) => false);
            },
          ),
          backgroundColor: Color(0xffE5E5E5),
          elevation: 0,
        ),
        body: (_initialPosition == null)
            ? Column(
                children: <Widget>[
                  SizedBox(
                    height: height / 3,
                  ),
                  Center(
                    child: SpinKitFadingCube(
                      color: Color(0xffff6530),
                      size: 50.0,
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Center(
                    child: Text('Please Wait...',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontFamily: "Gilroy",
                          fontSize: 28.0,
                        )),
                  )
                ],
              )
            : Builder(
                builder: (context) => SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height:
                            MediaQuery.of(context).padding.top + (height / 20),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 15),
                          child: Text('Update your location',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Gilroy",
                                fontSize: 28.0,
                              )),
                        ),
                      ),
                      SizedBox(height: height / 15),
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                width: 2,
                                color: Colors.black38,
                              )),
                          height: height / 3,
                          width: width - 20,
                          alignment: Alignment.center,
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: _initialPosition,
                                zoom: 16,
                              ),
                              onMapCreated: _onMapCreated,
                              myLocationButtonEnabled: true,
                              compassEnabled: true,
                              rotateGesturesEnabled: true,
                              // zoomControlsEnabled: true,
                              zoomGesturesEnabled: true,
                              markers: _markers,
                              onTap: _selectLocation,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: height / 50),
                      Container(
                        height: height / 15,
                        width: width - 20,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white),
                        child: TextField(
                          style: TextStyle(
                            color: Colors.black45,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Gilroy",
                            fontSize: 20.0,
                          ),
                          decoration: InputDecoration(
                              hintText: 'Or Search Location',
                              hintStyle: TextStyle(
                                color: Colors.black45,
                                fontWeight: FontWeight.w400,
                                fontFamily: "Gilroy",
                                fontSize: 20.0,
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.only(left: 15.0, top: 15.0),
                              suffixIcon: IconButton(
                                  icon: Icon(Icons.search),
                                  onPressed: searchandNavigate,
                                  iconSize: 30.0)),
                          onChanged: (val) {
                            setState(() {
                              searchAddr = val;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 40),
                      ButtonTheme(
                        minWidth: 200,
                        height: 40,
                        child: OutlineButton(
                            child: new Text(
                              "Update Location",
                              style: TextStyle(
                                  color: Color(0xffFE506D),
                                  fontFamily: "Gilroy",
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold),
                            ),
                            borderSide:
                                BorderSide(color: Color(0xffFE506D), width: 2),
                            onPressed: () async {
                              var point;
                              point = geo.point(
                                  latitude: _initialPosition.latitude,
                                  longitude: _initialPosition.longitude);

                              List<Placemark> p =
                                  await geolocator.placemarkFromCoordinates(
                                      _initialPosition.latitude,
                                      _initialPosition.longitude);

                              Placemark place = p[0];

                              setState(() {
                                _cname = place.locality;
                                _sname = place.administrativeArea;
                              });

                              _auth.onAuthStateChanged.listen((user) async {
                                firestore
                                    .collection('users')
                                    .document(user.uid)
                                    .updateData({
                                  'position': point.data,
                                  'city': _cname,
                                  'state': _sname
                                }).whenComplete(() {
                                  Navigator.pushReplacementNamed(
                                      context, "/BottomBarPage");
                                });
                              });
                            },
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(15.0))),
                      ),
                      FlatButton(
                        child: Text("Add manual address"),
                        onPressed: () {
                          showBottomSheet(
                              context: context,
                              builder: (ctx) {
                                return manualAddressBottomSheet();
                              });
                        },
                      )
                    ],
                  ),
                ),
              ));
  }

  Widget manualAddressBottomSheet() {
    TextEditingController nameController = TextEditingController();
    TextEditingController houseController = TextEditingController();
    TextEditingController localityController = TextEditingController();
    TextEditingController cityController = TextEditingController();
    TextEditingController stateController = TextEditingController();
    TextEditingController pinCodeController = TextEditingController();
    TextEditingController phoneController = TextEditingController();

    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return Container(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: formKey,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Text(
              'Update your location',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: "Gilroy",
                fontSize: 20.0,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            returnTextFormField("Name", nameController),
            returnTextFormField("House and Street", houseController),
            returnTextFormField("Locality", localityController),
            returnTextFormField("City", cityController),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(child: returnTextFormField("State", stateController)),
                Expanded(
                  child:
                      returnNumberField("Pin Code", pinCodeController, false),
                ),
              ],
            ),
            returnNumberField("Phone", phoneController, true),
            const SizedBox(
              height: 10,
            ),
            MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text("Add Address"),
              color: Colors.redAccent,
              textColor: Colors.white,
              onPressed: () async {
                if (formKey.currentState.validate()) {
                  Map obj = {};
                  obj["address"] = houseController.text;
                  obj["name"] = nameController.text;
                  obj["city"] = cityController.text;
                  obj["locality"] = localityController.text;
                  obj["state"] = stateController.text;
                  obj["pincode"] = pinCodeController.text;
                  obj["phone"] = phoneController.text;
                  await geolocator.getCurrentPosition().then((value) {
                    obj["longitude"] = value.longitude;
                    obj["latitude"] = value.latitude;
                    Firestore.instance
                        .collection("users")
                        .document(uid)
                        .updateData({
                      "address": FieldValue.arrayUnion([obj]),
                    });
                    int count = 0;
                    Navigator.popUntil(context, (route) {
                      return count++ == 2;
                    });
                  });
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget returnTextFormField(String text, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: text,
          border: OutlineInputBorder(),
        ),
        controller: controller,
        validator: (val) {
          return (val.length > 0) ? null : "Enter $text";
        },
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) {
          FocusScope.of(context).nextFocus();
        },
      ),
    );
  }

  Widget returnNumberField(
      String text, TextEditingController controller, bool done) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: text,
          border: OutlineInputBorder(),
        ),
        maxLength: (text == "Phone") ? 10 : 6,
        keyboardType: TextInputType.number,
        inputFormatters: [
          WhitelistingTextInputFormatter.digitsOnly,
        ],
        controller: controller,
        textInputAction: (done) ? TextInputAction.done : TextInputAction.next,
        onFieldSubmitted: (_) {
          if (!done) FocusScope.of(context).nextFocus();
        },
        validator: (val) {
          if (text == "Phone") {
            return (val.length == 10) ? null : "Enter valid Phone";
          }
          return (val.length == 6) ? null : "Enter valid $text";
        },
      ),
    );
  }
}
