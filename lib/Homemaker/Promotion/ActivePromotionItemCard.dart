import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ActivePromotionItemCard extends StatelessWidget {
  final String docId;
  final Map data;

  ActivePromotionItemCard({this.docId, this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(data["name"],
                      style: TextStyle(
                          fontFamily: "Gilroy", fontWeight: FontWeight.bold)),
                  Text(
                      "Referrals : ${data["orders"]}/${data["requiredOrders"]}",
                      style: TextStyle(fontFamily: "Gilroy"))
                ],
              ),
              leading: ClipRRect(
                child: Image.network(
                  data["image"],
                  fit: BoxFit.cover,
                  height: 60,
                  width: 100,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              subtitle: Text(docId),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Earned"),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text("₹ ${data["earned"]}"),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Cut"),
                      Text("Time Limit"),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text("₹ ${data["cut"]}"),
                      Text("${data["days"]} days"),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: Color(0xffe5e5e5),
                padding: EdgeInsets.all(8),
                child: SelectableText("${data["link"]}",
                    style:
                        TextStyle(fontFamily: "Gilroy", color: Colors.black)),
              ),
            ),
            SizedBox(height: 5),
            GestureDetector(
              onTap: () {
                Clipboard.setData(new ClipboardData(text: "${data["link"]}"))
                    .then((_) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("Link copied to clipboard")));
                });
              },
              child: Text("Share Link",
                  style: TextStyle(color: Color(0xffFE4E74))),
            )
          ],
        ),
      ),
    );
  }
}
