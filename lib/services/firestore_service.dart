import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final Firestore _db = Firestore.instance;
  static final liveCollection = 'liveuser';

  static void createLiveUser({name, id, time, image, organiser}) async {
    final snapShot = await _db.collection(liveCollection).document(name).get();
    if (snapShot.exists) {
      await _db.collection(liveCollection).document(name).updateData({
        'channelName': name,
        'channel': id,
        'time': time,
        'image': image,
        "organiser": organiser
      });
    } else {
      await _db.collection(liveCollection).document(name).setData({
        'channelName': name,
        'channel': id,
        'time': time,
        'image': image,
        "organiser": organiser
      });
    }
  }

  static void addUser({name, uid, imageUrl, approval, channelName}) async {
    Firestore.instance
        .collection(liveCollection)
        .document(channelName)
        .collection("users")
        .document(uid)
        .setData({
      "name": name,
      "approval": false,
      "imageUrl": imageUrl,
      "uid": uid
    });
  }

  static void deleteUser({username}) async {
    await _db.collection(liveCollection).document(username).collection("users").document().delete();
    await _db.collection(liveCollection).document(username).delete();
  }
}
