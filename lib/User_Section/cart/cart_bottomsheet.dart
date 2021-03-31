import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econoomaccess/add_recipe/pricemodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;

class CartBottomSheet extends StatefulWidget {
  const CartBottomSheet({Key key}) : super(key: key);

  @override
  _CartBottomSheetState createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> {
  List cart = [];
  bool loading = true;
  String uid;
  Razorpay _razorpay;
  var address;
  bool _reqDiscount = false;
  bool homeDeliveryPossible = true;
  List<TextEditingController> _discountController = List();

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    getUser();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    orderSuccessful("ORID353699");
    print("There was an error");
  }

  void orderSuccessful(String orderId) async {
    List cart;
    String fcmToken = await fcm.FirebaseMessaging().getToken();
    List<Map> orders = [];
    await Firestore.instance.collection('users').document(this.uid).get().then(
      (DocumentSnapshot userSnapshot) {
        cart = List.from(Map.from(userSnapshot.data)['current_cart']);
        for (int i = 0; i < cart.length; i++) {
          Map item = Map.from(cart[i]);
          bool found = false;
          for (int i = 0; i < orders.length; i++) {
            if (orders[i]['homemaker'] == item['homemaker']) {
              found = true;
              orders[i]['items'].add({
                'quantity': item['quantity'],
                'item': Map.from(item['item'])['name'],
              });
            }
          }
          if (!found) {
            orders.add({
              "discount": item["discount"],
              'token': fcmToken,
              'orderId': orderId,
              'address': address,
              'user': this.uid.toString(),
              'homemaker': item['homemaker'],
              'items': [
                {
                  'quantity': item['quantity'],
                  'item': Map.from(item['item'])['name'],
                }
              ],
              'Home_Delivery': Provider.of<PriceModel>(context).delivery,
              'order_placed_at': Timestamp.now(),
              'accepted': false,
              'order_accepted_at': Timestamp.now(),
              'out_for_delivery': false,
              'order_out_for_delivery_at': Timestamp.now(),
              'delivered': false,
              'order_delivered_at': Timestamp.now(),
            });
          }
        }
      },
    );
    Firestore.instance.collection('users').document(this.uid).updateData(
        {'orders': FieldValue.arrayUnion(orders), 'current_cart': []});
    for (int i = 0; i < orders.length; i++) {
      Firestore.instance
          .collection('homemakers')
          .document(orders[i]['homemaker'])
          .updateData({
        'orders': FieldValue.arrayUnion([orders[i]])
      });
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    orderSuccessful(response.orderId);
    print("The order was successfull");
    Navigator.pushReplacementNamed(context, "/BottomBarPage");
  }

  getUser() async {
    await FirebaseAuth.instance.currentUser().then((val) {
      setState(() {
        uid = val.uid;
        getData(uid);
      });
    });
  }

  getData(String uid) async {
    var k = await Firestore.instance.collection('users').document(uid).get();
    setState(() {
      loading = false;
      Provider.of<PriceModel>(context).cart =
          List.from(Map.from(k.data)['current_cart']);
      Provider.of<PriceModel>(context).convert();
      Provider.of<PriceModel>(context).calcPrice();
    });
  }

  @override
  Widget build(BuildContext context) {
    cart = Provider.of<PriceModel>(context).cart;
    print(cart);
    return Consumer<PriceModel>(
      builder: (BuildContext context, value, Widget child) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: loading
              ? Center(child: CircularProgressIndicator())
              : cart.length == 0
                  ? Container(
                      height: 150,
                      child: Center(
                          child: Text(
                        "Cart Empty!",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 40),
                      )),
                    )
                  : StatefulBuilder(
                      builder:
                          (BuildContext context, StateSetter setBottomState) {
                        return Container(
                            alignment: Alignment.topCenter,
                            height: MediaQuery.of(context).size.height * 0.7,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Divider(
                                      color: Colors.grey,
                                      height: 20,
                                      thickness: 5,
                                      indent: 120,
                                      endIndent: 120,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(
                                      _reqDiscount
                                          ? "Request Discount"
                                          : "Cart",
                                      style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: cart.length,
                                    itemBuilder: (context, index) {
                                      _discountController
                                          .add(TextEditingController());
                                      if (cart[index]["delivery"] == false) {
                                        homeDeliveryPossible = false;
                                        print(cart[index]["homemaker"]);
                                      }
                                      return Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 8.0),
                                        child: _reqDiscount
                                            ? Card(
                                                elevation: 5,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 24.0),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(6.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: cart[index]
                                                                        ['item']
                                                                    ['image'] ==
                                                                ""
                                                            ? CircleAvatar()
                                                            : Image.network(
                                                                cart[index]
                                                                        ['item']
                                                                    ['image'],
                                                                height: 70.0,
                                                                width: 90.0,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                      ),
                                                      Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    cart[index][
                                                                            'item']
                                                                        [
                                                                        'name'],
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        fontSize:
                                                                            20),
                                                                  ),
                                                                ),
                                                                Image.network(
                                                                  cart[index]['item']
                                                                          [
                                                                          'veg']
                                                                      ? 'https://s21425.pcdn.co/wp-content/uploads/2013/05/veg-300x259.jpg'
                                                                      : 'https://www.iec.edu.in/app/webroot/img/Icons/84246.png',
                                                                  width: 15,
                                                                  height: 15,
                                                                ),
                                                              ],
                                                            ),
                                                            RichText(
                                                                text: TextSpan(
                                                                    text:
                                                                        "₹${value.getQuantity(index) * value.getPrice(index)}",
                                                                    style: TextStyle(
                                                                        decoration: _discountController[index].text ==
                                                                                ""
                                                                            ? TextDecoration
                                                                                .none
                                                                            : TextDecoration
                                                                                .lineThrough,
                                                                        fontFamily:
                                                                            "Gilroy",
                                                                        color: Color(
                                                                            0xffFE506D),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            20),
                                                                    children: [
                                                                  TextSpan(
                                                                      text: _discountController[index].text == ""
                                                                          ? ""
                                                                          : "  ₹" +
                                                                              ((value.getQuantity(index) * value.getPrice(index)) - int.parse(_discountController[index].text))
                                                                                  .toString(),
                                                                      style: TextStyle(
                                                                          decoration: TextDecoration
                                                                              .none,
                                                                          fontFamily:
                                                                              "Gilroy",
                                                                          color: Color(
                                                                              0xffFE506D),
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              20))
                                                                ]))
                                                          ]),
                                                      Container(
                                                          width: 40,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .grey)),
                                                          child: Form(
                                                            child: TextField(
                                                              onChanged: (v) {
                                                                value.discount(
                                                                    index,
                                                                    Firestore
                                                                        .instance
                                                                        .collection(
                                                                            "users")
                                                                        .document(
                                                                            uid),
                                                                    v);
                                                              },
                                                              onSubmitted: (v) {
                                                                value.discount(
                                                                    index,
                                                                    Firestore
                                                                        .instance
                                                                        .collection(
                                                                            "users")
                                                                        .document(
                                                                            uid),
                                                                    v);
                                                              },
                                                              decoration: InputDecoration(
                                                                  focusedBorder:
                                                                      InputBorder
                                                                          .none,
                                                                  enabledBorder:
                                                                      InputBorder
                                                                          .none),
                                                              controller:
                                                                  _discountController[
                                                                      index],
                                                            ),
                                                          ))
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Card(
                                                elevation: 10,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 24.0),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(6.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        child: cart[index]
                                                                        ['item']
                                                                    ['image'] ==
                                                                ""
                                                            ? CircleAvatar()
                                                            : Image.network(
                                                                cart[index]
                                                                        ['item']
                                                                    ['image'],
                                                                height: 70.0,
                                                                width: 90.0,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                      ),
                                                      Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: Text(
                                                                    cart[index][
                                                                            'item']
                                                                        [
                                                                        'name'],
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w400,
                                                                        fontSize:
                                                                            20),
                                                                  ),
                                                                ),
                                                                Image.network(
                                                                  cart[index]['item']
                                                                          [
                                                                          'veg']
                                                                      ? 'https://s21425.pcdn.co/wp-content/uploads/2013/05/veg-300x259.jpg'
                                                                      : 'https://www.iec.edu.in/app/webroot/img/Icons/84246.png',
                                                                  width: 15,
                                                                  height: 15,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                IconButton(
                                                                  icon: Icon(Icons
                                                                      .remove),
                                                                  onPressed:
                                                                      () {
                                                                    value.reduceQuantity(
                                                                        index,
                                                                        Firestore
                                                                            .instance
                                                                            .collection('users')
                                                                            .document(uid));
                                                                  },
                                                                ),
                                                                Container(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          3.0,
                                                                      horizontal:
                                                                          15.0),
                                                                  child: Text(
                                                                      "${value.getQuantity(index)}"),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .black38),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(20)),
                                                                  ),
                                                                ),
                                                                IconButton(
                                                                  icon: Icon(
                                                                      Icons
                                                                          .add),
                                                                  onPressed:
                                                                      () {
                                                                    value.addQuantity(
                                                                        index,
                                                                        Firestore
                                                                            .instance
                                                                            .collection('users')
                                                                            .document(uid));
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ]),
                                                      Text(
                                                        "₹${value.getQuantity(index) * value.getPrice(index)}",
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xffFE506D),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                      );
                                    },
                                  ),
                                  Divider(
                                    thickness: 1,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              "Total",
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text("(Inc. All Taxes)")
                                          ],
                                        ),
                                        Text(
                                          "₹${value.price}",
                                          style: TextStyle(
                                              color: Color(0xffFE506D),
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    thickness: 1,
                                  ),
                                  (address == null)
                                      ? MaterialButton(
                                          padding: const EdgeInsets.all(10),
                                          color: Colors.redAccent,
                                          child: Text("Select Address"),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                                    context, "/SelectAddress",
                                                    arguments: uid)
                                                .then((value) {
                                              setBottomState(() {
                                                address = value;
                                              });
                                            });
                                          },
                                        )
                                      : ListTile(
                                          // leading: Text("Delivering\nto: "),
                                          title: Text(
                                              "Name: ${address["name"]}",
                                              style: TextStyle(
                                                  fontFamily: "Gilroy",
                                                  fontWeight: FontWeight.bold)),
                                          subtitle: Text(
                                              "Phone: ${address["phone"]}"),
                                          trailing: FlatButton(
                                            shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: Colors.redAccent),
                                            ),
                                            child: Text("Change address"),
                                            textColor: Colors.redAccent,
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                      context, "/SelectAddress",
                                                      arguments: uid)
                                                  .then((value) {
                                                setBottomState(() {
                                                  address = value;
                                                });
                                              });
                                            },
                                          ),
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          width: 150.0,
                                          child: RaisedButton(
                                            color: value.delivery
                                                ? Color(0xffFE506D)
                                                : Colors.white,
                                            textColor: value.delivery
                                                ? Colors.black
                                                : Colors.grey,
                                            elevation: null,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            ),
                                            child: Text(
                                              "Home Delivery",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15.0,
                                                fontFamily: "Gilroy",
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                homeDeliveryPossible = false;
                                                print(homeDeliveryPossible);
                                              });
                                              value.deliveryPressed();
                                            },
                                          ),
                                        ),
                                        Container(
                                          width: 150.0,
                                          child: RaisedButton(
                                            color: value.selfPU
                                                ? Color(0xffFE506D)
                                                : Colors.white,
                                            textColor: value.selfPU
                                                ? Colors.black
                                                : Colors.grey,
                                            elevation: null,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            ),
                                            child: Text(
                                              "Pick Up",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15.0,
                                                fontFamily: "Gilroy",
                                              ),
                                            ),
                                            onPressed: () => value.puPressed(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  (!homeDeliveryPossible || !value.delivery)
                                      ? Container()
                                      : Text(
                                          "Home delivery is not possible by a homemaker",
                                          style: TextStyle(
                                              fontSize: 13, color: Colors.red)),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 10.0, top: 10.0),
                                    child: Container(
                                      width: 250.0,
                                      child: OutlineButton(
                                          color: Color(0xffFE506D),
                                          textColor: Color(0xffFE506D),
                                          borderSide: BorderSide(
                                            color: Color(0xffFE506D),
                                            style: BorderStyle.solid,
                                            width: 1.8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Proceed to Pay",
                                              style: TextStyle(
                                                color: Color(0xffFE506D),
                                                fontSize: 15.0,
                                                fontFamily: "Gilroy",
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          onPressed: (address == null)
                                              ? null
                                              : () async {
                                                  var options = {
                                                    'key':
                                                        'rzp_test_0RVqU3HILYRp5O',
                                                    'amount': value.price * 100,
                                                    'name': 'Naniz Eats',
                                                    'description':
                                                        'Now anyone can serve their food.',
                                                    'prefill': {
                                                      'contact': '8945529381',
                                                      'email':
                                                          'mashutoshrao@gmail.com',
                                                    },
                                                  };

                                                  _razorpay.open(options);
                                                }),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  InkWell(
                                      onTap: () {
                                        setState(() {
                                          _reqDiscount = !_reqDiscount;
                                        });
                                      },
                                      child: Text("Request Discount")),
                                  SizedBox(
                                    height: 15,
                                  )
                                ],
                              ),
                            ));
                      },
                    ),
        );
      },
    );
  }
}
