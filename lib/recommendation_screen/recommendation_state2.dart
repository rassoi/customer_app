import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:rassoi/models/recommendation_models.dart';

class RecommendationState extends ChangeNotifier {
  List<DocumentSnapshot> categoriesSnapshotList = [];
  Future<List<RecommendationModel>>? _favouritesFuture;

  Future<List<RecommendationModel>>? get favouritesFuture => _favouritesFuture;

  DocumentSnapshot? lastDishModel;
  String? _currentQuery;

  set currentQuery(String currentQuery) {
    _currentQuery = currentQuery.toString();
    setFavouritesListFuture();
  }

  RecommendationState() {
    init();
  }

  void init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    if (categoriesSnapshotList.isEmpty) {
      FirebaseFirestore.instance
          .collection("categories")
          .get()
          .then((querySnapshot) {
        categoriesSnapshotList.addAll(querySnapshot.docs);
      });
    }

/*    // Listen to favorites changes
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    uid = "Karan_g";
    FirebaseFirestore.instance.collection("users/$uid/favourites").snapshots()
        .listen((querySnapshot) {

      querySnapshot.docs.sort((a, b) =>
          a.get("dishName").toUpperCase().toString().compareTo(b.get("dishName").toUpperCase().toString()));
    });*/
  }

  Future<List<RecommendationModel>>? setFavouritesListFuture() {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    uid = "Karan_g";
    _favouritesFuture = FirebaseFirestore.instance
        .collection("users/$uid/favourites")
        .get()
        .then((querySnapshot) {
      return _getFavouritesFuture(querySnapshot);
    });
  }

  _getFavouritesFuture(QuerySnapshot querySnapshot) {
    // First sort alpha numerically. Then order it based on match, startsWith, contains and no match.
    List<DocumentSnapshot> favouritesSnapshotList = [];
    favouritesSnapshotList.addAll(querySnapshot.docs);
    favouritesSnapshotList.sort((a, b) => a
        .get("dishName")
        .toLowerCase()
        .toString()
        .compareTo(b.get("dishName").toLowerCase().toString()));
    List<RecommendationModel> finalList = [];
    List<RecommendationModel> matchList = [];
    List<RecommendationModel> startsWithList = [];
    List<RecommendationModel> containsList = [];
    List<RecommendationModel> temporaryList = [];
    for (var favouriteDocument in favouritesSnapshotList) {
      String dishName = favouriteDocument.get("dishName") as String;
      if (_currentQuery != null && dishName == _currentQuery!) {
        matchList.add(RecommendationModel(favouriteDocument, true));
      } else if (_currentQuery != null && dishName.startsWith(_currentQuery!)) {
        startsWithList.add(RecommendationModel(favouriteDocument, true));
      } else if (_currentQuery != null && dishName.contains(_currentQuery!)) {
        containsList.add(RecommendationModel(favouriteDocument, true));
      } else if (_currentQuery != null) {
        temporaryList.add(RecommendationModel(favouriteDocument, true));
      } else if (_currentQuery == null) {
        finalList.add(RecommendationModel(favouriteDocument, true));
      }
    }
    finalList.addAll(matchList);
    finalList.addAll(startsWithList);
    finalList.addAll(containsList);
    finalList.addAll(temporaryList);
    return Future.value(finalList);
  }

  Future<List<RecommendationModel>>? getAllResultsFuture(int page) {
    List<RecommendationModel> finalList = [];
    finalList.add(RecommendationModel(null, false, isSearchBar: true));
    _favouritesFuture?.then((favouriteModels) {
      if (_currentQuery == null) {
        if (page == 0) {
          // Fetching 1st ten meals
          FirebaseFirestore.instance
              .collection("recipes")
              .limit(1)
              .get()
              .then((querySnapshot) {
            //   documentSnapshotList.add(querySnapshot.docs.last);
            FirebaseFirestore.instance
                .collection("recipes")
                .startAfterDocument(querySnapshot.docs.last)
                .limit(9)
                .get()
                .then((querySnapshot) {
              //    documentSnapshotList.addAll(querySnapshot.docs);
              //     notifyListeners();
              //documentSnapshotList.first.get("image");
            });
          });
        } else if (lastDishModel != null) {
          FirebaseFirestore.instance
              .collection("recipes")
              .startAfterDocument(lastDishModel!)
              .limit(9)
              .get()
              .then((querySnapshot) {
            //    documentSnapshotList.addAll(querySnapshot.docs);
            //     notifyListeners();
            //documentSnapshotList.first.get("image");
          });
        }
      }
      else if (_currentQuery != null) {
        if (page == 0) {
          _currentQuery = _currentQuery!.toLowerCase();
          return FirebaseFirestore.instance
              .collection("recipes")
              .where(
            "nameAsArray",
            arrayContains: _currentQuery!.toLowerCase(),
          )
              .get()
              .then((querySnapshot) {
            // 1. Remove all favourites dishes. Then sort in alpha numeric order after that only (so its not required to do henceforth in any following stp).
            // 2. If searched for specific category, show only those dishes which has the same category in its category list.
            // 3. If point 2 is not true then sort the dishes based on query in order of same, startswith, contains, no match

            // 1.
            List<DocumentSnapshot> removedFavouritesList = [];
            // 1a. Remove all favourites
            favouriteModels.map((favouriteModel) {
              for (var documentSnapshot in querySnapshot.docs) {
                String name = documentSnapshot.get("name") as String;
                if (name != favouriteModel.getDishName()) {
                  removedFavouritesList.add(documentSnapshot);
                }
              }
            });
            // 1b. sort alpha numerically
            removedFavouritesList.sort((a, b) => a
                .get("name")
                .toLowerCase()
                .toString()
                .compareTo(b.get("name").toLowerCase().toString()));

            // 2a. If matchingCategory is non null, then user searched for that specific category
            String? matchingCategory;
            for (int index = 0; index <= categoriesSnapshotList.length; index++) {
              String categoryName =
              categoriesSnapshotList.elementAt(index).get("categoryName");
              categoryName = categoryName.toLowerCase();
              if (_currentQuery != null &&
                  categoryName.startsWith(_currentQuery!)) {
                matchingCategory = categoryName;
                break;
              }
            }

            // 2b. Show only those dishes which has the searched matchingCategory in its category list.
            //     We sort the list alpha numerically before showing.
            List<RecommendationModel> queryMatchingCategoryDishList = [];
            if (matchingCategory != null) {
              for (var document in removedFavouritesList) {
                List<String> categoryNameList =
                (document.get("categoryName") as List<String>)
                    .map((categoryName) => categoryName.toLowerCase())
                    .toList();
                if (categoryNameList.contains(matchingCategory)) {
                  queryMatchingCategoryDishList
                      .add(RecommendationModel(document, false));
                }
              }
              return Future.value(queryMatchingCategoryDishList);
            }

            // 3
            List<DocumentSnapshot> finalDishList = [];
            List<DocumentSnapshot> dishMatchedList = [];
            List<DocumentSnapshot> dishStartsWithList = [];
            List<DocumentSnapshot> dishContainsList = [];
            List<DocumentSnapshot> dishUnMatchedList = [];
            for (var dishDocument in removedFavouritesList) {
              String name = dishDocument.get("name") as String;
              name = name.toLowerCase();

              if (_currentQuery != null && name == _currentQuery!) {
                dishMatchedList.add(dishDocument);
              } else if (_currentQuery != null &&
                  name.startsWith(_currentQuery!)) {
                dishStartsWithList.add(dishDocument);
              } else if (_currentQuery != null && name.contains(_currentQuery!)) {
                dishContainsList.add(dishDocument);
              } else {
                dishUnMatchedList.add(dishDocument);
              }
            }
            finalDishList.addAll(dishMatchedList);
            finalDishList.addAll(dishStartsWithList);
            finalDishList.addAll(dishContainsList);
            finalDishList.addAll(dishUnMatchedList);
            finalList.addAll(finalDishList.map((documentSnapshot) {
              return RecommendationModel(documentSnapshot, false);
            }));
            return finalList;
          });
        }
      }
    });
  }
}


// 2. Manage Pagination