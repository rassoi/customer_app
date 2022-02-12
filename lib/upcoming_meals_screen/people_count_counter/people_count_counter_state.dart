import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

class PeopleCountCounterState extends ChangeNotifier {
  int _count = -1;
  bool isMasterCounter;
  bool updateInProgress = false;

  int get count {
    return _count <= 1 ? 1 : _count;
  }

  set count(int count) {
    _count = count;
  }

  PeopleCountCounterState(this.isMasterCounter) {
    init();
  }

  init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    if (isMasterCounter) {
      // Fetch Master count
      String? uId = FirebaseAuth.instance.currentUser?.uid;
      uId = "Karan_g";
      FirebaseFirestore.instance
          .collection("users/$uId/meal_person_count")
          .doc("meal_person_count")
          .get()
          .then((documentSnapshot) {
        _count = documentSnapshot.get("count") as int;
        notifyListeners();
      }).onError((error, stackTrace) {
        int a =0;
      });
    }
  }

  Future<bool> update(bool isIncrement) {
    updateInProgress = true;
    if (_count <= 1 && !isIncrement) {
      return Future.value(true);
    }
    if (isMasterCounter) {
      int updatedValue = isIncrement ? count + 1 : count - 1;
      String? uId = FirebaseAuth.instance.currentUser?.uid;
      uId = "Karan_g";
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection("users/$uId/meal_person_count")
          .doc("meal_person_count");
      return documentReference.set({"count": updatedValue}).then((value) {
        _count = updatedValue;
        return true;
      }).onError((error, stackTrace) {
        return false;
      });
    } else {
      // Use path
      return Future.value(true);
    }
  }
}
