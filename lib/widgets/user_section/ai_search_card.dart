import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AiSearchCard extends StatefulWidget {
  final File image;

  const AiSearchCard({Key key, this.image}) : super(key: key);

  @override
  _AiSearchCardState createState() => _AiSearchCardState();
}

class _AiSearchCardState extends State<AiSearchCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        width: double.infinity,
        height: 160,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 10.0,
          child: Column(
            children: [
              Text(
                'AI Search by Image',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink),
              ),
              Text('Click or upload a pic of the dish you want to eat!'),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: 140,
                      child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: BorderSide(color: Colors.pink)),
                          onPressed: () => _pickImageCamera(widget.image),
                          child: Text(
                            'New Image',
                            style: TextStyle(color: Colors.pink, fontSize: 20),
                          )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      width: 140,
                      child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: BorderSide(color: Colors.pink)),
                          onPressed: () => _pickImageGallery(widget.image),
                          child: Text(
                            'Gallery',
                            style: TextStyle(color: Colors.pink, fontSize: 20),
                          )),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _pickImageCamera(File image) async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.camera);

    if (imageFile == null) {
      return;
    }

    setState(() {
      image = imageFile;
    });
  }

  void _pickImageGallery(File image) async {
    final imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile == null) {
      return;
    }

    setState(() {
      image = imageFile;
    });
  }
}
