import 'package:econoomaccess/User_Section/Bottom_nav/UserProfilePage.dart';
import 'package:econoomaccess/User_Section/cart/cart_bottomsheet.dart';
import 'package:econoomaccess/User_Section/Bottom_nav/favourites/favorites_screen.dart';
import 'package:econoomaccess/add_recipe/pricemodel.dart';
import 'package:econoomaccess/User_Section/Bottom_nav/search_screen.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:econoomaccess/User_Section/Bottom_nav/explore_page/ExplorePage.dart';
import 'package:econoomaccess/common/icon/my_flutter_app_icons.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'drawer.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:econoomaccess/AuthChoosePage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';
import 'package:econoomaccess/User_Section/Bottom_nav/logintocontinue.dart';

int currentTabIndex = 0;

class BottomBar extends StatefulWidget {
  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _database = Firestore.instance;
  var uid;
  var address;
  Razorpay _razorpay;

  Future<bool> willpop() async {
    return showDialog(
        context: context,
        child: AlertDialog(
          title: Text(
            "Are you sure want to exit?",
            style: TextStyle(
              fontFamily: "Gilroy",
            ),
          ),
          actions: [
            FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("No")),
            FlatButton(
                onPressed: () {
                  exit(0);
                },
                child: Text("Yes"))
          ],
        ));
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    orderSuccessful(response.orderId);
    print("The order was successfull");
    //Add success popup
    Navigator.pushReplacementNamed(context, "/BottomBarPage");
  }

  void orderSuccessful(String orderId) async {
    List cart;
    String fcmToken = await fcm.FirebaseMessaging().getToken();
    List<Map> orders = [];
    await _database.collection('users').document(this.uid).get().then(
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
    _database.collection('users').document(this.uid).updateData(
        {'orders': FieldValue.arrayUnion(orders), 'current_cart': []});
    for (int i = 0; i < orders.length; i++) {
      _database
          .collection('homemakers')
          .document(orders[i]['homemaker'])
          .updateData({
        'orders': FieldValue.arrayUnion([orders[i]])
      });
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    orderSuccessful("ORID353699");
    print("There was an error");
    //Add Failure popup
    // Navigator.pushReplacementNamed(context, "/BottomBarPage");
  }

  getUser() async {
    await _auth.currentUser().then((val) {
      setState(() {
        uid = val.uid;
      });
    });
  }

  bool type = true;
  getType() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      type = user.isAnonymous;
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
    getType();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  void _settingModalBottomSheet(context, String user) async {
    showModalBottomSheet<dynamic>(
        isScrollControlled: true,
        elevation: 250,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(40.0),
            topLeft: Radius.circular(40.0),
          ),
        ),
        context: context,
        builder: (BuildContext bc) {
          return CartBottomSheet();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(uid: this.uid),
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.shopping_cart,
                size: 25.0,
                color: Colors.black,
              ),
              onPressed: () async {
                type
                    ? Fluttertoast.showToast(
                        msg: "Please Login to buy !!",
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey,
                        textColor: Colors.white,
                        fontSize: 16.0)
                    : FirebaseAuth.instance.currentUser().then((value) async {
                        if (value != null) {
                          _settingModalBottomSheet(context, uid);
                        } else {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => AuthChoosePage()));
                          Fluttertoast.showToast(
                              msg: "Please Login to continue");
                        }
                      });
              })
        ],
        backgroundColor: Color(0xfff9f9f9),
        elevation: 0.0,
      ),
      body: WillPopScope(
        onWillPop: willpop,
        child: Center(
          child: !type
              ? IndexedStack(index: currentTabIndex, children: [
                  ExplorePage(),
                  SearchScreen(),
                  FavoritesScreen(),
                  UserProfilePage(),
                ])
              : IndexedStack(index: currentTabIndex, children: [
                  ExplorePage(),
                  SearchScreen(),
                  LoginPlease(),
                  LoginPlease()
                ]),
        ),
      ),
      extendBody: true,
      bottomNavigationBar: FloatingNavbar(
        backgroundColor: Colors.white70,
        selectedBackgroundColor: Colors.black87,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        onTap: (int val) {
          setState(() {
            // index = val;
            currentTabIndex = val;
          });
          return val;
        },
        currentIndex: currentTabIndex,
        items: [
          FloatingNavbarItem(
              icon: MyFlutterApp.explore_solid, title: 'Explore'),
          FloatingNavbarItem(icon: Icons.search, title: 'Search'),
          FloatingNavbarItem(
              icon: MyFlutterApp.favs_outline, title: 'Favorites'),
          FloatingNavbarItem(icon: Icons.person, title: 'Profile'),
        ],
      ),
    );
  }
}
