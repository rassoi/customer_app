import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class UpcomingMealsState extends ChangeNotifier {
  String _selectedDay = DateFormat('EEEE').format(DateTime.now());// e.g "Sunday"
  set selectDay(String selectedDay) {
    _selectedDay = selectedDay;
  }

  Map<int, List<DocumentSnapshot>> upcomingMealsForSelectedDayMap = HashMap();

  UpcomingMealsState() {
    fetchForUpcomingMeals();
  }

  void fetchForUpcomingMeals() {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    uid = "Karan_g";
    var now = DateTime.now();
    var formatter = DateFormat('MM-dd-yyyy');
    String todayDate = formatter.format(now);
    int presentDate = int.parse(todayDate);
    List<DocumentSnapshot> upcomingMealsForSelectedDay = [];

    FirebaseFirestore.instance.collection("users/$uid/meals/$todayDate/meals")// use /meals$_selectedDay instead
        .get()
        .then((querySnapshot) {
      // Delete old meals
      List<String> toRemoveList = [];
      for (var documentSnapshot in querySnapshot.docs) {
        String documentDate = documentSnapshot.get("date") as String;
          int date = int.parse((documentSnapshot.get("date") as String).replaceAll("-", ""));
          if (presentDate > date) {
            toRemoveList.add(documentDate);
          } else {
            upcomingMealsForSelectedDay.add(documentSnapshot);
          }
        }
      for (var name in toRemoveList) {
        FirebaseFirestore.instance
            .collection("users/$uid/meals/")// use /meals$_selectedDay instead
            .doc(name)
            .delete()
            .onError((error, stackTrace) => null);
      }

      int presentHours = int.parse(DateFormat('hh').format(DateTime.now()));
      if (presentHours >= 0 && presentHours <= 10) {
        updateSelectedDayTimeMap(upcomingMealsForSelectedDay, true, true, true, true);
      } else if (presentHours > 10 && presentHours <= 14) {
        updateSelectedDayTimeMap(upcomingMealsForSelectedDay, false, true, true, true);
      } else if (presentHours > 14 && presentHours <= 19) {
        updateSelectedDayTimeMap(upcomingMealsForSelectedDay, false, false, true, true);
      } else if (presentHours > 19 && presentHours <= 22) {
        updateSelectedDayTimeMap(upcomingMealsForSelectedDay, false, false, false, true);
      } else if (presentHours > 22 && presentHours < 24) {
        updateSelectedDayTimeMap(upcomingMealsForSelectedDay, false, false, false, false);
      }
    }).onError((error, stackTrace) => null);
  }

  updateSelectedDayTimeMap(
      List<DocumentSnapshot> upcomingMealsForSelectedDay,
      bool includeBreakfast,
      bool includeLunch,
      bool includeSnacks,
      bool includeDinner) {
    for (int index = 0; index< upcomingMealsForSelectedDay.length; index ++) {
      DocumentSnapshot documentSnapshot = upcomingMealsForSelectedDay.elementAt(index);
      documentSnapshot.id;
      String time = documentSnapshot.get("time");
      documentSnapshot.data()

      for () {

      }

      if (time == 0 && includeBreakfast) {
        upcomingMealsForSelectedDayMap[0] = documentSnapshot;
      }
      if (time == 1 && includeLunch) {
        upcomingMealsForSelectedDayMap[1] = documentSnapshot;
      }
      if (time == 2 && includeSnacks) {
        upcomingMealsForSelectedDayMap[2] = documentSnapshot;
      }
      if (time == 3 && includeDinner) {
        upcomingMealsForSelectedDayMap[3] = documentSnapshot;
      }
    }
  }
}