import 'package:flutter/material.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          elevation: 5.0,
          flexibleSpace: Image.asset(
            "images/Image1.png",
            width: 120.0,
          ),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 30.0,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0))),
          backgroundColor: Color(0xFFFE4E74),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 20.0, left: 20.0),
              child: Text(
                "About Naaniz",
                style: TextStyle(
                    fontFamily: "Gilroy",
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20.0, left: 20.0),
              child: Text(
                "Naaniz is aimed at bringing the household individuals close to the customers in need. We expect to make a network of home makers across every city so that the user is not dependent on food from the restaurants\nand has healthy and liked options available at all times at low prices, and the homemakers have an option to use their talent for their financial well-being.",
                style: TextStyle(
                  fontFamily: "Gilroy",
                  fontSize: 15.0,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20.0, left: 20.0),
              child: Text(
                "Our Team",
                style: TextStyle(
                    fontFamily: "Gilroy",
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0)),
              child: ExpansionTile(
                backgroundColor: Colors.white,
                trailing: SizedBox(
                  height: 0.0,
                ),
                title: Text(
                  "UI/UX Design",
                  style: TextStyle(
                      fontFamily: "Gilroy", fontWeight: FontWeight.bold),
                ),
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 10.0, right: 10.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0)),
                    height: 200,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: uiTeam.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Row(
                            children: <Widget>[
                              Text(
                                uiTeam[index]["name"],
                                style: TextStyle(
                                    fontSize: 14.0, fontFamily: "Gilroy"),
                              ),
                              Expanded(child: SizedBox()),
                              Text(
                                uiTeam[index]["position"],
                                style: TextStyle(
                                    fontSize: 14.0, fontFamily: "Gilroy"),
                              ),
                            ],
                          );
                        }),
                  )
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0)),
              margin: EdgeInsets.all(10.0),
              child: ExpansionTile(
                trailing: SizedBox(
                  height: 0.0,
                ),
                backgroundColor: Colors.white,
                title: Text(
                  "Development Team",
                  style: TextStyle(
                      fontFamily: "Gilroy", fontWeight: FontWeight.bold),
                ),
                children: <Widget>[
                  Container(
                    height: 200,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: backendTeam.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Row(
                            children: <Widget>[
                              Text(
                                backendTeam[index]["name"],
                                style: TextStyle(
                                    fontSize: 14.0, fontFamily: "Gilroy"),
                              ),
                              Expanded(child: SizedBox()),
                              Text(
                                backendTeam[index]["position"],
                                style: TextStyle(
                                    fontSize: 14.0, fontFamily: "Gilroy"),
                              ),
                            ],
                          );
                        }),
                  )
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0)),
              margin: EdgeInsets.all(10.0),
              child: ExpansionTile(
                trailing: SizedBox(
                  height: 0.0,
                ),
                backgroundColor: Colors.white,
                title: Text(
                  "AI/Machine Learning Team",
                  style: TextStyle(
                      fontFamily: "Gilroy", fontWeight: FontWeight.bold),
                ),
                children: <Widget>[
                  Container(
                    height: 200,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: mlTeam.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Row(
                            children: <Widget>[
                              Text(
                                mlTeam[index]["name"],
                                style: TextStyle(
                                    fontSize: 14.0, fontFamily: "Gilroy"),
                              ),
                              Expanded(child: SizedBox()),
                              Text(
                                mlTeam[index]["position"],
                                style: TextStyle(
                                    fontSize: 14.0, fontFamily: "Gilroy"),
                              ),
                            ],
                          );
                        }),
                  )
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0)),
              margin: EdgeInsets.all(10.0),
              child: ExpansionTile(
                trailing: SizedBox(
                  height: 0.0,
                ),
                backgroundColor: Colors.white,
                title: Text(
                  "Content Team",
                  style: TextStyle(
                      fontFamily: "Gilroy", fontWeight: FontWeight.bold),
                ),
                children: <Widget>[
                  Container(
                    height: 200,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: promotionTeam.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Row(
                            children: <Widget>[
                              Text(
                                promotionTeam[index]["name"],
                                style: TextStyle(
                                    fontSize: 14.0, fontFamily: "Gilroy"),
                              ),
                              Expanded(child: SizedBox()),
                              Text(
                                promotionTeam[index]["position"],
                                style: TextStyle(
                                    fontSize: 14.0, fontFamily: "Gilroy"),
                              ),
                            ],
                          );
                        }),
                  )
                ],
              ),
            ),
            // Container(
            //   decoration: BoxDecoration(
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(15.0)),
            //   margin: EdgeInsets.all(10.0),
            //   child: ExpansionTile(
            //     trailing: SizedBox(
            //       height: 0.0,
            //     ),
            //     backgroundColor: Colors.white,
            //     title: Text(
            //       "Project Lead",
            //       style: TextStyle(
            //           fontFamily: "Gilroy", fontWeight: FontWeight.bold),
            //     ),
            //     children: <Widget>[
            //       Container(
            //         height: 200,
            //         child: ListView.builder(
            //             shrinkWrap: true,
            //             itemCount: projectLead.length,
            //             itemBuilder: (BuildContext context, int index) {
            //               return Row(
            //                 children: <Widget>[
            //                   Text(
            //                     projectLead[index]["name"],
            //                     style: TextStyle(
            //                         fontSize: 14.0, fontFamily: "Gilroy"),
            //                   ),
            //                   Expanded(child: SizedBox()),
            //                   Text(
            //                     projectLead[index]["position"],
            //                     style: TextStyle(
            //                         fontSize: 14.0, fontFamily: "Gilroy"),
            //                   ),
            //                 ],
            //               );
            //             }),
            //       )
            //     ],
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}

List<Map<String, String>> uiTeam = [
  {"name": "Developer 1", "position": "Position 1"},
  {"name": "Developer 2", "position": "Position 2"},
];

List<Map<String, String>> backendTeam = [
  {"name": "M Ashutosh Rao", "position": "Application Team Lead"},
  {"name": "Ashutosh Sharma", "position": "Co Team-Lead"},
  {"name": "B Shashi Kumar", "position": "Co Team-Lead"},
  {"name": "Ishaan Kolli", "position": "Developer"},
  {"name": "Akshaz Singh", "position": "Developer"},
  {"name": "Naman Agarwal", "position": "Developer"},
  {"name": "Sirsha Chakraborty", "position": "Developer"},
  {"name": "Delicia Fernandes", "position": "Developer"},
  {"name": "Aditya Pandey", "position": "Developer"},
  {"name": "Ashutosh Sharma", "position": "Developer"},
  {"name": "Suraj Verma", "position": "Backend Team Lead"},
  {"name": "Himanshu Dahiya", "position": "Backend Developer"},
  {"name": "Ridham Garg", "position": "Backend Developer"},
  {"name": "Saurabh Tiwari", "position": "Backend Developer"},
  {"name": "Sherwyn D'souza", "position": "Backend Developer"},
  {"name": "Sunny Jain", "position": "Backend Developer"},
  {"name": "Kunal agarwal", "position": "Backend Developer"},
];

List<Map<String, String>> mlTeam = [
  {"name": "Mohsin Kaleem", "position": "Team Lead"},
  {"name": "Sonu Sharma", "position": "ML Developer"},
  {"name": "Ayushi Mishra", "position": "ML Developer"},
  {"name": "Neil Gautam", "position": "ML Developer"},
  {"name": "Geetha Reddy", "position": "Team Lead"},
  {"name": "Shubham Jain", "position": "ML Developer"},
  {"name": "Deekshanth", "position": "ML Developer"},
  {"name": "Harsimran Jit Singh", "position": "Team Lead"},
  {"name": "Saurabh thakur", "position": "ML Developer"},
  {"name": "Niket Jain", "position": "ML Developer"},
  {"name": "Vijay chakole", "position": "ML Developer"},
  {"name": "Pankaj", "position": "ML Developer"},
  {"name": "Janhavi", "position": "ML Developer"},
  {"name": "Hardik seth", "position": "ML Developer"},
  {"name": "Muktikanta pandab", "position": "ML Developer"},
  {"name": "Harshmeet Singh", "position": "Team Lead"},
  {"name": "Shweta kamble", "position": "ML Developer"},
  {"name": "Aman Rawat", "position": "ML Developer"},
  {"name": "Shubham Sharma", "position": "ML Developer"},
  {"name": "Ashutosh", "position": "Team Lead"},
];

List<Map<String, String>> promotionTeam = [
  {"name": "Vaishnavi Rana", "position": "Content Creation"},
  {"name": "Radhakrishnan", "position": "Content Creation"},
  {"name": "Geetha", "position": "Picture and Designer"},
  {"name": "Prabhanjan Mishra", "position": "Sales and poster making"},
  {"name": "Gurkarman Singh", "position": "Advertising and marketing"},
  {"name": "Namisha", "position": "Advertising and marketing"},
  {"name": "Sahil Khindawat", "position": "sales and marketing"},
  {"name": "Anshuka", "position": "sales and marketing"},
  {"name": "Ritu Dubey", "position": "Sales and marketing"},
  {"name": "Astha Singh", "position": "Sales and marketing"},
  {"name": "Daryl", "position": "Sales and marketing"},
  {"name": "Lipsa Verhani", "position": "Sales and marketing"},
  {"name": "Aman Choudhary", "position": "Sales and marketing"},
];
// List<Map<String, String>> projectLead = [
//   {"name": "Developer 1", "position": "Position 1"},
//   {"name": "Developer 2", "position": "Position 2"},
// ];
