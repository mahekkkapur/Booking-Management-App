import 'package:econoomaccess/Homemaker/Profile_setup/ProfileSetUpIntoPageMaker.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class MakerOnBoardPage extends StatefulWidget {
  @override
  _MakerOnBoardPageState createState() => _MakerOnBoardPageState();
}

class _MakerOnBoardPageState extends State<MakerOnBoardPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProfileSetUpIntoPageMaker()),
    );
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: Image.asset(
        'images/$assetName.png',
        width: 291.0,
        height: 298,
      ),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(
      fontSize: 15.0,
      fontFamily: "Gilroy",
    );
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 25.0,
        fontWeight: FontWeight.w700,
        fontFamily: "Gilroy",
      ),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      pages: [
        PageViewModel(
          title: "Your kitchen, your rules!",
          body:
              "Cook whatever you wish, let Naaniz share that for you to bring in orders.From menu items to operating time, you decide it all",
          image: _buildImage('cropped-naaniz-logo'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Connect better with your customers!",
          body:
              "Naaniz recommends you suitable customer hotspots, as well as appropriate items depending on your location or situation which can boost your sales.",
          image: _buildImage('cropped-naaniz-logo'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Keep track of your orders!",
          body:
              "Every order you get through Naaniz is stored in the database, giving you a complete overview of your sales as well as specific details of every order ever!",
          image: _buildImage('cropped-naaniz-logo'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "Earn Referral points!",
          body:
              "Share Naaniz with your friends, and earn Referral points for every new homemaker joining. Use these to earn monetary benefits!",
          image: _buildImage('cropped-naaniz-logo'),
          decoration: pageDecoration,
        ),
        // PageViewModel(
        //   title: "Another title page",
        //   body: "Another beautiful body text for this example onboarding",
        //   image: _buildImage('img2'),
        //   footer: RaisedButton(
        //     onPressed: () {
        //       introKey.currentState?.animateScroll(0);
        //     },
        //     child: const Text(
        //       'FooButton',
        //       style: TextStyle(color: Colors.white),
        //     ),
        //     color: Colors.lightBlue,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(8.0),
        //     ),
        //   ),
        //   decoration: pageDecoration,
        // ),
        // PageViewModel(
        //   title: "Title of last page",
        //   bodyWidget: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: const [
        //       Text("Click on ", style: bodyStyle),
        //       Icon(Icons.edit),
        //       Text(" to edit a post", style: bodyStyle),
        //     ],
        //   ),
        //   image: _buildImage('img1'),
        //   decoration: pageDecoration,
        // ),
      ],
      onDone: () => _onIntroEnd(context),
      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipFlex: 0,
      nextFlex: 0,
      skip: const Text(
        'Skip',
        style: TextStyle(
          fontSize: 15.0,
          fontFamily: "Gilroy",
        ),
      ),
      // next: const Icon(Icons.arrow_forward),
      done: const Text('Done',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: "Gilroy",
          )),
      dotsDecorator: const DotsDecorator(
        activeColor: Color(0xffFE4E74),
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}