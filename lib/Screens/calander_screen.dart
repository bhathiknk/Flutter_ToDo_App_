import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalanderScreen extends StatefulWidget {

  @override
  State<CalanderScreen> createState() => _CalanderScreenState();
}

class _CalanderScreenState extends State<CalanderScreen> {

//creating variables to focus day(current day)
  DateTime today = DateTime.now();

//capture the selected date
void _onDaySelected(DateTime day, DateTime focusedDay) {
  setState(() {
    today = day;
  });
}
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Calander',
        )
      ),
      //Calander 
      body: Column(
        children: [
          TableCalendar(
            locale: "en_US",
            rowHeight: 43,
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            availableGestures: AvailableGestures.all,
            selectedDayPredicate: (day) => isSameDay(day, today),
            focusedDay: today,
            firstDay: DateTime.utc(2000,01,01),
            lastDay: DateTime.utc(2050,12,31),
            onDaySelected: _onDaySelected,
           ),
        ]
      ),
      //Calander end
     );
  }
}