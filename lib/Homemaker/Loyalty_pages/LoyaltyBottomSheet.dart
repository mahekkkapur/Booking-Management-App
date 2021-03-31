import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//TODO make focus node work
class LoyaltyBottomSheet extends StatefulWidget {
  final String uid;

  LoyaltyBottomSheet({Key key, @required this.uid}) : super(key: key);
  @override
  _LoyaltyBottomSheetState createState() => _LoyaltyBottomSheetState();
}

class _LoyaltyBottomSheetState extends State<LoyaltyBottomSheet> {
  TextEditingController ordersController = TextEditingController(text: "0");
  TextEditingController amountController = TextEditingController(text: "0");
  TextEditingController discountController = TextEditingController(text: "0");
  String dropDownValue = "single";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: MediaQuery.of(context).size.height * 0.4,
      child: SingleChildScrollView(
        child: Form(
          child: Column(
            children: <Widget>[
              Row(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SizedBox(
                        width: 30,
                      ),
                      Text(
                        "Loyalty Rules",
                        style: TextStyle(
                            fontSize: 25.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontFamily: "Gilroy"),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 35,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: ordersController,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 5),
                          border: OutlineInputBorder(),
                          labelText: "Min. Purchases",
                          labelStyle: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black,
                              fontFamily: "Gilroy")),
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).nextFocus(),
                      autovalidate: true,
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        return (value.isEmpty) ? "Enter Valid no." : null;
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 60,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: amountController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 5),
                        border: OutlineInputBorder(),
                        labelText: "Min. Spending",
                        labelStyle: TextStyle(
                            fontSize: 12.0,
                            color: Colors.black,
                            fontFamily: "Gilroy"),
                        prefix: Text("₹"),
                      ),
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).nextFocus(),
                      autovalidate: true,
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        return (value.isEmpty) ? "Enter Valid no." : null;
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 35,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: DropdownButton<String>(
                      items: [
                        DropdownMenuItem(
                          value: "single",
                          child: Text("One Time",
                              style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.black,
                                  fontFamily: "Gilroy")),
                        ),
                        DropdownMenuItem(
                          value: "repeat",
                          child: Text("Repeat",
                              style: TextStyle(
                                  fontSize: 12.0,
                                  color: Colors.black,
                                  fontFamily: "Gilroy")),
                        ),
                      ],
                      value: dropDownValue,
                      onChanged: (value) {
                        setState(() {
                          dropDownValue = value;
                        });
                      },
                      isExpanded: true,
                      isDense: true,
                    ),
                  ),
                  const SizedBox(
                    width: 60,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: discountController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 5),
                        border: OutlineInputBorder(),
                        labelText: "Discount",
                        labelStyle: TextStyle(
                            fontSize: 12.0,
                            color: Colors.black,
                            fontFamily: "Gilroy"),
                        prefix: Text("₹"),
                      ),
                      autovalidate: true,
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        return (value.isEmpty) ? "Enter Valid no." : null;
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              MaterialButton(
                height: 45,
                minWidth: 150,
                child: Text("Add rule"),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.redAccent,
                textColor: Colors.white,
                onPressed: () {
                  Map<String, dynamic> data = {};
                  data["orders"] = int.parse(ordersController.text);
                  data["amount"] = int.parse(amountController.text);
                  data["discount"] = int.parse(discountController.text);
                  data["repeat"] = dropDownValue == "repeat";
                  data["enabled"] = true;
                  print(data);
                  Firestore.instance
                      .collection("homemakers")
                      .document(widget.uid)
                      .updateData({
                    "loyalty": FieldValue.arrayUnion([data])
                  }).then((value) {
                    Navigator.of(context).pop();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
