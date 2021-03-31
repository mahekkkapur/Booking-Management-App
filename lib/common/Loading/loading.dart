import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SpinKitRing(
          color: Color(0xFFFE4E74),
          size: 60.0
            ),
            SizedBox(height: 15.0,),
            Text("loading....",style: TextStyle(
              color: Colors.black,
              fontSize: 15.0,
              
            ),),
          ],
        ),
      ),
    );
  }
}
