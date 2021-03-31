import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

const PdfColor green = PdfColor.fromInt(0xffFF6530);
const PdfColor lightGreen = PdfColor.fromInt(0xffFE4E74);

class ProfilePageOptions extends StatefulWidget {
  final Map<String, dynamic> data;
  final String docId;
  ProfilePageOptions({this.data, this.docId});

  @override
  _ProfilePageOptionsState createState() => _ProfilePageOptionsState();
}

class _ProfilePageOptionsState extends State<ProfilePageOptions> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore firestore = Firestore.instance;
  FirebaseUser currentUser;
  DocumentReference favoriteDoc;
  bool isFavorite;
  var temp;
  var documentName;

  @override
  void initState() {
    getFavorite(widget.data, widget.docId);
    super.initState();
  }

  getData() {
    firestore
        .collection('homemakers')
        .document(widget.docId)
        .get()
        .then((doc) => {
              temp = doc.data['menu'],
              _generatePDF(temp),
            });
  }

  _generatePDF(temp) async {
    final doc = pw.Document();
    const imageProvider = const AssetImage('images/cropped-naaniz-logo.png');
    final PdfImage image = await pdfImageFromImageProvider(
        pdf: doc.document, image: imageProvider);
    final font = await rootBundle.load("fonts/KaushanScript-Regular.ttf");
    final ttf = pw.Font.ttf(font);

    doc.addPage(pw.MultiPage(
        pageTheme: pw.PageTheme(
          buildBackground: (pw.Context context) {
            return pw.FullPage(
              ignoreMargins: true,
              child: pw.CustomPaint(
                size: PdfPoint(500, 600),
                painter: (PdfGraphics canvas, PdfPoint size) {
                  context.canvas
                    ..setColor(lightGreen)
                    ..moveTo(0, size.y)
                    ..lineTo(0, size.y - 230)
                    ..lineTo(60, size.y)
                    ..fillPath()
                    ..setColor(green)
                    ..moveTo(0, size.y)
                    ..lineTo(0, size.y - 100)
                    ..lineTo(100, size.y)
                    ..fillPath()
                    ..setColor(lightGreen)
                    ..moveTo(30, size.y)
                    ..lineTo(110, size.y - 50)
                    ..lineTo(150, size.y)
                    ..fillPath()
                    ..moveTo(size.x, 0)
                    ..lineTo(size.x, 230)
                    ..lineTo(size.x - 60, 0)
                    ..fillPath()
                    ..setColor(green)
                    ..moveTo(size.x, 0)
                    ..lineTo(size.x, 100)
                    ..lineTo(size.x - 100, 0)
                    ..fillPath()
                    ..setColor(lightGreen)
                    ..moveTo(size.x - 30, 0)
                    ..lineTo(size.x - 110, 50)
                    ..lineTo(size.x - 150, 0)
                    ..fillPath();
                },
              ),
            );
          },
        ),
        build: (context) => [
              pw.Row(children: [
                pw.Center(
                  child: pw.Image(image, height: 120, width: 120),
                ),
                pw.SizedBox(width: 20),
                pw.Center(
                    child: pw.Text("MENU",
                        style: pw.TextStyle(
                            font: ttf,
                            fontSize: 100,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromInt(0xffFE506D)))),
              ]),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                border: null,
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: pw.BoxDecoration(
                  borderRadius: 2,
                  color: PdfColor.fromInt(0xffFE506D),
                ),
                headerHeight: 25,
                cellHeight: 40,
                cellAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.center,
                },
                headerStyle: pw.TextStyle(
                  color: PdfColor.fromInt(0xffFFFFFF),
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
                rowDecoration: pw.BoxDecoration(
                  border: pw.BoxBorder(
                    bottom: true,
                    width: .5,
                  ),
                ),
                cellStyle: const pw.TextStyle(
                  fontSize: 10,
                ),
                context: context,
                data: <List<String>>[
                  <String>['Food Name', 'Cost'],
                  ...temp.map((item) =>
                      [item['name'].toString(), item['price'].toString()])
                ],
              ),
            ]));

    await Printing.sharePdf(bytes: doc.save(), filename: 'my-menu.pdf');
  }

  _addFavorite(Map<String, dynamic> data, String docId) async {
    if (isFavorite) {
      print("deleting");
      fcm.FirebaseMessaging().unsubscribeFromTopic(docId);
      favoriteDoc.delete();
      setState(() {
        isFavorite = false;
      });
    } else {
      print("adding");
      List<dynamic> smallMeals = data["menu"].take(3).toList();
      fcm.FirebaseMessaging().subscribeToTopic(docId);
      favoriteDoc.setData({
        "name": data["name"],
        "image": data["image"],
        "menu": smallMeals,
      });
      setState(() {
        isFavorite = true;
      });
    }
  }

  getFavorite(Map<String, dynamic> data, String docId) async {
    currentUser = await _auth.currentUser();
    setState(() {
      favoriteDoc = Firestore.instance
          .collection("users")
          .document("${currentUser.uid}")
          .collection("favorites")
          .document(docId);
    });
    DocumentSnapshot snapshot = await favoriteDoc.get();
    if (snapshot.exists) {
      if (!mounted) return;
      setState(() {
        isFavorite = true;
      });
    } else {
      if (!mounted) return;
      setState(() {
        isFavorite = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
            color:
                (isFavorite == null || !isFavorite) ? Colors.black : Colors.red,
            icon: Icon(
              Icons.bookmark_border,
              size: 25.0,
            ),
            onPressed: () => _addFavorite(widget.data, widget.docId)),
        SizedBox(
          width: 10.0,
        ),
        IconButton(
            icon: Icon(
              Icons.chat_bubble_outline,
              size: 25.0,
              color: Colors.black,
            ),
            onPressed: () {
              print(widget.docId);
              Navigator.of(context).pushReplacementNamed('/ChatPage',
                  arguments: [currentUser.uid, widget.docId]);
            }),
        SizedBox(
          width: 10.0,
        ),
        IconButton(
            icon: Icon(
              Icons.share,
              size: 25.0,
              color: Colors.black,
            ),
            onPressed: () {
              getData();
            }),
      ],
    );
  }
}
