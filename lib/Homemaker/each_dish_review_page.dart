import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class EachDishReviewPage extends StatelessWidget {
  static const routeName = '/each-dish-review-page';

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    final String homemaker = routeArgs['homemaker'];
    final String dishName = routeArgs['dishName'];
    final String dishImage = routeArgs['dishImage'];

    return Scaffold(
        appBar: AppBar(
          // leading: GestureDetector(
          //     onTap: () {
          //       Navigator.pushReplacementNamed(context, "/ExplorePage");
          //     },
          //     child: Icon(Icons.arrow_back_ios)),
          elevation: 0.0,
          backgroundColor: Color(0xFFFF9F9F9),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 8),
                  child: Text(
                    'Reviews',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Gilroy",
                        fontSize: 30),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0, top: 8),
                  child: Column(
                    children: <Widget>[
                      Container(
                          height: 70,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                dishImage,
                                fit: BoxFit.fitWidth,
                              ))),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          dishName,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Gilroy",
                              fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            ReviewTypeChange(homemaker: homemaker, dishName: dishName)
          ],
        ));
  }
}

class ReviewTypeChange extends StatefulWidget {
  final String homemaker;
  final String dishName;
  ReviewTypeChange({
    @required this.homemaker,
    @required this.dishName,
  });

  @override
  _ReviewTypeChangeState createState() => _ReviewTypeChangeState();
}

class _ReviewTypeChangeState extends State<ReviewTypeChange> {
  Widget _reviewType;
  bool _isPositive = true;
  bool _isNegative = false;

  @override
  void initState() {
    super.initState();
    _reviewType = PositiveReviews(
      dishName: widget.dishName,
      homemaker: widget.homemaker,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Positive',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: (_isPositive == true)
                          ? FontWeight.bold
                          : FontWeight.normal),
                ),
              ),
              onTap: () {
                setState(() {
                  _reviewType = PositiveReviews(
                    dishName: widget.dishName,
                    homemaker: widget.homemaker,
                  );
                  _isPositive = true;
                  _isNegative = false;
                });
              },
            ),
            SizedBox(width: 20),
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Critical',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: (_isNegative == true)
                          ? FontWeight.bold
                          : FontWeight.normal),
                ),
              ),
              onTap: () {
                setState(() {
                  _reviewType = CriticalReviews(
                    dishName: widget.dishName,
                    homemaker: widget.homemaker,
                  );
                  _isPositive = false;
                  _isNegative = true;
                });
              },
            ),
          ],
        ),
        _reviewType,
      ],
    );
  }
}

class PositiveReviews extends StatelessWidget {
  final String homemaker;
  final String dishName;
  final List<Widget> _positiveReviews = [];
  PositiveReviews({
    @required this.homemaker,
    @required this.dishName,
  });

  @override
  Widget build(BuildContext context) {
    bool exists;
    return StreamBuilder(
        stream: Firestore.instance
            .collection("homemakers/$homemaker/reviews")
            .snapshots(),
        builder: (context, collectionSnapshot) {
          if (collectionSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Column(
              children: <Widget>[
                SizedBox(height:MediaQuery.of(context).size.height/4),
                CircularProgressIndicator(),
              ],
            ));
          }
          if (collectionSnapshot.data.documents.length != 0)
            return FutureBuilder(
                future: Firestore.instance
                    .document("homemakers/$homemaker/reviews/$dishName")
                    .get()
                    .then((value) {
                  value.exists ? exists = true : exists = false;
                }),
                builder: (context, futureSnapshot) {
                  if (futureSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: Column(
              children: <Widget>[
                SizedBox(height:MediaQuery.of(context).size.height/4),
                CircularProgressIndicator(),
              ],
            ));
                  }
                  if (exists)
                    return Container(
                      child: StreamBuilder(
                          stream: Firestore.instance
                              .collection('homemakers')
                              .document(homemaker)
                              .collection('reviews')
                              .document(dishName)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: Column(
              children: <Widget>[
                SizedBox(height:MediaQuery.of(context).size.height/4),
                CircularProgressIndicator(),
              ],
            ));
                            }
                            for (int i = 0;
                                i < snapshot.data['$dishName'].length;
                                i++) {
                              if (snapshot.data['$dishName'][i]['rating'] >=
                                  3) {
                                _positiveReviews.add(Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, left: 8, bottom: 8),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: (MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4) *
                                              2.5,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                '${snapshot.data[dishName][i]['username']} : ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              Container(
                                                width: (MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        4) *
                                                    2.5,
                                                child: Text(
                                                  snapshot.data[dishName][i]
                                                      ['text'],
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      RatingBarIndicator(
                                        rating: snapshot.data[dishName][i]
                                                ['rating']
                                            .toDouble(),
                                        itemBuilder: (context, index) => Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        itemCount: 5,
                                        itemSize: 15.0,
                                        direction: Axis.horizontal,
                                      ),
                                    ],
                                  ),
                                ));
                              }
                            }
                            return Container(
                              height: 500,
                              child: (_positiveReviews.length == 0)
                                  ? Center(
                                      child: Text(
                                        ' No Reviews Yet ...',
                                        style: TextStyle(
                                            color: Colors.black26,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Gilroy",
                                            fontSize: 30),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: _positiveReviews.length,
                                      itemBuilder: (context, index) {
                                        return _positiveReviews[index];
                                      }),
                            );
                          }),
                    );
                  else
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 4),
                        Text(
                          ' No Reviews Yet ...',
                          style: TextStyle(
                              color: Colors.black26,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Gilroy",
                              fontSize: 30),
                        ),
                      ],
                    );
                });
          else
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height / 4),
                Text(
                  ' No Reviews Yet ...',
                  style: TextStyle(
                      color: Colors.black26,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Gilroy",
                      fontSize: 30),
                ),
              ],
            );
        });
  }
}

class CriticalReviews extends StatelessWidget {
  final String homemaker;
  final String dishName;
  final List<Widget> _criticalReviews = [];
  CriticalReviews({
    @required this.homemaker,
    @required this.dishName,
  });
  @override
  Widget build(BuildContext context) {
    bool exists;
    return StreamBuilder(
        stream: Firestore.instance
            .collection("homemakers/$homemaker/reviews")
            .snapshots(),
        builder: (context, collectionSnapshot) {
          if (collectionSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Column(
              children: <Widget>[
                SizedBox(height:MediaQuery.of(context).size.height/4),
                CircularProgressIndicator(),
              ],
            ));
          }
          if (collectionSnapshot.data.documents.length != 0)
            return FutureBuilder(
                future: Firestore.instance
                    .document("homemakers/$homemaker/reviews/$dishName")
                    .get()
                    .then((value) {
                  value.exists ? exists = true : exists = false;
                }),
                builder: (context, futureSnapshot) {
                  if (futureSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: Column(
              children: <Widget>[
                SizedBox(height:MediaQuery.of(context).size.height/4),
                CircularProgressIndicator(),
              ],
            ));
                  }
                  if (exists)
                    return Container(
                      child: StreamBuilder(
                          stream: Firestore.instance
                              .collection('homemakers')
                              .document(homemaker)
                              .collection('reviews')
                              .document(dishName)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: Column(
              children: <Widget>[
                SizedBox(height:MediaQuery.of(context).size.height/4),
                CircularProgressIndicator(),
              ],
            ));
                            }
                            for (int i = 0;
                                i < snapshot.data['$dishName'].length;
                                i++) {
                              if (snapshot.data['$dishName'][i]['rating'] < 3) {
                                _criticalReviews.add(Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, left: 8, bottom: 8),
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: (MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  4) *
                                              2.5,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                '${snapshot.data[dishName][i]['username']} : ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                              Container(
                                                width: (MediaQuery.of(context)
                                                            .size
                                                            .width /
                                                        4) *
                                                    2.5,
                                                child: Text(
                                                  snapshot.data[dishName][i]
                                                      ['text'],
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      RatingBarIndicator(
                                        rating: snapshot.data[dishName][i]
                                                ['rating']
                                            .toDouble(),
                                        itemBuilder: (context, index) => Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        itemCount: 5,
                                        itemSize: 15.0,
                                        direction: Axis.horizontal,
                                      ),
                                    ],
                                  ),
                                ));
                              }
                            }
                            return Container(
                              height: 500,
                              child: (_criticalReviews.length == 0)
                                  ? Center(
                                      child: Text(
                                        ' No Reviews Yet ...',
                                        style: TextStyle(
                                            color: Colors.black26,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Gilroy",
                                            fontSize: 30),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: _criticalReviews.length,
                                      itemBuilder: (context, index) {
                                        return _criticalReviews[index];
                                      }),
                            );
                          }),
                    );
                  else
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 4),
                        Text(
                          ' No Reviews Yet ...',
                          style: TextStyle(
                              color: Colors.black26,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Gilroy",
                              fontSize: 30),
                        ),
                      ],
                    );
                });
          else
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height / 4),
                Text(
                  ' No Reviews Yet ...',
                  style: TextStyle(
                      color: Colors.black26,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Gilroy",
                      fontSize: 30),
                ),
              ],
            );
        });
  }
}
