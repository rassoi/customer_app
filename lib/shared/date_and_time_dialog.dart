import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Map<int, String> dayMap = {
  1: "S",
  2: "M",
  3: "T",
  4: "W",
  5: "T",
  6: "F",
  7: "S"
};

class DateAndTimeDialog extends StatefulWidget {
  const DateAndTimeDialog({Key? key}) : super(key: key);

  @override
  State<DateAndTimeDialog> createState() => _DateAndTimeDialog();
}

class _DateAndTimeDialog extends State<DateAndTimeDialog> {
  String? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      //this right here
      child: SizedBox(
        height: 300.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
             Container(
              padding: const EdgeInsets.only(left: 15.0, bottom: 15.0, right: 15.0),
              margin: const EdgeInsets.only(bottom: 30),
              child: const Text("Select Day and Time",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, bottom: 15.0, right: 15.0),
              child: getCompleteDayWidget(),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: DropdownButton<String>(
                alignment: AlignmentDirectional.center,
                hint: const Text("Choose time", textAlign: TextAlign.center),
                value: _selectedTime,
                items: <String>['Breakfast', 'Lunch', 'Snacks', 'Dinner']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: SizedBox(
                        width: 230,
                        child: Text(value, textAlign: TextAlign.center)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedTime = newValue;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, bottom: 15.0, right: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                children: [
                  getActionButton("Cancel"),
                  getActionButton("Ok"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getCompleteDayWidget() {
    List<Widget> dayWidget = [];
    String day = DateFormat('EEEE').format(DateTime.now());
    dayMap.forEach((key, value) {
      bool isDefaultSelected = (day.toLowerCase() == "sunday" && key == 1 && day[0] == value[0])
          || (day.toLowerCase() != "sunday" && day[0] == value[0]);
      dayWidget.add(getDayWidget(key, value, isDefaultSelected));
    });
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: dayWidget,
    );
  }

  Widget getDayWidget(int key, String day, bool isDefaultSelected) {
    return InkWell(
      onTap: () {

      },
      splashColor: Colors.green,
      customBorder:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      borderRadius: BorderRadius.circular(12.0),
      child: Ink(
        height: 30,
        width: 30,
        decoration: BoxDecoration(
            color: isDefaultSelected ? Colors.black38 : Colors.white,
            border: Border.all(color: Colors.black),
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        child: Center(
          child: Text(day,
              style: day == "S" && key == 1
                  ? TextStyle(color: Colors.red)
                  : TextStyle(color: Colors.black87)),
        ),
      ),
    );
  }

  getActionButton(String action) {
    return Expanded(
      flex: 1,
      child: Container(
        margin: EdgeInsets.only(left: 8, right: 8, top: 18),
        child: InkWell(
          onTap: () {

          },
          splashColor: Colors.green,
          customBorder:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          borderRadius: BorderRadius.circular(12.0),
          child: Ink(
            height: 35,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
                borderRadius: const BorderRadius.all(Radius.circular(8))),
            child: Center(
              child: Text(action, style: TextStyle(color: Colors.black87)
              ),
            ),
          ),
        ),
      ),
    );
  }
}
