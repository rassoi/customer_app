import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class RecommendationState extends ChangeNotifier {
  List<DocumentSnapshot> documentSnapshotList = [];
  List<DocumentSnapshot> favouritesSnapshotList = [];
  List<DocumentSnapshot> categoriesSnapshotList = [];

  RecommendationState() {
    init();
  }

  void init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    // Fetching 1st ten meals
      FirebaseFirestore.instance
          .collection("recipes")
          .limit(1)
          .get()
          .then((querySnapshot) {
              documentSnapshotList.add(querySnapshot.docs.last);
              FirebaseFirestore.instance
                 .collection("recipes")
                 .startAfterDocument(documentSnapshotList.last)
                 .limit(9)
                 .get()
                 .then((querySnapshot) {
                documentSnapshotList.addAll(querySnapshot.docs);
                //documentSnapshotList.first.get("image");
        });
      });
      //    .then((value) => documentSnapshotList.forEach((querySnapshot) {}));
    if (categoriesSnapshotList.isEmpty) {
      FirebaseFirestore.instance
          .collection("categories")
          .get()
          .then((querySnapshot) {
          categoriesSnapshotList.addAll(querySnapshot.docs);
      });
    }
    
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    uid = "Karan_g";
    if (uid != null && favouritesSnapshotList.isEmpty) {
      Future<List<String>> future = FirebaseFirestore.instance.collection("users/$uid/favourites")
          .get().then((querySnapshot) {
        favouritesSnapshotList.addAll(querySnapshot.docs);
        favouritesSnapshotList.sort((a, b) =>
            a.get("name").toUpperCase().toString().compareTo(b.get("name").toUpperCase().toString()));
      });
    }
  }

  void paginate() {
    FirebaseFirestore.instance
        .collection("recipes")
        .startAfterDocument(documentSnapshotList.last)
        .limit(9)
        .get()
        .then((querySnapshot) {
      documentSnapshotList.addAll(querySnapshot.docs);
      //documentSnapshotList.first.get("image");
    });
  }

  querySearchSuggestionList(String searchQuery) {
    searchQuery = searchQuery.toLowerCase();
    List<String> searchList = [];
    List<String> snapshotMatchedList = [];
    List<String> snapshotContainsList = [];
    List<String> snapshotUnMatchedList = [];
    return FirebaseFirestore.instance
        .collection("recipes")
        .where(
      "nameAsArray",
      arrayContains: searchQuery)
        .get()
        .then((querySnapshot) {
      List<String> categorySuggestions = [];
      for (int index = 0; index <= categoriesSnapshotList.length; index++) {
        String categoryName = categoriesSnapshotList.elementAt(index).get("categoryName");
        categoryName = categoryName.toLowerCase();
        if (categoryName.startsWith(searchQuery)) {
          categorySuggestions.add(categoryName);
          break;
        }
      }
      querySnapshot.docs.map((documentSnapshot) {
        String name = documentSnapshot.get("name") as String;
        name = name.toLowerCase();
        if (categorySuggestions.isNotEmpty && searchList.isEmpty) {
            searchList.addAll(categorySuggestions);
        }
        if (name.startsWith(searchQuery)) {
          snapshotMatchedList.add(name);
        } else if (name.contains(searchQuery)) {
          snapshotContainsList.add(name);
        } else {
          snapshotUnMatchedList.add(name);
        }
      });
        searchList.addAll(snapshotMatchedList);
        searchList.addAll(snapshotContainsList);
        searchList.addAll(snapshotUnMatchedList);
      //   documentSnapshotList.addAll(querySnapshot.docs);
      //documentSnapshotList.first.get("image");
    });
  }

  querySearchResultList(String searchQuery) {
    searchQuery = searchQuery.toLowerCase();
    List<DocumentSnapshot> modifiedList = [];
    List<DocumentSnapshot> snapshotMatchedList = [];
    List<DocumentSnapshot> snapshotContainsList = [];
    List<DocumentSnapshot> snapshotUnMatchedList = [];
    return FirebaseFirestore.instance
        .collection("recipes")
        .where(
          "nameAsArray",
          arrayContains: searchQuery.toLowerCase(),
        )
        .get()
        .then((querySnapshot) {
          String? categorySuggestion;
          for (int index = 0; index <= categoriesSnapshotList.length; index++) {
           String categoryName = categoriesSnapshotList.elementAt(index).get("categoryName");
           categoryName = categoryName.toLowerCase();
           if (categoryName == searchQuery) {
             categorySuggestion = categoryName;
             break;
           }
          }
      querySnapshot.docs.map((documentSnapshot) {
        String name = documentSnapshot.get("name") as String;
        name = name.toLowerCase();
        String categoryName = documentSnapshot.get("categoryName") as String;
        categoryName = categoryName.toLowerCase();

        if (categorySuggestion != null) {
          if (categoryName == categorySuggestion) {
            modifiedList.add(documentSnapshot);
          }
        } else if (name.startsWith(searchQuery)) {
          snapshotMatchedList.add(documentSnapshot);
        } else if (name.contains(searchQuery)) {
          snapshotContainsList.add(documentSnapshot);
        } else {
          snapshotUnMatchedList.add(documentSnapshot);
        }
      });
      if (categorySuggestion == null) {
        modifiedList.addAll(snapshotMatchedList);
        modifiedList.addAll(snapshotContainsList);
        modifiedList.addAll(snapshotUnMatchedList);
      }
      //   documentSnapshotList.addAll(querySnapshot.docs);
      //documentSnapshotList.first.get("image");
    });
  }
}
