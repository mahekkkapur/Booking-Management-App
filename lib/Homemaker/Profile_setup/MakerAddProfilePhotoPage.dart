import 'package:econoomaccess/Homemaker/Profile_setup/happy_cooking.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MakerAddProfilePhotoPage extends StatefulWidget {
  @override
  _MakerAddProfilePhotoPageState createState() =>
      _MakerAddProfilePhotoPageState();
}

class _MakerAddProfilePhotoPageState extends State<MakerAddProfilePhotoPage> {
  var disabledButton = true;
  var imageFile;
  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context).settings.arguments;
    args = "h0nYXpUImvfALRMVx6tGBGMgm8B2";

    return Scaffold(
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('homemakers')
              .document(args)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              return Padding(
                padding:
                    const EdgeInsets.only(left: 15.0, right: 15.0, top: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    this.imageFile == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Almost done, add a",
                                  style: TextStyle(fontSize: 25)),
                              Text("profile photo",
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              Text(
                                  "Upload a picture of yours to make your profile more personal!",
                                  style: TextStyle(fontSize: 18)),
                              SizedBox(height: 45),
                            ],
                          )
                        : Column(
                            children: <Widget>[
                              Text("Perfect! You're all set now.",
                                  style: TextStyle(fontSize: 30)),
                              SizedBox(height: 45),
                            ],
                          ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Color(0xffF9E7EB),
                          minRadius: 100,
                          child: this.imageFile == null
                              ? Icon(
                                  Icons.person_outline,
                                  size: 150,
                                  color: Color(0xffFE4E74),
                                )
                              : Container(
                                  width: 200,
                                  height: 200,
                                  decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                          fit: BoxFit.cover,
                                          image: FileImage(imageFile)))),
                        ),
                        SizedBox(height: 5),
                        Text("${snapshot.data["name"]}",
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold)),
                        SizedBox(height: 100),
                        imageFile == null
                            ? Column(
                                children: <Widget>[
                                  ButtonTheme(
                                    minWidth: 150,
                                    child: OutlineButton(
                                        child: Text(
                                          "USE CAMERA",
                                          style: TextStyle(
                                              color: Color(0xffFE506D),
                                              fontFamily: "Gilroy",
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        borderSide: BorderSide(
                                            color: Color(0xffFE506D), width: 2),
                                        onPressed: () async {
                                          await ImagePicker.pickImage(
                                                  source: ImageSource.camera)
                                              .then((image) {
                                            setState(() {
                                              this.imageFile = image;
                                            });
                                          });
                                        },
                                        shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(
                                                    15.0))),
                                  ),
                                  SizedBox(height: 10),
                                  ButtonTheme(
                                    minWidth: 150,
                                    child: OutlineButton(
                                        child: Text(
                                          "FROM GALLERY",
                                          style: TextStyle(
                                              color: Color(0xffFE506D),
                                              fontFamily: "Gilroy",
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        borderSide: BorderSide(
                                            color: Color(0xffFE506D), width: 2),
                                        onPressed: () async {
                                          await ImagePicker.pickImage(
                                                  source: ImageSource.gallery)
                                              .then((image) {
                                            if (image == null) {
                                            } else {
                                              setState(() {
                                                this.imageFile = image;
                                              });
                                            }
                                          });
                                        },
                                        shape: new RoundedRectangleBorder(
                                            borderRadius:
                                                new BorderRadius.circular(
                                                    15.0))),
                                  ),
                                  SizedBox(height: 10),
                                  GestureDetector(
                                      onTap: () {
                                        Firestore.instance
                                            .collection('homemakers')
                                            .document(args)
                                            .updateData({
                                          'image':
                                              "https://firebasestorage.googleapis.com/v0/b/naniz-team.appspot.com/o/defaultImage.jpg?alt=media&token=8fa0d735-4c1b-4ef4-bb3f-a9f45bd31d83"
                                        }).whenComplete(() {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HappyCooking()));
                                        });
                                      },
                                      child: Text("Skip this step",
                                          style: TextStyle(fontSize: 13)))
                                ],
                              )
                            : Column(
                                children: <Widget>[
                                  SizedBox(height: 100),
                                  disabledButton
                                      ? Material(
                                          color: Color(0xffFE4E74),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12.0)),
                                          elevation: 0.0,
                                          child: MaterialButton(
                                            onPressed: () async {
                                              Fluttertoast.showToast(
                                                  msg: "Please wait");
                                              setState(() {
                                                disabledButton =
                                                    !disabledButton;
                                              });
                                              StorageReference
                                                  storageReference =
                                                  FirebaseStorage.instance
                                                      .ref()
                                                      .child(Path.basename(
                                                          imageFile.path));
                                              await storageReference
                                                  .putFile(imageFile)
                                                  .onComplete;
                                              String url =
                                                  await storageReference
                                                      .getDownloadURL();

                                              Firestore.instance
                                                  .collection('homemakers')
                                                  .document(args)
                                                  .updateData({
                                                'image': url
                                              }).whenComplete(() {
                                                Navigator.pushReplacementNamed(
                                                    context,
                                                    "/MakerInstructionsPage");
                                              });
                                              //Implement login functionality.
                                            },
                                            minWidth: 200.0,
                                            height: 40.0,
                                            child: Text(
                                              'START',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Gilroy",
                                                fontSize: 15.0,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: SpinKitWave(
                                          color: Colors.red,
                                          size: 30,
                                        )),
                                ],
                              ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return SizedBox();
          }),
    );
  }
}
