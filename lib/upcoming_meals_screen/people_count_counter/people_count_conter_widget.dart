import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rassoi/home_screen/main.dart';
import 'package:rassoi/shared/date_and_time_dialog.dart';
import 'package:rassoi/upcoming_meals_screen/people_count_counter/people_count_counter_state.dart';

class PeopleCountCounterWidget extends StatefulWidget {
  const PeopleCountCounterWidget({Key? key}) : super(key: key);

  @override
  State<PeopleCountCounterWidget> createState() =>
      _PeopleCountCounterWidgetState();
}

class _PeopleCountCounterWidgetState extends State<PeopleCountCounterWidget> {
  @override
  Widget build(BuildContext context) {
    PeopleCountCounterState countState =
        Provider.of<PeopleCountCounterState>(context);
    return SizedBox(
      height: 30,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        InkWell(
          splashColor: Colors.green,
          onTap: () {
            _handleTap(context, countState, false);
          },
          customBorder: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
          ),
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10))),
            child: const Center(
                child: Padding(
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    child: Text("-"))),
          ),
        ),
        InkWell(
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) => DateAndTimeDialog());
          },
          splashColor: Colors.green,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: Center(
                child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 5, bottom: 5),
                    child: countState.updateInProgress
                        ? const SizedBox(
                            height: 10,
                            width: 10,
                            child: CircularProgressIndicator())
                        : Text(countState.count.toString()))),
          ),
        ),
        InkWell(
          customBorder: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10)),
          ),
          onTap: () {
            _handleTap(context, countState, true);
          },
          splashColor: Colors.green,
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10))),
            child: const Center(
                child: Padding(
                    padding:
                        EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    child: Text("+"))),
          ),
        ),
      ]),
    );
  }

  void _handleTap(BuildContext context, PeopleCountCounterState countState,
      bool isIncrement) {
    var future = countState.update(isIncrement);
    setState(() {});
    future.then((success) {
      if (success) {
        setState(() {
          countState.updateInProgress = false;
        });
      } else if (!success) {
        showSnackBar(context, "Something went wrong");
      }
    });
  }
}
