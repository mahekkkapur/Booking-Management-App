import 'package:flutter/material.dart';

class LoyaltyRuleCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function loyaltyToggleHandler;

  LoyaltyRuleCard(this.data, this.loyaltyToggleHandler);

  @override
  _LoyaltyRuleCardState createState() => _LoyaltyRuleCardState();
}

class _LoyaltyRuleCardState extends State<LoyaltyRuleCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text("Orders :"),
                    SizedBox(height: 5),
                    Text("Amount :"),
                    SizedBox(height: 5),
                    Text("Discount :"),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    children: <Widget>[
                      Text("${widget.data["orders"]}"),
                      SizedBox(height: 5),
                      Text("₹${widget.data["amount"]}"),
                      SizedBox(height: 5),
                      Text("₹${widget.data["discount"]}"),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text("Type :"),
                          SizedBox(height: 5),
                          Text("Repeat :"),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          widget.data["repeat"] == false
                              ? Text("Once")
                              : Text("All"),
                          SizedBox(height: 5),
                          widget.data["repeat"] == false
                              ? Text("No")
                              : Text("Yes"),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    width: 100,
                    height: 25,
                    child: ToggleButtons(
                      color: Colors.black,
                      fillColor: Color(0xffFE506D),
                      selectedColor: Colors.white,
                      children: <Widget>[
                        Text("On"),
                        Text("Off"),
                      ],
                      isSelected: [
                        widget.data["enabled"],
                        !widget.data["enabled"],
                      ],
                      onPressed: (value) {
                        widget.loyaltyToggleHandler(value, widget.data);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
