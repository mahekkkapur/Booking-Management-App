class User {
  String id;
  String name;
  var rating;
  String iname;
  var icost;
  var pay;

  User({this.id, this.name,this.rating});

  User.fromMap(Map snapshot,String id) :
        id = id ?? '',
        name = snapshot['name'] ?? '',
        rating = snapshot['rating'] ?? '',
        iname = snapshot['iname'] ?? '',
        pay= snapshot['pay'] ?? '',
        icost = snapshot['icost'] ?? '';
        

  toJson() {
    return {
      "name": name,
      "rating": rating,
  };
}
}