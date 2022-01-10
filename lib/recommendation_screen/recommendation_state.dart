import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:rassoi/models/recommendation_models.dart';

class RecommendationState extends ChangeNotifier {
  List<DocumentSnapshot>? fetchedCategoriesSnapshotList;
  List<DocumentSnapshot>? fetchedFavouritesSnapshotList;
  List<DocumentSnapshot>? fetchedDishesSnapshotList;
  Map<String, DocumentSnapshot?> nameFavouritesMap = HashMap();
  bool shouldShowLoader = true;
  bool noInternet = false;
  
  String? currentSearchedQuery;

  RecommendationState() {
    init();
  }

  void init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    // Fetch Categories
    FirebaseFirestore.instance
        .collection("categories")
        .get()
        .then((querySnapshot) {
      fetchedCategoriesSnapshotList = [];
      fetchedCategoriesSnapshotList!.addAll(querySnapshot.docs);
      loadInitialResults();
    }).onError((error, stackTrace) {
      showErrorScreen();
    });

    // Fetch Favorites
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    uid = "Karan_g";
    FirebaseFirestore.instance
        .collection("users/$uid/favourites")
        .get()
        .then((querySnapshot) {
      fetchedFavouritesSnapshotList = [];
      fetchedFavouritesSnapshotList!.addAll(querySnapshot.docs);
      fetchedFavouritesSnapshotList!.sort((a, b) => (a.get("dishName") as String)
          .toLowerCase()
          .toString()
          .compareTo((b.get("dishName") as String).toLowerCase().toString()));
      for (var favouriteDocument in querySnapshot.docs) {
        String dishName = favouriteDocument.get("dishName");
        nameFavouritesMap[dishName.toLowerCase()] = favouriteDocument;
      }
      loadInitialResults();
    }).onError((error, stackTrace) {
      showErrorScreen();
    });;

    // Fetch Dishes
    FirebaseFirestore.instance
        .collection("recipes")
        .get()
        .then((querySnapshot) {
      fetchedDishesSnapshotList = [];
      fetchedDishesSnapshotList!.addAll(querySnapshot.docs);
      fetchedFavouritesSnapshotList!.sort((a, b) => (a.get("name") as String)
          .toLowerCase()
          .toString()
          .compareTo((b.get("name") as String).toLowerCase().toString()));
      loadInitialResults();
    }).onError((error, stackTrace) {
      showErrorScreen();
    });
  }

  List<RecommendationModel> getFavourites() {
    if (fetchedFavouritesSnapshotList == null) {
      return [];
    }
    List<RecommendationModel> finalList = [];
    if (currentSearchedQuery == null) {
       for (var documentSnapshot in fetchedFavouritesSnapshotList!) {
         String dishName = documentSnapshot.get("dishName");
         if (nameFavouritesMap[dishName] != null) {
           finalList.add(RecommendationModel(documentSnapshot, true));
         }
      }
    } else {
      List<RecommendationModel> matchList = [];
      List<RecommendationModel> startsWithList = [];
      List<RecommendationModel> containsList = [];
      List<RecommendationModel> noMatchList = [];
      for (var favouriteDocument in fetchedFavouritesSnapshotList!) {
        String dishName = favouriteDocument.get("dishName") as String;
        if (nameFavouritesMap[dishName] == null) {
            continue;
        }
        if (dishName == currentSearchedQuery!) {
          matchList.add(RecommendationModel(favouriteDocument, true));
        } else if (dishName.startsWith(currentSearchedQuery!)) {
          startsWithList.add(RecommendationModel(favouriteDocument, true));
        } else if (dishName.contains(currentSearchedQuery!)) {
          containsList.add(RecommendationModel(favouriteDocument, true));
        } else if (currentSearchedQuery != null) {
          noMatchList.add(RecommendationModel(favouriteDocument, true));
        }
      }
      finalList.addAll(matchList);
      finalList.addAll(startsWithList);
      finalList.addAll(containsList);
      finalList.addAll(noMatchList);
    }
    return finalList;
  }

  List<String> getSuggestions(String? currentTypedQuery) {
    if (fetchedCategoriesSnapshotList == null
        || fetchedDishesSnapshotList == null
        || currentTypedQuery == null
        || currentTypedQuery.isEmpty) {
      return ["Search all dishes"];
    }
    currentTypedQuery = currentTypedQuery.toLowerCase();
    List<String> suggestionList = [];
    List<String> matchedList = [];
    List<String> startsWithList = [];
    List<String> containsList = [];
  //  List<String> unMatchedList = [];

    List<String> categorySuggestions = [];
    for (int index = 0; index < fetchedCategoriesSnapshotList!.length; index++) {
      String categoryName = fetchedCategoriesSnapshotList!.elementAt(index).get("categoryName");
      categoryName = categoryName.toLowerCase();
      if (categoryName.startsWith(currentTypedQuery)) {
        categorySuggestions.add(categoryName);
        break;
      }
    }
    for (var dishDocumentSnapshot in fetchedDishesSnapshotList!) {
      String dishName = dishDocumentSnapshot.get("name") as String;
      dishName = dishName.toLowerCase();
      if (categorySuggestions.isNotEmpty && suggestionList.isEmpty && currentTypedQuery != null) {
        suggestionList.addAll(categorySuggestions);
      }
      if (dishName == currentTypedQuery) {
        matchedList.add(dishName);
      } else if (dishName.startsWith(currentTypedQuery)) {
        startsWithList.add(dishName);
      } else if (dishName.contains(currentTypedQuery)) {
        containsList.add(dishName);
      }
    }
    suggestionList.addAll(matchedList);
    suggestionList.addAll(startsWithList);
    suggestionList.addAll(containsList);
 //   searchList.addAll(unMatchedList);
    return suggestionList.take(5).toList();
  }

  List<RecommendationModel> getAllResults() {
    if (fetchedDishesSnapshotList == null) {
      return [];
    }
    List<RecommendationModel> finalList = [];
    if (nameFavouritesMap.isNotEmpty) {
      finalList.add(RecommendationModel(null, true));
    }
    if (currentSearchedQuery == null || currentSearchedQuery == "Search all dishes") {
      List<DocumentSnapshot> removedFavouritesList = [];
      // 1a. Remove all favourites
      for (var fetchedDishSnapshot in fetchedDishesSnapshotList!) {
//        bool match = false;
        String name = fetchedDishSnapshot.get("name") as String;
        if (nameFavouritesMap[name.toLowerCase()] == null) {
          removedFavouritesList.add(fetchedDishSnapshot);
        }
/*        for (var fetchedFavouriteSnapshot in fetchedFavouritesSnapshotList!) {
          if (name.toLowerCase() == fetchedFavouriteSnapshot.get("dishName").toLowerCase()) {
            match = true;
            break;
          }
        }
        if (!match) {
          removedFavouritesList.add(fetchedDishSnapshot);
        }*/
      }
      // 1b. sort alpha numerically
      removedFavouritesList.sort((a, b) => a
          .get("name")
          .toLowerCase()
          .toString()
          .compareTo(b.get("name").toLowerCase().toString()));
      for (int i = 0; i < removedFavouritesList.length; i++) {
        finalList.add(
            RecommendationModel(
                removedFavouritesList[i],
                false,
                isStartOfAllResults: i == 0)
        );
      }
      return finalList;
    } else {
      List<DocumentSnapshot> removedFavouritesList = [];
      // 1a. Remove all favourites
      for (var fetchedDishSnapshot in fetchedDishesSnapshotList!) {
//        bool match = false;
        String name = fetchedDishSnapshot.get("name") as String;
        if (nameFavouritesMap[name.toLowerCase()] == null) {
          removedFavouritesList.add(fetchedDishSnapshot);
        }
      }
      // 1b. sort alpha numerically
      removedFavouritesList.sort((a, b) => a
          .get("name")
          .toLowerCase()
          .toString()
          .compareTo(b.get("name").toLowerCase().toString()));

      // 2a. If matchingCategory is non null, then user searched for that specific category
      String? matchingCategory;
      if (fetchedCategoriesSnapshotList != null && fetchedCategoriesSnapshotList!.isNotEmpty) {
        for (int index = 0; index < fetchedCategoriesSnapshotList!.length; index++) {
          String categoryName = fetchedCategoriesSnapshotList!.elementAt(index).get("categoryName");
          categoryName = categoryName.toLowerCase();
          if (currentSearchedQuery != null && categoryName.startsWith(currentSearchedQuery!)) {
            matchingCategory = categoryName;
            break;
          }
        }
      }

      // 2b. Show only those dishes which has the searched matchingCategory in its category list.
      //     We sort the list alpha numerically before showing.
      if (matchingCategory != null) {
        List<RecommendationModel> queryMatchingCategoryDishList = [];
        for (var document in removedFavouritesList) {
          List<dynamic> categoryNameList = document.get("categoryName")
              .map((categoryName) => (categoryName as String).toLowerCase())
              .toList();
          if (categoryNameList.contains(matchingCategory)) {
            queryMatchingCategoryDishList
                .add(RecommendationModel(document, false, isStartOfAllResults: queryMatchingCategoryDishList.isEmpty));
          }
        }
        return queryMatchingCategoryDishList;
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

        if (currentSearchedQuery != null && name == currentSearchedQuery!) {
          dishMatchedList.add(dishDocument);
        } else if (currentSearchedQuery != null &&
            name.startsWith(currentSearchedQuery!)) {
          dishStartsWithList.add(dishDocument);
        } else if (currentSearchedQuery != null && name.contains(currentSearchedQuery!)) {
          dishContainsList.add(dishDocument);
        } else {
          dishUnMatchedList.add(dishDocument);
        }
      }
      finalDishList.addAll(dishMatchedList);
      finalDishList.addAll(dishStartsWithList);
      finalDishList.addAll(dishContainsList);
      finalDishList.addAll(dishUnMatchedList);
      for (int i = 0; i < finalDishList.length; i++) {
        finalList.add(
            RecommendationModel(
              finalDishList[i],
              false,
              isStartOfAllResults: i == 0)
        );
      }
      return finalList;
    }
  }

  loadInitialResults() {
    if (fetchedCategoriesSnapshotList == null
        || fetchedFavouritesSnapshotList == null
        || fetchedDishesSnapshotList == null) {
      return;
    }
    noInternet = false;
    shouldShowLoader = false;
    notifyListeners();
  }

  void showErrorScreen() {
    noInternet = true;
    shouldShowLoader = false;
    notifyListeners();
  }

  tryAgainTapped() {
    noInternet = false;
    shouldShowLoader = true;
    init();
  }
}
