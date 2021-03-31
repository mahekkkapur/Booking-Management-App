import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final Firestore firestore = Firestore.instance;

Future<String> getUser() async {
  final FirebaseUser user = await _auth.currentUser();
  return user.uid;
}

class VendorLocation extends StatefulWidget {
  @override
  State<VendorLocation> createState() => VendorLocationState();
}

class VendorLocationState extends State<VendorLocation> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  String mobileno, address;
  static CameraPosition _position = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14,
  );

  Future<void> getPosition(String vendor) async {
    firestore
        .collection('homemakers')
        .document(vendor)
        .get()
        .then((DocumentSnapshot snapshot) {
      GeoPoint point =
          Map.from(Map.from(snapshot.data)['position'])['geopoint'];
      setState(() {
        _position = CameraPosition(
            target: LatLng(point.latitude, point.longitude), zoom: 18);
        _markers.add(Marker(
            markerId: MarkerId(vendor),
            position: LatLng(point.latitude, point.longitude)));
        mobileno = Map.from(snapshot.data)['mobileno'];
        address = Map.from(snapshot.data)['address'];
      });
    });
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_position));
  }

  @override
  Widget build(BuildContext context) {
    getPosition(ModalRoute.of(context).settings.arguments);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed("/ExplorePage");
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        title: Text("Orders"),
        elevation: 0,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Vendor Location",
                  style: TextStyle(
                      color: Color(0xffFE506D),
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                padding: EdgeInsets.all(32.0),
                child: GoogleMap(
                  markers: _markers,
                  mapType: MapType.hybrid,
                  initialCameraPosition: _position,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "Address",
                    style: TextStyle(
                        color: Color(0xffFE506D),
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("$address"),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "Phone",
                    style: TextStyle(
                        color: Color(0xffFE506D),
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("$mobileno"),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(45.0),
                        side: BorderSide(color: Colors.red)),
                    color: Colors.white,
                    textColor: Color(0xffFE506D),
                    padding: EdgeInsets.all(16.0),
                    onPressed: () {
                      //To Chat
                    },
                    child: Text(
                      "Message",
                      style: TextStyle(
                        fontSize: 15.0,
                        fontFamily: "Gilroy",
                      ),
                    ),
                  ),
                  FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(45.0),
                        side: BorderSide(color: Colors.red)),
                    color: Colors.white,
                    textColor: Color(0xffFE506D),
                    padding: EdgeInsets.all(16.0),
                    onPressed: () async {
                      Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                      String url = 'https://www.google.com/maps/dir/api=1&origin=${position.latitude},${position.longitude}&destination=${_position.target.latitude},${_position.target.longitude}&dir_action=navigate';
                      if(await canLaunch(url)){
                        launch(url);
                        }
                        else{
                          print("$url can't be launched");
                        }
                    },
                    child: Text(
                      "Navigate",
                      style: TextStyle(
                        fontSize: 15.0,
                        fontFamily: "Gilroy",
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(45.0),
                        side: BorderSide(color: Colors.red)),
                    color: Color(0xffFE506D),
                    textColor: Colors.white,
                    padding: EdgeInsets.all(16.0),
                    onPressed: () {
                      //To Chat
                    },
                    child: Text(
                      "OTP 1234",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: "Gilroy",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
