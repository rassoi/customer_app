// flutter run --no-sound-null-safety
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rassoi/home_screen/main.dart';
import 'package:rassoi/upcoming_meals_screen/people_count_counter/people_count_conter_widget.dart';
import 'package:rassoi/upcoming_meals_screen/people_count_counter/people_count_counter_state.dart';

import 'grid_with_header.dart';

class UpcomingMealsPage extends StatelessWidget {
  const UpcomingMealsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: MaterialColor(0xffFFE9D2, swatch), primaryColor: const Color(0xffFFE9D2)),
      title: "Recommendation Page",
      home:  UpcomingMealsWidget(),
    );
  }
}

class UpcomingMealsWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Upcoming Meals", style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xffFF8816),
          elevation: 0
      ),
      body: ChangeNotifierProvider<PeopleCountCounterState>(
          create: (_) => PeopleCountCounterState(true),
          child: PeopleCountCounterWidget() // also use GridHeader()
      ),
    );
  }
}