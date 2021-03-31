import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ViewReviews extends StatefulWidget {
  final String data;
  ViewReviews({this.data});

  @override
  _ViewReviewsState createState() => _ViewReviewsState();
}

class _ViewReviewsState extends State<ViewReviews> {
  Widget _reviewType = PositiveReviews();
  bool _isPositive = true;
  bool _isNegative = false;

  @override
  void initState() {
    super.initState();
    _reviewType = PositiveReviews(
      data: widget.data,
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
                    data: widget.data,
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
                    data: widget.data,
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
  final String data;
  PositiveReviews({this.data});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('homemakers')
          .document(this.data)
          .collection('reviews')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        List<Widget> review = [];
        List<Widget> positive = [];
        snapshot.data.documents.forEach((element) {
          for (int i = 0; i < element.data[element.documentID].length; i++) {
            if (element.data[element.documentID][i]['rating'] >= 3)
              positive.add(Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8, bottom: 8),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: (MediaQuery.of(context).size.width / 4) * 2.5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${element.data[element.documentID][i]['username']} : ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              width:
                                  (MediaQuery.of(context).size.width / 4) * 2.5,
                              child: Text(
                                element.data[element.documentID][i]['text'],
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    RatingBarIndicator(
                      rating: element.data[element.documentID][i]['rating']
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
          if (positive.length != 0)
            review.add(Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(element.data['image']),
                  ),
                  title: Text(
                    element.data['name'],
                    style: TextStyle(
                      fontFamily: "Gilroy",
                    ),
                  ),
                  subtitle:
                      Text('₹' + element.data['price'].toString() + '/plate'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: (element.data['veg'] == true)
                                      ? Colors.green
                                      : Colors.brown,
                                  width: 2)),
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: CircleAvatar(
                              backgroundColor: (element.data['veg'] == true)
                                  ? Colors.green
                                  : Colors.brown,
                            ),
                          ),
                        ),
                      ),
                      RatingBarIndicator(
                        rating: element.data['rating'].toDouble(),
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
                ),
                Container(
                  height: 200,
                  child: ListView.builder(
                      itemCount: positive.length,
                      itemBuilder: (context, index) {
                        return positive[index];
                      }),
                ),
              ],
            ));
        });
        return Container(
          height: 440,
          //MediaQuery.of(context).size.height / 3,
          child: ListView.builder(
            itemCount: review.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                child: Card(
                  child: review[index],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class CriticalReviews extends StatelessWidget {
  final String data;
  CriticalReviews({this.data});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('homemakers')
          .document(this.data)
          .collection('reviews')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        List<Widget> review = [];
        List<Widget> negative = [];
        snapshot.data.documents.forEach((element) {
          for (int i = 0; i < element.data[element.documentID].length; i++)
            if (element.data[element.documentID][i]['rating'] < 3)
              negative.add(Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8, bottom: 8),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: (MediaQuery.of(context).size.width / 4) * 2.5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${element.data[element.documentID][i]['username']} : ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              width:
                                  (MediaQuery.of(context).size.width / 4) * 2.5,
                              child: Text(
                                element.data[element.documentID][i]['text'],
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    RatingBarIndicator(
                      rating: element.data[element.documentID][i]['rating']
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
          if (negative.length != 0)
            review.add(Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(element.data['image']),
                  ),
                  title: Text(element.data['name']),
                  subtitle:
                      Text('₹' + element.data['price'].toString() + '/plate'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: (element.data['veg'] == true)
                                      ? Colors.green
                                      : Colors.brown,
                                  width: 2)),
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: CircleAvatar(
                              backgroundColor: (element.data['veg'] == true)
                                  ? Colors.green
                                  : Colors.brown,
                            ),
                          ),
                        ),
                      ),
                      RatingBarIndicator(
                        rating: element.data['rating'].toDouble(),
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
                ),
                Container(
                  height: 200,
                  child: ListView.builder(
                      itemCount: negative.length,
                      itemBuilder: (context, index) {
                        return negative[index];
                      }),
                ),
              ],
            ));
        });

        return Container(
          height: 400,
          //MediaQuery.of(context).size.height / 3,
          child: ListView.builder(
            itemCount: review.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                child: Card(
                  child: review[index],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
