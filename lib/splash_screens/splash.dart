import 'package:econoomaccess/AuthChoosePage.dart';
import 'package:econoomaccess/User_Section/bottomBar.dart';
import 'package:econoomaccess/Homemaker/bottomBarMaker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String status;
  @override
  void initState() {
    super.initState();
    checkAuth();
    //Timer(Duration(seconds: 2), () => Navigator.pushNamed(context, '/AuthChoosePage'));
  }

  checkAuth() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    status = sp.getString("isUserLoggedin");
    // Fluttertoast.showToast(msg: status.toString());
    if (status == "user") {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BottomBar()));
      });
    } else if (status == "homeMaker") {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BottomBarMaker()));
      });
    } else {
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => AuthChoosePage()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(254, 78, 116, 1),
              Color.fromRGBO(254, 86, 93, 1),
              Color.fromRGBO(255, 90, 81, 1),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: (MediaQuery.of(context).size.height) / 3,
              color: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: ((MediaQuery.of(context).size.height) / 3) - 40,
                    width: 170,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'images/cropped-naaniz-logo.png',
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "CLOUD KITCHEN",
                    style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        letterSpacing: 1,
                        wordSpacing: 1,
                        fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
            SizedBox(height: 200),
            SpinKitWave(
              color: Colors.white,
              size: 30,
            )
          ],
        ),
      ),
    );
  }
}
