import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rassoi/recipe_screen/recipe_widget.dart';
import 'package:rassoi/recommendation_screen/recommendation_state.dart';
import 'package:rassoi/recommendation_screen/recommendation_widget.dart';
import 'package:rassoi/upcoming_meal.dart';
import 'package:transparent_image/transparent_image.dart';

import 'food_categories.dart';
import 'login_screen/authentication.dart';
import 'login_screen/login_widget.dart';

void main() async {

  /**
   * Recommendation Page
   */
  runApp(RecommendationPage());

  /**
   * Recipe Screen
   */
 // runApp(RecipeWidget());

  /**
   * Rassoi Home Page
   */
 // runApp(const HomePage());

  /**
   * Login
   */
//  isLoggedIn();
}

FutureOr<void> isLoggedIn() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAuth.instance.userChanges().listen((user) {
    runApp(
      ChangeNotifierProvider(
        create: (context) => ApplicationState(user != null),
        builder: (context, _) => LoginPage(user != null ? '/homeWidget' : '/'),
      ),
    );
  });
}

/**
 * Rassoi
 */
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const HomeWidget(title: 'Flutter Demo Home Page'),
    );
  }
}

/**
 * Rassoi
 */
class HomeWidget extends StatelessWidget {
  final String title;
  static const int LEFT_PADDING = 20;
  static const int RIGHT_PADDING = 10;
  static const int TOP_PADDING = 50;
  static const int BOTTOM_PADDING = 20;

  const HomeWidget({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    return ChangeNotifierProvider<UpcomingMeal>(
      create: (context) {
        return UpcomingMeal();
      },
      child: Scaffold(
/*      appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),*/
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 10, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const <Widget>[
                  Text("Rassoi"),
                  Icon(Icons.search_outlined),
                ],
              ),
            ),
            const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 10, 20),
                child: Text("Upcoming Meals")),
            FutureBuilder<Iterable<String>>(
              future: getUpcomingMealsFuture(),
              builder: (BuildContext context,
                  AsyncSnapshot<Iterable<String>> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Text('Loading...');
                  default:
                    return SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.length,
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(
                            height: 10,
                            width: 10,
                          );
                        },
                        itemBuilder: (BuildContext context, int index) {
                          String image = snapshot.data!.elementAt(index);
                          return Container(
                            color: Colors.red,
                            height: 100,
                            child: FadeInImage.memoryNetwork(
                              width: 100,
                              height: 100,
                              placeholder: kTransparentImage,
                              fit: BoxFit.cover,
                              image:
                                  "https://images.unsplash.com/photo-1503818454-2a008dc38d43?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8dGFsbHxlbnwwfHwwfHw%3D&w=1000&q=80",
                            ),
                          );
                        },
                      ),
                    );
                }
              },
            ),
            const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 10, 20),
                child: Text("Explore Food")),
            FutureBuilder(
              future: getFoodCategories(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                return Container(
                    alignment: Alignment.topLeft,
                    height: 90,
                    child: GridView.builder(
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4),
                        itemBuilder: (_, index) {
                          bool shouldShowAllButton =
                              index + 1 > snapshot.data!.docs.length;
                          Map<String, dynamic>? map;
                          if (!shouldShowAllButton) {
                            map = snapshot.data?.docs.elementAt(index).data();
                          }
                          return FoodCategory(
                              map?.values.last,
                              map?.values.first,
                              index > 7
                                  ? true
                                  : shouldShowAllButton
                                      ? true
                                      : false);
                        },
                        itemCount: getCategoriesCount(snapshot)));
              },
            ),
/*            ListView(
              scrollDirection: Axis.horizontal,
              children: [

              ],
            )*/
          ],
        ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business),
                label: 'Business',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: 'School',
              ),
            ],
            currentIndex: 1,
            selectedItemColor: Colors.amber[800],
  //     onTap: _onItemTapped,
          )
      ),
    );
  }

  int getCategoriesCount(
      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
    if (snapshot.data == null) {
      return 0;
    }
    return snapshot.data!.docs.length >= 8 ? 8 : snapshot.data!.docs.length + 1;
  }

/*  List<Widget> getUpcomingMealsWidgets(List<String>? dataList) {
    if (dataList == null) {
      return [const Text("snapshot data is null")];
    }
    return dataList.map((imageUrl) => Container(
      color: Colors.red,
      height: 100,
      child: FadeInImage.memoryNetwork(
        width: 100,
        height: 100,
        placeholder: kTransparentImage,
        fit: BoxFit.cover,
        image: "https://images.unsplash.com/photo-1503818454-2a008dc38d43?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8dGFsbHxlbnwwfHwwfHw%3D&w=1000&q=80",
      ),
    ),
    ).toList();
  }*/

  Future<List<String>> getUpcomingMealsFuture() async {
    await Firebase.initializeApp();
    String uid = "Karan_g";
    return FirebaseFirestore.instance
        .collection("/users/$uid/meals")
        .get()
        .then((collection) {
      return collection.docs.map((documentSnapshot) {
        return documentSnapshot.get("dish_image") as String;
      }).toList();
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getFoodCategories() async {
    await Firebase.initializeApp();
    return FirebaseFirestore.instance.collection("/categories/").get();
  }
}
