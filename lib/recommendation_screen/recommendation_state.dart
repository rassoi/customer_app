import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class RecommendationState extends ChangeNotifier {
  List<DocumentSnapshot> documentSnapshotList = [];
  List<DocumentSnapshot> favouritesSnapshotList = [];
  List<DocumentSnapshot> categoriesSnapshotList = [];

  Map<int, bool> saveMap = HashMap();

  String? _latestSearchQuery;

  String? get latestSearchQuery => _latestSearchQuery;

  set latestSearchQuery(String? latestSearchQuery) {
    _latestSearchQuery = latestSearchQuery;
    notifyListeners();
  }

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
                notifyListeners();
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
       FirebaseFirestore.instance.collection("users/$uid/favourites")
          .get().then((querySnapshot) {
        favouritesSnapshotList.addAll(querySnapshot.docs);
        favouritesSnapshotList.sort((a, b) =>
            a.get("dishName").toUpperCase().toString().compareTo(b.get("dishName").toUpperCase().toString()));
        notifyListeners();
        return querySnapshot.docs.map((documentSnapshot) {
          return documentSnapshot.get("image") as String;
        }).toList();
      });
    }
    FirebaseFirestore.instance.collection("users/$uid/favourites").snapshots()
        .listen((querySnapshot) {
      favouritesSnapshotList = querySnapshot.docs;
      favouritesSnapshotList.sort((a, b) =>
          a.get("dishName").toUpperCase().toString().compareTo(b.get("dishName").toUpperCase().toString()));
    });
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

  Future<List<String>> querySearchSuggestionList(String searchQuery) {
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
      for (int index = 0; index < categoriesSnapshotList.length; index++) {
        String categoryName = categoriesSnapshotList.elementAt(index).get("categoryName");
        categoryName = categoryName.toLowerCase();
        if (categoryName.startsWith(searchQuery)) {
          categorySuggestions.add(categoryName);
          break;
        }
      }
      for (var documentSnapshot in querySnapshot.docs) {
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
      }
        searchList.addAll(snapshotMatchedList);
        searchList.addAll(snapshotContainsList);
        searchList.addAll(snapshotUnMatchedList);
        return Future.value(searchList);
      //   documentSnapshotList.addAll(querySnapshot.docs);
      //documentSnapshotList.first.get("image");
    });
  }

  Future<List<String>> querySearchResultList() {
    List<String> dishImageList = [];
    dishImageList.add("");
    dishImageList.add("");
    if (latestSearchQuery == null) {
      dishImageList.addAll(documentSnapshotList.map((documentSnapshot) {
        return documentSnapshot.get("img") as String;
      }).toList());
      return Future.value(dishImageList);
    }
    latestSearchQuery = latestSearchQuery!.toLowerCase();
    List<DocumentSnapshot> modifiedList = [];
    List<DocumentSnapshot> snapshotMatchedList = [];
    List<DocumentSnapshot> snapshotContainsList = [];
    List<DocumentSnapshot> snapshotUnMatchedList = [];
    return FirebaseFirestore.instance
        .collection("recipes")
        .where(
          "nameAsArray",
          arrayContains: latestSearchQuery!.toLowerCase(),
        )
        .get()
        .then((querySnapshot) {
          String? categorySuggestion;
          for (int index = 0; index <= categoriesSnapshotList.length; index++) {
           String categoryName = categoriesSnapshotList.elementAt(index).get("categoryName");
           categoryName = categoryName.toLowerCase();
           if (categoryName == latestSearchQuery) {
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
        } else if (name.startsWith(latestSearchQuery!)) {
          snapshotMatchedList.add(documentSnapshot);
        } else if (name.contains(latestSearchQuery!)) {
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
      dishImageList.addAll(modifiedList.map((documentSnapshot) {
        return documentSnapshot.get("img") as String;
      }).toList());
      return Future.value(dishImageList);
    });
  }

  saveDish(int index) {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    uid = "Karan_g";
      favouritesFuture = FirebaseFirestore.instance.collection("users/$uid/favourites").
  }
}
