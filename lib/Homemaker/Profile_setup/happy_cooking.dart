import 'package:econoomaccess/Homemaker/bottomBarMaker.dart';
import 'package:flutter/material.dart';

class HappyCooking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffFF6530), Color(0xffFE4E74)]),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: EdgeInsets.only(left: 10, top: 30),
              height: MediaQuery.of(context).size.height * 0.15,
              child: Text(
                "You're all set!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                    child: Text(
                      "We are generating your digital menu. All your prices will be marked up by 5% which will be Naaniz’s cut. You will be payed all the earned amount upon the completion of your order directly in your wallet.You can transfer your wallet content to your bank account anytime you want.You can also promote your products by advertising on our platform.",
                      style: TextStyle(
                        wordSpacing: 5,
                        fontSize: 16,
                        fontWeight: FontWeight.w200,
                        fontFamily: "Gilroy",
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    "Happy Cooking!",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        fontFamily: "Gilroy"),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  buttonpart(context),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.10,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buttonpart(context) {
  return Card(
    elevation: 5.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 35, vertical: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => BottomBarMaker()));
        },
        child: Text(
          "Continue",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontFamily: "Gilroy",
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ),
  );
}
