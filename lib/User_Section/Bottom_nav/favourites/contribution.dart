import 'package:flutter/material.dart';

class Contribution extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dishName = TextField(
      minLines: 1,
      maxLines: 1,
      autocorrect: false,
      decoration: InputDecoration(
        hintText: 'Dish Name',
        hintStyle: TextStyle(fontFamily: 'Gilroy', color: Colors.grey[300]),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey[300]),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey[300]),
        ),
      ),
    );

    final yourRecipe = TextField(
      minLines: 10,
      maxLines: 12,
      autocorrect: false,
      decoration: InputDecoration(
        hintText: 'Your Recipe',
        hintStyle: TextStyle(fontFamily: 'Gilroy', color: Colors.grey[300]),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey[300]),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          borderSide: BorderSide(color: Colors.grey[300]),
        ),
      ),
    );

    final submit = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(15.0),
      color: Colors.pink,
      child: MaterialButton(
        minWidth: (MediaQuery.of(context).size.width) / 2,
        padding: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 15.0),
        onPressed: () {},
        child: Text("Submit",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white, fontFamily: 'Gilroy', fontSize: 15)),
      ),
    );

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 30,
              ),
              onPressed: () => Navigator.pop(context)),
        ),
        body: Container(
          color: Colors.grey[200],
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Contribute',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                dishName,
                SizedBox(
                  height: 20.0,
                ),
                yourRecipe,
                SizedBox(
                  height: 120.0,
                ),
                Text(
                  'Note: All user added reciped added by user will be published only after being verified by our content moderation team.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontFamily: 'Gilroy',
                  ),
                ),
                SizedBox(
                  height: 12.0,
                ),
                submit,
              ]),
            ),
          ),
        ));
  }
}
