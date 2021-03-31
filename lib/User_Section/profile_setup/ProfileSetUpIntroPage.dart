import 'package:flutter/material.dart';

class ProfileSetUpIntoPage extends StatefulWidget {
  @override
  _ProfileSetUpIntoPageState createState() => _ProfileSetUpIntoPageState();
}

class _ProfileSetUpIntoPageState extends State<ProfileSetUpIntoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(50.0,30.0,40.0,30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 259,
            ),
            Text(
              "Let's set up your profile",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: "Gilroy",
                fontSize: 25.0,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              "Let us know about your preferences,\nfor a truly personalized experience\nwith Naaniz.",
              style: TextStyle(
                color: Colors.black,
                // fontWeight: FontWeight.bold,
                fontFamily: "Gilroy",
                fontSize: 15.0,
              ),
            ),
            SizedBox(
              height: 100,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Material(
                color: Color(0xffFF6530),
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                elevation: 0.0,
                child: MaterialButton(
                  onPressed: () {
                    //Implement login functionality.
                    Navigator.pushReplacementNamed(context, "/UserDetailsPage");
                  },
                  minWidth: 200.0,
                  height: 40.0,
                  child: Text(
                    'NEXT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Gilroy",
                      fontSize: 15.0,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
