import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class UpcomingMeal extends ChangeNotifier {
  UpcomingMeal() {
    init();
  }

  void init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    // String uid = FirebaseAuth.instance.currentUser!.uid;
    String uid = "Karan_g";
    await FirebaseFirestore.instance
        .collection("/users/$uid/meals")
        .get()
        .then((collection) {
          collection.docs.forEach((documentSnapshot) {
         //   documentSnapshot.get(field)
         //   documentSnapshot.get(field);
          });
     // collection.docs.first.;
     // QueryDocumentSnapshot queryDocumentSnapshot = collection.docs.first;
     // queryDocumentSnapshot.get()
      for (var doc in collection.docs) {
        // mealNames.add(doc.id);
        var k = doc;
      }
    }
    );
  }
}
