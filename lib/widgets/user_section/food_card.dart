import 'package:flutter/material.dart';

class FoodCard extends StatefulWidget {
  final String imageUrl;
  final bool isveg;
  final String homemakername;
  final String recipename;
  final String price;
  final bool offerAvailable;
  FoodCard(
      {@required this.price,
      @required this.homemakername,
      @required this.isveg,
      @required this.recipename,
      @required this.offerAvailable,
      @required this.imageUrl});

  @override
  _FoodCardState createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        width: width * .9,
        height: width * .24,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: [
              widget.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.imageUrl,
                        width: width * .18,
                        height: width * .2,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          return loadingProgress != null
                              ? Container(
                                  width: width * .18,
                                  height: width * .2,
                                  child: Image.asset(
                                    "images/noRecipe.jpg",
                                    width: width * .18,
                                    height: width * .2,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : child;
                        },
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: width * .18,
                        height: width * .2,
                        child: Image.asset(
                          "images/noRecipe.jpg",
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: width * .30,
                    child: Text(
                      widget.recipename,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: width * .045,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    width: width * .30,
                    child: Text(
                      widget.homemakername,
                      overflow: TextOverflow.fade,
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: width * .03,
                          fontWeight: FontWeight.w200),
                    ),
                  ),
                  Text(
                    "${widget.price}",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: width * .03,
                        fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: widget.isveg ? Colors.green : Colors.red,
                            width: 1.0)),
                    child: Center(
                      child: Container(
                        width: 10.0,
                        height: 10.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50.0),
                            color: widget.isveg ? Colors.green : Colors.red),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: width * .03,
                        color: Colors.yellow,
                      ),
                      Icon(
                        Icons.star,
                        size: width * .03,
                        color: Colors.yellow,
                      ),
                      Icon(
                        Icons.star,
                        size: width * .03,
                        color: Colors.yellow,
                      ),
                      Icon(
                        Icons.star_border,
                        size: width * .03,
                        color: Colors.yellow,
                      ),
                      Icon(
                        Icons.star_border,
                        size: width * .03,
                        color: Colors.yellow,
                      ),
                    ],
                  ),
                  widget.offerAvailable
                      ? Container(
                          height: width * .04,
                          width: width * .2,
                          child: RaisedButton(
                            onPressed: () {},
                            child: Text(
                              "Order Now",
                              style: TextStyle(
                                  color: Colors.white, fontSize: width * .02),
                            ),
                            color: Colors.redAccent,
                          ))
                      : SizedBox()
                ],
              ),
            ],
          ),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      margin: EdgeInsets.all(10),
    );
  }
}
