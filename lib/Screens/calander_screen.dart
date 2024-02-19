import 'package:flutter/material.dart';
import 'package:flutter_todo_app/etc/event.dart';
import 'package:table_calendar/table_calendar.dart';

class CalanderScreen extends StatefulWidget {

  @override
  State<CalanderScreen> createState() => _CalanderScreenState();
}

class _CalanderScreenState extends State<CalanderScreen> {

//creating variables to focus day(current day)
  DateTime today = DateTime.now();

  //store the events creayed
Map <DateTime, List< Event>> events = {};

//get user inputs to add a event
TextEditingController _eventController = TextEditingController();
  

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
    
      //event add button
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          //show dilog for user to input event name
          showDialog(
            context: context,
            builder: (context){
              return AlertDialog(
                scrollable: true,
                title: Opacity(
                      opacity: 0.7, 
                      child: Text("Add an Event"),
                     ),
              
                content: Padding(
                  padding: EdgeInsets.all(8),
                  child: TextField(
                    controller: _eventController,
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: (){},
                     child: Text("Save"),
                  ),
                ]
              );
            }
          );
        },
        child: Icon(Icons.add),
        //add
        backgroundColor: Color(0xFF674AEF),
        foregroundColor: Colors.white,
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(15.0), 
         ),
         //add end
        ),

      //Calander 
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text("Selected Date = " + today.toString().split(" ")[0]),
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
      ),
      //Calander end
     );
  }
}