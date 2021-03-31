import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:econoomaccess/Homemaker/MakerDrawer.dart';
import 'package:flutter/material.dart';

class Payouts extends StatefulWidget {
  @override
  _PayoutsState createState() => _PayoutsState();
}

class _PayoutsState extends State<Payouts> {
  var uid;
  Widget _payoutRows(String label, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 2, left: 8.0),
          child: Text(label,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                fontFamily: "Gilroy",
                fontSize: 20.0,
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2, right: 8.0),
          child: Text(price,
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w400,
                fontFamily: "Gilroy",
                fontSize: 20.0,
              )),
        ),
      ],
    );
  }

  Widget _payoutRowsBold(String title, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 8.0, bottom: 10),
          child: Text(title,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                fontFamily: "Gilroy",
                fontSize: 20.0,
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 8.0, bottom: 10),
          child: Text(price,
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w700,
                fontFamily: "Gilroy",
                fontSize: 20.0,
              )),
        ),
      ],
    );
  }

  String accountNumber;
  String checkAccountNumber;
  String accountHolderName;
  String bankBranch;
  String ifscCode;

  // Color _confirmButtonColor = Colors.white;
  // Color _confirmButtonTextColor = Colors.redAccent;

  void _linkNewAccount(BuildContext ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (ctx) {
          Widget _accountFormText(String title) {
            return Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(title,
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontFamily: "Gilroy",
                        fontSize: 15.0,
                      )),
                ),
              ],
            );
          }

          final height = MediaQuery.of(ctx).size.height;
          final width = MediaQuery.of(ctx).size.width;

          // if (accountNumber == checkAccountNumber &&
          //     accountNumber != null &&
          //     accountHolderName != null &&
          //     bankBranch != null &&
          //     ifscCode != null)
          //   setState(() {
          //     _confirmButtonColor = Colors.redAccent;
          //     _confirmButtonTextColor = Colors.white;
          //   });

          return Column(
            children: <Widget>[
              SizedBox(height: height / 50),
              Divider(
                thickness: 3,
                color: Colors.redAccent,
                indent: (MediaQuery.of(ctx).size.width / 2) - 70,
                endIndent: (MediaQuery.of(ctx).size.width / 2) - 70,
              ),
              SizedBox(height: height / 50),
              Text('Add Account',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w900,
                    fontFamily: "Gilroy",
                    fontSize: 30.0,
                  )),
              SizedBox(height: height / 40),
              _accountFormText('Account Number'),
              Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                      left: 8,
                      top: 5,
                      bottom: 5,
                    ),
                    height: 52,
                    width: width / 1.2,
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          accountNumber = val;
                        });
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        fillColor: Colors.white70,
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black38, width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black54, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black54, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _accountFormText('Re-Enter Account Number'),
              //SizedBox(height:3),
              Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                      left: 8,
                      top: 5,
                      bottom: 5,
                    ),
                    height: 52,
                    width: width / 1.2,
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          checkAccountNumber = val;
                        });
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        fillColor: Colors.white70,
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black38, width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black54, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black54, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _accountFormText('Account Holder\'s Name'),
              //SizedBox(height:3),
              Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(
                      left: 8,
                      top: 5,
                      bottom: 5,
                    ),
                    height: 52,
                    width: width / 1.2,
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          accountHolderName = val;
                        });
                      },
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        fillColor: Colors.white70,
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black38, width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black54, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black54, width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _accountFormText('Bank Branch'),
                      //SizedBox(height:3),
                      Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                              left: 8,
                              top: 5,
                              bottom: 5,
                            ),
                            height: 52,
                            width: width / 2.1,
                            child: TextField(
                              onChanged: (val) {
                                setState(() {
                                  bankBranch = val;
                                });
                              },
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                fillColor: Colors.white70,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black38, width: 1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black54, width: 1.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black54, width: 1.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6.0)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _accountFormText('IFSC Code'),
                      //SizedBox(height:3),
                      Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(
                                left: 8, top: 5, bottom: 5, right: 8),
                            height: 52,
                            width: width / 2.1,
                            child: TextField(
                              onChanged: (val) {
                                setState(() {
                                  ifscCode = val;
                                });
                              },
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                fillColor: Colors.white70,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black38, width: 1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black54, width: 1.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black54, width: 1.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6.0)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              MaterialButton(
                  color:
                      (accountNumber == checkAccountNumber &&
                              accountNumber != null &&
                              accountHolderName != null &&
                              bankBranch != null &&
                              ifscCode != null)
                          ? Colors.redAccent
                          : Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Colors.redAccent,
                      )),
                  child: Text('CONFIRM',
                      style: TextStyle(
                        color:
                            //_confirmButtonTextColor,
                            (accountNumber == checkAccountNumber &&
                                    accountNumber != null &&
                                    accountHolderName != null &&
                                    bankBranch != null &&
                                    ifscCode != null)
                                ? Colors.white
                                : Colors.redAccent,
                        fontWeight: FontWeight.w900,
                        fontFamily: "Gilroy",
                        fontSize: 18.0,
                      )),
                  onPressed: () {
                    List<Map> list = [
                      {
                        'Account Number': accountNumber,
                        'Account Holder Name': accountHolderName,
                        'Bank Branch': bankBranch,
                        'IFSC Code': ifscCode,
                      }
                    ];
                    if (accountNumber == checkAccountNumber &&
                        accountNumber != null &&
                        accountHolderName != null &&
                        bankBranch != null &&
                        ifscCode != null) addPayout(list);
                  }),
            ],
          );
        });
  }

  void addPayout(List<Map> list) async {
    Firestore.instance.collection('homemakers').document(uid).updateData({
      "payouts": FieldValue.arrayUnion(list),
    }).whenComplete(() {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)), //this right here
              child: Container(
                height: 160,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Text(
                          "Account Added Successfully",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'SF Pro Text',
                            fontWeight: FontWeight.bold,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      SizedBox(
                        width: 320.0,
                        child: RaisedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "CONTINUE >",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'SF Pro Text',
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              height: 1.15,
                            ),
                          ),
                          color: Color(0xffFE4E74),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    String s = ModalRoute.of(context).settings.arguments;
    uid = s;

    return Scaffold(
      drawer: MakerDrawerWidget(uid: s),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.grey[50],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 0),
            Padding(
              padding: const EdgeInsets.only(left: 28.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Payout',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Gilroy",
                      fontSize: 25.0,
                    )),
              ),
            ),
            StreamBuilder(
                stream: Firestore.instance
                    .collection('homemakers')
                    .document(s)
                    .snapshots(),
                builder: (context, streamSnapshot) {
                  if (streamSnapshot.connectionState == ConnectionState.waiting)
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  else if (streamSnapshot.hasData) {
                    int cost = 0;
                    var menu = streamSnapshot.data['menu'];
                    int wallet = streamSnapshot.data["promotedCut"] ?? 0;

                    int getPrice(String item) {
                      for (int i = 0; i < menu.length; i++) {
                        if (menu[i]['name'] == item) return menu[i]['price'];
                      }
                      return 0;
                    }

                    for (int i = 0;
                        i < streamSnapshot.data['orders'].length;
                        i++) {
                      for (int j = 0;
                          j < streamSnapshot.data['orders'][i]['items'].length;
                          j++) {
                        cost += streamSnapshot.data['orders'][i]['items'][j]
                                ['quantity'] *
                            getPrice(streamSnapshot.data['orders'][i]['items']
                                [j]['item']);
                      }
                    }
                    return Column(
                      children: <Widget>[
                        SizedBox(height: MediaQuery.of(context).padding.top),
                        Container(
                          padding: EdgeInsets.only(left: 10, top: 15),
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              "${streamSnapshot.data['image']}",
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('${streamSnapshot.data['name']}\'s Kitchen',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontFamily: "Gilroy",
                              fontSize: 25.0,
                            )),
                        SizedBox(
                          height: 5,
                        ),
                        Text(streamSnapshot.data['city'],
                            style: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.w900,
                              fontFamily: "Gilroy",
                              fontSize: 16.0,
                            )),
                        SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                              color: Colors.white,
                              child: Column(
                                children: <Widget>[
                                  _payoutRowsBold('Total Earned', '+ ₹$cost'),
                                  _payoutRows('Promotions', '- ₹${wallet}'),
                                  _payoutRows(
                                      'Naaniz Cut(5%)', '- ₹${0.05 * cost}'),
                                  _payoutRows('GST', '- ₹${0.1 * cost}'),
                                  SizedBox(height: 5),
                                  MyCustomDivider(),
                                  _payoutRowsBold('Total Earnings',
                                      '+ ₹${cost - (wallet) - (0.05 * cost) - (0.1 * cost)}'),
                                  //SizedBox(height: 5),
                                  MyCustomDivider(),
                                  SizedBox(height: 5),
                                  MaterialButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          side: BorderSide(
                                            color: Colors.black26,
                                          )),
                                      child: Text('CASH IN',
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w900,
                                            fontFamily: "Gilroy",
                                            fontSize: 18.0,
                                          )),
                                      onPressed: null),
                                  SizedBox(height: 5),
                                ],
                              )),
                        )
                      ],
                    );
                  } else {
                    return Container(child: Text("No data Present"));
                  }
                }),
            SizedBox(height: 15),
            Text('Connected Accounts',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontFamily: "Gilroy",
                  fontSize: 18.0,
                )),
            SizedBox(height: 15),
            DottedBorder(
                dashPattern: [10, 10],
                borderType: BorderType.RRect,
                radius: Radius.circular(10),
                strokeWidth: 1,
                color: Colors.black54,
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: width / 1.3,
                    child: ListTile(
                      title: Text('Link a New Account',
                          style: TextStyle(
                            color: Colors.black45,
                            fontWeight: FontWeight.w900,
                            fontFamily: "Gilroy",
                            fontSize: 20.0,
                          )),
                      trailing: Icon(Icons.add),
                      onTap: () {
                        _linkNewAccount(context);
                      },
                    ))),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('homemakers')
                      .document(s)
                      .snapshots(),
                  builder: (context, payoutSnapshot) {
                    if (payoutSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return Container(
                      height: 100,
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return Container(
                            color: Colors.white,
                            child: ListTile(
                                leading: Icon(
                                  Icons.attach_money,
                                  size: 40,
                                ),
                                title: Text(
                                  payoutSnapshot.data.data['payouts'][index]
                                      ['Bank Branch'],
                                  style: TextStyle(
                                      fontFamily: "Gilroy", fontSize: 15),
                                ),
                                subtitle: Text(payoutSnapshot.data
                                    .data['payouts'][index]['Account Number']),
                                trailing: MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(
                                          color: Color(0xffFE506D),
                                        )),
                                    child: Text('UNLINK',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w900,
                                          fontFamily: "Gilroy",
                                          fontSize: 18.0,
                                        )),
                                    onPressed: () {
                                      // CHECK PLEASE
                                      Firestore.instance
                                          .collection('homemakers')
                                          .document(s)
                                          .updateData({
                                        "payouts": FieldValue.arrayRemove([
                                          {
                                            'Account Number': payoutSnapshot
                                                    .data.data['payouts'][index]
                                                ['Account Number'],
                                            'Account Holder Name':
                                                payoutSnapshot.data
                                                        .data['payouts'][index]
                                                    ['Account Holder Name'],
                                            'Bank Branch': payoutSnapshot
                                                    .data.data['payouts'][index]
                                                ['Bank Branch'],
                                            'IFSC Code': payoutSnapshot
                                                    .data.data['payouts'][index]
                                                ['IFSC Code'],
                                          }
                                        ]),
                                      }).whenComplete(() {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0)), //this right here
                                                child: Container(
                                                  height: 160,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        15, 15, 15, 15),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        Center(
                                                          child: Text(
                                                            "Account Removed Successfully",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  'SF Pro Text',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 15.0,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 40),
                                                        SizedBox(
                                                          width: 320.0,
                                                          child: RaisedButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: Text(
                                                              "CONTINUE >",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontFamily:
                                                                    'SF Pro Text',
                                                                fontSize: 15.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                height: 1.15,
                                                              ),
                                                            ),
                                                            color: Color(
                                                                0xffFE4E74),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            });
                                      });
                                    })),
                          );
                        },
                        itemCount: payoutSnapshot.data.data["payouts"].length,
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}

class MyCustomDivider extends StatelessWidget {
  final double height;
  final Color color;

  const MyCustomDivider({this.height = 1, this.color = Colors.black26});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = 10.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}
