import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:econoomaccess/common/Loading/loading.dart';

bool load = false;

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

class BusinessLocation extends StatefulWidget {
  static const routeName = '/business-location';

  @override
  _BusinessLocationState createState() => _BusinessLocationState();
}

class _BusinessLocationState extends State<BusinessLocation> {
  GoogleMapController mapController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  GeoFirePoint point;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  void _selectLocation(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(Marker(
          markerId: MarkerId(DateTime.now().toString()), position: position));
    });
  }

  Set<Marker> _markers = HashSet<Marker>();

  void _onMapCreated(GoogleMapController controller) async {
    final locData = await Location().getLocation();
    mapController = controller;
    if (!mounted) return;
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId("0"),
        position: LatLng(locData.latitude, locData.longitude),
      ));
    });
  }

  String searchAddr;

  var currentLocation = LocationData;

  var location = new Location();

  LatLng _initialPosition;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  void _getUserLocation() async {
    Position position = await Geolocator().getCurrentPosition();
    List<Placemark> placemark = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      print('${placemark[0].name}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
        body: (_initialPosition == null)
            ? Column(
                children: <Widget>[
                  SizedBox(
                    height: height / 2,
                  ),
                  Center(
                    child: CircularProgressIndicator(),
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
            : load
                ? Loading()
                : SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: MediaQuery.of(context).padding.top +
                              (height / 20),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 15),
                            child: Text('Set Business Location',
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: _initialPosition,
                                  zoom: 16,
                                ),
                                onMapCreated: _onMapCreated,
                                myLocationButtonEnabled: true,
                                compassEnabled: true,
                                rotateGesturesEnabled: true,
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
                        SizedBox(height: height / 5),
                        ButtonTheme(
                          minWidth: 200,
                          height: 40,
                          child: OutlineButton(
                              child: new Text(
                                "Continue",
                                style: TextStyle(
                                    color: Color(0xffFE506D),
                                    fontFamily: "Gilroy",
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              borderSide: BorderSide(
                                  color: Color(0xffFE506D), width: 2),
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
                                  load = true;
                                });

                                _auth.onAuthStateChanged.listen((user) async {
                                  firestore
                                      .collection('homemakers')
                                      .document(user.uid)
                                      .updateData({
                                    'position': point.data,
                                    'city': place.locality,
                                    'state': place.administrativeArea
                                  }).whenComplete(() {
                                    Navigator.pushReplacementNamed(
                                        context, "/MakerAddProfilePhotoPage",
                                        arguments: user.uid);
                                  });
                                });
                              },
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(15.0))),
                        ),
                      ],
                    ),
                  ));
  }

  searchandNavigate() {
    Geolocator().placemarkFromAddress(searchAddr).then((result) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target:
              LatLng(result[0].position.latitude, result[0].position.longitude),
          zoom: 16.0)));

      setState(() {
        _initialPosition =
            LatLng(result[0].position.latitude, result[0].position.longitude);
        _markers.clear();
        _markers.add(Marker(
          markerId: MarkerId("result[0]"),
          position:
              LatLng(result[0].position.latitude, result[0].position.longitude),
        ));
      });
    });
  }
}
