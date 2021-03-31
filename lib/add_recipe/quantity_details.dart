import 'package:econoomaccess/add_recipe/instructions.dart';
import 'package:econoomaccess/add_recipe/recipeVariables.dart' as variable;
import 'package:flutter/material.dart';

class QuantityDetails extends StatefulWidget {
  final String name;
  final String uid;
  final String imageUrl;
  final String userType;
  QuantityDetails({
    Key key,
    @required this.name,
    @required this.uid,
    @required this.imageUrl,
    @required this.userType,
  }) : super(key: key);

  @override
  _QuantityDetailsState createState() => _QuantityDetailsState();
}

class _QuantityDetailsState extends State<QuantityDetails> {
  int ingredients = 1;
  String selected;
  List<String> types = [];
  typo() {
    for (int i = 0; i < 40; i++) {
      types.insert(0, "");
    }
  }

  @override
  void initState() {
    typo();
    super.initState();
  }

  pushBack() {
    if (widget.userType == "homeMaker") {
      Navigator.of(context).pushNamed('/EditPage');
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 25.0,
            ),
            onPressed: () => pushBack()),
        elevation: 0.0,
        backgroundColor: Color(0xFFFF9F9F9),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Color(0xFFFF9F9F9),
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.all(20.0),
              child: Text(
                "Add Ingredients",
                style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Gilroy"),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: width * 0.18,
                ),
                Container(
                  width: width * 0.4,
                  child: Text(
                    "Ingredient",
                    style: TextStyle(fontSize: 15.0, fontFamily: "Gilroy"),
                  ),
                ),
                Container(
                  width: width * 0.2,
                  child: Text("Quantity",
                      style: TextStyle(fontSize: 15.0, fontFamily: "Gilroy")),
                ),
                Text(
                  "Type",
                  style: TextStyle(fontSize: 15.0, fontFamily: "Gilroy"),
                ),
                SizedBox(
                  width: 10.0,
                ),
              ],
            ),
            Flexible(
              child: ListView.builder(
                itemCount: ingredients,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 5.0),
                        width: width * 0.1,
                        height: 35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50.0),
                            gradient: LinearGradient(
                                colors: [Color(0xFFFF6530), Color(0xFFFE4E74)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter)),
                        child: Center(
                            child: Text(
                          (index + 1).toString(),
                          style: TextStyle(color: Colors.white, fontSize: 20.0),
                        )),
                      ),
                      Container(
                        width: width * 0.25,
                        height: 50,
                        padding: EdgeInsets.only(left: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey,
                        ),
                        margin: EdgeInsets.all(10.0),
                        child: TextField(
                          controller: variable.ingredients[index],
                          decoration: InputDecoration(border: InputBorder.none),
                        ),
                      ),
                      Container(
                        width: width * 0.14,
                        padding: EdgeInsets.only(left: 5.0),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.grey,
                        ),
                        margin: EdgeInsets.all(10.0),
                        child: TextField(
                          controller: variable.quantity[index],
                          decoration: InputDecoration(border: InputBorder.none),
                        ),
                      ),
                      Container(
                        width: width * 0.20,
                        child: DropdownButton<String>(
                          hint: Text("Choose"),
                          value:
                              types[index] == "" ? this.selected : types[index],
                          isDense: true,
                          onChanged: (String newValue) {
                            setState(() {
                              selected = newValue;
                              types[index] = newValue;
                            });
                          },
                          items: ["g", "kg","ml","l","cup","tablespoon","teaspoon"].map((String v) {
                            return DropdownMenuItem(
                              value: v,
                              child: Text(v),
                            );
                          }).toList(),
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    ingredients++;
                  });
                },
                child: Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      gradient: LinearGradient(
                          colors: [Color(0xFFFF6530), Color(0xFFFE4E74)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter)),
                  child: Icon(
                    Icons.add,
                    size: 30.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Instructions(
                              userType: widget.userType,
                              name: widget.name,
                              ingredients: ingredients,
                              type: types,
                              uid: widget.uid,
                              image: widget.imageUrl)));
                },
                child: Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      gradient: LinearGradient(
                          colors: [Color(0xFFFF6530), Color(0xFFFE4E74)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter)),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 30.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20.0,
            )
          ],
        ),
      ),
    );
  }
}
